import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'admin_check.dart';

/// Holds the signed-in user's resolved [UserRole] for the lifetime of the
/// app session. Populated once at login (see lib/home/loginpage.dart,
/// lib/widgets/google_sign_in_button.dart, lib/utils/authentication.dart)
/// since custom claims only change on token refresh, not mid-session.
class RoleController {
  RoleController._();

  static final ValueNotifier<UserRole> role =
      ValueNotifier<UserRole>(UserRole.none);

  static Future<void> refresh(User user) async {
    role.value = await resolveUserRole(user);
  }

  static bool get isSuperAdmin => role.value == UserRole.superAdmin;
  static bool get isEmployee => role.value == UserRole.employee;
}
