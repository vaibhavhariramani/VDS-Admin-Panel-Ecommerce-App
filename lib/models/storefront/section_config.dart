import 'package:flutter/material.dart';

/// One of the 13 predefined homepage section types the Client App's fixed
/// widget library knows how to render. This string is the only thing that
/// travels as `StorefrontSection.type` — the Client App switches on it to
/// pick a widget, per the config-driven contract (no arbitrary UI is ever
/// stored).
class SectionType {
  SectionType._();
  static const String hero = 'hero';
  static const String announcementBar = 'announcement_bar';
  static const String categoryGrid = 'category_grid';
  static const String featuredProducts = 'featured_products';
  static const String productGrid = 'product_grid';
  static const String productCarousel = 'product_carousel';
  static const String promotionalBanner = 'promotional_banner';
  static const String imageText = 'image_text';
  static const String bestSellers = 'best_sellers';
  static const String newArrivals = 'new_arrivals';
  static const String testimonials = 'testimonials';
  static const String storeInformation = 'store_information';
  static const String newsletter = 'newsletter';

  static const List<String> all = [
    hero,
    announcementBar,
    categoryGrid,
    featuredProducts,
    productGrid,
    productCarousel,
    promotionalBanner,
    imageText,
    bestSellers,
    newArrivals,
    testimonials,
    storeInformation,
    newsletter,
  ];
}

/// Base type every section's `config` object implements. Each subtype is a
/// small, genuinely typed model (real fields, not a shared "everything"
/// bag) — the Admin edit *form* for each is generated from [fieldSpecs] in
/// the registry below rather than 13 hand-built dialogs, but the stored
/// data is always fully typed.
abstract class SectionConfig {
  const SectionConfig();
  Map<String, dynamic> toJson();
}

/// A single admin-editable field on a section's config, used to generate
/// the edit form in `storefront_section_edit_dialog.dart`.
enum FieldKind {
  text,
  multiline,
  image,
  number,
  boolean,
  productPicker,
  categoryPicker,
}

class FieldSpec {
  final String key;
  final String label;
  final FieldKind kind;
  const FieldSpec(this.key, this.label, this.kind);
}

String? _str(Map<String, dynamic> j, String key) => j[key]?.toString();
List<String> _strList(Map<String, dynamic> j, String key) =>
    (j[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
int _int(Map<String, dynamic> j, String key, [int fallback = 0]) =>
    int.tryParse(j[key]?.toString() ?? '') ?? fallback;
bool _bool(Map<String, dynamic> j, String key, [bool fallback = false]) =>
    j[key] is bool ? j[key] as bool : fallback;

class HeroSectionConfig extends SectionConfig {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String buttonAction;
  const HeroSectionConfig({
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.buttonText = '',
    this.buttonAction = '',
  });
  factory HeroSectionConfig.fromJson(Map<String, dynamic> j) => HeroSectionConfig(
        title: _str(j, 'title') ?? '',
        subtitle: _str(j, 'subtitle') ?? '',
        imageUrl: _str(j, 'imageUrl') ?? '',
        buttonText: _str(j, 'buttonText') ?? '',
        buttonAction: _str(j, 'buttonAction') ?? '',
      );
  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'buttonText': buttonText,
        'buttonAction': buttonAction,
      };
}

class AnnouncementBarSectionConfig extends SectionConfig {
  final String message;
  final String link;
  const AnnouncementBarSectionConfig({this.message = '', this.link = ''});
  factory AnnouncementBarSectionConfig.fromJson(Map<String, dynamic> j) =>
      AnnouncementBarSectionConfig(
        message: _str(j, 'message') ?? '',
        link: _str(j, 'link') ?? '',
      );
  @override
  Map<String, dynamic> toJson() => {'message': message, 'link': link};
}

class CategoryGridSectionConfig extends SectionConfig {
  final String title;
  final List<String> categoryIds;
  const CategoryGridSectionConfig({this.title = '', this.categoryIds = const []});
  factory CategoryGridSectionConfig.fromJson(Map<String, dynamic> j) =>
      CategoryGridSectionConfig(
        title: _str(j, 'title') ?? '',
        categoryIds: _strList(j, 'categoryIds'),
      );
  @override
  Map<String, dynamic> toJson() => {'title': title, 'categoryIds': categoryIds};
}

class FeaturedProductsSectionConfig extends SectionConfig {
  final String title;
  final List<String> productIds;
  const FeaturedProductsSectionConfig({this.title = '', this.productIds = const []});
  factory FeaturedProductsSectionConfig.fromJson(Map<String, dynamic> j) =>
      FeaturedProductsSectionConfig(
        title: _str(j, 'title') ?? '',
        productIds: _strList(j, 'productIds'),
      );
  @override
  Map<String, dynamic> toJson() => {'title': title, 'productIds': productIds};
}

class ProductGridSectionConfig extends SectionConfig {
  final String title;
  final List<String> productIds;
  final int columns;
  const ProductGridSectionConfig({
    this.title = '',
    this.productIds = const [],
    this.columns = 2,
  });
  factory ProductGridSectionConfig.fromJson(Map<String, dynamic> j) => ProductGridSectionConfig(
        title: _str(j, 'title') ?? '',
        productIds: _strList(j, 'productIds'),
        columns: _int(j, 'columns', 2),
      );
  @override
  Map<String, dynamic> toJson() =>
      {'title': title, 'productIds': productIds, 'columns': columns};
}

class ProductCarouselSectionConfig extends SectionConfig {
  final String title;
  final List<String> productIds;
  const ProductCarouselSectionConfig({this.title = '', this.productIds = const []});
  factory ProductCarouselSectionConfig.fromJson(Map<String, dynamic> j) =>
      ProductCarouselSectionConfig(
        title: _str(j, 'title') ?? '',
        productIds: _strList(j, 'productIds'),
      );
  @override
  Map<String, dynamic> toJson() => {'title': title, 'productIds': productIds};
}

class PromotionalBannerSectionConfig extends SectionConfig {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String buttonAction;
  const PromotionalBannerSectionConfig({
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.buttonText = '',
    this.buttonAction = '',
  });
  factory PromotionalBannerSectionConfig.fromJson(Map<String, dynamic> j) =>
      PromotionalBannerSectionConfig(
        title: _str(j, 'title') ?? '',
        subtitle: _str(j, 'subtitle') ?? '',
        imageUrl: _str(j, 'imageUrl') ?? '',
        buttonText: _str(j, 'buttonText') ?? '',
        buttonAction: _str(j, 'buttonAction') ?? '',
      );
  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'buttonText': buttonText,
        'buttonAction': buttonAction,
      };
}

