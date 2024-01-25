import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';

import '../../../../../models/Orders.dart';
import '../../../../../models/Users.dart';
import '../../controllers/orders_controller.dart';
// import '../../controllers/Orders_controller.dart';

class DataSourceOrders extends DataTableSource {
  DataSourceOrders(this.context, this.rows); //snapshot.data
  OrdersController controller = Get.put(OrdersController());
  final BuildContext context;
  RxList<Orders?> rows;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];
    return DataRow.byIndex(
      selected: false,
      index: index,
      onSelectChanged: (value) {},
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textScaleFactor: Get.textScaleFactor,
                maxLines: 2,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: row?.customerName.toString() == 'null'
                          ? ''
                          : row?.customerName.toString(),
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 14,
                          ),
                    ),
                    const TextSpan(
                      text: '\n',
                    ),
                    TextSpan(
                      text: row?.Address.toString() == 'null'
                          ? ''
                          : row?.Address.toString(),
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
        DataCell(Text(row?.deliveryDate.toString() == 'null'
            ? ''
            : row!.deliveryDate.toString())),
        DataCell(Text(row?.customerNumber.toString() == 'null'
            ? ''
            : row!.customerNumber!)),
        DataCell(
          Text(
            row!.status.toString() == 'null' ? '' : row.status!,
            // style: TextStyle(
            //     color: row.status == 'Active'
            //         ? Colors.green
            //         : row.status == 'Pending'
            //             ? const Color(0xFFFF9F43)
            //             : const Color(0xFF82868B),
            //     fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          CircleAvatar(
            radius: 20,
            backgroundImage: Image.network(
              row!.deliveryPersonPhoto.toString() == 'null'
                  ? 'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200'
                  : row.deliveryPersonPhoto.toString(),
              fit: BoxFit.cover,
            ).image,
          ),
        ),
        DataCell(Row(
          children: [
            IconButton(
                onPressed: () {
                  Get.dialog(AlertDialog(
                    content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Card(
                                child: SizedBox.square(
                              dimension: 80,
                              child: Image.network(
                                row.deliveryPersonPhoto.toString() == 'null'
                                    ? 'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200'
                                    : row.deliveryPersonPhoto.toString(),
                                fit: BoxFit.cover,
                              ),
                            )),
                          ),
                          Center(
                            child: Text(
                              row.customerName.toString() == 'null'
                                  ? ''
                                  : row.customerName.toString(),
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            "Details",
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                          const Divider(),
                          Text(
                            "Email: ${row.Address.toString() == 'null' ? '' : row.Address.toString()}",
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                "Status: ",
                                style:
                                    DefaultTextStyle.of(context).style.copyWith(
                                          fontSize: 14,
                                        ),
                              ),
                              Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    row.status!.toString() == 'null'
                                        ? ''
                                        : row.status!,
                                    // style: TextStyle(
                                    //   color: row.status == 'Active'
                                    //       ? Colors.green
                                    //       : row.status == 'Pending'
                                    //           ? const Color(0xFFFF9F43)
                                    //           : const Color(0xFF82868B),
                                    // ),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Contact: ${row.customerNumber.toString() == 'null' ? '' : row.customerNumber.toString()}",
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Country: ${row.Address.toString() == 'null' ? '' : row.Address.toString()}",
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                        ]),
                  ));
                },
                icon: const Icon(IconlyLight.show)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
