import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/models/firebase.service.dart';
import 'package:vdsadmin/theme/app_theme.dart';

class BannerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  const BannerCard({Key? key, required this.data, required this.id})
      : super(key: key);

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this banner?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              InsertDatainFirebase().DeleteBanner(id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox.expand(
              child: CachedNetworkImage(
                imageUrl: (data['image'] ?? '').toString(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.black.withOpacity(0.55),
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ),
      ],
    );
  }
}
