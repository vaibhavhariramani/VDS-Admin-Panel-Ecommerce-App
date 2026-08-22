import 'package:cloud_firestore/cloud_firestore.dart';

import 'storefront_section.dart';

class StorefrontBranding {
  final String storeName;
  final String tagline;
  final String logoUrl;
  final String faviconUrl;
  final String coverImageUrl;

  const StorefrontBranding({
    this.storeName = '',
    this.tagline = '',
    this.logoUrl = '',
    this.faviconUrl = '',
    this.coverImageUrl = '',
  });

  StorefrontBranding copyWith({
    String? storeName,
    String? tagline,
    String? logoUrl,
    String? faviconUrl,
    String? coverImageUrl,
  }) =>
      StorefrontBranding(
        storeName: storeName ?? this.storeName,
        tagline: tagline ?? this.tagline,
        logoUrl: logoUrl ?? this.logoUrl,
        faviconUrl: faviconUrl ?? this.faviconUrl,
        coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      );

  factory StorefrontBranding.fromJson(Map<String, dynamic>? j) => StorefrontBranding(
        storeName: j?['storeName']?.toString() ?? '',
        tagline: j?['tagline']?.toString() ?? '',
        logoUrl: j?['logoUrl']?.toString() ?? '',
        faviconUrl: j?['faviconUrl']?.toString() ?? '',
        coverImageUrl: j?['coverImageUrl']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'tagline': tagline,
        'logoUrl': logoUrl,
        'faviconUrl': faviconUrl,
        'coverImageUrl': coverImageUrl,
      };
}

/// `buttonStyle` is one of `rounded` | `pill` | `square`; `fontFamily` one
/// of [predefinedFontFamilies] — both closed lists, not free text, so the
/// Client App only ever has to handle known values.
const List<String> predefinedFontFamilies = [
  'System Default',
  'Poppins',
  'Roboto',
  'Inter',
  'Lato',
  'Montserrat',
];
const List<String> predefinedButtonStyles = ['rounded', 'pill', 'square'];

class StorefrontTheme {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;
  final String textColor;
  final int borderRadius;
  final String buttonStyle;
  final String fontFamily;

  const StorefrontTheme({
    this.primaryColor = '#111827',
    this.secondaryColor = '#F59E0B',
    this.accentColor = '#10B981',
    this.backgroundColor = '#FFFFFF',
    this.textColor = '#111827',
    this.borderRadius = 10,
    this.buttonStyle = 'rounded',
    this.fontFamily = 'System Default',
  });

  StorefrontTheme copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? backgroundColor,
    String? textColor,
    int? borderRadius,
    String? buttonStyle,
    String? fontFamily,
  }) =>
      StorefrontTheme(
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        accentColor: accentColor ?? this.accentColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        textColor: textColor ?? this.textColor,
        borderRadius: borderRadius ?? this.borderRadius,
        buttonStyle: buttonStyle ?? this.buttonStyle,
        fontFamily: fontFamily ?? this.fontFamily,
      );

  factory StorefrontTheme.fromJson(Map<String, dynamic>? j) => StorefrontTheme(
        primaryColor: j?['primaryColor']?.toString() ?? '#111827',
        secondaryColor: j?['secondaryColor']?.toString() ?? '#F59E0B',
        accentColor: j?['accentColor']?.toString() ?? '#10B981',
        backgroundColor: j?['backgroundColor']?.toString() ?? '#FFFFFF',
        textColor: j?['textColor']?.toString() ?? '#111827',
        borderRadius: int.tryParse(j?['borderRadius']?.toString() ?? '') ?? 10,
        buttonStyle: j?['buttonStyle']?.toString() ?? 'rounded',
        fontFamily: j?['fontFamily']?.toString() ?? 'System Default',
      );

  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'accentColor': accentColor,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'borderRadius': borderRadius,
        'buttonStyle': buttonStyle,
        'fontFamily': fontFamily,
      };
}

/// `type` is one of [predefinedNavigationTypes]; `referenceId` means
/// different things per type (a category string for `category`, a page
/// slug for `page`, a URL for `external`, unused for `home`/`products`).
const List<String> predefinedNavigationTypes = [
  'home',
  'banners',
  'products',
  'category',
  'collection',
  'page',
  'external',
];

