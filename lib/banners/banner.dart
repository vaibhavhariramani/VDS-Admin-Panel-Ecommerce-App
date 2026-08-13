import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/banners/bannercard.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/models/firebase.service.dart';
import 'package:vdsadmin/theme/app_theme.dart';
import 'package:vdsadmin/widgets/image_upload_field.dart';

class BannerDisplay extends StatefulWidget {
  const BannerDisplay({Key? key}) : super(key: key);

  @override
  State<BannerDisplay> createState() => _BannerDisplayState();
}

class _BannerDisplayState extends State<BannerDisplay> {
  String? _pendingImageUrl;

  void _addBanner() {
    _pendingImageUrl = null;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Banner'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageUploadField(
                      label: 'Banner image',
                      storagePathPrefix: 'Banner',
                      size: 180,
                      onUploaded: (url) =>
                          setDialogState(() => _pendingImageUrl = url),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                PillButton(
                  label: 'Add',
                  onPressed: _pendingImageUrl == null
                      ? null
                      : () {
                          InsertDatainFirebase().uploadBanner(_pendingImageUrl);
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
        title: const Text('Banners'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: PillButton(
                label: 'Add Banner',
                icon: Icons.add_photo_alternate_outlined,
                onPressed: _addBanner,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataProvider.banners(''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load banners: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text('No banners yet. Tap "Add Banner" to create one.',
                  style: AppText.caption(context)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              return BannerCard(data: data, id: docs[index].id);
            },
          );
        },
      ),
    );
  }
}
