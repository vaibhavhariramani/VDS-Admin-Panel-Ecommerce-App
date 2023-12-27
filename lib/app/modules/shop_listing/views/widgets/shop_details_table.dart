import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../models/Product.dart';
import '../../controllers/shop_listing_controller.dart';

class ShopDetailTable extends GetResponsiveView<ShopListingController> {
  ShopDetailTable({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        controller.products.isNotEmpty && !controller.isProductLoading.value
            ? Padding(
                padding: const EdgeInsets.only(right: 2, top: 12),
                child: PaginatedDataTable(
                  showCheckboxColumn: false,
                  rowsPerPage: controller.products.isEmpty
                      ? 1
                      : controller.products.length < 10
                          ? controller.products.length
                          : 10,
                  columns: const [
                    // DataColumn(label: Text('Icon')),
                    DataColumn(label: Text('Product Name')),

                    DataColumn(label: Text('Offer Price')),
                    DataColumn(label: Text('Deal Type')),
                    // DataColumn(label: Text('Stats')),
                    DataColumn(label: Text('Available Date')),
                    DataColumn(label: Text('Expiry Date')),
                    // DataColumn(label: Text('Actions')),
                  ],
                  columnSpacing: Get.width * 0.1,
                  source: DataSource(context, controller.products),
                ),
              )
            : controller.products.isEmpty && !controller.isProductLoading.value
                ? const Text('No Products Found')
                : Center(
                    child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  )));
  }
}

class DataSource extends DataTableSource {
  DataSource(this.context, this.rows); //snapshot.data

  final BuildContext context;
  List<Product> rows;
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
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                row.img_token!,
              ),
              radius: 15,
            ),
            title: Text(
              row.name.toString(),
              maxLines: 1,
            ),
          ),
        ),
        DataCell(Text('\$ ${row.price}')),
        DataCell(Text('${row.deal_type?.name ?? 'N/A'}')),
        // DataCell(Text(row.is_available! ? 'Available' : 'Not Available')),
        DataCell(Text('${row.available_from.toString().substring(0, 10)}')),
        DataCell(Text('${row.expires_on.toString().substring(0, 10)}')),
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
