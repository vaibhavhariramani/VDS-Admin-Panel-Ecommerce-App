import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/storefront/section_config.dart';
import '../../../../models/storefront/storefront_config.dart';
import '../../../../models/storefront/storefront_section.dart';
import '../controllers/storefront_controller.dart';

Color _colorFromHex(String hex, {Color fallback = Colors.black}) {
  final String cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return fallback;
  return Color(int.parse('FF$cleaned', radix: 16));
}

/// A simplified, in-admin-only rendering of the *draft* config — good
/// enough to sanity-check content/order/branding before publishing. This
/// is not the Client App's real production widget library (that lives in
/// the separate Client App repo); it's a lightweight mock keyed off the
/// same section registry.
class StorefrontPreviewView extends StatelessWidget {
  const StorefrontPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StorefrontController controller = Get.find<StorefrontController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Preview (Draft)'), elevation: 0),
      backgroundColor: Colors.grey.shade300,
      body: Obx(() {
        final StorefrontConfig config = controller.draft.value;
        final Color bg = _colorFromHex(config.theme.backgroundColor, fallback: Colors.white);
        final Color text = _colorFromHex(config.theme.textColor);
        final Color primary = _colorFromHex(config.theme.primaryColor);
        final List<StorefrontSection> sections =
            List.of(config.homepage.where((s) => s.enabled))
              ..sort((a, b) => a.order.compareTo(b.order));

        return Center(
          child: Container(
            width: 380,
            margin: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black87, width: 8),
              color: bg,
            ),
            clipBehavior: Clip.hardEdge,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brandingHeader(config.branding, primary, text),
                  for (final StorefrontSection s in sections)
                    s.type == SectionType.hero && config.banners.isNotEmpty
                        ? _bannerHero(config.banners.where((banner) => banner.enabled).toList(), primary, text)
                        : _sectionPreview(s, primary, text),
                  if (sections.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No visible sections yet.',
                          style: TextStyle(color: text.withOpacity(0.6))),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _brandingHeader(StorefrontBranding branding, Color primary, Color text) {
    return Container(
      color: primary.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primary,
            backgroundImage: branding.logoUrl.isNotEmpty ? NetworkImage(branding.logoUrl) : null,
            child: branding.logoUrl.isEmpty
                ? Text(
                    branding.storeName.isNotEmpty ? branding.storeName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branding.storeName.isEmpty ? 'Your Store' : branding.storeName,
                    style: TextStyle(fontWeight: FontWeight.bold, color: text)),
                if (branding.tagline.isNotEmpty)
                  Text(branding.tagline, style: TextStyle(fontSize: 12, color: text.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionPreview(StorefrontSection s, Color primary, Color text) {
    final SectionTypeInfo? info = sectionTypeRegistry[s.type];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: text.withOpacity(0.1)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(info?.icon ?? Icons.widgets_outlined, color: primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info?.displayName ?? s.type,
                    style: TextStyle(fontWeight: FontWeight.w600, color: text)),
                const SizedBox(height: 4),
                Text(_summaryFor(s), style: TextStyle(fontSize: 12, color: text.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerHero(List<StorefrontBanner> banners, Color primary, Color text) {
    if (banners.isEmpty) return const SizedBox.shrink();
    final StorefrontBanner banner = banners.first;
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        image: banner.imageUrl.isEmpty ? null : DecorationImage(image: NetworkImage(banner.imageUrl), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(banner.title, style: TextStyle(color: banner.imageUrl.isEmpty ? text : Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        if (banner.subtitle.isNotEmpty) Text(banner.subtitle, style: TextStyle(color: banner.imageUrl.isEmpty ? text.withOpacity(0.75) : Colors.white70)),
        const SizedBox(height: 8),
        Text('Hero banners • ${banners.length} slide${banners.length == 1 ? '' : 's'}', style: TextStyle(fontSize: 11, color: banner.imageUrl.isEmpty ? text.withOpacity(0.6) : Colors.white70)),
      ]),
    );
  }

  String _summaryFor(StorefrontSection s) {
    final config = s.config;
    if (config is HeroSectionConfig) return '${config.title} — ${config.subtitle}';
    if (config is AnnouncementBarSectionConfig) return config.message;
    if (config is CategoryGridSectionConfig) return '${config.categoryIds.length} categories';
    if (config is FeaturedProductsSectionConfig) return '${config.productIds.length} products';
    if (config is ProductGridSectionConfig) return '${config.productIds.length} products, ${config.columns} columns';
    if (config is ProductCarouselSectionConfig) return '${config.productIds.length} products';
    if (config is PromotionalBannerSectionConfig) return config.title;
    if (config is ImageTextSectionConfig) return config.title;
    if (config is BestSellersSectionConfig) return 'Top ${config.limit}';
    if (config is NewArrivalsSectionConfig) return 'Latest ${config.limit}';
    if (config is TestimonialsSectionConfig) return '${config.items.length} testimonials';
    if (config is StoreInformationSectionConfig) return 'Store details';
    if (config is NewsletterSectionConfig) return config.title;
    return '';
  }
}
