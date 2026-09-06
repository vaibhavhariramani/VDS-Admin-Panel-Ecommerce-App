import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';

import '../../../../constants/order_status.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../controllers/orders_controller.dart';
import 'components/table_datasrc_orders.dart';

DeletionStatusController deletionStatusController2 = Get.put(DeletionStatusController());

class OnlineOrderstableView extends GetResponsiveView<OrdersController> {
  OnlineOrderstableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            visible: controller.showOnlineOrdersTable.value && !deletionStatusController2.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: screen.isDesktop ? AppSpacing.xxl : AppSpacing.lg,
              topPadding: AppSpacing.lg,
              bottomPadding: 0,
              child: SliverToBoxAdapter(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => controller.showOnlineOrdersTable(false),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(
                      'Online Orders',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverVisibility(
            visible: controller.showOnlineOrdersTable.value && !deletionStatusController2.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: screen.isDesktop ? AppSpacing.xxl : AppSpacing.lg,
              topPadding: AppSpacing.md,
              bottomPadding: AppSpacing.sm,
              child: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Search by customer name, phone, or address',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        ChoiceChip(
                          label: Text('All (${controller.OnlineordersData.length})'),
                          selected: controller.statusFilter.value == null,
                          onSelected: (_) => controller.statusFilter.value = null,
                        ),
                        ...OrderStatus.all.map(
                          (status) => ChoiceChip(
                            label: Text('${OrderStatus.label(status)} (${controller.countForStatus(status)})'),
                            selected: controller.statusFilter.value == status,
                            selectedColor: OrderStatus.color(status).withValues(alpha: 0.15),
                            onSelected: (_) => controller.statusFilter.value = status,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverVisibility(
            visible: controller.showOnlineOrdersTable.value && !deletionStatusController2.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: Builder(builder: (context) {
                final visible = controller.visibleOrders;
                if (visible.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : Text(
                              controller.OnlineordersData.isEmpty
                                  ? 'No orders found'
                                  : 'No orders match your search or filter',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                            ),
                    ),
                  );
                }
                return Theme(
                  data: Theme.of(context).copyWith(cardColor: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, top: 12),
                    child: PaginatedDataTable(
                      showCheckboxColumn: false,
                      rowsPerPage: visible.length < 10 ? visible.length : 10,
                      sortColumnIndex: controller.sortColumnIndex.value,
                      sortAscending: controller.sortAscending.value,
                      columns: [
                        const DataColumn(label: Text('Name')),
                        DataColumn(
                          label: const Text('Date Of order'),
                          onSort: (columnIndex, ascending) => controller.sortOnlineOrdersByDate(ascending: ascending),
                        ),
                        const DataColumn(label: Text('contact')),
                        const DataColumn(label: Text('Status')),
                        const DataColumn(label: Text('Delivery Boy')),
                        const DataColumn(label: Text('ACTIONS')),
                      ],
                      columnSpacing: 20,
                      source: DataSourceOrders(context, visible),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
