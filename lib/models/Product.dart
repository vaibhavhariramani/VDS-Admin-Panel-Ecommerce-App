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

  /// Denormalized from the owning shop at creation time (see
  /// `DataService.CreateNewHotProduct` / `CreateService.CreateNewGreenProduct`)
  /// so region/country-scoped product queries and Firestore rules don't
  /// need a join back to `Shops`. `null` on any product created before
  /// this field existed, until backfilled.
  String? _region_id;
  String? _country;
  String? _brand;

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
    String? region_id,
    String? country,
    String? brand,
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
    _region_id = region_id;
    _country = country;
    _brand = brand;
  }

  String? get shop_id => _shop_id;

  String? get region_id => _region_id;

  String? get country => _country;

  String? get brand => _brand;

  /// True if [query] (case-insensitive, substring) matches this product's
  /// name, barcode, category, or brand — the fields search covers on the
  /// Master List / Scheduled / Published product screens.
  bool matchesSearch(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return (_name?.toLowerCase().contains(q) ?? false) ||
        (_barcode?.toLowerCase().contains(q) ?? false) ||
        (_category?.toLowerCase().contains(q) ?? false) ||
        (_brand?.toLowerCase().contains(q) ?? false);
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
    // Safely parse barcode as string
    String barcode = data['barcode']?.toString() ?? '';

    // Safely parse quantity as string (used for the 'quantity' field)
    String quantity = data['quantity']?.toString() ?? '0';

    // Safely parse count as int (used for the 'count' field)
    int count = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

    // Safely parse price, mrp and discount as doubles
    double price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
    double mrp = (data['mrp'] is num) ? (data['mrp'] as num).toDouble() : 0.0;
    double discount = (data['discount'] is num) ? (data['discount'] as num).toDouble() : 0.0;

    // Parse optional fields with null safety
    String? shopId = data['shopId']?.toString() ?? data['shop_id']?.toString();
    String? regionId = data['regionId']?.toString();
    String? country = data['Country']?.toString();
    String? description = data['description']?.toString();
    String? brand = data['brand']?.toString();
    String category = data['category']?.toString() ?? '';
    String? image = data['image']?.toString();
    String? name = data['name']?.toString();
    String? currencyType = data['currencyType']?.toString();

    ProductDealType dealType = ProductDealType.values.firstWhere(
      (e) => e.name == data['dealType']?.toString(),
      orElse: () => ProductDealType.GREENDEALS,
    );

    DateTime? availableFrom = _timestampToDateTime(data['availableFrom']);
    DateTime? expiresOn = _timestampToDateTime(data['expiresOn']);

    try {
      Product tempProduct = Product(
        price: price,
        mrp: mrp,
        discount: discount,
        barcode: barcode,
        shop_id: shopId,
        region_id: regionId,
        country: country,
        brand: brand,
        description: description,
        category: category,
        quantity: quantity,
        count: count,
        image: image,
        img_token: image,
        currency_type: currencyType,
        deal_type: dealType,
        available_from: availableFrom,
        expires_on: expiresOn,
        name: name,
        id: barcode, // or use a dedicated 'id' field if available
      );
      return tempProduct;
    } catch (e, stackTrace) {
      print('Error parsing product data: $e\n$stackTrace');
      rethrow;
    }
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    try {
      // Avoids a hard dependency on cloud_firestore's Timestamp type here;
      // Timestamp exposes toDate() so this works for both Timestamp and DateTime.
      if (value is DateTime) return value;
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
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
