import 'package:get/get.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';

enum ProductStatusFilter { all, published, scheduled, hotDeals }

/// Replaces MasterListController + ScheduledProductsController +
/// PublishedProductsController + HotDealsController — those 4 controllers
/// ran 4 separate full-collection fetches of the same shop's `Products`
/// and filtered client-side in near-identical ways (see
/// docs/architecture/CURRENT_ARCHITECTURE.md's product-management
/// findings). This fetches once and derives every filter from the same
/// list, matching the filter semantics those controllers actually used:
/// - Published: isPublished && started (availableFrom not in the future)
///   && not expired (expiresOn not in the past)
/// - Scheduled: isPublished && availableFrom in the future
/// - Hot Deals: dealType == HOTDEALS (orthogonal to publish state - a
///   product can be a hot deal AND scheduled/published at once)
class ProductManagementController extends GetxController {
  final DataService _dataService = DataService.to;
  final FetchService _fetchService = FetchService.to;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxList<Product> allProducts = <Product>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<ProductStatusFilter> statusFilter = ProductStatusFilter.all.obs;
  final RxString shopId = ''.obs;

  List<Product> get _searched =>
      allProducts.where((Product p) => p.matchesSearch(searchQuery.value)).toList();

  List<Product> get visibleProducts {
    switch (statusFilter.value) {
      case ProductStatusFilter.all:
        return _searched;
      case ProductStatusFilter.published:
        return _searched.where(isPublishedNow).toList();
      case ProductStatusFilter.scheduled:
        return _searched.where(isScheduled).toList();
      case ProductStatusFilter.hotDeals:
        return _searched.where((Product p) => p.deal_type == ProductDealType.HOTDEALS).toList();
    }
  }

  int get publishedCount => allProducts.where(isPublishedNow).length;
  int get scheduledCount => allProducts.where(isScheduled).length;
  int get hotDealsCount =>
      allProducts.where((Product p) => p.deal_type == ProductDealType.HOTDEALS).length;

  bool isPublishedNow(Product p) {
    final DateTime now = DateTime.now();
    final bool started = p.available_from == null || !p.available_from!.isAfter(now);
    final bool notExpired = p.expires_on == null || p.expires_on!.isAfter(now);
    return p.is_published && started && notExpired;
  }

  bool isScheduled(Product p) {
    return p.is_published && p.available_from != null && p.available_from!.isAfter(DateTime.now());
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading(true);
    final String? id = await _fetchService.fetchShopId();
    shopId.value = id ?? '';
    if (id != null) {
      final List<Product> products = await _fetchService.fetchAllProductsByShop(id);
      allProducts.assignAll(products);
    }
    isLoading(false);
  }

  Future<void> refresh() => _load();

  Future<String> uploadImage(String fileNameSeed) {
    return _dataService.uploadImage(fileNameSeed);
  }

  /// Returns null on success, or an error message.
  Future<String?> createProduct({
    required String sku,
    required String name,
    required String? brand,
    required String category,
    required String currencyType,
    required double price,
    required double offerPrice,
    required int quantity,
    required ProductDealType dealType,
    required DateTime availableFrom,
    required DateTime expiresOn,
    required String imageUrl,
  }) async {
    if (shopId.value.isEmpty) return "Couldn't determine which shop this product belongs to.";
    isSaving(true);
    final bool ok = await _dataService.CreateNewHotProduct(
      img_token: imageUrl,
      product_name: name,
      shopid: shopId.value,
      currency_type: currencyType,
      price: price,
      offer_price: offerPrice,
      offer_ends_on: expiresOn,
      offer_starts_on: availableFrom,
      offer_available_from: availableFrom,
      sku: sku,
      deal_type: dealType,
    );
    isSaving(false);
    if (!ok) return 'Could not create the product. Please try again.';
    await _load();
    return null;
  }

  Future<String?> updateProduct({
    required Product product,
    required String name,
    required double price,
    required double offerPrice,
    required DateTime availableFrom,
    required DateTime expiresOn,
  }) async {
    isSaving(true);
    final bool ok = product.deal_type == ProductDealType.HOTDEALS
        ? await _dataService.updateHotDealProductData(
            id: product.id!,
            product_name: name,
            price: price,
            discount: offerPrice,
            available_from: availableFrom,
            expire_on: expiresOn,
            startson: availableFrom,
          )
        : await _dataService.updateProductData(
            id: product.id!,
            product_name: name,
            price: price,
            discount: offerPrice,
            available_from: availableFrom,
            expire_on: expiresOn,
          );
    isSaving(false);
    if (!ok) return 'Could not save changes. Please try again.';
    await _load();
    return null;
  }

  Future<bool> deleteProduct(String id) async {
    final bool ok = await _dataService.productDelete(id: id);
    if (ok) await _load();
    return ok;
  }

  Future<bool> setPublished(String id, bool published) async {
    final bool ok = published
        ? await _dataService.publishNow(id)
        : await _dataService.updateProductStatus(id, false);
    if (ok) await _load();
    return ok;
  }
}
