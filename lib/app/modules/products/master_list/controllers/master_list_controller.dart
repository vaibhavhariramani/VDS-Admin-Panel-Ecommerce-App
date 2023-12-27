import 'dart:convert';

// import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../models/Users.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';
import '../../hot_deals/controllers/hot_deals_controller.dart';
import '../../published_products/controllers/published_products_controller.dart';
import '../../scheduled_products/controllers/scheduled_products_controller.dart';

class MasterListController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  int totalProducts = 0;
  int productsPerPage = 6;
  int currentPage = 0;
  final RxList<Product> allProducts = <Product>[].obs;
  final RxBool CreatingNewProduct = false.obs;
  final RxBool showProductUploadForm = false.obs;
  final RxBool showBulkProductUploadForm = false.obs;
  final DataService _dataService = DataService.to;
  final DataService dataSer = DataService.to;
  final FetchService _fetchService = FetchService.to;
  final RxBool GreenDealChecked = false.obs;
  final RxBool RedDealChecked = false.obs;
  final RxBool hotDealChecked = false.obs;
  final RxBool ScheduleisChecked = false.obs;
  final RxBool PublishedisChecked = false.obs;
  final RxBool hotdealisChecked = false.obs;
  final RxBool isPicUploading0 = false.obs;
  final RxBool isPicUploading1 = false.obs;
  final RxBool isPicUploading2 = false.obs;
  final RxBool isPicUploading3 = false.obs;
  final RxString productImageUrl0 = "".obs;
  final RxString productImageUrl1 = "".obs;
  final RxString productImageUrl2 = "".obs;
  final RxString productImageUrl3 = "".obs;
  final Rx<ProductDealType> Dealtype = ProductDealType.GREENDEALS.obs;
  final RxString userImageUrl = "".obs;
  final RxBool isPicUploading = false.obs;
  final RxBool productdeleting = false.obs;
  final AuthService _userService = AuthService.to;
  final RxBool showGreenDeal = true.obs;
  final Rx<ProductDealType> filerdeal = Rx(ProductDealType.GREENDEALS);

  Rx<Users?> get user => _userService.user.value.obs;
  List<List<dynamic>> rowsAsListOfValues = [[]].obs;
  List<dynamic> ListOfValues = [];
  final RxString shopId = "".obs;
  final RxBool showBulkCSVList = false.obs;
  ScheduledProductsController SController =
      Get.put(ScheduledProductsController());
  PublishedProductsController PController =
      Get.put(PublishedProductsController());
  HotDealsController Hcontroller = Get.put(HotDealsController());
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

  Future<void> getshopId() async {
    await FetchService.to.fetchShopId().then((value) => shopId(value));
  }

  void _fetchData() async {
    // if (_dataService.client != null) {
    await getshopId();
    await _fetchAllProducts(shopId.value);
    isEditing(false);
    // }
  }

  Future<void> pickImage(RxString imageUrl, RxBool loadingbool) async {
    print('pick image');
    loadingbool(true);
    await _dataService
        .uploadImage('${user.value!.id}_${DateTime.now().toString()}')
        .then((fireBaseUrl) async {
      // print(value);
      imageUrl(fireBaseUrl);
      loadingbool(false);
      print(fireBaseUrl);
    });
  }

  int pageCount() {
    return (totalProducts / productsPerPage) as int;
  }

  nextPage() {
    if ((currentPage + 1) < pageCount()) {
      currentPage += 1;
    }
  }

  previousPage() {
    //lets not go bellow 0 :-)
    if (currentPage != 0) {
      currentPage -= 1;
    }
  }

  updatepage(int pageNumber) {
    currentPage = pageNumber;
    update();
  }

  Future<void> _fetchAllProducts(String shopid) async {
    allProducts.clear();
    await Future.delayed(1000.milliseconds, () async {
      await _fetchService
          .fetchAllProductsByShop(shopid)
          .then((_productResponse) {
        allProducts.addAll(_productResponse);

        // print(allProducts);
      });

      isLoading(false);
    });
    totalProducts = allProducts.length;
  }

  Future<void> deleteproduct(String id) async {
    // productdeleting(true);
    allProducts.clear();
    await _dataService
        .productDelete(id: id)
        .then((value) => productdeleting(!value));

    onInit();
    SController.onInit();
    Get.snackbar(
      "Product Deleted",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
    PController.onInit();
    Hcontroller.onInit();
  }

  Future<void> importCSV() async {
    //Pick file
    FilePickerResult? csvFile = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
        allowMultiple: false);
    if (csvFile != null) {
      //decode bytes back to utf8
      print(
          " ${isLoading.value} + ${allProducts.isNotEmpty} + ${CreatingNewProduct.value}  + ${showBulkProductUploadForm.value} + ${showBulkCSVList.value}");
      final bytes = utf8.decode(csvFile.files[0].bytes!);
      //from the csv plugin
      // rowsAsListOfValues = const CsvToListConverter().convert(bytes);
      ListOfValues = rowsAsListOfValues;
      print(rowsAsListOfValues);
      // showBulkCSVList.toggle();
    }
  }

  // void createProduct() async {
  //   print("Creating new Product");
  //   TemporalDateTime? date =
  //       TemporalDateTime(productAddForm.value["expiry_date"] as DateTime);
  //   double actualPrice =
  //       double.parse(productAddForm.value["actual_price"].toString());
  //   print("actual price: $actualPrice");
  //   print("object: ${actualPrice.runtimeType}");
  //   double offerPrice =
  //       double.parse(productAddForm.value["offer_price"].toString());
  //   print("actual price: $offerPrice");
  //   print("object: ${offerPrice.runtimeType}");
  //   // isEditing.toggle();
  //   var x = await _dataService.CreateNewGreenProduct(
  //     offer_available_from: date,
  //     shopid: user.value!.id,
  //     offer_ends_on: date,
  //     img_token: productImageUrl0.value,
  //     product_name: productAddForm.value["productname"].toString(),
  //     deal_type: Dealtype.value,
  //     price: actualPrice,
  //     offer_price: offerPrice,
  //     currency_type: currency.value,
  //   );
  //   showProductUploadForm(false);
  //   showBulkProductUploadForm(false);
  //   GreenDealChecked(false);
  //   RedDealChecked(false);
  //   hotDealChecked(false);
  //   productImageUrl0('');
  //   productImageUrl1('');
  //   productImageUrl2('');
  //   productImageUrl3('');
  //   productAddForm.value["actual_price"] = '';
  //   productAddForm.value["offer_price"] = '';
  //   productAddForm.value["expiry_date"] = '';

  //   print("Product Create: " + x.toString());

  //   Get.snackbar(
  //     "New Product Created",
  //     "updated on backend",
  //   );
  // }

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
            ? ProductDetails?.start_date
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
            product_name: product_name!,
            price: price!,
            discount: discount!,
            available_from: available_from!,
            expire_on: expires_on!,
          )
        : await _dataService.updateHotDealProductData(
            startson: startson!,
            id: productId!,
            product_name: product_name!,
            price: price!,
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

  Future<void> scheduleProduct({Product? ProductDetails}) async {
    allProducts.clear();
    String? productId = ProductDetails?.id;
    DateTime? available_from =
        productEditForm.value["available_from"].toString() == "null"
            ? ProductDetails?.available_from
            : DateTime(productEditForm.value["available_from"] as int);
    DateTime? expires_on =
        productEditForm.value["expiry_date"].toString() == "null"
            ? ProductDetails?.expires_on
            : DateTime(productEditForm.value["expiry_date"] as int);

    print("available_from: $available_from");
    print("expires_on: $expires_on");
    var x = await _dataService.scheduleProductData(
      id: productId!,
      available_from: available_from!,
      expire_on: expires_on!,
    );
    isLoading(true);
    onInit();

    Get.snackbar(
      "Product Scheduled",
      "Updated on backend",
      duration: Duration(seconds: 5),
    );
    // await Future.delayed(2.seconds);
    // Get.back();
  }

  Future<void> publishNow(String productId) async {
    allProducts.clear();
    await _dataService.publishNow(productId);
    isLoading(true);
    onInit();
  }

  void updateProductStatus(String id, bool isPublished) async {
    print("Switching status of product: $isPublished");
    await _dataService.updateProductStatus(id, isPublished);
    isLoading(true);
    onInit();
  }
}
