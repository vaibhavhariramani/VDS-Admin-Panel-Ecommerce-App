import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';

class PublishedProductsController extends GetxController {
  final isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool productdeleting = false.obs;
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> publishedProducts = <Product>[].obs;
  final DataService _dataService = DataService.to;
  final RxString shopId = ''.obs;
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

  final RxBool showGreenDeal = true.obs;
  @override
  void onInit() {
    isLoading(true);
    _fetchData();
    productEditForm.reset();
    productAddForm.reset();
    super.onInit();
  }

  void _fetchData() async {
    // if (_dataService.client != null) {
    await getshopId();
    await _fetchAllProducts();
    await fetchAllPublishedProducts();
    // }
  }

  Future<void> getshopId() async {
    await FetchService.to.fetchShopId().then((value) => shopId(value));
  }

  Future<void> _fetchAllProducts() async {
    allProducts.clear();
    await Future.delayed(1000.milliseconds, () async {
      await _dataService
          .fetchAllProducts()
          .then((List<Product> _productResponse) {
        allProducts.addAll(_productResponse);

        // print(allProducts);
      });

      isLoading(false);
    });
  }

  Future<void> fetchAllPublishedProducts() async {
    print("\n");
    print("Fetching Already Published Products ");
    publishedProducts.clear();
    isLoading(true);
    await Future.delayed(1000.milliseconds, () async {
      await _dataService
          .fetchAllPublishedProducts(shopId.value)
          .then((List<Product> _response) {
        publishedProducts.addAll(_response);
      });

      isLoading(false);
    });
  }

  void publishNow(String productId) {
    _dataService.publishNow(productId);
    isLoading(true);
    onInit();
  }

  Future<void> deleteproduct(String id) async {
    productdeleting(true);
    await _dataService
        .productDelete(id: id)
        .then((value) => productdeleting(!value));
  }

  Future<void> editProduct({Product? ProductDetails}) async {
    allProducts.clear();
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
    DateTime? startson =
        productEditForm.value["start_date"].toString() == "null"
            ? ProductDetails?.available_from
            : DateTime(productEditForm.value["start_date"] as int);

    print("productId: $productId");
    print("product_name: $product_name");
    print("price: $price");
    print("available_from: $available_from");
    print("expires_on: $expires_on");
    print("discount: $discount");
    isLoading(true);
    ProductDetails?.deal_type == ProductDealType.GREENDEALS
        ? await _dataService.updateProductData(
            id: productId!,
            product_name: product_name,
            price: price,
            discount: discount!,
            available_from: available_from!,
            expire_on: expires_on!,
          )
        : await _dataService.updateHotDealProductData(
            startson: startson!,
            id: productId!,
            product_name: product_name,
            price: price,
            discount: discount!,
            available_from: available_from!,
            expire_on: expires_on!,
          );

    onInit();

    Get.snackbar(
      "Product Edited",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
    // await Future.delayed(2.seconds);
    // Get.back();
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
