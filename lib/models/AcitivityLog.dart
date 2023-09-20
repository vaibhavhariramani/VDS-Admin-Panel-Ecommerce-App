class ActivityLog {
  String? id;
  DateTime? _datetime;
  String? _actio;
  String? _usersID;
  String? _brief_discription;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  @override
  String? getId() {
    return id;
  }

  DateTime? get datetime {
    return _datetime;
  }

  String? get actio {
    return _actio;
  }

  String get usersID {
    try {
      return _usersID!;
    } catch (e) {
      throw Exception(
          // ExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          // recoverySuggestion:
          //   amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          // underlyingException: e.toString()
          );
    }
  }

  String? get brief_discription {
    return _brief_discription;
  }

  DateTime? get createdAt {
    return _createdAt;
  }

  DateTime? get updatedAt {
    return _updatedAt;
  }

  static ActivityLog fromJson(item) {
    return ActivityLog();
  }
}