/// A promotional slide rendered by the client app's hero banner. Keeping
/// these in the storefront config means they are shop-specific and follow
/// the normal draft/publish lifecycle.
class StorefrontBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String action;
  final bool enabled;

  const StorefrontBanner({
    required this.id,
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.action = 'products',
    this.enabled = true,
  });

  StorefrontBanner copyWith({String? title, String? subtitle, String? imageUrl, String? action, bool? enabled}) =>
      StorefrontBanner(id: id, title: title ?? this.title, subtitle: subtitle ?? this.subtitle,
          imageUrl: imageUrl ?? this.imageUrl, action: action ?? this.action, enabled: enabled ?? this.enabled);

  factory StorefrontBanner.fromJson(Map<String, dynamic> j) => StorefrontBanner(
        id: j['id']?.toString() ?? '', title: j['title']?.toString() ?? '',
        subtitle: j['subtitle']?.toString() ?? '', imageUrl: j['imageUrl']?.toString() ?? '',
        action: j['action']?.toString() ?? 'products', enabled: j['enabled'] is bool ? j['enabled'] as bool : true,
      );
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subtitle': subtitle, 'imageUrl': imageUrl, 'action': action, 'enabled': enabled};
}

class StoreDetails {
  final String location;
  final String address;
  final String googleMapsUrl;
  final String openingTime;
  final String closingTime;
  final String phoneNumber;

  const StoreDetails({this.location = '', this.address = '', this.googleMapsUrl = '', this.openingTime = '', this.closingTime = '', this.phoneNumber = ''});
  StoreDetails copyWith({String? location, String? address, String? googleMapsUrl, String? openingTime, String? closingTime, String? phoneNumber}) =>
      StoreDetails(location: location ?? this.location, address: address ?? this.address, googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
          openingTime: openingTime ?? this.openingTime, closingTime: closingTime ?? this.closingTime, phoneNumber: phoneNumber ?? this.phoneNumber);
  factory StoreDetails.fromJson(Map<String, dynamic>? j) => StoreDetails(
        location: j?['location']?.toString() ?? '', address: j?['address']?.toString() ?? '',
        googleMapsUrl: j?['googleMapsUrl']?.toString() ?? '', openingTime: j?['openingTime']?.toString() ?? '',
        closingTime: j?['closingTime']?.toString() ?? '', phoneNumber: j?['phoneNumber']?.toString() ?? '',
      );
  Map<String, dynamic> toJson() => {'location': location, 'address': address, 'googleMapsUrl': googleMapsUrl, 'openingTime': openingTime, 'closingTime': closingTime, 'phoneNumber': phoneNumber};
}

class StorefrontFaq {
  final String id;
  final String question;
  final String answer;
  const StorefrontFaq({required this.id, required this.question, required this.answer});
  factory StorefrontFaq.fromJson(Map<String, dynamic> j) => StorefrontFaq(id: j['id']?.toString() ?? '', question: j['question']?.toString() ?? '', answer: j['answer']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'question': question, 'answer': answer};
}

const List<StorefrontFaq> defaultStorefrontFaqs = [
  StorefrontFaq(id: 'faq_delivery', question: 'When will my order arrive?', answer: 'Delivery times are shown at checkout. We will keep you updated once your order is on its way.'),
  StorefrontFaq(id: 'faq_returns', question: 'What is your return policy?', answer: 'Please contact the store with your order details and we will help you with an eligible return or exchange.'),
  StorefrontFaq(id: 'faq_contact', question: 'How can I contact the store?', answer: 'Use the contact details on this storefront during opening hours and our team will be happy to help.'),
];

class NavigationItem {
  final String label;
  final String type;
  final String referenceId;
  final int order;

  const NavigationItem({
    required this.label,
    required this.type,
    this.referenceId = '',
    this.order = 0,
  });

