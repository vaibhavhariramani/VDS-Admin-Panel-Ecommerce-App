import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The two kinds of staff account this panel recognizes.
///
/// - [superAdmin]: full access, gated by the `admin: true` custom claim
///   (same claim the Firestore rules' `isAdmin()` checks).
/// - [employee]: gated by the `staff: true` custom claim. Can sign in and
///   use Start Billing, but billing submits an approval request instead of
///   finalizing an invoice directly - see lib/billing/invoice_requests.
/// - [none]: not authorized to use this panel at all.
enum UserRole { superAdmin, employee, none }

/// Resolves [user]'s role from their Firebase Auth ID token claims, falling
/// back to the legacy `Admins/{uid}.isAdmin` Firestore document (super admin
/// only) for any account that hasn't been migrated to a custom claim yet.
Future<UserRole> resolveUserRole(User user) async {
  try {
    final tokenResult = await user.getIdTokenResult(true);
    if (tokenResult.claims?['admin'] == true) {
      return UserRole.superAdmin;
    }
    if (tokenResult.claims?['staff'] == true) {
      return UserRole.employee;
    }
  } catch (_) {
    // Fall through to the legacy check.
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('Admins')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['isAdmin'] ?? false) == true) {
        return UserRole.superAdmin;
      }
    }
  } catch (_) {
    // No access to the legacy doc (e.g. rules no longer allow it) - not an
    // admin as far as this app can tell.
  }
  return UserRole.none;
}

/// Whether [user] is authorized to use the admin panel at all (either role).
Future<bool> isAdminUser(User user) async {
  final role = await resolveUserRole(user);
  return role != UserRole.none;
}
