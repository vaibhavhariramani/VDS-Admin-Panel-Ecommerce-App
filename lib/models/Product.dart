import 'package:vdsadmin/models/ProductDealType.dart';

class Product {
  String? id;
  String? _barcode;
  String? _image;
  String? _name;
  double? _mrp;
  double? _price;
  double? _discount;
  String? _quantity;
  int? _count;
  String? _description;
  String? _category;
  String? _currency_type;
  String? _img_token;
  String? _shop_id;
  ProductDealType? _deal_type;
  DateTime? _expires_on;
  DateTime? _available_from;

  Product({
    this.id,
    String? barcode,
    String? image,
    String? name,
    double? mrp,
    double? price,
    double? discount,
    String? quantity,
    int? count,
    String? description,
    String? category,
    String? currency_type,
    String? img_token,
    String? shop_id,
    ProductDealType? deal_type,
    DateTime? expires_on,
    DateTime? available_from,
  }) {
    _barcode = barcode;
    _image = image;
    _name = name;
    _mrp = mrp;
    _price = price;
    _discount = discount;
    _quantity = quantity;
    _count = count;
    _description = description;
    _category = category;
    _currency_type = currency_type;
    _img_token = img_token;
    _deal_type = deal_type;
    _expires_on = expires_on;
    _available_from = available_from;
    _shop_id = shop_id;
  }

  double? get price {
    return _price;
  }

  String? get name {
    return _name;
  }

  DateTime? get available_from {
    return _available_from;
  }

  bool get is_published {
    return true;
  }

  get mrp {
    return _mrp;
  }

  get count {
    return _count;
  }

  @override
  String? getId() {
    return id;
  }

  String? get barcode {
    return _barcode;
  }

  ProductDealType? get deal_type {
    return _deal_type;
  }

  DateTime? get expires_on {
    return _expires_on;
  }

  String? get img_token {
    return _img_token;
  }

  String? get currency_type {
    return _currency_type;
  }

  double? get discount {
    return _discount;
  }

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
      shop_id: '',
    );
  }

  static Product fromJson(Map<String, dynamic> data) {
    Product tempProduct = emptyProduct();
    print("Converted snapshot data into Map");
    print(data);
    String barcode1 =
        data['barcode'] is int ? data['barcode'].toString() : data['barcode'];
    String quantity1 =
        data['quantity'] is int ? data['quantity'].toString() : data['barcode'];

    try {
      tempProduct = Product(
          price: data['price'],
          mrp: data['mrp'],
          barcode: barcode1,
          shop_id: data['shop_id'],
          description: data['description'],
          category: 'category',
          quantity: quantity1,
          count: data['quantity'],
          image: data['image'],
          name: data['name'],
          id: data['barcode'].toString());
      print("Product detail added: ${tempProduct.barcode}");
    } catch (e, stackTrace) {
      print('Error parsing product data: $e\n$stackTrace');
      // Handle the error or rethrow if necessary
      rethrow;
    }
    return tempProduct;
  }

  static Product emptyProduct() {
    return Product(
        barcode: '',
        category: '',
        count: 0,
        description: '',
        image: '',
        mrp: 0,
        name: '',
        price: 0,
        quantity: '0',
        id: '');
  }
}
