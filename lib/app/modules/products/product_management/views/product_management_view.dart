import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/Product.dart';
import '../../../../../themes/app_theme.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/product_management_controller.dart';
import 'widgets/product_form_dialog.dart';
import 'widgets/product_list_card.dart';

/// Replaces Master List + the orphaned Hot Deals page + the
/// easter-egg-only Scheduled/Published pages with one screen: search,
/// status filter chips, and one card design. See
/// docs/architecture/CURRENT_ARCHITECTURE.md for why those existed as 4
/// separate, largely-unreachable pages before this.
class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          TextButton.icon(
            onPressed: () => Get.toNamed(Routes.PRODUCTS_LISTING),
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: const Text('Bulk upload'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: () => Get.dialog(ProductFormDialog(controller: controller)),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add product'),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchField(controller: controller),
                      const SizedBox(height: AppSpacing.md),
                      _FilterChips(controller: controller),
                    ],
                  ),
                ),
              ),
              if (controller.visibleProducts.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _EmptyState(controller: controller))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final Product product = controller.visibleProducts[index];
                        return ProductListCard(
                          product: product,
                          isPublishedNow: controller.isPublishedNow(product),
                          isScheduled: controller.isScheduled(product),
                          isBusy: controller.isSaving.value,
                          onEdit: () => Get.dialog(
                            ProductFormDialog(controller: controller, existing: product),
                          ),
                          onDelete: () => _confirmDelete(context, product),
                          onPublishedChanged: (published) =>
                              controller.setPublished(product.id!, published),
                        );
                      },
                      childCount: controller.visibleProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete product?'),
        content: Text('This permanently removes "${product.name}". This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id!);
            },
            child: const Text('Delete', style: TextStyle(color: AppSemanticColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ProductManagementController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => controller.searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Search by name, barcode, category, or brand',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ProductManagementController controller;
  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          spacing: AppSpacing.sm,
          children: [
            _chip(context, 'All', controller.allProducts.length, ProductStatusFilter.all),
            _chip(context, 'Published', controller.publishedCount, ProductStatusFilter.published),
            _chip(context, 'Scheduled', controller.scheduledCount, ProductStatusFilter.scheduled),
            _chip(context, 'Hot Deals', controller.hotDealsCount, ProductStatusFilter.hotDeals),
          ],
        ));
  }

  Widget _chip(BuildContext context, String label, int count, ProductStatusFilter value) {
    final bool selected = controller.statusFilter.value == value;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => controller.statusFilter.value = value,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ProductManagementController controller;
  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool filtered = controller.statusFilter.value != ProductStatusFilter.all ||
        controller.searchQuery.value.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey),
            const SizedBox(height: AppSpacing.md),
            Text(
              filtered ? 'No products match this filter.' : 'No products yet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!filtered) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add your first product to get started.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
