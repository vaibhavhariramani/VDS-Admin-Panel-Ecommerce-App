import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../controllers/orders_controller.dart';
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