  factory NavigationItem.fromJson(Map<String, dynamic> j) => NavigationItem(
        label: j['label']?.toString() ?? '',
        type: j['type']?.toString() ?? 'home',
        referenceId: j['referenceId']?.toString() ?? '',
        order: int.tryParse(j['order']?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'label': label, 'type': type, 'referenceId': referenceId, 'order': order};
}

/// `type` is one of `heading` | `paragraph` | `image` — intentionally the
/// only three block types a custom page can be built from.
class PageBlock {
  final String type;
  final String value;
  const PageBlock({required this.type, required this.value});
  factory PageBlock.fromJson(Map<String, dynamic> j) =>
      PageBlock(type: j['type']?.toString() ?? 'paragraph', value: j['value']?.toString() ?? '');
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class CustomPage {
  final String slug;
  final String title;
  final List<PageBlock> content;
  const CustomPage({required this.slug, required this.title, this.content = const []});
  factory CustomPage.fromJson(Map<String, dynamic> j) => CustomPage(
        slug: j['slug']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        content: (j['content'] as List<dynamic>? ?? const [])
            .map((e) => PageBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
  Map<String, dynamic> toJson() =>
      {'slug': slug, 'title': title, 'content': content.map((b) => b.toJson()).toList()};
}

/// The full shape of `Shops/{shopId}/Storefront/draft` and
/// `Shops/{shopId}/Storefront/published` — identical structure for both,
/// only which doc you read/write differs.
class StorefrontConfig {
  final StorefrontBranding branding;
  final StorefrontTheme theme;
  final List<StorefrontSection> homepage;
  final List<NavigationItem> navigation;
  final List<CustomPage> pages;
  final List<StorefrontBanner> banners;
  final StoreDetails storeDetails;
  final List<StorefrontFaq> faqs;
  final DateTime? updatedAt;
  final String? updatedBy;

  const StorefrontConfig({
    this.branding = const StorefrontBranding(),
    this.theme = const StorefrontTheme(),
    this.homepage = const [],
    this.navigation = const [],
    this.pages = const [],
    this.banners = const [],
    this.storeDetails = const StoreDetails(),
    this.faqs = const [],
    this.updatedAt,
    this.updatedBy,
  });

  StorefrontConfig copyWith({
    StorefrontBranding? branding,
    StorefrontTheme? theme,
    List<StorefrontSection>? homepage,
    List<NavigationItem>? navigation,
    List<CustomPage>? pages,
    List<StorefrontBanner>? banners,
    StoreDetails? storeDetails,
    List<StorefrontFaq>? faqs,
  }) =>
      StorefrontConfig(
        branding: branding ?? this.branding,
        theme: theme ?? this.theme,
        homepage: homepage ?? this.homepage,
        navigation: navigation ?? this.navigation,
        pages: pages ?? this.pages,
        banners: banners ?? this.banners,
        storeDetails: storeDetails ?? this.storeDetails,
        faqs: faqs ?? this.faqs,
        updatedAt: updatedAt,
        updatedBy: updatedBy,
      );

  factory StorefrontConfig.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const StorefrontConfig();
    final dynamic updatedAtRaw = j['updatedAt'];
    return StorefrontConfig(
      branding: StorefrontBranding.fromJson(j['branding'] as Map<String, dynamic>?),
      theme: StorefrontTheme.fromJson(j['theme'] as Map<String, dynamic>?),
      homepage: (j['homepage'] as List<dynamic>? ?? const [])
          .map((e) => StorefrontSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      navigation: (j['navigation'] as List<dynamic>? ?? const [])
          .map((e) => NavigationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pages: (j['pages'] as List<dynamic>? ?? const [])
          .map((e) => CustomPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      banners: (j['banners'] as List<dynamic>? ?? const []).map((e) => StorefrontBanner.fromJson(e as Map<String, dynamic>)).toList(),
      storeDetails: StoreDetails.fromJson(j['storeDetails'] as Map<String, dynamic>?),
      faqs: (j['faqs'] as List<dynamic>? ?? const []).map((e) => StorefrontFaq.fromJson(e as Map<String, dynamic>)).toList(),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : null,
      updatedBy: j['updatedBy']?.toString(),
    );
  }

  /// `updatedAt`/`updatedBy` are stamped by `StorefrontService`, not here —
  /// this only serializes the editable content.
  Map<String, dynamic> toJson() => {
        'branding': branding.toJson(),
        'theme': theme.toJson(),
        'homepage': homepage.map((s) => s.toJson()).toList(),
        'navigation': navigation.map((n) => n.toJson()).toList(),
        'pages': pages.map((p) => p.toJson()).toList(),
        'banners': banners.map((b) => b.toJson()).toList(),
        'storeDetails': storeDetails.toJson(),
        'faqs': faqs.map((f) => f.toJson()).toList(),
      };
}
