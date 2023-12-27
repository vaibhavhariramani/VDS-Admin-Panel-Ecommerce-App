import 'InvitedUserStatus.dart';
import 'UserType.dart';

class InvitedUser {
  final String id;
  final String? _fullname;
  final String? _img_token;
  final String? _phn_number;
  final String? _gmail_id;
  final String? _fb_id;
  final String? _apple_id;
  final String? _email;
  final String? _current_language;
  final double? _current_lat;
  final double? _current_lon;
  final String? _saved_location;
  final double? _radiusPrefernce;
  final String? _deleted_parent;
  final UserType? _user_type;
  final bool? _isUserSecure;
  final String? _usersID;
  final InvitedUserStatus? _status;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;

  @override
  String getId() {
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

  String? get apple_id {
    return _apple_id;
  }

  String? get email {
    return _email;
  }

  String? get current_language {
    return _current_language;
  }

  double? get current_lat {
    return _current_lat;
  }

  double? get current_lon {
    return _current_lon;
  }

  String? get saved_location {
    return _saved_location;
  }

  double? get radiusPrefernce {
    return _radiusPrefernce;
  }

  String? get deleted_parent {
    return _deleted_parent;
  }

  UserType? get user_type {
    return _user_type;
  }

  bool? get isUserSecure {
    return _isUserSecure;
  }

  String get usersID {
    try {
      return _usersID!;
    } catch (e) {
      throw e;
    }
  }

  InvitedUserStatus? get status {
    return _status;
  }

  DateTime? get createdAt {
    return _createdAt;
  }

  DateTime? get updatedAt {
    return _updatedAt;
  }

  const InvitedUser._internal(
      {required this.id,
      fullname,
      img_token,
      phn_number,
      gmail_id,
      fb_id,
      apple_id,
      email,
      current_language,
      current_lat,
      current_lon,
      saved_location,
      radiusPrefernce,
      deleted_parent,
      user_type,
      isUserSecure,
      required usersID,
      status,
      createdAt,
      updatedAt})
      : _fullname = fullname,
        _img_token = img_token,
        _phn_number = phn_number,
        _gmail_id = gmail_id,
        _fb_id = fb_id,
        _apple_id = apple_id,
        _email = email,
        _current_language = current_language,
        _current_lat = current_lat,
        _current_lon = current_lon,
        _saved_location = saved_location,
        _radiusPrefernce = radiusPrefernce,
        _deleted_parent = deleted_parent,
        _user_type = user_type,
        _isUserSecure = isUserSecure,
        _usersID = usersID,
        _status = status,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory InvitedUser(
      {String? id,
      String? fullname,
      String? img_token,
      String? phn_number,
      String? gmail_id,
      String? fb_id,
      String? apple_id,
      String? email,
      String? current_language,
      double? current_lat,
      double? current_lon,
      String? saved_location,
      double? radiusPrefernce,
      String? deleted_parent,
      UserType? user_type,
      bool? isUserSecure,
      required String usersID,
      InvitedUserStatus? status}) {
    return InvitedUser._internal(
        id: id == null ? "1" : id,
        fullname: fullname,
        img_token: img_token,
        phn_number: phn_number,
        gmail_id: gmail_id,
        fb_id: fb_id,
        apple_id: apple_id,
        email: email,
        current_language: current_language,
        current_lat: current_lat,
        current_lon: current_lon,
        saved_location: saved_location,
        radiusPrefernce: radiusPrefernce,
        deleted_parent: deleted_parent,
        user_type: user_type,
        isUserSecure: isUserSecure,
        usersID: usersID,
        status: status);
  }

  bool equals(Object other) {
    return this == other;
  }
}
