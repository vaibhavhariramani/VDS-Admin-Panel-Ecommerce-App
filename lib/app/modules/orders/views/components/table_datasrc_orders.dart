import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';

import '../../../../../constants/order_status.dart';
import '../../../../../models/Orders.dart';
import '../../../../../themes/app_theme.dart';
import '../../controllers/orders_controller.dart';
import '../order_details.dart';

class DataSourceOrders extends DataTableSource {
  DataSourceOrders(this.context, this.rows);
  OrdersController controller = Get.put(OrdersController());
  final BuildContext context;
  final List<Orders?> rows;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];
    // Safely handle null row
    if (row == null) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(6, (_) => DataCell(Text('Deleted'))),
      );
    }
    // Safe conversion
    DateTime dateOfOrder;
    final dateValue = row.dateOfOrder;
    if (dateValue is Timestamp) {
      dateOfOrder = dateValue.toDate();
    } else if (dateValue is DateTime) {
      dateOfOrder = dateValue;
    } else {
      dateOfOrder = DateTime.now();
    }

    final String status = row.status?.toString() ?? '';
    final String riderName = row.deliveryPersonName?.toString() ?? '';

    return DataRow.byIndex(
      selected: false,
      index: index,
      onSelectChanged: (value) {
        // Plain Navigator.push, not a named route: two different named-
        // route approaches (nested under /dashboard/orders, then a
        // root-level page) both broke live - the second one sent every
        // click into a continuous exception loop dead-ending at
        // /error404. This app's flutter_dashboard version's routing is
        // too fragile to risk again for what's a "nice to have" (a
        // shareable URL) rather than a functional requirement. This is
        // back to the original, proven-stable approach; it just doesn't
        // update the browser URL.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderDetails(
                      mp: row,
                    )));
      },
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 2,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: row.customerName.toString() == 'null' ? '' : row.customerName.toString(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 14,
                          ),
                    ),
                    const TextSpan(
                      text: '\n',
                    ),
                    TextSpan(
                      text: row.Address.toString() == 'null' ? '' : row.Address.toString(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(dateOfOrder.toString())),
        DataCell(Text(row.customerNumber.toString() == 'null' ? '' : row.customerNumber!)),
        DataCell(
          status.isEmpty
              ? const Text('')
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: OrderStatus.color(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    OrderStatus.label(status),
                    style: TextStyle(color: OrderStatus.color(status), fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
        ),
        DataCell(
          riderName.isEmpty
              ? Text('—', style: TextStyle(color: Theme.of(context).disabledColor))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                    const SizedBox(width: 6),
                    Text(riderName, overflow: TextOverflow.ellipsis),
                  ],
                ),
        ),
        DataCell(Row(
          children: [
            IconButton(
                onPressed: () => _showQuickView(context, row, status),
                icon: const Icon(IconlyLight.show)),
            IconButton(
              onPressed: () => _confirmDelete(context, row),
              icon: Icon(Icons.delete_outline, color: AppSemanticColors.danger),
            ),
          ],
        )),
      ],
    );
  }

  void _showQuickView(BuildContext context, Orders row, String status) {
    Get.dialog(AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              row.customerName.toString() == 'null' ? '' : row.customerName.toString(),
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Text(
            "Address: ${row.Address.toString() == 'null' ? 'Not provided' : row.Address.toString()}",
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Status: ", style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14)),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: OrderStatus.color(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    OrderStatus.label(status),
                    style: TextStyle(color: OrderStatus.color(status), fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Contact: ${row.customerNumber.toString() == 'null' ? 'Not provided' : row.customerNumber.toString()}",
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
          ),
        ],
      ),
    ));
  }

  void _confirmDelete(BuildContext context, Orders row) {
    Get.dialog(AlertDialog(
      title: const Text('Delete order?'),
      content: Text(
        'This permanently removes the order from ${row.customerName ?? 'this customer'}. This cannot be undone.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteOrder(row.orderId);
            notifyListeners();
          },
          child: Text('Delete', style: TextStyle(color: AppSemanticColors.danger)),
        ),
      ],
    ));
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
