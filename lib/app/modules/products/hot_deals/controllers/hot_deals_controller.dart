import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';

class HotDealsController extends GetxController {
  final isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> hotdealProducts = <Product>[].obs;
  final RxBool productdeleting = false.obs;
  final DataService _dataService = DataService.to;
  final RxString shopId = ''.obs;
  final RxString shopCurrency = ''.obs;
  final FormGroup productAddForm = FormGroup(
    {
      'productname': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'brand': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'category': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'sub_category': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'sku': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'actual_price': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'offer_price': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'discount_price': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'offer_percentage': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'expiry_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      'schedule_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );
  final FormGroup productEditForm = FormGroup(
    {
      'product_name': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'product_price': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'offer_price': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'start_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      'expiry_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      'available_from': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      'visibility_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );

  @override
  void onInit() {
    isLoading(true);
    _fetchData();
    productAddForm.reset();
    productEditForm.reset();
    super.onInit();
  }

  void _fetchData() async {
    // if (_dataService.client != null) {
    await getshopId();
    await fetchAllHotdealProducts();
    // }
  }

  Future<void> getshopId() async {
    await FetchService.to.fetchShopId().then((value) => shopId(value));
  }

  Future<void> getshopCurrency() async {
    await FetchService.to
        .fetchShopCurrency()
        .then((value) => shopCurrency(value));
  }

  Future<void> fetchAllHotdealProducts() async {
    print("\n");
    print("Fetching Hot Deal Products ");
    hotdealProducts.clear();
    isLoading(true);
    await Future.delayed(1000.milliseconds, () async {
      await _dataService
          .fetchAllProductsaccordingProductType(
              shopId: shopId.value, deal_type: ProductDealType.HOTDEALS)
          .then((List<Product> _response) {
        hotdealProducts.addAll(_response);
      });

      isLoading(false);
    });
  }

  Future<void> editProduct({Product? ProductDetails}) async {
    allProducts.clear();
    String? productId = ProductDetails?.id;
    // Handle text fields safely
    String? product_name = productEditForm.control('product_name').value;
    if (product_name == null || product_name == "null") {
      product_name = ProductDetails!.name;
    }

    double? price = double.tryParse(productEditForm.control('product_price').value?.toString() ?? '');
    price ??= ProductDetails?.price;

    double? discount = double.tryParse(productEditForm.control('discount').value?.toString() ?? '');
    discount ??= ProductDetails?.discount;

    DateTime? available_from = productEditForm.control('available_from').value;
    DateTime? expires_on = productEditForm.control('expiry_date').value;
    DateTime? startson = productEditForm.control('start_date').value;
    // Fallback to existing product values if form fields are untouched
    available_from ??= ProductDetails?.available_from;
    expires_on ??= ProductDetails?.expires_on;
    startson ??= ProductDetails?.available_from;

    print("productId: $productId");
    print("product_name: $product_name");
    print("price: $price");
    print("available_from: $available_from");
    print("expires_on: $expires_on");
    print("discount: $discount");
    isLoading(true);
    var x = await _dataService.updateHotDealProductData(
      id: productId!,
      product_name: product_name,
      price: price!,
      discount: discount!,
      available_from: available_from!,
      expire_on: expires_on!,
      startson: startson!,
    );

    onInit();

    Get.snackbar(
      "Product Edited",
      "Updated on backend",
      duration: const Duration(seconds: 5),
    );
    // await Future.delayed(2.seconds);
    // Get.back();
  }

  void publishNow(String productId) {
    _dataService.publishNow(productId);
    isLoading(true);
    onInit();
  }

  Future<void> deleteproduct(String id) async {
    productdeleting(true);
    isLoading(true);
    await _dataService
        .productDelete(id: id)
        .then((value) => productdeleting(!value));

    onInit();
  }

  Future<void> unpublishProduct(String id) async {
    productdeleting(true);
    print("Unpublishing Product");
    await _dataService
        .productUnpublish(id: id)
        .then((value) => productdeleting(!value));
    isLoading(true);
    onInit();
  }
}