class ImageTextSectionConfig extends SectionConfig {
  final String title;
  final String description;
  final String imageUrl;
  final String buttonText;
  final String buttonAction;
  const ImageTextSectionConfig({
    this.title = '',
    this.description = '',
    this.imageUrl = '',
    this.buttonText = '',
    this.buttonAction = '',
  });
  factory ImageTextSectionConfig.fromJson(Map<String, dynamic> j) => ImageTextSectionConfig(
        title: _str(j, 'title') ?? '',
        description: _str(j, 'description') ?? '',
        imageUrl: _str(j, 'imageUrl') ?? '',
        buttonText: _str(j, 'buttonText') ?? '',
        buttonAction: _str(j, 'buttonAction') ?? '',
      );
  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'buttonText': buttonText,
        'buttonAction': buttonAction,
      };
}

class BestSellersSectionConfig extends SectionConfig {
  final String title;
  final int limit;
  const BestSellersSectionConfig({this.title = 'Best Sellers', this.limit = 8});
  factory BestSellersSectionConfig.fromJson(Map<String, dynamic> j) => BestSellersSectionConfig(
        title: _str(j, 'title') ?? 'Best Sellers',
        limit: _int(j, 'limit', 8),
      );
  @override
  Map<String, dynamic> toJson() => {'title': title, 'limit': limit};
}

class NewArrivalsSectionConfig extends SectionConfig {
  final String title;
  final int limit;
  const NewArrivalsSectionConfig({this.title = 'New Arrivals', this.limit = 8});
  factory NewArrivalsSectionConfig.fromJson(Map<String, dynamic> j) => NewArrivalsSectionConfig(
        title: _str(j, 'title') ?? 'New Arrivals',
        limit: _int(j, 'limit', 8),
      );
  @override
  Map<String, dynamic> toJson() => {'title': title, 'limit': limit};
}

class TestimonialItem {
  final String name;
  final String message;
  final int rating;
  const TestimonialItem({required this.name, required this.message, this.rating = 5});
  factory TestimonialItem.fromJson(Map<String, dynamic> j) => TestimonialItem(
        name: j['name']?.toString() ?? '',
        message: j['message']?.toString() ?? '',
        rating: int.tryParse(j['rating']?.toString() ?? '') ?? 5,
      );
  Map<String, dynamic> toJson() => {'name': name, 'message': message, 'rating': rating};
}

