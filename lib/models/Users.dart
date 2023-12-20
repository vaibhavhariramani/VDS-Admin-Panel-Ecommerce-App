import 'UserType.dart';

class Users {
  String? id;
  String? _fullname;
  String? _img_token;
  String? _phn_number;
  String? _gmail_id;
  String? _fb_id;
  String? _applie_id;
  String? _email;
  String? _phonepinID;
  UserType? _user_type;
  String? _current_language;
  double? _current_lat;
  bool? _isUserSecure;
  double? _radiusPreference;
  String? _saved_location;
  double? _current_lon;
  String? _managed_by;

  get current_lon => null;

  @override
  String? getId() {
    return id;
  }

  String? get fullname {
    return _fullname;
  }

  String? get img_token {
    return _img_token;
  }

  String? get phn_number {
    return _phn_number;
  }

  String? get gmail_id {
    return _gmail_id;
  }

  String? get fb_id {
    return _fb_id;
  }

  String? get applie_id {
    return _applie_id;
  }

  String? get email {
    return _email;
  }

  String? get phonepinID {
    return _phonepinID;
  }

  UserType? get user_type {
    return _user_type;
  }

  double? get current_lat {
    return _current_lat;
  }

  Users._internal(
      {required this.id,
      fullname,
      img_token,
      phn_number,
      gmail_id,
      fb_id,
      applie_id,
      email,
      phonepinID,
      user_type,
      current_language,
      current_lat,
      isUserSecure,
      radiusPreference,
      saved_location,
      current_lon,
      managed_by})
      : _fullname = fullname,
        _img_token = img_token,
        _phn_number = phn_number,
        _gmail_id = gmail_id,
        _fb_id = fb_id,
        _applie_id = applie_id,
        _email = email,
        _phonepinID = phonepinID,
        _user_type = user_type,
        _current_language = current_language,
        _current_lat = current_lat,
        _isUserSecure = isUserSecure,
        _radiusPreference = radiusPreference,
        _saved_location = saved_location,
        _current_lon = current_lon,
        _managed_by = managed_by;
  factory Users(
      {String? id,
      String? fullname,
      String? img_token,
      String? phn_number,
      String? gmail_id,
      String? fb_id,
      String? applie_id,
      String? email,
      String? phonepinID,
      UserType? user_type,
      String? current_language,
      double? current_lat,
      bool? isUserSecure,
      double? radiusPreference,
      String? saved_location,
      double? current_lon,
      String? managed_by}) {
    return Users._internal(
      id: id,
      fullname: fullname,
      img_token: img_token,
      phn_number: phn_number,
      gmail_id: gmail_id,
      fb_id: fb_id,
      applie_id: applie_id,
      email: email,
      user_type: user_type,
      current_language: current_language,
      current_lat: current_lat,
      isUserSecure: isUserSecure,
      radiusPreference: radiusPreference,
      saved_location: saved_location,
      current_lon: current_lon,
      managed_by: managed_by,
    );
  }

  static Users? fromJson(versionResopnseMap) {}
}
