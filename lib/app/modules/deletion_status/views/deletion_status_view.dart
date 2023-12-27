import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import '../../../../models/UserType.dart';
import '../../../../models/deletion_data_model.dart';
import '../../../../services/auth_service.dart';
import '../component/header.dart';
import '../controllers/deletion_status_controller.dart';

class DeletionStatusView extends GetResponsiveView {
  @override
  Widget build(BuildContext context) {
    DeletionStatusController Dcontroller = Get.put(DeletionStatusController());
    return FlutterDashboardListView(
      slivers: [
        Header(
          title: 'Deletion Status',
          columnlist: const [
            'User',
            'Action',
            'Role',
            'Location',
            'Date',
            'Request'
          ],
          isOpen: true.obs,
        ),
        SliverToBoxAdapter(
          child: Dcontroller.allNotifications.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 2, top: 12),
                  child: Obx(
                    () => PaginatedDataTable(
                      showCheckboxColumn: false,
                      rowsPerPage: Dcontroller.allNotifications.isEmpty
                          ? 1
                          : Dcontroller.allNotifications.length < 10
                              ? Dcontroller.allNotifications.length
                              : 10,
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Action')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Request')),
                      ],
                      columnSpacing: 10,
                      source: DataSource(
                          context,
                          Dcontroller.allNotifications
                              as List<DeleteNotification>),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class DataSource extends DataTableSource {
  DataSource(this.context, this.rows); //snapshot.data

  final BuildContext context;
  List<DeleteNotification> rows;
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
          Text(
            '${row.user}',
            maxLines: 1,
          ),
        ),
        DataCell(Text(
          '${row.action}',
        )),
        DataCell(Text('${row.role}')),
        DataCell(Text('${row.location}')),
        DataCell(Text('${row.date}')),
        AuthService.to.userType == UserType.ADMIN
            ? DataCell(
                row.status == 'Pending'
                    ? Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                IconlyBold.close_square,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                IconlyBold.tick_square,
                                color: Colors.green,
                              )),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: row.status == 'Approved'
                                ? Colors.green.withOpacity(0.8)
                                : row.status == 'Rejected'
                                    ? Colors.red.withOpacity(0.8)
                                    : null,
                            borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '${row.status}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              )
            : DataCell(
                Container(
                  decoration: BoxDecoration(
                      color: row.status == 'Approved'
                          ? Colors.green.withOpacity(0.8)
                          : row.status == 'Rejected'
                              ? Colors.red.withOpacity(0.8)
                              : row.status == 'Pending'
                                  ? Colors.orange.withOpacity(0.8)
                                  : null,
                      borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '${row.status}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
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
