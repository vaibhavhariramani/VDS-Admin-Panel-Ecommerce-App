import 'Product.dart';

class Shop {
  String? id;
  String? _name;
  List<String>? _img_token;
  String? _phn_number;
  DateTime? _opening_time;
  DateTime? _closing_time;
  String? _about;
  String? _phonepinID;
  String? _usersID;
  String? _shopcategoryID;
  List<Product>? _ProductsShop;
  String? _radiusPreference;
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

  Shop._internal(
      {required this.id,
      name,
      img_token,
      phn_number,
      opening_time,
      closing_time,
      about,
      phonepinID,
      usersID,
      shopcategoryID,
      Products,
      lon,
      lat,
      address,
      radiusPreference,
      url,
      saved_location,
      rating,
      manager,
      renewed_on,
      expiry_date,
      currency_type,
      is_active})
      : _name = name,
        _img_token = img_token,
        _phn_number = phn_number,
        _opening_time = opening_time,
        _closing_time = closing_time,
        _about = about,
        _phonepinID = phonepinID,
        _usersID = usersID,
        _shopcategoryID = shopcategoryID,
        _ProductsShop = Products,
        _lon = lon,
        _lat = lat,
        _phy_address = address,
        _radiusPreference = radiusPreference,
        _url = url,
        _rating = rating,
        _manager = manager,
        _license_renewed_on = renewed_on,
        _license_expiry_date = expiry_date,
        _currency_type = currency_type,
        _is_active = is_active;
  factory Shop(
      {String? id,
      String? name,
      String? img_token,
      String? phn_number,
      String? opening_time,
      String? closing_time,
      String? about,
      String? phonepinID,
      String? usersID,
      String? shopcategoryID,
      List<Product>? Products,
      double? current_lon,
      double? current_lat,
      String? address,
      double? radiusPreference,
      String? url,
      String? saved_location,
      String? rating,
      String? managed_by,
      String? renewed_on,
      String? expiry_date,
      String? currency_type,
      String? is_active}) {
    return Shop._internal(
        id: id,
        name: name,
        img_token: img_token,
        phn_number: phn_number,
        opening_time: opening_time,
        closing_time: closing_time,
        phonepinID: phonepinID,
        usersID: usersID,
        shopcategoryID: shopcategoryID,
        Products: Products,
        lon: current_lon,
        lat: current_lat,
        address: address,
        radiusPreference: radiusPreference,
        url: url,
        saved_location: saved_location,
        rating: rating,
        manager: managed_by,
        renewed_on: renewed_on,
        expiry_date: expiry_date,
        currency_type: currency_type,
        is_active: is_active);
  }

  //fetching Shop Details index wise
  static Shop IndexData(i) {
    //code to iterator Product index wise
    return Shop();
  }

  static Shop? fromJson(item) {}
}
