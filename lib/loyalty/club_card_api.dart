import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const _clubFunctionsBase =
    'https://us-central1-ecommerce-26b18.cloudfunctions.net';

/// A loyalty card's printed/QR value *is* its Firestore document id under
/// `ClubCards/{cardId}`, formatted like `VDS000000000000` (see
/// CLUBCARD_INTEGRATION.md). Product barcodes never use this prefix, so this
/// is enough to tell a scanned loyalty card apart from a scanned product.
final RegExp _clubCardIdPattern = RegExp(r'^VDS\d+$');

bool isClubCardId(String code) => _clubCardIdPattern.hasMatch(code);

class ClubCardException implements Exception {
  final String message;
  ClubCardException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the `awardPoints` / `redeemVoucherAtStore` callable
/// Cloud Functions backing the loyalty program. This app doesn't use the
/// `cloud_functions` plugin (see lib/whatsappApi/wa.dart, which hit the same
/// issue calling `sendWhatsAppBill`), so callable functions are invoked over
/// raw HTTPS instead, wrapping the payload in the `{"data": ...}` envelope
/// the callable protocol expects and reading `result`/`error` back out of
/// the JSON response the same way the real plugin would.
class ClubCardApi {
  static Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.post(
      Uri.parse('$_clubFunctionsBase/$functionName'),
      headers: {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'data': data}),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || decoded['error'] != null) {
      throw ClubCardException(
        decoded['error']?['message']?.toString() ??
            'Loyalty card request failed.',
      );
    }
    return (decoded['result'] as Map<String, dynamic>?) ?? {};
  }

  /// Awards points to [cardId] for one purchase of [amount] rupees.
  /// [referenceId] must stay the same across retries of the *same*
  /// purchase - the backend treats a repeated referenceId as a safe no-op
  /// rather than a double-award, so don't generate a fresh one on retry.
  static Future<Map<String, dynamic>> awardPoints({
    required String cardId,
    required int amount,
    required String referenceId,
  }) {
    return _call('awardPoints', {
      'cardId': cardId,
      'amount': amount,
      'referenceId': referenceId,
    });
  }

  static Future<Map<String, dynamic>> redeemVoucherAtStore({
    required String cardId,
    required String voucherId,
  }) {
    return _call('redeemVoucherAtStore', {
      'cardId': cardId,
      'voucherId': voucherId,
    });
  }
}
