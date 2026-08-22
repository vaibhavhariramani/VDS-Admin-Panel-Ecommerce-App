import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../controllers/orders_controller.dart';
import 'components/table_datasrc_offline_orders.dart';
import 'online_orders_table.dart';

class OrdersView extends GetResponsiveView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(() => FlutterDashboardListView(
          shrinkWrap: true,
          slivers: [
            _OrdersButtons(),
            _OnlineOrders(context),
            _OfflineOrders(context),
          ],
        ));
  }

  Widget _OrdersButtons() {
    return SliverVisibility(
      visible: !controller.showOnlineOrdersTable.value &&
          !controller.showOfflineOrdersTable.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: screen.isDesktop ? 50 : 20,
        horizontalPadding: screen.isDesktop ? 60 : 20,
        child: FlutterDashboardListView.grid(
          isSliverItem: true,
          childCount: 2,
          mainAxisSpacing: screen.isPhone ? 20 : 50,
          crossAxisSpacing: screen.isPhone ? 20 : 50,
          gridDelegate: !screen.isPhone
              ? FlutterDashboardGridDelegates.columns_2(
                  width: screen.width,
                  length: 2,
                )
              : FlutterDashboardGridDelegates.columns_1(
                  width: screen.width,
                  length: 2,
                ),
          buildItem: (BuildContext context, int index) {
            return _cardItems()[index];
          },
          listType: FlutterDashboardListType.Grid,
        ),
      ),
    );
  }

  Widget _OnlineOrders(BuildContext context) {
    screen.context = context;
    return SliverVisibility(
      visible: controller.showOnlineOrdersTable.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: 10,
        horizontalPadding: screen.isDesktop ? 30 : 20,
        child: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _typeofdealsRow(context),
              OnlineOrderstableView(),
              // OnlineOrders(),
            ],
          ),
        ),
      ),
    );
  }

  /// Table of POS sales, sourced from the `Bills` collection
  /// `BillingController.createBill()` writes to. Refreshes on every open
  /// (not just once on page load) so a bill rung up moments ago — possibly
  /// in another tab — actually shows up.
  Widget _OfflineOrders(BuildContext context) {
    screen.context = context;
    return SliverVisibility(
      visible: controller.showOfflineOrdersTable.value,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: 10,
        horizontalPadding: screen.isDesktop ? 30 : 20,
        child: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.showOfflineOrdersTable(false),
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Text(
                        'Offline Orders',
                        textScaleFactor: Get.textScaleFactor,
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: controller.refreshOfflineOrders,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (controller.isLoadingOffline.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.offlineOrdersData.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  child: Center(
                    child: Text(
                      'No offline (POS) sales yet for this shop.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PaginatedDataTable(
                    showCheckboxColumn: false,
                    rowsPerPage: controller.offlineOrdersData.length < 10
                        ? controller.offlineOrdersData.length
                        : 10,
                    columns: const [
                      DataColumn(label: Text('Invoice')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Items')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Actions')),
                    ],
                    columnSpacing: 20,
                    source: DataSourceOfflineOrders(
                      context,
                      controller.offlineOrdersData,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _cardItems() {
    return [
      _buildCard(
        text: 'Online Orders',
        onPressed: () {
          controller.showOnlineOrdersTable(true);
        },
      ),
      _buildCard(
        text: 'Offline Orders',
        onPressed: () {
          controller.showOfflineOrdersTable(true);
          controller.refreshOfflineOrders();
        },
      ),
    ];
  }

  Widget _buildCard({required String text, required VoidCallback onPressed}) {
    return CommonCard(
      onTap: onPressed,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.plus,
            color: DefaultTextStyle.of(screen.context).style.color,
            size: 50,
          ),
          const Divider(
            color: Colors.transparent,
          ),
          Text(
            text,
            textScaleFactor: Get.textScaleFactor,
            style: DefaultTextStyle.of(screen.context).style.copyWith(
                  fontSize:
                      Theme.of(screen.context).textTheme.titleLarge?.fontSize,
                ),
          ),
        ],
      ),
    );
  }

}
