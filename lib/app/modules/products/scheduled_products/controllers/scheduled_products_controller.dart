import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../../models/Product.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';

class ScheduledProductsController extends GetxController {
  final isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool isEmpty = false.obs;
  final RxBool showGreenDeal = true.obs;

  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> scheduledProducts = <Product>[].obs;
  final RxString searchQuery = ''.obs;
  List<Product> get visibleScheduledProducts => scheduledProducts
      .where((Product p) => p.matchesSearch(searchQuery.value))
      .toList();
  final RxBool isLoadingForScheduled = false.obs;
  final DataService _dataService = DataService.to;
  final RxString shopId = ''.obs;
  final RxBool productdeleting = false.obs;
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
    super.onInit();
  }

  Future<void> getshopId() async {
    await FetchService.to.fetchShopId().then((value) => shopId(value));
  }

  void _fetchData() async {
    // if (_dataService.client != null) {
    await getshopId();
    await fetchAllScheduledProducts();
    // }
  }

  Future<void> fetchAllScheduledProducts() async {
    print("\n");
    print("Fetching Scheduled Products ");
    scheduledProducts.clear();
    isLoading(true);
    await Future.delayed(1000.milliseconds, () async {
      await _dataService
          .fetchAllScheduledProducts(shopId.value)
          .then((List<Product> _response) {
        scheduledProducts.addAll(_response);
      });

      isLoading(false);
    });
  }

  Future<void> editProduct({Product? ProductDetails}) async {
    String? productId = ProductDetails?.id;
    String? product_name =
        productEditForm.value["product_name"].toString() == "null"
            ? ProductDetails!.name
            : productEditForm.value["product_name"].toString();
    double? price = productEditForm.value["product_price"].toString() == "null"
        ? ProductDetails!.price
        : double.parse(productEditForm.value["product_price"].toString());
    double? discount = productEditForm.value["discount"].toString() == "null"
        ? ProductDetails!.discount
        : double.parse(productEditForm.value["discount"].toString());
    DateTime? available_from =
        productEditForm.value["available_from"].toString() == "null"
            ? ProductDetails?.available_from
            : DateTime(productEditForm.value["available_from"] as int);
    DateTime? expires_on =
        productEditForm.value["expiry_date"].toString() == "null"
            ? ProductDetails?.expires_on
            : DateTime(productEditForm.value["expiry_date"] as int);

    print("productId: $productId");
    print("product_name: $product_name");
    print("price: $price");
    print("available_from: $available_from");
    print("expires_on: $expires_on");
    print("discount: $discount");
    isLoading(true);
    var x = await _dataService.updateProductData(
      id: productId!,
      product_name: product_name,
      price: price,
      discount: discount!,
      available_from: available_from!,
      expire_on: expires_on!,
    );
    productEditForm.reset();
    onInit();

    Get.snackbar(
      "Product Edited",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
    // await Future.delayed(2.seconds);
    // Get.back();
  }

  Future<void> publishNow(String productId) async {
    await _dataService.publishNow(productId);
    isLoading(true);
    onInit();
    Get.snackbar(
      "Product published",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
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
