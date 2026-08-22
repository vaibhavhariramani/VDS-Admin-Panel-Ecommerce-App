import 'package:cloud_firestore/cloud_firestore.dart';

/// A completed POS sale, as written by `BillingController.createBill()` to
/// the `Bills` collection. Distinct from the unused `Invoice`/`InvoiceInfo`
/// models in invoice.dart, which don't match this schema.
class Bill {
  final String id;
  final String? invoiceNumber;
  final String? shopId;
  final String? regionId;
  final String? country;
  final List<Map<String, dynamic>> items;
  final double total;
  final String? customerName;
  final String? customerContact;
  final String? createdBy;
  final String? pdfUrl;
  final DateTime? createdAt;

  Bill({
    required this.id,
    this.invoiceNumber,
    this.shopId,
    this.regionId,
    this.country,
    this.items = const [],
    this.total = 0,
    this.customerName,
    this.customerContact,
    this.createdBy,
    this.pdfUrl,
    this.createdAt,
  });

  int get itemCount =>
      items.fold(0, (int sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0));

  factory Bill.fromDoc(DocumentSnapshot<Object?> doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final Timestamp? createdAtTs = data['createdAt'] as Timestamp?;
    return Bill(
      id: doc.id,
      invoiceNumber: data['invoiceNumber']?.toString(),
      shopId: data['shopId']?.toString(),
      regionId: data['regionId']?.toString(),
      country: data['Country']?.toString(),
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      total: (data['total'] is num) ? (data['total'] as num).toDouble() : 0,
      customerName: data['customerName']?.toString(),
      customerContact: data['customerContact']?.toString(),
      createdBy: data['createdBy']?.toString(),
      pdfUrl: data['pdfUrl']?.toString(),
      createdAt: createdAtTs?.toDate(),
    );
  }
}
