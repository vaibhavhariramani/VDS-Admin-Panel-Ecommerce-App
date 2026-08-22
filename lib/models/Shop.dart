import 'Product.dart';

class Shop {
  String? id;
  String? _name;

  /// The shop's single logo image. Sourced from Firestore's `imgToken`
  /// field, which has only ever stored one URL — this used to be typed
  /// `List<String>?` while every call site indexed it as `img_token![0]`,
  /// which meant `Shop.fromJson` threw the moment a shop actually had a
  /// logo set (assigning the String from `imgToken` to a `List<String>?`
  /// field is a runtime type error), silently "working" only because no
  /// shop had the field populated yet.
  String? _img_token;

  /// Extra promotional images shown in the client app's shop header/carousel.
  List<String>? _bannerUrls;

  /// Hex color string (e.g. `#2E7D32`) the client app themes this shop's
  /// storefront with.
  String? _brandColor;

  /// URL-safe, platform-wide-unique slug (e.g. `fashion-hub`) identifying
  /// this shop's public storefront URL. Reserved via the `StoreCodes`
  /// collection so two shops can never collide. `null` until the shop
  /// admin claims one from the Storefront > Store URL screen.
  String? _storeCode;
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

  /// The `Regions` doc this shop belongs to. `Regions` is the canonical
  /// region↔shop edge (a Region's `ShopsList` array is still the source of
  /// truth for *assignment*); this is a denormalized copy for querying and
  /// for Firestore security rules to check without a second lookup.
  /// `null` on any shop that predates this field until backfilled.
  String? _regionId;

  /// Same name-string convention as `Users.Country` / `Regions.Country` —
  /// denormalized from the owning region, not an independent value.
  String? _country;

  @override
  String? getId() {
    return id;
  }

  String? get regionId => _regionId;

  String? get country => _country;

  String? get name {
    return _name;
  }

  String? get phn_number {
    return _phn_number;
  }

  String? get img_token {
    return _img_token;
  }

  List<String>? get bannerUrls {
    return _bannerUrls;
  }

  String? get brandColor {
    return _brandColor;
  }

  String? get storeCode {
    return _storeCode;
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
      bannerUrls,
      brandColor,
      storeCode,
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
      is_active,
      regionId,
      country})
      : _regionId = regionId,
        _country = country,
        _name = name,
        _img_token = img_token,
        _bannerUrls = bannerUrls,
        _brandColor = brandColor,
        _storeCode = storeCode,
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
      List<String>? bannerUrls,
      String? brandColor,
      String? storeCode,
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
      String? is_active,
      String? regionId,
      String? country}) {
    return Shop._internal(
        id: id,
        name: name,
        img_token: img_token,
        bannerUrls: bannerUrls,
        brandColor: brandColor,
        storeCode: storeCode,
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
        is_active: is_active,
        regionId: regionId,
        country: country);
  }

  //fetching Shop Details index wise
  static Shop IndexData(i) {
    //code to iterator Product index wise
    return Shop();
  }

  static Shop? fromJson(Map<String, dynamic>? data, {String? id}) {
    if (data == null) return null;
    return Shop(
      id: id ?? data['id']?.toString(),
      name: data['name']?.toString(),
      img_token: data['imgToken']?.toString(),
      bannerUrls: (data['bannerUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      brandColor: data['brandColor']?.toString(),
      storeCode: data['storeCode']?.toString(),
      phn_number: data['phone_number']?.toString(),
      address: data['address']?.toString(),
      url: data['url']?.toString(),
      managed_by: data['shopAdmin']?.toString(),
      currency_type: data['currencyType']?.toString(),
      is_active: data['isactive']?.toString(),
      regionId: data['regionId']?.toString(),
      country: data['Country']?.toString(),
    );
  }
}
