import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../widgets/components/header.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../controllers/orders_controller.dart';
import 'components/table_datasrc_orders.dart';

DeletionStatusController deletionStatusController2 =
    Get.put(DeletionStatusController());

class OnlineOrderstableView extends GetResponsiveView<OrdersController> {
  OnlineOrderstableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get.lazyPut(() => ShopListingController());
    screen.context = context;
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: controller.showOnlineOrdersTable.value &&
                !deletionStatusController2.isVisible.value,
            sliver: UsersHeader(
              title: 'Online Orders',
              showBackButton: true,
              onPressBackButton: () => controller.showOnlineOrdersTable(false),
              onCreateNew: () {
                controller.isInviting.toggle();
                print("Create");
              },
            ),
          ),
          SliverVisibility(
            visible: controller.showOnlineOrdersTable.value &&
                !deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              // hasScrollBody: false,
              child: controller.OnlineordersData.isNotEmpty
                  ? Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2, top: 12),
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          rowsPerPage: controller.OnlineordersData.isEmpty
                              ? 1
                              : controller.OnlineordersData.length < 10
                                  ? controller.OnlineordersData.length
                                  : 10,
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          columns: [
                            const DataColumn(label: Text('Name')),
                            DataColumn(
                              label: const Text('Date Of order'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sortOnlineOrdersByDate(
                                      ascending: ascending),
                            ),
                            const DataColumn(label: Text('contact')),
                            const DataColumn(label: Text('Status')),
                            const DataColumn(label: Text('Delivery Boy')),
                            const DataColumn(label: Text('ACTIONS')),
                          ],
                          columnSpacing: 20,
                          source: DataSourceOrders(
                              context, controller.OnlineordersData!),
                        ),
                      ),
                    )
                  : controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text('No orders found')),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
