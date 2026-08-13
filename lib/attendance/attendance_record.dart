import 'package:cloud_firestore/cloud_firestore.dart';

/// One clock-in/clock-out shift.
///
/// Lifecycle: 'open' (clocked in, no clock-out yet) -> 'pending' (clocked
/// out, awaiting a super admin) -> 'approved' | 'rejected'.
class AttendanceRecord {
  final String id;
  final String employeeUid;
  final String employeeName;
  final String employeeEmail;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final double? hoursWorked;
  final String status;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  AttendanceRecord({
    required this.id,
    required this.employeeUid,
    required this.employeeName,
    required this.employeeEmail,
    required this.clockIn,
    required this.clockOut,
    required this.hoursWorked,
    required this.status,
    this.reviewedByName,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory AttendanceRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      employeeUid: (data['employeeUid'] ?? '').toString(),
      employeeName: (data['employeeName'] ?? '').toString(),
      employeeEmail: (data['employeeEmail'] ?? '').toString(),
      clockIn: (data['clockIn'] as Timestamp?)?.toDate(),
      clockOut: (data['clockOut'] as Timestamp?)?.toDate(),
      hoursWorked: (data['hoursWorked'] as num?)?.toDouble(),
      status: (data['status'] ?? 'open').toString(),
      reviewedByName: data['reviewedByName']?.toString(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason']?.toString(),
    );
  }
}
