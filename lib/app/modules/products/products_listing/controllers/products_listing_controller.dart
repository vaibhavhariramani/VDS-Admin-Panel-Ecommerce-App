import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:file_picker/file_picker.dart';

// import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

import '../../../../../models/Product.dart';
import '../../../../../models/ProductCategory.dart';
import '../../../../../models/ProductDealType.dart';
import '../../../../../models/Users.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/create_data.dart';
import '../../../../../services/data_service.dart';
import '../../../../../services/fetch_data.dart';

class ProductsListingController extends GetxController {
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
      'offer_percentage': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      'currency_type': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      //Fresh Untill date for green Deal & End Date for Hot Deal
      'expiry_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      //Fresh Untill time for green Deal & End time for Hot Deal
      'end_time': FormControl<TimeOfDay>(
        validators: [
          Validators.required,
        ],
      ),
      //Start Date for Hot Deal
      'start_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),
      'start_time': FormControl<TimeOfDay>(
        validators: [
          Validators.required,
        ],
      ),
      //Schedule Date
      'visible_date': FormControl<DateTime>(
        validators: [
          Validators.required,
        ],
      ),

      'visible_time': FormControl<TimeOfDay>(
        validators: [
          Validators.required,
        ],
      ),
    },
  );
  final RxString currency = "".obs;
  final RxString productImageUrl0 = "".obs;
  final RxString productImageUrl1 = "".obs;
  final RxString productImageUrl2 = "".obs;
  final RxString productImageUrl3 = "".obs;
  final AuthService _userService = AuthService.to;
  final RxBool isPicUploading0 = false.obs;
  final RxBool isPicUploading1 = false.obs;
  final RxBool isPicUploading2 = false.obs;
  final RxBool isPicUploading3 = false.obs;
  final RxBool GreenDealChecked = false.obs;
  final RxBool RedDealChecked = false.obs;
  final RxBool hotDealChecked = false.obs;
  static final DataService _dataService = DataService.to;
  static final CreateService _createService = CreateService.to;

  Rx<Users?> get user => _userService.user.value.obs;
  final RxString shopId = "".obs;
  final RxString shopCurrency = "".obs;
  final RxBool showProductUploadForm = false.obs;
  final RxBool show_GreenDeal_ProductUploadForm = false.obs;
  final RxBool show_HotDeal_ProductUploadForm = false.obs;
  final RxBool showBulkProductUploadForm = false.obs;
  final RxBool ScheduleisChecked = false.obs;
  final RxBool PublishedisChecked = true.obs;
  final RxBool hotdealisChecked = false.obs;
  final Rx<ProductCategory> product_cat = ProductCategory.FOOD.obs;
  final RxBool showBulkCSVList = false.obs;
  final RxBool showBulkList = false.obs;
  final RxBool isEditing = false.obs;
  final Rx<ProductDealType> Dealtype = ProductDealType.GREENDEALS.obs;
  final RxBool singleProductUploadComplete = false.obs;
  List<List<dynamic>> rowsAsListOfValues = [[]].obs;
  final RxList<ProductCategory> columnlist = [
    ProductCategory.FOOD,
    ProductCategory.VEGITABLE,
    ProductCategory.FASTFOOD
  ].obs;
  List<dynamic> ListOfValues = [];
  final RxList<Product>? ListOfValues2 = <Product>[].obs;
  final RxList<Product>? products = <Product>[].obs;

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

  Future<void> editProduct({Product? ProductDetails, int? index}) async {
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
    Product temp = Product(
      id: productId!,
      barcode: '',
      category: '',
      name: product_name!,
      price: price!,
      discount: discount!,
      available_from: available_from!,
      expires_on: expires_on!,
      count: '0',
      description: '',
      image: '',
      mrp: 0.0,
      quantity: '',
      currency_type: '',
      deal_type: ProductDealType.HOTDEALS,
      img_token: null,
      shop_id: '',
    );
    // products?.removeAt(index!);
    // products?.insert(index!, temp);
    print("products: $products");
    // await Future.delayed(2.seconds);
    // Get.back();
  }

  @override
  void onInit() {
    _fetchData();
    super.onInit();
  }

  void _fetchData() async {
    await getshopId();
    await getshopCurrency();
  }

  Future<void> getshopId() async {
    await FetchService.to.fetchShopId().then((value) => shopId(value));
  }

  Future<void> getshopCurrency() async {
    await FetchService.to
        .fetchShopCurrency()
        .then((value) => shopCurrency(value));
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

  // Future<void> imagepick() async {
  //   print('pick image');
  //   isPicUploading(true);
  //   await _dataService.uploadImage(_userService.user.value!.id).then((fireBaseUrl) async {
  //     // print(value);
  //     productImageUrl(fireBaseUrl);
  //     isPicUploading(false);
  //     print(fireBaseUrl);
  //   });
  // }

  Future<void> importCSV() async {
    //Pick file
    DateTime now = DateTime.now();
    FilePickerResult? csvFile = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
        allowMultiple: false);
    if (csvFile != null) {
      //decode bytes back to utf8
      var uuid = const Uuid();
      final bytes = utf8.decode(csvFile.files[0].bytes!);
      Uint8List? doc = csvFile.files.first.bytes;
      String filename = csvFile.files.first.name;
      String nameForApi = AuthService.to.user.value!.id! +
          filename +
          uuid.v1().toString().substring(0, 10);
      DataService.to.uploadCSV(csv: nameForApi, filebytes: doc);
      //from the csv plugin

      // rowsAsListOfValues = const CsvToListConverter().convert(bytes);
      // var temp = const CsvToListConverter().convert(bytes);
      // Get.log(ListOfValues2!.length.toString());
      // rowsAsListOfValues.removeAt(0);
      for (var item in rowsAsListOfValues) {
        // ListOfValues2?.add(Product(id: item));
        print("CSV FILE DATA");
        print(item.toString());
        DateTime createdon = DateTime.parse(item[5].toString());
        DateTime expireon = DateTime.parse(item[6].toString());
        // Product temp = Product(
        //   img_token: item[0],
        //   name: item[1],
        //   price: item[2],
        //   discount: item[3],
        //   created_on: TemporalDateTime(createdon),
        //   expires_on: TemporalDateTime(expireon),
        //   deal_type: ProductDealType.GREENDEALS,
        //   shopID: shopId.value,
        //   currency_type: item[4],
        // );
        Product temp = Product(
          id: '',
          img_token: item[0],
          barcode: '',
          // sku: item[1],
          name: item[2],
          price: item[3],
          discount: item[4],
          available_from: DateTime(createdon as int),
          expires_on: DateTime(expireon as int),
          deal_type: ProductDealType.GREENDEALS,
          shop_id: shopId.value,
          currency_type: shopCurrency.value,
          category: '',
          count: '0',
          description: '',
          image: '',
          mrp: 0,
          quantity: '',
        );

        products?.add(temp);
        // print('List values:' + item.runtimeType.toString());
      }
      // print("After ::: " + ListOfValues2!.length.toString());
      // print('List of products from csv: \n ${ListOfValues2?.value}');
      ListOfValues = rowsAsListOfValues;
      // Get.log('This is list of values: ' + ListOfValues[0].toString());
      // Get.log("Length of Columns in list: ${rowsAsListOfValues[0].length}");
      // for (var col in rowsAsListOfValues[0]) {
      //   Get.log(col);
      // // }
      // print("print(showBulkList.toggle());");
      // print(showBulkList.toggle());

      showBulkCSVList(true);
    }
  }

  Future<void> uploadBulkProducts() async {
    showBulkList.toggle();
    showBulkProductUploadForm.toggle();
  }

  Future<void> createProductFromList() async {
    isEditing.toggle();
    print("Product list 238:" + products.toString());
    await Future.wait([
      for (var item in products!)
        _createService.CreateNewGreenProduct(
          offer_ends_on: item.expires_on,
          shopid: shopId.value,
          img_token: item.img_token!,
          product_name: item.name!,
          deal_type: item.deal_type!,
          price: item.price!,
          offer_price: item.discount!,
          offer_available_from: item.available_from,
          currency_type:
              item.currency_type == null ? "DKK" : item.currency_type!,
          sku: item.id!,
        )
    ], cleanUp: (val) {
      print("CLEAN THE PRODUCT LIST ");
    });

    print("Data uploaded");
    print(showBulkList.toggle());
    // showBulkCSVList.toggle();
    showBulkList(false);
    products?.clear();
    isEditing(false);

    print("products >>>>");
    print(products.toString());
    Get.snackbar(
      "New Product Created",
      "updated on backend",
    );
  }

  Future<void> createProductFromListForm() async {
    isEditing.toggle();

    print("Product list 276 :" + ListOfValues.toString());

    await Future.wait([
      for (var item in ListOfValues)
        // {
        _createService.CreateNewGreenProduct(
          offer_ends_on: item.expires_on,
          shopid: shopId.value,
          img_token: item.img_token!,
          product_name: item.name!,
          deal_type: item.deal_type!,
          price: item.price!,
          offer_price: item.discount!,
          offer_available_from: item.available_from,
          currency_type: item.currency_type,
          sku: item.sku,
        )
      // }
    ]);

    showBulkCSVList.toggle();
    isEditing(false);
  }

  void createProduct() async {
    print("Creating new Green Deal Product");
    DateTime? date = DateTime(productAddForm.value["expiry_date"] as int);
    String sku = productAddForm.value["sku"].toString();
    double actualPrice =
        double.parse(productAddForm.value["actual_price"].toString());
    print("actual price: $actualPrice");
    print("object: ${actualPrice.runtimeType}");
    double offerPrice =
        double.parse(productAddForm.value["offer_price"].toString());
    print("actual price: $offerPrice");
    print("object: ${offerPrice.runtimeType}");
    if (currency.isEmpty) {
      currency("USD");
    }
    DateTime? date3;
    if (PublishedisChecked.isTrue) {
      DateTime d3 = DateTime.now();
      date3 = DateTime(d3 as int);
    } else {
      DateTime d3 = productAddForm.value["visible_date"] as DateTime;

      TimeOfDay t3 = productAddForm.value["visible_time"] as TimeOfDay;
      DateTime Avdate = DateTime(d3.year, d3.month, d3.day, t3.hour, t3.minute);
      date3 = DateTime(Avdate as int);
    }
    isEditing.toggle();
    var x = await _createService.CreateNewGreenProduct(
      offer_ends_on: date,
      shopid: shopId.value,
      img_token: productImageUrl0.value,
      product_name: productAddForm.value["productname"].toString(),
      deal_type: Dealtype.value,
      price: actualPrice,
      offer_price: offerPrice,
      offer_available_from: date3,
      currency_type: shopCurrency.value,
      sku: sku,
    );
    // ListOfValues.add(x);

    showProductUploadForm(false);
    showBulkProductUploadForm(false);
    GreenDealChecked(false);
    RedDealChecked(false);
    hotDealChecked(false);
    productImageUrl0('');
    productImageUrl1('');
    productImageUrl2('');
    productImageUrl3('');
    currency('');
    productAddForm.reset();
    Get.snackbar(
      "New Product Created",
      "updated on backend",
    );
  }

  String? get StrDate {
    TimeOfDay t1 = productAddForm.value["start_time"] as TimeOfDay;
    DateTime d1 = productAddForm.value["start_date"] as DateTime;
    DateTime StrDate = DateTime(d1.year, d1.month, d1.day, t1.hour, t1.minute);
    print("Start date: ${StrDate.toString()}");

    String formattedDateTime = DateFormat('yyyy-MM-dd').format(StrDate) +
        "   " +
        t1.format(Get.context!).toString();
    return formattedDateTime.toString();
  }

  String? get SchDate {
    DateTime? date3;
    DateTime d3;
    TimeOfDay t3;
    if (PublishedisChecked.isTrue) {
      d3 = DateTime.now();
      t3 = TimeOfDay.now();
    } else {
      d3 = productAddForm.value["visible_date"] as DateTime;

      t3 = productAddForm.value["visible_time"] as TimeOfDay;
    }
    DateTime Avdate = DateTime(d3.year, d3.month, d3.day, t3.hour, t3.minute);
    date3 = DateTime(Avdate as int);
    print("Schdule date: ${date3.toString()}");
    return DataService.to.DateTimeToString(date: date3);
    // return date3.toString().substring(0, 10);
  }

  String? get ExpDate {
    DateTime d2 = productAddForm.value["expiry_date"] as DateTime;

    TimeOfDay t2 = productAddForm.value["end_time"] as TimeOfDay;
    DateTime Expdate = DateTime(d2.year, d2.month, d2.day, t2.hour, t2.minute);
    print("End date: ${Expdate.toString()}");
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(Expdate) +
        "   " +
        t2.format(Get.context!).toString();
    return formattedDateTime.toString();
  }

  void createHotDealProduct() async {
    print("Creating new Hot Deal Product");
    TimeOfDay t1 = productAddForm.value["start_time"] as TimeOfDay;
    DateTime d1 = productAddForm.value["start_date"] as DateTime;
    DateTime Schdate = DateTime(d1.year, d1.month, d1.day, t1.hour, t1.minute);
    DateTime? date = DateTime(Schdate as int);

    DateTime d2 = productAddForm.value["expiry_date"] as DateTime;
    TimeOfDay t2 = productAddForm.value["end_time"] as TimeOfDay;
    DateTime Expdate = DateTime(d2.year, d2.month, d2.day, t2.hour, t2.minute);
    DateTime? date2 = Expdate;

    DateTime? date3;
    DateTime d3;
    TimeOfDay t3;
    if (PublishedisChecked.isTrue) {
      d3 = DateTime.now();
      t3 = TimeOfDay.now();
    } else {
      d3 = productAddForm.value["visible_date"] as DateTime;

      t3 = productAddForm.value["visible_time"] as TimeOfDay;
    }
    DateTime Avdate = DateTime(d3.year, d3.month, d3.day, t3.hour, t3.minute);
    date3 = DateTime(Avdate as int);

    double actualPrice =
        double.parse(productAddForm.value["actual_price"].toString());
    print("actual price: $actualPrice");
    print("object: ${actualPrice.runtimeType}");
    String sku = productAddForm.value["sku"].toString();
    double offerPrice =
        double.parse(productAddForm.value["offer_price"].toString());
    print("actual price: $offerPrice");
    print("object: ${offerPrice.runtimeType}");
    print("product going live on: ${date2.toString()}");
    isEditing.toggle();
    var x = await _dataService.CreateNewHotProduct(
      sku: sku,
      shopid: shopId.value,
      offer_ends_on: date2,
      offer_starts_on: date,
      offer_available_from: date3,
      img_token: productImageUrl0.value,
      product_name: productAddForm.value["productname"].toString(),
      deal_type: ProductDealType.HOTDEALS,
      price: actualPrice,
      offer_price: offerPrice,
      currency_type: shopCurrency.value,
    );
    // ListOfValues.add(x);
    productAddForm.reset();
    showProductUploadForm(false);
    showBulkProductUploadForm(false);
    GreenDealChecked(false);
    RedDealChecked(false);
    hotDealChecked(false);
    productImageUrl0('');
    productImageUrl1('');
    productImageUrl2('');
    productImageUrl3('');

    print("Product Create: " + x.toString());
    print("Product list:" + ListOfValues.toString());
    Get.snackbar(
      "New Product Created",
      "updated on backend",
    );
  }

  Future<void> FetchAndReset() async {
    TimeOfDay t1 = productAddForm.value["end_time"] as TimeOfDay;
    DateTime d1 = productAddForm.value["expiry_date"] as DateTime;
    DateTime Expdate = DateTime(d1.year, d1.month, d1.day, t1.hour, t1.minute);
    DateTime? date = Expdate;

    DateTime? date3;
    if (PublishedisChecked.isTrue) {
      DateTime d3 = DateTime.now();
      TimeOfDay t3 = TimeOfDay.now();
      DateTime Avdate = DateTime(d3.year, d3.month, d3.day, t3.hour, t3.minute);
      date3 = Avdate;
    } else {
      DateTime d3 = productAddForm.value["visible_date"] as DateTime;
      TimeOfDay t3 = productAddForm.value["visible_time"] as TimeOfDay;
      DateTime Avdate = DateTime(d3.year, d3.month, d3.day, t3.hour, t3.minute);
      date3 = Avdate;
    }

    double offerPrice =
        double.parse(productAddForm.value["offer_price"].toString());
    Product temp = Product(
      id: '',
      expires_on: date,
      available_from: date3,
      img_token: productImageUrl0.value,
      name: productAddForm.value["productname"].toString(),
      deal_type: Dealtype.value,
      discount: offerPrice,
      price: double.parse(productAddForm.value["actual_price"].toString()),
      currency_type: shopCurrency.value,
      // sku: productAddForm.value["sku"].toString(),
      shop_id: shopId.value,
      barcode: '',
      category: '',
      count: '0',
      description: '',
      image: '',
      mrp: 0,
      quantity: '',
      // currency_type: currency
    );

    products?.add(temp);

    productImageUrl0('');
    productImageUrl1('');
    productImageUrl2('');
    productImageUrl3('');
    currency('');
    productAddForm.reset();
  }

  void deleteProduct(int index) {
    print("Deleting product");
    products?.removeAt(index);
    print("Product list:" + products.toString());
  }
}
