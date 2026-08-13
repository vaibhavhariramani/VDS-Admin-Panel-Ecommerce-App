import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/category/categorycard.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/firebase.service.dart';
import 'package:vdsadmin/theme/app_theme.dart';
import 'package:vdsadmin/widgets/image_upload_field.dart';

class Category1 extends StatefulWidget {
  const Category1({Key? key}) : super(key: key);

  @override
  State<Category1> createState() => _Category1State();
}

class _Category1State extends State<Category1> {
  void _addCategory() {
    final nameController = TextEditingController();
    final indexController = TextEditingController();
    String? imageUrl;
    String? iconUrl;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Category'),
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
                            onUploaded: (url) =>
                                setDialogState(() => imageUrl = url),
                          ),
                          ImageUploadField(
                            label: 'Category icon',
                            storagePathPrefix: 'icons',
                            size: 120,
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
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PillButton(
                  label: 'Add',
                  onPressed: (imageUrl == null ||
                          iconUrl == null ||
                          nameController.text.trim().isEmpty)
                      ? null
                      : () {
                          InsertDatainFirebase().uploadCategory(
                            indexController.text,
                            nameController.text.trim(),
                            iconUrl,
                            imageUrl,
                          );
                          Navigator.pop(dialogContext);
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
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: PillButton(
                label: 'Add Category',
                icon: Icons.add,
                onPressed: _addCategory,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataProvider.category(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load categories: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text(
                  'No categories yet. Tap "Add Category" to create one.',
                  style: AppText.caption(context)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) => CategoryCard(doc: docs[index]),
          );
        },
      ),
    );
  }
}
