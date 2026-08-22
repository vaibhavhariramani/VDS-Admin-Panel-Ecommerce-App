import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/Bill.dart';

class DataSourceOfflineOrders extends DataTableSource {
  DataSourceOfflineOrders(this.context, this.rows);
  final BuildContext context;
  final List<Bill> rows;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final Bill bill = rows[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(bill.invoiceNumber ?? bill.id)),
        DataCell(Text(
          bill.createdAt != null
              ? bill.createdAt!.toString().substring(0, 16)
              : '—',
        )),
        DataCell(Text(
          (bill.customerName?.isNotEmpty ?? false) ? bill.customerName! : 'Walk-in',
        )),
        DataCell(Text('${bill.itemCount}')),
        DataCell(Text(bill.total.toStringAsFixed(2))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'View items',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () => _showDetails(bill),
            ),
            IconButton(
              tooltip: bill.pdfUrl == null ? 'PDF still uploading' : 'Open invoice PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: bill.pdfUrl == null
                  ? null
                  : () => launchUrl(Uri.parse(bill.pdfUrl!)),
            ),
          ],
        )),
      ],
    );
  }

  void _showDetails(Bill bill) {
    Get.dialog(
      AlertDialog(
        title: Text(bill.invoiceNumber ?? bill.id),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bill.customerName?.isNotEmpty ?? false) Text('Customer: ${bill.customerName}'),
              if (bill.customerContact?.isNotEmpty ?? false) Text('Contact: ${bill.customerContact}'),
              const SizedBox(height: 12),
              ...bill.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item['name'] ?? ''}')),
                        Text('x${item['quantity'] ?? 0}'),
                        const SizedBox(width: 12),
                        Text('${item['lineTotal'] ?? 0}'),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(bill.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
