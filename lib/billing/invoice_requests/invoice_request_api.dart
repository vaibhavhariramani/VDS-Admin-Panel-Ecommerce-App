import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_data.dart';

class InvoiceRequestApi {
  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('InvoiceRequests');

  /// Submitted by an employee from Start Billing instead of finalizing the
  /// bill directly - see the role branch in lib/billing/bill.dart's
  /// Checkout dialog.
  static Future<void> submit({
    required User user,
    required List<ProductData> products,
    required double mrptotal,
    required double total,
    required String customerPhone,
  }) {
    return _collection.add({
      'requestedByUid': user.uid,
      'requestedByName': user.displayName ?? user.email ?? 'Employee',
      'requestedByEmail': user.email ?? '',
      'products': products
          .map((p) => {
                'barcode': p.barcode,
                'image': p.image,
                'name': p.name,
                'mrp': p.mrp,
                'price': p.price,
                'count': p.count,
                'description': p.description,
                'category': p.category,
              })
          .toList(),
      'mrptotal': mrptotal,
      'total': total,
      'customerPhone': customerPhone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// All requests, newest first - the super admin review queue.
  static Stream<QuerySnapshot<Map<String, dynamic>>> allRequests() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  /// One employee's own submitted requests - "My Requests". Sorted
  /// client-side (see invoice_requests_screen.dart) rather than via
  /// `.orderBy` here, since combining that with the `where` below would
  /// need a composite Firestore index that doesn't exist yet.
  static Stream<QuerySnapshot<Map<String, dynamic>>> myRequests(String uid) {
    return _collection.where('requestedByUid', isEqualTo: uid).snapshots();
  }

  static Future<void> reject({
    required String requestId,
    required User reviewer,
    String? reason,
  }) {
    return _collection.doc(requestId).update({
      'status': 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedByName': reviewer.displayName ?? reviewer.email ?? 'Admin',
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason ?? '',
    });
  }

  /// Called once the reviewing super admin actually finishes checkout for
  /// this request in the Bill screen (see Bill's `reviewingRequestId`).
  static Future<void> markApproved({
    required String requestId,
    required User reviewer,
    required String approvedOrderId,
  }) {
    return _collection.doc(requestId).update({
      'status': 'approved',
      'reviewedBy': reviewer.uid,
      'reviewedByName': reviewer.displayName ?? reviewer.email ?? 'Admin',
      'reviewedAt': FieldValue.serverTimestamp(),
      'approvedOrderId': approvedOrderId,
    });
  }
}
