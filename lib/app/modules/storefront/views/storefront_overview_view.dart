import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/constants.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../../widgets/utils/shimmer_helper.dart';
import '../controllers/storefront_controller.dart';
import 'storefront_appearance_view.dart';
import 'store_details_view.dart';
import 'storefront_banners_view.dart';
import 'storefront_homepage_view.dart';
import 'storefront_navigation_view.dart';
import 'storefront_pages_view.dart';
import 'storefront_preview_view.dart';

class StorefrontOverviewView extends GetView<StorefrontController> {
  const StorefrontOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storefront'), elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SingleChildScrollView(
            child: PaddingWrapper(
              isSliverItem: false,
              horizontalPadding: AppSpacing.xl,
              topPadding: AppSpacing.lg,
              bottomPadding: AppSpacing.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerHelper.buildBasicShimmer(height: 24, width: 160),
                  const SizedBox(height: AppSpacing.lg),
                  ShimmerHelper.buildBasicShimmer(height: 100),
                  const SizedBox(height: AppSpacing.xl),
                  ShimmerHelper.buildBasicShimmer(height: 24, width: 160),
                  const SizedBox(height: AppSpacing.md),
                  ShimmerHelper.buildBasicShimmer(height: 90),
                  const SizedBox(height: AppSpacing.xl),
                  ShimmerHelper.buildBasicShimmer(height: 24, width: 160),
                  const SizedBox(height: AppSpacing.md),
                  ShimmerHelper.buildBasicShimmer(height: 90),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerHelper.buildBasicShimmer(height: 90),
                  const SizedBox(height: AppSpacing.sm),
                  ShimmerHelper.buildBasicShimmer(height: 90),
                ],
              ),
            ),
          );
        }
        if (controller.shopId == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No shop found for your account.'),
            ),
          );
        }
        return SingleChildScrollView(
          child: PaddingWrapper(
            isSliverItem: false,
            horizontalPadding: AppSpacing.xl,
            topPadding: AppSpacing.lg,
            bottomPadding: AppSpacing.xxl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusRow(context),
                const SizedBox(height: AppSpacing.lg),
                _storeUrlCard(context),
                const SizedBox(height: AppSpacing.xl),
                Text('Appearance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.md),
                _summaryCard(
                  context,
                  title: 'Branding & Theme',
                  subtitle:
                      'Logo, colors, fonts — ${controller.draft.value.branding.storeName.isEmpty ? 'not set up yet' : controller.draft.value.branding.storeName}',
                  icon: Icons.palette_outlined,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontAppearanceView())),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Homepage', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.md),
                _summaryCard(
                  context,
                  title: 'Homepage Sections',
                  subtitle:
                      '${controller.draft.value.homepage.length} section${controller.draft.value.homepage.length == 1 ? '' : 's'} configured',
                  icon: Icons.view_agenda_outlined,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontHomepageView())),
                ),
                const SizedBox(height: AppSpacing.sm),
                _summaryCard(
                  context,
                  title: 'Manage Banners',
                  subtitle: '${controller.draft.value.banners.length} hero banner${controller.draft.value.banners.length == 1 ? '' : 's'} configured',
                  icon: Icons.view_carousel_outlined,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontBannersView())),
                ),
                const SizedBox(height: AppSpacing.sm),
                _summaryCard(
                  context,
                  title: 'Store Details',
                  subtitle: controller.draft.value.storeDetails.address.isEmpty ? 'Add location, hours and contact details' : controller.draft.value.storeDetails.address,
                  icon: Icons.location_on_outlined,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StoreDetailsView())),
                ),
                const SizedBox(height: AppSpacing.sm),
                _summaryCard(
                  context,
                  title: 'Navigation',
                  subtitle: '${controller.draft.value.navigation.length} menu items',
                  icon: Icons.menu,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontNavigationView())),
                ),
                const SizedBox(height: AppSpacing.sm),
                _summaryCard(
                  context,
                  title: 'Pages',
                  subtitle: '${controller.draft.value.pages.length} custom pages',
                  icon: Icons.description_outlined,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontPagesView())),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _publishingBar(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _statusRow(BuildContext context) {
    final bool isLive = controller.published.value != null &&
        controller.published.value!.homepage.isNotEmpty;
    final Color color = isLive ? AppSemanticColors.success : AppColors.grey;
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          isLive ? 'Live' : 'Not published yet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _storeUrlCard(BuildContext context) {
    // The Client App routes directly by shopId - every shop already has a
    // working link the moment it exists, nothing to "set up" first.
    final String? shopId = controller.shopId;
    final String url = shopId != null ? '$storefrontBaseUrl/$shopId' : '';
    return CommonCard(
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Store URL', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            url,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open Store'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    Get.snackbar('Copied', 'Store URL copied to clipboard.',
                        duration: const Duration(seconds: 3));
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Link'),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CommonCard(
      onTap: onTap,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _publishingBar(BuildContext context) {
    final DateTime? publishedAt = controller.published.value?.updatedAt;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Publishing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              publishedAt != null
                  ? 'Last published: ${publishedAt.toString().substring(0, 16)}'
                  : 'Never published',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                OutlinedButton(
                  onPressed: controller.isSaving.value ? null : controller.saveDraft,
                  child: Text(controller.isSaving.value ? 'Saving...' : 'Save Draft'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const StorefrontPreviewView())),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                ),
                ElevatedButton(
                  onPressed: controller.isPublishing.value ? null : controller.publish,
                  child: Text(controller.isPublishing.value ? 'Publishing...' : 'Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
