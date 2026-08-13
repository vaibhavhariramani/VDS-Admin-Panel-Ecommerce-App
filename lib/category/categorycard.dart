import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/category_wise/filter_products.dart';
import 'package:vdsadmin/models/firebase.service.dart';
import 'package:vdsadmin/theme/app_theme.dart';
import 'package:vdsadmin/widgets/image_upload_field.dart';

class CategoryCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const CategoryCard({Key? key, required this.doc}) : super(key: key);

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  Map<String, dynamic> get _data => widget.doc.data() as Map<String, dynamic>;
  String get _tag => (_data['tag'] ?? widget.doc.id).toString();

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "$_tag"?'),
        content: const Text(
            'Products already tagged with this category keep the tag, but it will no longer appear in Category View.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              InsertDatainFirebase().DeleteCategory(widget.doc.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(String oldTag, String newTag) async {
    final products = await FirebaseFirestore.instance
        .collection('Products')
        .where('category', arrayContains: oldTag)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in products.docs) {
      final data = doc.data();
      final category = ((data['category'] as List?) ?? [])
          .map((e) => e == oldTag ? newTag : e)
          .toList();
      final tags = ((data['tags'] as List?) ?? [])
          .map((e) => e == oldTag ? newTag : e)
          .toList();
      batch.update(doc.reference, {'category': category, 'tags': tags});
    }
    await batch.commit();
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _tag);
    final indexController =
        TextEditingController(text: (_data['index'] ?? '').toString());
    String? imageUrl = _data['image']?.toString();
    String? iconUrl = _data['icon']?.toString();
    final oldTag = _tag;
    bool saving = false;
    String? error;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ImageUploadField(
                            label: 'Category image',
                            storagePathPrefix: 'category',
                            size: 120,
                            initialImageUrl: imageUrl,
                            onUploaded: (url) =>
                                setDialogState(() => imageUrl = url),
                          ),
                          ImageUploadField(
                            label: 'Category icon',
                            storagePathPrefix: 'icons',
                            size: 120,
                            initialImageUrl: iconUrl,
                            onUploaded: (url) =>
                                setDialogState(() => iconUrl = url),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: indexController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Display order (index)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PillButton(
                  label: saving ? 'Saving…' : 'Save',
                  onPressed: saving
                      ? null
                      : () async {
                          final newTag = nameController.text.trim();
                          if (newTag.isEmpty) {
                            setDialogState(() => error = 'Enter a name.');
                            return;
                          }
                          setDialogState(() {
                            saving = true;
                            error = null;
                          });
                          try {
                            if (newTag != oldTag) {
                              final clash = await FirebaseFirestore.instance
                                  .collection('Category')
                                  .doc(newTag)
                                  .get();
                              if (clash.exists) {
                                setDialogState(() {
                                  saving = false;
                                  error = 'A category named "$newTag" already exists.';
                                });
                                return;
                              }
                              await _rename(oldTag, newTag);
                              await FirebaseFirestore.instance
                                  .collection('Category')
                                  .doc(newTag)
                                  .set({
                                'name': newTag,
                                'tag': newTag,
                                'index': indexController.text,
                                'icon': iconUrl,
                                'image': imageUrl,
                              });
                              await FirebaseFirestore.instance
                                  .collection('Category')
                                  .doc(oldTag)
                                  .delete();
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('Category')
                                  .doc(oldTag)
                                  .update({
                                'index': indexController.text,
                                'icon': iconUrl,
                                'image': imageUrl,
                              });
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                              error = 'Failed to save: $e';
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FilterProduct(snapshot: widget.doc)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: CachedNetworkImage(
                  imageUrl: (_data['image'] ?? '').toString(),
                  fit: BoxFit.cover,
                  height: 110,
                  width: 110,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.bodyStrong(context),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primaryDark,
                onPressed: _showEditDialog,
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.accentRed,
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
