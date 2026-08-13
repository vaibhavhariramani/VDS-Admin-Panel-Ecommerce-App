import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vdsadmin/models/data_provider.dart';
import 'package:vdsadmin/search/product_details.dart';
import 'package:vdsadmin/theme/app_theme.dart';

class FilterProduct extends StatelessWidget {
  final DocumentSnapshot snapshot;

  const FilterProduct({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = snapshot.get('tag').toString();

    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: Text(tag),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataProvider.products(null, filter: tag),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load products: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text('No products in this category yet.',
                  style: AppText.caption(context)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetails(snapshot: doc)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: CachedNetworkImage(
                            imageUrl: (data['image'] ?? '').toString(),
                            fit: BoxFit.contain,
                            height: 110,
                            width: 110,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (data['name'] ?? '').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppText.bodyStrong(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${data['selling'] ?? data['price'] ?? 0}',
                      style: AppText.body(context, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
