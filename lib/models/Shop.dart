import 'Product.dart';

class Shop {
  String? id;
  String? _name;
  String? _phn_number;
  List<String>? _img_token;
  DateTime? _opening_time;
  DateTime? _closing_time;
  String? _about;
  String? _phonepinID;
  String? _usersID;
  String? _shopcategoryID;
  List<Product>? _ProductsShop;
  // List<UserShopReview>? _UserShopReviews;
  double? _lon;
  double? _lat;
  String? _phy_address;
  // List<UserShopFavourite>? _UserShopFavourites;
  String? _url;
  double? _rating;
  String? _manager;
  DateTime? _license_renewed_on;
  DateTime? _license_expiry_date;
  String? _currency_type;
  DateTime? _created_on;
  bool? _is_deleted;
  bool? _is_active;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  @override
  String? getId() {
    return id;
  }

  String? get name {
    return _name;
  }

  String? get phn_number {
    return _phn_number;
  }

  List<String>? get img_token {
    return _img_token;
  }

  DateTime? get opening_time {
    return _opening_time;
  }

  DateTime? get closing_time {
    return _closing_time;
  }

  String? get about {
    return _about;
  }

  String? get phonepinID {
    return _phonepinID;
  }

  String? get usersID {
    return _usersID;
  }

  String? get shopcategoryID {
    return _shopcategoryID;
  }

  List<Product>? get ProductsShop {
    return _ProductsShop;
  }

  // List<UserShopReview>? get UserShopReviews {
  //   return _UserShopReviews;
  // }

  double? get lon {
    return _lon;
  }

  double? get lat {
    return _lat;
  }

  String? get phy_address {
    return _phy_address;
  }

  String? get url {
    return _url;
  }

  double? get rating {
    return _rating;
  }

  String? get manager {
    return _manager;
  }

  //fetching Shop Details index wise
  static Shop IndexData(i) {
    //code to iterator Product index wise
    return Shop();
  }

  static Shop? fromJson(item) {}
}
