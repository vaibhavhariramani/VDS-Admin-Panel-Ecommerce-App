import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const _notificationFunctionsBase =
    'https://us-central1-ecommerce-26b18.cloudfunctions.net';

class NotificationApiException implements Exception {
  final String message;
  NotificationApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the `sendPushNotification` Cloud Function, using the
/// same raw-HTTPS-with-ID-token pattern as lib/loyalty/club_card_api.dart
/// and lib/staff/staff_api.dart.
class NotificationApi {
  static Future<Map<String, dynamic>> send({
    required String title,
    required String message,
    List<String>? playerIds,
    List<String>? audienceUids,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.post(
      Uri.parse('$_notificationFunctionsBase/sendPushNotification'),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'data': {
          'title': title,
          'message': message,
          if (playerIds != null) 'playerIds': playerIds,
          if (audienceUids != null) 'audienceUids': audienceUids,
        },
      }),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || decoded['error'] != null) {
      throw NotificationApiException(
        decoded['error']?['message']?.toString() ??
            'Failed to send notification.',
      );
    }
    return (decoded['result'] as Map<String, dynamic>?) ?? {};
  }
}
