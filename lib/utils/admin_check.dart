import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Whether [user] is authorized to use the admin panel.
///
/// Source of truth is the `admin: true` custom claim on the Firebase Auth
/// token (matches the Firestore security rules' `isAdmin()` check). Falls
/// back to the legacy `Admins/{uid}.isAdmin` Firestore document for any
/// account that hasn't been migrated to a custom claim yet.
Future<bool> isAdminUser(User user) async {
  try {
    final tokenResult = await user.getIdTokenResult(true);
    if (tokenResult.claims?['admin'] == true) {
      return true;
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
      return data['isAdmin'] ?? false;
    }
  } catch (_) {
    // No access to the legacy doc (e.g. rules no longer allow it) - not an
    // admin as far as this app can tell.
  }
  return false;
}
