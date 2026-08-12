import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const _staffFunctionsBase =
    'https://us-central1-ecommerce-26b18.cloudfunctions.net';

class StaffApiException implements Exception {
  final String message;
  StaffApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the `setStaffRole` callable Cloud Function, using the
/// same raw-HTTPS-with-ID-token pattern as lib/loyalty/club_card_api.dart
/// and lib/whatsappApi/wa.dart (this app doesn't use the cloud_functions
/// plugin).
class StaffApi {
  static Future<Map<String, dynamic>> setStaffRole({
    required String email,
    required String role, // 'superadmin' | 'employee' | 'none'
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.post(
      Uri.parse('$_staffFunctionsBase/setStaffRole'),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'data': {'email': email, 'role': role},
      }),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || decoded['error'] != null) {
      throw StaffApiException(
        decoded['error']?['message']?.toString() ??
            'Failed to update staff access.',
      );
    }
    return (decoded['result'] as Map<String, dynamic>?) ?? {};
  }
}
