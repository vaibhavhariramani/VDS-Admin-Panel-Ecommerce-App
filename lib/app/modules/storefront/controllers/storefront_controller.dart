import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Product.dart';
import '../../../../models/Shop.dart';
import '../../../../models/storefront/section_config.dart';
import '../../../../models/storefront/storefront_config.dart';
import '../../../../models/storefront/storefront_section.dart';
import '../../../../services/fetch_data.dart';
import '../../../../services/storefront_service.dart';

/// Central state for the whole Storefront feature: which shop is in
/// scope, its draft/published config, and every edit action every
/// Storefront screen performs. `draft` is a local working copy - nothing
/// reaches Firestore until [saveDraft] runs, and nothing reaches the
/// Client App until [publish] runs.
class StorefrontController extends GetxController {
  final StorefrontService _service = StorefrontService.to;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPublishing = false.obs;

  String? shopId;
  final Rx<Shop?> shop = Rx<Shop?>(null);
  final Rx<StorefrontConfig> draft = Rx<StorefrontConfig>(const StorefrontConfig());
  final Rx<StorefrontConfig?> published = Rx<StorefrontConfig?>(null);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading(true);
    shopId = await FetchService.to.fetchShopId();
    if (shopId != null) {
      // Shop must be loaded first: a first-time draft is seeded from the
      // shop's own name/logo/brand color/products, so there's a real
      // starting storefront (not a blank page) the moment a merchant opens
      // this section — see [_loadDraft].
      await _loadShop();
      await Future.wait([
        _loadDraft(),
        _loadPublished(),
      ]);
    }
    isLoading(false);
  }

  Future<void> _loadShop() async {
    final Shop? fetched = await FetchService.to.fetchShopById(shopId!);
    shop(fetched);
  }

  bool _isBlank(StorefrontConfig c) =>
      c.branding.storeName.isEmpty &&
      c.homepage.isEmpty &&
      c.navigation.isEmpty &&
      c.pages.isEmpty;

  Future<void> _loadDraft() async {
    final StorefrontConfig fetched = await _service.fetchDraft(shopId!);
    if (_isBlank(fetched)) {
      // No draft has ever been saved for this shop - generate and persist
      // a sensible starting point (from real shop data where available) so
      // Preview/Publish have something meaningful on day one, rather than
      // an empty homepage. Later loads find this saved draft and skip
      // regeneration, so it never overwrites real edits.
      final StorefrontConfig defaultConfig = await _buildDefaultConfig();
      draft(defaultConfig);
      _service.saveDraft(shopId!, defaultConfig);
    } else {
      // Safely enrich existing storefronts with the new defaults without
      // replacing any merchant-authored content.
      final bool needsFaqs = fetched.faqs.isEmpty;
      final bool needsBannerLink = !fetched.navigation.any((item) => item.type == 'banners');
      final bool needsBanners = fetched.banners.isEmpty;
      final List<HeroSectionConfig> heroSections = fetched.homepage
          .where((section) => section.type == SectionType.hero)
          .map((section) => section.config)
          .whereType<HeroSectionConfig>()
          .toList();
      final HeroSectionConfig? hero = heroSections.isEmpty ? null : heroSections.first;
      final StorefrontConfig enriched = fetched.copyWith(
        faqs: needsFaqs ? defaultStorefrontFaqs : fetched.faqs,
        banners: needsBanners && hero != null
            ? [StorefrontBanner(id: 'banner_hero', title: hero.title, subtitle: hero.subtitle, imageUrl: hero.imageUrl, action: hero.buttonAction)]
            : fetched.banners,
        navigation: needsBannerLink
            ? [...fetched.navigation, NavigationItem(label: 'Banners', type: 'banners', order: fetched.navigation.length)]
            : fetched.navigation,
      );
      draft(enriched);
      if (needsFaqs || needsBannerLink || needsBanners) _service.saveDraft(shopId!, enriched);
    }
  }

  Future<StorefrontConfig> _buildDefaultConfig() async {
    final Shop? s = shop.value;
    final String storeName = (s?.name?.isNotEmpty ?? false) ? s!.name! : 'My Store';
    final String logoUrl = s?.img_token ?? '';
    final String coverImageUrl = (s?.bannerUrls?.isNotEmpty ?? false) ? s!.bannerUrls!.first : '';
    final String primaryColor = (s?.brandColor?.isNotEmpty ?? false) ? s!.brandColor! : '#111827';
    final String about =
        (s?.about?.isNotEmpty ?? false) ? s!.about! : 'Quality products, delivered to your door.';

    final List<String> categories = await fetchDistinctCategories();
    final List<Product> products = await fetchPickableProducts();
    final List<String> productIds = products
        .take(8)
        .map((p) => (p.barcode?.isNotEmpty ?? false) ? p.barcode! : (p.id ?? p.name))
        .toList();

    return StorefrontConfig(
      branding: StorefrontBranding(
        storeName: storeName,
        tagline: 'Quality products, delivered to your door',
        logoUrl: logoUrl,
        coverImageUrl: coverImageUrl,
      ),
      theme: StorefrontTheme(primaryColor: primaryColor),
      homepage: [
        StorefrontSection(
          id: 'sec_default_hero',
          type: SectionType.hero,
          order: 0,
          enabled: true,
          config: HeroSectionConfig(
            title: 'Welcome to $storeName',
            subtitle: about,
            imageUrl: coverImageUrl,
            buttonText: 'Shop Now',
            buttonAction: 'products',
          ),
        ),
        StorefrontSection(
          id: 'sec_default_categories',
          type: SectionType.categoryGrid,
          order: 1,
          enabled: true,
          config: CategoryGridSectionConfig(
            title: 'Shop by Category',
            categoryIds: categories.take(6).toList(),
          ),
        ),
        StorefrontSection(
          id: 'sec_default_featured',
          type: SectionType.featuredProducts,
          order: 2,
          enabled: true,
          config: FeaturedProductsSectionConfig(
            title: 'Featured Products',
            productIds: productIds.take(4).toList(),
          ),
        ),
        const StorefrontSection(
          id: 'sec_default_bestsellers',
          type: SectionType.bestSellers,
          order: 3,
          enabled: true,
          config: BestSellersSectionConfig(),
        ),
        const StorefrontSection(
          id: 'sec_default_storeinfo',
          type: SectionType.storeInformation,
          order: 4,
          enabled: true,
          config: StoreInformationSectionConfig(),
        ),
        const StorefrontSection(
          id: 'sec_default_newsletter',
          type: SectionType.newsletter,
          order: 5,
          enabled: true,
          config: NewsletterSectionConfig(),
        ),
      ],
      navigation: const [
        NavigationItem(label: 'Home', type: 'home', order: 0),
        NavigationItem(label: 'Banners', type: 'banners', order: 1),
        NavigationItem(label: 'Products', type: 'products', order: 2),
        NavigationItem(label: 'About Us', type: 'page', referenceId: 'about-us', order: 3),
        NavigationItem(label: 'Contact', type: 'page', referenceId: 'contact', order: 4),
      ],
      banners: [
        StorefrontBanner(id: 'banner_welcome', title: 'Welcome to $storeName', subtitle: about,
            imageUrl: coverImageUrl, action: 'products'),
      ],
      storeDetails: StoreDetails(
        address: s?.phy_address ?? '',
        phoneNumber: s?.phn_number ?? '',
      ),
      faqs: defaultStorefrontFaqs,
      pages: [
        CustomPage(slug: 'about-us', title: 'About Us', content: [
          const PageBlock(type: 'heading', value: 'Who We Are'),
          PageBlock(type: 'paragraph', value: about),
        ]),
        CustomPage(slug: 'contact', title: 'Contact', content: [
          const PageBlock(type: 'heading', value: 'Get in Touch'),
          PageBlock(
            type: 'paragraph',
            value: 'Phone: ${(s?.phn_number?.isNotEmpty ?? false) ? s!.phn_number! : 'Add your phone number'}\n'
                'Address: ${(s?.phy_address?.isNotEmpty ?? false) ? s!.phy_address! : 'Add your address'}',
          ),
        ]),
        const CustomPage(slug: 'faq', title: 'FAQ', content: [
          PageBlock(type: 'heading', value: 'Frequently Asked Questions'),
          PageBlock(type: 'paragraph', value: 'Add your frequently asked questions here.'),
        ]),
      ],
    );
  }

  Future<void> _loadPublished() async {
    published(await _service.fetchPublished(shopId!));
  }

  Future<void> reloadAll() => _load();

  // ---------------------------------------------------------------------
  // Branding / Theme
  // ---------------------------------------------------------------------

  void updateBranding(StorefrontBranding branding) {
    draft(draft.value.copyWith(branding: branding));
  }

  void updateTheme(StorefrontTheme theme) {
    draft(draft.value.copyWith(theme: theme));
  }

  // ---------------------------------------------------------------------
  // Homepage sections
  // ---------------------------------------------------------------------

  void addSection(String type) {
    final List<StorefrontSection> sections = List.of(draft.value.homepage);
    sections.add(StorefrontSection.create(type).copyWith(order: sections.length));
    draft(draft.value.copyWith(homepage: sections));
  }

  void updateSection(String id, SectionConfig config) {
    final List<StorefrontSection> sections = draft.value.homepage
        .map((s) => s.id == id ? s.copyWith(config: config) : s)
        .toList();
    draft(draft.value.copyWith(homepage: sections));
  }

  void removeSection(String id) {
    final List<StorefrontSection> sections =
        draft.value.homepage.where((s) => s.id != id).toList();
    draft(draft.value.copyWith(homepage: _reindexed(sections)));
  }

  void toggleSectionEnabled(String id, bool enabled) {
    final List<StorefrontSection> sections = draft.value.homepage
        .map((s) => s.id == id ? s.copyWith(enabled: enabled) : s)
        .toList();
    draft(draft.value.copyWith(homepage: sections));
  }

  void reorderSections(int oldIndex, int newIndex) {
    final List<StorefrontSection> sections = List.of(draft.value.homepage);
    if (newIndex > oldIndex) newIndex -= 1;
    final StorefrontSection moved = sections.removeAt(oldIndex);
    sections.insert(newIndex, moved);
    draft(draft.value.copyWith(homepage: _reindexed(sections)));
  }

  List<StorefrontSection> _reindexed(List<StorefrontSection> sections) => [
        for (int i = 0; i < sections.length; i++) sections[i].copyWith(order: i),
      ];

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------

  void addNavigationItem(NavigationItem item) {
    final List<NavigationItem> items = List.of(draft.value.navigation)
      ..add(NavigationItem(
        label: item.label,
        type: item.type,
        referenceId: item.referenceId,
        order: draft.value.navigation.length,
      ));
    draft(draft.value.copyWith(navigation: items));
  }

  void removeNavigationItemAt(int index) {
    final List<NavigationItem> items = List.of(draft.value.navigation)..removeAt(index);
    draft(draft.value.copyWith(navigation: items));
  }

  void reorderNavigation(int oldIndex, int newIndex) {
    final List<NavigationItem> items = List.of(draft.value.navigation);
    if (newIndex > oldIndex) newIndex -= 1;
    final NavigationItem moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    draft(draft.value.copyWith(navigation: items));
  }

  // ---------------------------------------------------------------------
  // Banners, store details and FAQs
  // ---------------------------------------------------------------------

  void saveBanner(StorefrontBanner banner) {
    final List<StorefrontBanner> banners = List.of(draft.value.banners);
    final int index = banners.indexWhere((b) => b.id == banner.id);
    if (index == -1) {
      banners.add(banner);
    } else {
      banners[index] = banner;
    }
    draft(draft.value.copyWith(banners: banners));
  }

  void removeBanner(String id) => draft(draft.value.copyWith(
      banners: draft.value.banners.where((banner) => banner.id != id).toList()));

  void updateStoreDetails(StoreDetails details) =>
      draft(draft.value.copyWith(storeDetails: details));

  void saveFaq(StorefrontFaq faq) {
    final List<StorefrontFaq> faqs = List.of(draft.value.faqs);
    final int index = faqs.indexWhere((item) => item.id == faq.id);
    if (index == -1) {
      faqs.add(faq);
    } else {
      faqs[index] = faq;
    }
    draft(draft.value.copyWith(faqs: faqs));
  }

  void removeFaq(String id) => draft(draft.value.copyWith(
      faqs: draft.value.faqs.where((faq) => faq.id != id).toList()));

  // ---------------------------------------------------------------------
  // Pages
  // ---------------------------------------------------------------------

  void savePage(CustomPage page, {int? replaceIndex}) {
    final List<CustomPage> pages = List.of(draft.value.pages);
    if (replaceIndex != null) {
      pages[replaceIndex] = page;
    } else {
      pages.add(page);
    }
    draft(draft.value.copyWith(pages: pages));
  }

  void removePageAt(int index) {
    final List<CustomPage> pages = List.of(draft.value.pages)..removeAt(index);
    draft(draft.value.copyWith(pages: pages));
  }

  // ---------------------------------------------------------------------
  // Save / Publish
  // ---------------------------------------------------------------------

  Future<bool> saveDraft() async {
    if (shopId == null) return false;
    isSaving(true);
    final bool success = await _service.saveDraft(shopId!, draft.value);
    isSaving(false);
    if (success) {
      Get.snackbar('Draft Saved', 'Your changes are saved but not live yet.',
          duration: const Duration(seconds: 4));
    } else {
      Get.snackbar('Failed to save', 'Please try again.',
          duration: const Duration(seconds: 4));
    }
    return success;
  }

  Future<bool> publish() async {
    if (shopId == null) return false;
    final bool saved = await saveDraft();
    if (!saved) return false;
    isPublishing(true);
    final bool success = await _service.publish(shopId!);
    isPublishing(false);
    if (success) {
      await _loadPublished();
      Get.snackbar('Storefront Published', 'Your storefront is now live.',
          duration: const Duration(seconds: 4));
    } else {
      Get.snackbar('Failed to publish', 'Please try again.',
          duration: const Duration(seconds: 4));
    }
    return success;
  }

  // ---------------------------------------------------------------------
  // Store URL
  // ---------------------------------------------------------------------

  String? get storeCode => shop.value?.storeCode;

  String? validateStoreCode(String code) => _service.validateStoreCode(code);

  String slugify(String input) => _service.slugify(input);

  Future<bool> isStoreCodeAvailable(String code) => _service.isStoreCodeAvailable(code);

  Future<String?> claimStoreCode(String code) async {
    if (shopId == null) return 'No shop found for your account.';
    final String? error = await _service.claimStoreCode(shopId!, code);
    if (error == null) {
      await _loadShop();
    }
    return error;
  }

  // ---------------------------------------------------------------------
  // Pickers
  // ---------------------------------------------------------------------

  Future<List<Product>> fetchPickableProducts() =>
      shopId == null ? Future.value(const <Product>[]) : _service.fetchPickableProducts(shopId!);

  Future<List<String>> fetchDistinctCategories() =>
      shopId == null ? Future.value(const <String>[]) : _service.fetchDistinctCategories(shopId!);
}
