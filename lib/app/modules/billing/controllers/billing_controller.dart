import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../../models/Product.dart';
import '../../../../models/invoice.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:io' as android;
import 'package:permission_handler/permission_handler.dart';
import '../../../../services/firebase.service.dart';
import '../../../widgets/components/raised_gradient_button.dart';
import '../views/components/add_item_dialogBox.dart';
import '../views/components/dialog_popup.dart';
import 'package:image_picker/image_picker.dart';

class BillingController extends GetxController {
  //TODO: Implement BillingController
  List<Product> products = [];
  bool? addedfromDB;
  final RxBool isloading = false.obs;
  final count = 0.obs;
  RxInt activeUserCount = 0.obs;
  RxInt inActiveUserCount = 0.obs;
  RxInt requestedUser = 0.obs;
  String? Dataseturl;
  var url;
  late StateSetter sete;
  var category1;
  late String tags2;
  late String category2;

  List<InvoiceItem> saman = [
    InvoiceItem(
      description: 'Thanks for shopping',
      quantity: 0,
      MRP: 0.00,
      OurPrice: 0.00,
    ),
  ];
  final List<Map<String, dynamic>> snapshots = [];
  TextEditingController contact = TextEditingController();

  TextEditingController newProductName = TextEditingController();
  TextEditingController newMRP = TextEditingController();
  TextEditingController newSP = TextEditingController();
  String? _barcode;
  dynamic mrptotal = 0;
  dynamic total = 0;
  late bool visible;
  void clearText() {
    contact.clear();
  }

  String? scanBarcode;
  ScrollController controller = ScrollController();
  Map? data;
  @override
  void onInit() {
    super.onInit();
    if (addedfromDB == true) {
      mrptotal = products != null
          ? products
              .map((product) => product.mrp)
              .toList()
              .reduce((value, element) => value + element)
          : 0;
      total = products != null
          ? products
              .map((product) => product.price)
              .toList()
              .reduce((value, element) => value! + element!)
          : 0;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    scanBarcode = barcodeScanRes;
    Fetcher(barcodeScanRes);
  }

  Future<void> Fetcher(String text) async {
    var stream = FirebaseFirestore.instance.collection("Products1");
    QuerySnapshot querySnapshot = await stream.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    var length = querySnapshot.docs.length;
    print(length);
    print(allData);

    print("Now callng individual dataset");
    FirebaseFirestore.instance
        .collection("Products")
        .doc(text)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        Map<String, dynamic> data1 =
            documentSnapshot.data() as Map<String, dynamic>;
        var index = -1;
        var present = false;
        for (var i = 0; i < products.length; i++) {
          // you may have to check the equality operator
          if (data1["barcode"] == products[i].barcode) {
            present = true;
            index = i;
            break;
          }
        }
        if (index >= 0) {
          products[index].count = products[index].count + 1;
          saman[index + 1].quantity = saman[index + 1].quantity + 1;
          mrptotal = mrptotal + products[index].mrp;
          total = total + products[index].price;
        } else {
          snapshots.add(data1);
          products.add(Product(
              barcode: data1["barcode"],
              image: data1["image"],
              name: data1["name"],
              mrp: data1["mrp"],
              price: data1["selling"],
              quantity: "quantity",
              count: 1,
              description: data1["description"],
              category: data1["category"][0]));
          saman.add(
            InvoiceItem(
              description: data1["name"],
              quantity: 1,
              MRP: data1["mrp"],
              OurPrice: data1["selling"],
            ),
          );
          mrptotal = mrptotal + data1["mrp"];
          total = total + data1["selling"];
        }
      } else {
        print('Document does not exist on the database');
        Fluttertoast.showToast(msg: 'Document does not exist on the database');
        addNewItemToDatabase(text);
      }
    });
  }

  void addNewItemToDatabase(String barcode, BuildContext context) {
    showDialog(
        context: context,
        builder: (
          context,
        ) {
          addItemDialog(context, barcode: barcode);
        });
  }

  Future<void> addToDatabase(
    String barcode,
    String PName,
    double m,
    String mrp1,
    double sp,
    String selling,
  ) async {
    products.add(Product(
        barcode: barcode,
        image:
            'https://thumbs.dreamstime.com/b/new-item-sticker-label-editable-vector-illustration-isolated-white-background-new-item-sticker-123424483.jpg',
        name: PName,
        mrp: m,
        price: sp,
        quantity: "quantity",
        count: '1',
        description: "description",
        category: "category"));
    saman.add(
      InvoiceItem(
        description: PName,
        quantity: 1,
        MRP: m,
        OurPrice: sp,
      ),
    );

    total = total + sp;
    mrptotal = mrptotal + m;
    Dataseturl == null
        ? InsertDatainFirebase().upload(
            barcode,
            PName,
            PName,
            mrp1,
            selling,
            'quantity',
            selling,
            'https://thumbs.dreamstime.com/b/new-item-sticker-label-editable-vector-illustration-isolated-white-background-new-item-sticker-123424483.jpg',
            category1)
        : InsertDatainFirebase().upload(barcode, PName, PName, mrp1, selling,
            'quantity', selling, Dataseturl, category1);
  }

  Future<void> ImagePickerFromCamera() async {
    final picker = ImagePicker();
    var fb = FirebaseStorage.instance;
    XFile? dfile;

    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      dfile = (await picker.pickImage(
          source: ImageSource.camera, imageQuality: 70));
      if (dfile != null) {
        final filePath = '${DateTime.now()}.png';
        var file = android.File(dfile.path);

        var upl = fb.ref().child("shops/$filePath").putFile(file).then((value) {
          return value;
        });
        String downloadurl = await (await upl).ref.getDownloadURL();
        url = file;
        Dataseturl = downloadurl;
        Fluttertoast.showToast(msg: 'Image Uploade Sucessfully');
        setState(() {});
      } else {
        print('No image Selected');
      }
    } else {
      print('Permission not Provided');
    }
  }

  Future<void> ImagePickerFromGalleryWeb() async {
    final picker = ImagePicker();
    var fb = FirebaseStorage.instance;
    XFile? dfile;
    final filePath = '${DateTime.now()}.png';
    var file;
    FilePickerResult? result;
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);
    } catch (e) {
      print(e);
    }
    if (result != null) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;
        String filename = result.files.single.name;
        var upl = fb.ref().child("shops/$filePath").putData(uploadFile!);
        String downloadurl = await (await upl).ref.getDownloadURL();
        print(downloadurl);
        url = downloadurl;
        Dataseturl = downloadurl;

        Fluttertoast.showToast(msg: 'Image Uploade Sucessfully');
      } catch (e) {
        print(e);
      }
    } else {
      // TODO: show "file not selected" snack bar
    }
  }

  Future<void> ImagePickerFromGallery() async {
    final picker = ImagePicker();
    var fb = FirebaseStorage.instance;
    XFile? dfile;
    final filePath = '${DateTime.now()}.png';
    var file;

    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      dfile = (await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70));
      if (dfile != null) {
        file = android.File(dfile.path);
        var upl = fb.ref().child("shops/$filePath").putFile(file).then((value) {
          return value;
        });
        String downloadurl = await (await upl).ref.getDownloadURL();

        url = downloadurl;
        Dataseturl = downloadurl;

        Fluttertoast.showToast(msg: 'Image Uploade Sucessfully');
      } else {
        print('No image Selected');
      }
    } else {
      print('Permission not Provided');
    }
  }
}
