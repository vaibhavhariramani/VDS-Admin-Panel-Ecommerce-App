import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'attendance_record.dart';

class AttendanceApi {
  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('Attendance');

  static Future<void> clockIn(User user) {
    return _collection.add({
      'employeeUid': user.uid,
      'employeeName': user.displayName ?? user.email ?? 'Employee',
      'employeeEmail': user.email ?? '',
      'clockIn': FieldValue.serverTimestamp(),
      'clockOut': null,
      'hoursWorked': null,
      'status': 'open',
    });
  }

  /// [openRecord] must be the caller's own record with status 'open' -
  /// hours are computed from its already-loaded clockIn time rather than
  /// re-reading the doc.
  static Future<void> clockOut(AttendanceRecord openRecord) {
    final clockIn = openRecord.clockIn;
    if (clockIn == null) {
      throw StateError('Cannot clock out a record with no clock-in time.');
    }
    final now = DateTime.now();
    final hours = now.difference(clockIn).inSeconds / 3600.0;
    return _collection.doc(openRecord.id).update({
      'clockOut': FieldValue.serverTimestamp(),
      'hoursWorked': double.parse(hours.toStringAsFixed(2)),
      'status': 'pending',
    });
  }

  static Future<void> approve({
    required String recordId,
    required User reviewer,
  }) {
    return _collection.doc(recordId).update({
      'status': 'approved',
      'reviewedBy': reviewer.uid,
      'reviewedByName': reviewer.displayName ?? reviewer.email ?? 'Admin',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> reject({
    required String recordId,
    required User reviewer,
    String? reason,
  }) {
    return _collection.doc(recordId).update({
      'status': 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedByName': reviewer.displayName ?? reviewer.email ?? 'Admin',
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason ?? '',
    });
  }

  /// One employee's own shifts (open + history). Sorted client-side (see
  /// attendance_screen.dart) to avoid needing a composite index for
  /// `where` + `orderBy` on different fields.
  static Stream<QuerySnapshot<Map<String, dynamic>>> myRecords(String uid) {
    return _collection.where('employeeUid', isEqualTo: uid).snapshots();
  }

  /// Every shift, across all employees - the super admin view.
  static Stream<QuerySnapshot<Map<String, dynamic>>> allRecords() {
    return _collection.orderBy('clockIn', descending: true).snapshots();
  }
}