class TestimonialsSectionConfig extends SectionConfig {
  final String title;
  final List<TestimonialItem> items;
  const TestimonialsSectionConfig({this.title = 'What our customers say', this.items = const []});
  factory TestimonialsSectionConfig.fromJson(Map<String, dynamic> j) => TestimonialsSectionConfig(
        title: _str(j, 'title') ?? 'What our customers say',
        items: (j['items'] as List<dynamic>? ?? const [])
            .map((e) => TestimonialItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  @override
  Map<String, dynamic> toJson() =>
      {'title': title, 'items': items.map((e) => e.toJson()).toList()};
}

class StoreInformationSectionConfig extends SectionConfig {
  final bool showAddress;
  final bool showPhone;
  final bool showHours;
  final String customText;
  const StoreInformationSectionConfig({
    this.showAddress = true,
    this.showPhone = true,
    this.showHours = true,
    this.customText = '',
  });
  factory StoreInformationSectionConfig.fromJson(Map<String, dynamic> j) =>
      StoreInformationSectionConfig(
        showAddress: _bool(j, 'showAddress', true),
        showPhone: _bool(j, 'showPhone', true),
        showHours: _bool(j, 'showHours', true),
        customText: _str(j, 'customText') ?? '',
      );
  @override
  Map<String, dynamic> toJson() => {
        'showAddress': showAddress,
        'showPhone': showPhone,
        'showHours': showHours,
        'customText': customText,
      };
}

class NewsletterSectionConfig extends SectionConfig {
  final String title;
  final String subtitle;
  final String buttonText;
  const NewsletterSectionConfig({
    this.title = 'Join our newsletter',
    this.subtitle = '',
    this.buttonText = 'Subscribe',
  });
  factory NewsletterSectionConfig.fromJson(Map<String, dynamic> j) => NewsletterSectionConfig(
        title: _str(j, 'title') ?? 'Join our newsletter',
        subtitle: _str(j, 'subtitle') ?? '',
        buttonText: _str(j, 'buttonText') ?? 'Subscribe',
      );
  @override
  Map<String, dynamic> toJson() =>
      {'title': title, 'subtitle': subtitle, 'buttonText': buttonText};
}

/// Everything the Homepage editor and the generic section-edit dialog need
/// to know about a section type: its display name/icon, how to parse/
/// build a default config, and (for every type except `testimonials`,
/// which gets a small bespoke repeater widget instead) the flat list of
/// fields to render as a form.
class SectionTypeInfo {
  final String type;
  final String displayName;
  final IconData icon;
  final SectionConfig Function(Map<String, dynamic> json) fromJson;
  final SectionConfig Function() defaultConfig;
  final List<FieldSpec> fieldSpecs;
  const SectionTypeInfo({
    required this.type,
    required this.displayName,
    required this.icon,
    required this.fromJson,
    required this.defaultConfig,
    required this.fieldSpecs,
  });
}

final Map<String, SectionTypeInfo> sectionTypeRegistry = {
  SectionType.hero: SectionTypeInfo(
    type: SectionType.hero,
    displayName: 'Hero Banner',
    icon: Icons.wallpaper,
    fromJson: (j) => HeroSectionConfig.fromJson(j),
    defaultConfig: () => const HeroSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('subtitle', 'Subtitle', FieldKind.text),
      FieldSpec('imageUrl', 'Banner Image', FieldKind.image),
      FieldSpec('buttonText', 'Button Text', FieldKind.text),
      FieldSpec('buttonAction', 'Button Destination', FieldKind.text),
    ],
  ),
  SectionType.announcementBar: SectionTypeInfo(
    type: SectionType.announcementBar,
    displayName: 'Announcement Bar',
    icon: Icons.campaign_outlined,
    fromJson: (j) => AnnouncementBarSectionConfig.fromJson(j),
    defaultConfig: () => const AnnouncementBarSectionConfig(),
    fieldSpecs: const [
      FieldSpec('message', 'Message', FieldKind.text),
      FieldSpec('link', 'Link (optional)', FieldKind.text),
    ],
  ),
  SectionType.categoryGrid: SectionTypeInfo(
    type: SectionType.categoryGrid,
    displayName: 'Category Grid',
    icon: Icons.grid_view_outlined,
    fromJson: (j) => CategoryGridSectionConfig.fromJson(j),
    defaultConfig: () => const CategoryGridSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('categoryIds', 'Categories', FieldKind.categoryPicker),
    ],
  ),
  SectionType.featuredProducts: SectionTypeInfo(
    type: SectionType.featuredProducts,
    displayName: 'Featured Products',
    icon: Icons.star_border,
    fromJson: (j) => FeaturedProductsSectionConfig.fromJson(j),
    defaultConfig: () => const FeaturedProductsSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('productIds', 'Products', FieldKind.productPicker),
    ],
  ),
  SectionType.productGrid: SectionTypeInfo(
    type: SectionType.productGrid,
    displayName: 'Product Grid',
    icon: Icons.apps,
    fromJson: (j) => ProductGridSectionConfig.fromJson(j),
    defaultConfig: () => const ProductGridSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('productIds', 'Products', FieldKind.productPicker),
      FieldSpec('columns', 'Columns', FieldKind.number),
    ],
  ),
  SectionType.productCarousel: SectionTypeInfo(
    type: SectionType.productCarousel,
    displayName: 'Product Carousel',
    icon: Icons.view_carousel_outlined,
    fromJson: (j) => ProductCarouselSectionConfig.fromJson(j),
    defaultConfig: () => const ProductCarouselSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('productIds', 'Products', FieldKind.productPicker),
    ],
  ),
  SectionType.promotionalBanner: SectionTypeInfo(
    type: SectionType.promotionalBanner,
    displayName: 'Promotional Banner',
    icon: Icons.local_offer_outlined,
    fromJson: (j) => PromotionalBannerSectionConfig.fromJson(j),
    defaultConfig: () => const PromotionalBannerSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('subtitle', 'Subtitle', FieldKind.text),
      FieldSpec('imageUrl', 'Banner Image', FieldKind.image),
      FieldSpec('buttonText', 'Button Text', FieldKind.text),
      FieldSpec('buttonAction', 'Button Destination', FieldKind.text),
    ],
  ),
  SectionType.imageText: SectionTypeInfo(
    type: SectionType.imageText,
    displayName: 'Image + Text',
    icon: Icons.image_outlined,
    fromJson: (j) => ImageTextSectionConfig.fromJson(j),
    defaultConfig: () => const ImageTextSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('description', 'Description', FieldKind.multiline),
      FieldSpec('imageUrl', 'Image', FieldKind.image),
      FieldSpec('buttonText', 'Button Text', FieldKind.text),
      FieldSpec('buttonAction', 'Button Destination', FieldKind.text),
    ],
  ),
  SectionType.bestSellers: SectionTypeInfo(
    type: SectionType.bestSellers,
    displayName: 'Best Sellers',
    icon: Icons.trending_up,
    fromJson: (j) => BestSellersSectionConfig.fromJson(j),
    defaultConfig: () => const BestSellersSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('limit', 'How many to show', FieldKind.number),
    ],
  ),
  SectionType.newArrivals: SectionTypeInfo(
    type: SectionType.newArrivals,
    displayName: 'New Arrivals',
    icon: Icons.fiber_new_outlined,
    fromJson: (j) => NewArrivalsSectionConfig.fromJson(j),
    defaultConfig: () => const NewArrivalsSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('limit', 'How many to show', FieldKind.number),
    ],
  ),
  SectionType.testimonials: SectionTypeInfo(
    type: SectionType.testimonials,
    displayName: 'Testimonials',
    icon: Icons.format_quote,
    fromJson: (j) => TestimonialsSectionConfig.fromJson(j),
    defaultConfig: () => const TestimonialsSectionConfig(),
    // Items are edited via a dedicated repeater widget, not this list.
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
    ],
  ),
  SectionType.storeInformation: SectionTypeInfo(
    type: SectionType.storeInformation,
    displayName: 'Store Information',
    icon: Icons.storefront_outlined,
    fromJson: (j) => StoreInformationSectionConfig.fromJson(j),
    defaultConfig: () => const StoreInformationSectionConfig(),
    fieldSpecs: const [
      FieldSpec('showAddress', 'Show Address', FieldKind.boolean),
      FieldSpec('showPhone', 'Show Phone', FieldKind.boolean),
      FieldSpec('showHours', 'Show Opening Hours', FieldKind.boolean),
      FieldSpec('customText', 'Extra Text', FieldKind.multiline),
    ],
  ),
  SectionType.newsletter: SectionTypeInfo(
    type: SectionType.newsletter,
    displayName: 'Newsletter',
    icon: Icons.mail_outline,
    fromJson: (j) => NewsletterSectionConfig.fromJson(j),
    defaultConfig: () => const NewsletterSectionConfig(),
    fieldSpecs: const [
      FieldSpec('title', 'Title', FieldKind.text),
      FieldSpec('subtitle', 'Subtitle', FieldKind.text),
      FieldSpec('buttonText', 'Button Text', FieldKind.text),
    ],
  ),
};
