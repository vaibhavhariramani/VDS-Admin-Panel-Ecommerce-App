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

  double get price {
    return _price!;
  }

  set price(double value) {
    _price = value;
  }

  String get name {
    return _name!;
  }

  set name(String value) {
    _name = value;
  }

  DateTime? get available_from {
    return _available_from;
  }

  bool get is_published {
    return true;
  }

  double get mrp {
    return _mrp!;
  }

  set mrp(double value) {
    _mrp = value;
  }

  int get count {
    return _count!;
  }

  get image {
    return _image;
  }

  get description {
    return _description;
  }

  get category {
    return _category;
  }

  set count(int value) {
    _count = value;
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
    
    print("Converted snapshot data into Map");
    print(data);
    // Product tempProduct = emptyProduct();
    // Safely parse barcode as string
    String barcode = data['barcode']?.toString() ?? '';

    // Safely parse quantity as string (used for the 'quantity' field)
    String quantity = data['quantity']?.toString() ?? '0';

    // Safely parse count as int (used for the 'count' field)
    int count = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

    // Safely parse price and mrp as doubles
    double price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
    double mrp = (data['mrp'] is num) ? (data['mrp'] as num).toDouble() : 0.0;

    // Parse optional fields with null safety
    String? shopId = data['shop_id']?.toString();
    String? description = data['description']?.toString();
    String category = data['category']?.toString() ?? '';
    String? image = data['image']?.toString();
    String? name = data['name']?.toString();

    try {
    Product tempProduct = Product(
      price: price,
      mrp: mrp,
      barcode: barcode,
      shop_id: shopId,
      description: description,
      category: category,
      quantity: quantity,
      count: count,
      image: image,
      name: name,
      id: barcode, // or use a dedicated 'id' field if available
    );
    print("Product detail added: ${tempProduct.barcode}");
    return tempProduct;
  } catch (e, stackTrace) {
    print('Error parsing product data: $e\n$stackTrace');
    rethrow;
    }
    
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
