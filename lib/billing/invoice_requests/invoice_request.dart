import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/product_data.dart';

/// A bill an employee has built on Start Billing but can't finalize
/// themselves - see lib/utils/admin_check.dart's UserRole.employee. A super
/// admin reviews it on the Invoice Requests screen and either approves it
/// (which runs the normal Bill/Checkout flow to actually create the
/// invoice) or rejects it.
class InvoiceRequest {
  final String id;
  final String requestedByUid;
  final String requestedByName;
  final String requestedByEmail;
  final List<ProductData> products;
  final double mrptotal;
  final double total;
  final String customerPhone;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime? createdAt;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? approvedOrderId;

  InvoiceRequest({
    required this.id,
    required this.requestedByUid,
    required this.requestedByName,
    required this.requestedByEmail,
    required this.products,
    required this.mrptotal,
    required this.total,
    required this.customerPhone,
    required this.status,
    this.createdAt,
    this.reviewedByName,
    this.reviewedAt,
    this.rejectionReason,
    this.approvedOrderId,
  });

  factory InvoiceRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final productMaps = (data['products'] as List?) ?? [];
    return InvoiceRequest(
      id: doc.id,
      requestedByUid: (data['requestedByUid'] ?? '').toString(),
      requestedByName: (data['requestedByName'] ?? '').toString(),
      requestedByEmail: (data['requestedByEmail'] ?? '').toString(),
      products: productMaps.map((raw) {
        final p = Map<String, dynamic>.from(raw as Map);
        return ProductData(
          barcode: (p['barcode'] ?? '').toString(),
          image: (p['image'] ?? '').toString(),
          name: (p['name'] ?? '').toString(),
          mrp: (p['mrp'] as num?)?.toDouble() ?? 0,
          price: (p['price'] as num?)?.toDouble() ?? 0,
          quantity: 'quantity',
          count: (p['count'] as num?)?.toInt() ?? 1,
          description: (p['description'] ?? '').toString(),
          category: (p['category'] ?? '').toString(),
        );
      }).toList(),
      mrptotal: (data['mrptotal'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      customerPhone: (data['customerPhone'] ?? '').toString(),
      status: (data['status'] ?? 'pending').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      reviewedByName: data['reviewedByName']?.toString(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason']?.toString(),
      approvedOrderId: data['approvedOrderId']?.toString(),
    );
  }

  int get itemCount => products.fold(0, (total, p) => total + p.count);
}
