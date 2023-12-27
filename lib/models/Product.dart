import 'package:vdsadmin/models/ProductDealType.dart';

class Product {
  String id;
  String barcode;
  String image;
  String name;
  double mrp;
  double price;
  double discount;
  String quantity;
  int count;
  String description;
  String category;
  DateTime? available_from;
  DateTime? expires_on;

  Product(
      {required this.id,
      required this.barcode,
      required this.image,
      required this.name,
      required this.mrp,
      required this.price,
      required this.discount,
      required this.quantity,
      required this.count,
      required this.description,
      required this.category,
      required DateTime available_from,
      required DateTime expires_on,
      required ProductDealType deal_type,
      required String shopID,
      required String currency_type,
      required sku,
      required img_token});

  get img_token {
    return img_token;
  }

  get deal_type {
    return deal_type;
  }

  get currency_type => null;

  get sku => null;

  get is_published => null;

  get start_date => null;

//fetching product index wise
  static Product IndexData(i) {
    //code to iterator Product index wise
    return Product(
      id: i,
      barcode: '',
      category: '',
      count: 0,
      description: '',
      image: '',
      mrp: 0,
      discount: 1,
      name: '',
      price: 0,
      quantity: '',
      available_from: DateTime.utc(2024),
      currency_type: '',
      deal_type: ProductDealType.HOTDEALS,
      expires_on: DateTime.utc(2024),
      img_token: null,
      shopID: '',
      sku: null,
    );
  }

  static Product fromJson(i) {
    return Product(
      id: i,
      barcode: '',
      category: '',
      count: 0,
      description: '',
      image: '',
      mrp: 0,
      discount: 0,
      name: '',
      price: 0,
      quantity: '',
      available_from: DateTime.utc(2024),
      currency_type: '',
      deal_type: ProductDealType.HOTDEALS,
      expires_on: DateTime.utc(2024),
      img_token: null,
      shopID: '',
      sku: null,
    );
  }
}
