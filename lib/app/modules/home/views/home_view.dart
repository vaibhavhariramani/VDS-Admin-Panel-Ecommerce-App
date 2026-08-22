import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:iconly/iconly.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../constants/constants.dart';
import '../../../../models/UserType.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/controllers/deletion_status_controller.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../controllers/home_controller.dart';
import 'dashboard_alerts_panel.dart';

DateTime startDate = DateTime(2000);
DateTime endDate = DateTime(3000);
DeletionStatusController deletionStatusController =
    Get.put(DeletionStatusController());

class HomeView extends GetResponsiveView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    controller.onInit();
    return Obx(() {
      // if (controller.userType == UserType.ADMIN) {}
      switch (controller.userType) {
        case UserType.ADMIN:
          return _RootAdminHome();
        case UserType.SHOP_ADMIN:
          return _ShopAdminView();
        case UserType.MERCHANT:
          return _MerchantAdminView();
        case UserType.COUNTRY_HEAD:
          return _CountryAdminView();
        case UserType.AFFILIATES:
          return _AffiliatesAdminView();
        default:
          return const Scaffold(
            body: Center(
              child: Text(
                "you don't have enough permission to view this page",
              ),
            ),
          );
      }
    });
  }
}

class _RootAdminHome extends GetResponsiveView<HomeController> {
  _RootAdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 20,
              topPadding: 20,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 3,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 3,
                          )
                        : FlutterDashboardGridDelegates.fit(3, 3, 1),
                crossAxisSpacing: screen.isDesktop ? 20 : 0,
                mainAxisSpacing: screen.isDesktop ? 15 : 15,
                buildItem: (BuildContext context, int index) {
                  return Obx(() => _buildTiles()[index]);
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 35,
              topPadding: 50,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 2,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 2,
                          )
                        : FlutterDashboardGridDelegates.fit(2, 2, 1),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                buildItem: (BuildContext context, int index) {
                  return _buildBody(
                    screen,
                    chartData: <CartesianSeries<dynamic, dynamic>>[
                      ColumnSeries<ShopVisitorChartData, String>(
                        dataSource: controller.data,
                        xValueMapper: (ShopVisitorChartData data, _) => data.x,
                        yValueMapper: (ShopVisitorChartData data, _) => data.y,
                        name: 'Visitors',
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        isTrackVisible: true,
                        trackBorderWidth: 0,
                        color: Theme.of(screen.context).primaryColor,
                      )
                    ],
                  )[index];
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        child: Center(
          child: _buildTileItem(
            totalCount: 21459,
            title: 'Total Users',
            color: const Color(0xff006E1B),
            icon: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: Image.asset(
                'assets/all_user.png',
                scale: 1,
              ),
            ),
          ),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffE5F6FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.activeUserCount.value,
                  title: 'Active Users',
                  color: const Color(0xff2C71FF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/active_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffF6F3FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.inActiveUserCount.value,
                  title: 'Inactive Users',
                  color: const Color(0xff6955BF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/pending_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      )
    ];
  }

  _buildTileItem({
    required int totalCount,
    required String title,
    required Widget icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      dense: true,
      title: Text(
        "$totalCount".replaceAllMapped(numberFormatterRegex, formatNumberCount),
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}

class _AffiliatesAdminView extends GetResponsiveView<HomeController> {
  _AffiliatesAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 20,
              topPadding: 20,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 3,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 3,
                          )
                        : FlutterDashboardGridDelegates.fit(3, 3, 1),
                crossAxisSpacing: screen.isDesktop ? 20 : 0,
                mainAxisSpacing: screen.isDesktop ? 15 : 15,
                buildItem: (BuildContext context, int index) {
                  return Obx(() => _buildTiles()[index]);
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 35,
              topPadding: 50,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 2,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 2,
                          )
                        : FlutterDashboardGridDelegates.fit(2, 2, 1),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                buildItem: (BuildContext context, int index) {
                  return _buildBody(
                    screen,
                    chartData: <CartesianSeries<dynamic, dynamic>>[
                      ColumnSeries<ShopVisitorChartData, String>(
                        dataSource: controller.data,
                        xValueMapper: (ShopVisitorChartData data, _) => data.x,
                        yValueMapper: (ShopVisitorChartData data, _) => data.y,
                        name: 'Visitors',
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        isTrackVisible: true,
                        trackBorderWidth: 0,
                        color: Theme.of(screen.context).primaryColor,
                      )
                    ],
                  )[index];
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        child: Center(
          child: _buildTileItem(
            totalCount: 21459,
            title: 'Total Users',
            color: const Color(0xff006E1B),
            icon: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: Image.asset(
                'assets/all_user.png',
                scale: 1,
              ),
            ),
          ),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffE5F6FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.activeUserCount.value,
                  title: 'Active Users',
                  color: const Color(0xff2C71FF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/active_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffF6F3FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.inActiveUserCount.value,
                  title: 'Inactive Users',
                  color: const Color(0xff6955BF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/pending_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      )
    ];
  }

  _buildTileItem({
    required int totalCount,
    required String title,
    required Widget icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      dense: true,
      title: Text(
        "$totalCount".replaceAllMapped(numberFormatterRegex, formatNumberCount),
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}

class _CountryAdminView extends GetResponsiveView<HomeController> {
  _CountryAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(
      () => FlutterDashboardListView(
        slivers: [
          SliverVisibility(
            visible: deletionStatusController.isVisible.value,
            sliver: SliverToBoxAdapter(
              child: DeletionStatusView(),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 20,
              topPadding: 20,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 3,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 3,
                          )
                        : FlutterDashboardGridDelegates.fit(3, 3, 1),
                crossAxisSpacing: screen.isDesktop ? 20 : 0,
                mainAxisSpacing: screen.isDesktop ? 15 : 15,
                buildItem: (BuildContext context, int index) {
                  return Obx(() => _buildTiles()[index]);
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: 35,
              topPadding: 50,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 2,
                gridDelegate: screen.isPhone
                    ? null
                    : !screen.isDesktop
                        ? FlutterDashboardGridDelegates.columns_1(
                            width: screen.width,
                            length: 2,
                          )
                        : FlutterDashboardGridDelegates.fit(2, 2, 1),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                buildItem: (BuildContext context, int index) {
                  return _buildBody(
                    screen,
                    chartData: <CartesianSeries<dynamic, dynamic>>[
                      ColumnSeries<ShopVisitorChartData, String>(
                        dataSource: controller.data,
                        xValueMapper: (ShopVisitorChartData data, _) => data.x,
                        yValueMapper: (ShopVisitorChartData data, _) => data.y,
                        name: 'Visitors',
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        isTrackVisible: true,
                        trackBorderWidth: 0,
                        color: Theme.of(screen.context).primaryColor,
                      )
                    ],
                  )[index];
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        child: Center(
          child: _buildTileItem(
            totalCount: 21459,
            title: 'Total Users',
            color: const Color(0xff006E1B),
            icon: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: Image.asset(
                'assets/all_user.png',
                scale: 1,
              ),
            ),
          ),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffE5F6FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.activeUserCount.value,
                  title: 'Active Users',
                  color: const Color(0xff2C71FF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/active_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffF6F3FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.inActiveUserCount.value,
                  title: 'Inactive Users',
                  color: const Color(0xff6955BF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/pending_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      )
    ];
  }

  _buildTileItem({
    required int totalCount,
    required String title,
    required Widget icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      dense: true,
      title: Text(
        "$totalCount".replaceAllMapped(numberFormatterRegex, formatNumberCount),
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}

class _MerchantAdminView extends GetResponsiveView<HomeController> {
  _MerchantAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(() => FlutterDashboardListView(
          slivers: [
            SliverVisibility(
              visible: deletionStatusController.isVisible.isTrue,
              sliver: SliverToBoxAdapter(
                child: DeletionStatusView(),
              ),
            ),
            SliverVisibility(
              visible: deletionStatusController.isVisible.isFalse,
              sliver: PaddingWrapper(
                isSliverItem: true,
                horizontalPadding: 20,
                topPadding: 20,
                child: FlutterDashboardListView.grid(
                  isSliverItem: true,
                  childCount: 3,
                  gridDelegate: screen.isPhone
                      ? null
                      : !screen.isDesktop
                          ? FlutterDashboardGridDelegates.columns_1(
                              width: screen.width,
                              length: 3,
                            )
                          : FlutterDashboardGridDelegates.fit(3, 3, 1),
                  crossAxisSpacing: screen.isDesktop ? 20 : 0,
                  mainAxisSpacing: screen.isDesktop ? 15 : 15,
                  buildItem: (BuildContext context, int index) {
                    return Obx(() => _buildTiles()[index]);
                  },
                  listType: FlutterDashboardListType.Grid,
                ),
              ),
            ),
            SliverVisibility(
              visible: deletionStatusController.isVisible.isFalse,
              sliver: PaddingWrapper(
                isSliverItem: true,
                horizontalPadding: 35,
                topPadding: 50,
                child: FlutterDashboardListView.grid(
                  isSliverItem: true,
                  childCount: 2,
                  gridDelegate: screen.isPhone
                      ? null
                      : !screen.isDesktop
                          ? FlutterDashboardGridDelegates.columns_1(
                              width: screen.width,
                              length: 2,
                            )
                          : FlutterDashboardGridDelegates.fit(2, 2, 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  buildItem: (BuildContext context, int index) {
                    return _buildBody(
                      screen,
                      chartData: <CartesianSeries<dynamic, dynamic>>[
                        ColumnSeries<ShopVisitorChartData, String>(
                          dataSource: controller.data,
                          xValueMapper: (ShopVisitorChartData data, _) =>
                              data.x,
                          yValueMapper: (ShopVisitorChartData data, _) =>
                              data.y,
                          name: 'Visitors',
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          isTrackVisible: true,
                          trackBorderWidth: 0,
                          color: Theme.of(screen.context).primaryColor,
                        )
                      ],
                    )[index];
                  },
                  listType: FlutterDashboardListType.Grid,
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.activeUserCount.value,
                  title: 'Active Users',
                  color: const Color(0xff006E1B),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/active_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffE5F6FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.inActiveUserCount.value,
                  title: 'Inactive Users',
                  color: const Color(0xff2C71FF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/pending_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffF6F3FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.requestedUser.value,
                  title: 'Requested Users',
                  color: const Color(0xff6955BF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/all_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    ];
  }

  _buildTileItem({
    required int totalCount,
    required String title,
    required Widget icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      dense: true,
      title: Text(
        "$totalCount".replaceAllMapped(numberFormatterRegex, formatNumberCount),
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}

class _ShopAdminView extends GetResponsiveView<HomeController> {
  _ShopAdminView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return Obx(() => FlutterDashboardListView(
          slivers: [
            SliverVisibility(
              visible: deletionStatusController.isVisible.value,
              sliver: SliverToBoxAdapter(
                child: DeletionStatusView(),
              ),
            ),
            SliverVisibility(
              visible: !deletionStatusController.isVisible.value,
              sliver: PaddingWrapper(
                isSliverItem: true,
                horizontalPadding: 20,
                topPadding: 20,
                child: FlutterDashboardListView.grid(
                  isSliverItem: true,
                  childCount: 3,
                  gridDelegate: screen.isPhone
                      ? null
                      : !screen.isDesktop
                          ? FlutterDashboardGridDelegates.columns_1(
                              width: screen.width,
                              length: 3,
                            )
                          : FlutterDashboardGridDelegates.fit(3, 3, 1),
                  crossAxisSpacing: screen.isDesktop ? 20 : 0,
                  mainAxisSpacing: screen.isDesktop ? 15 : 15,
                  buildItem: (BuildContext context, int index) {
                    return Obx(() => _buildTiles()[index]);
                  },
                  listType: FlutterDashboardListType.Grid,
                ),
              ),
            ),
            SliverVisibility(
              visible: !deletionStatusController.isVisible.value,
              sliver: PaddingWrapper(
                isSliverItem: true,
                horizontalPadding: 35,
                topPadding: 50,
                child: FlutterDashboardListView.grid(
                  isSliverItem: true,
                  childCount: 2,
                  gridDelegate: screen.isPhone
                      ? null
                      : !screen.isDesktop
                          ? FlutterDashboardGridDelegates.columns_1(
                              width: screen.width,
                              length: 2,
                            )
                          : FlutterDashboardGridDelegates.fit(2, 2, 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  buildItem: (BuildContext context, int index) {
                    return _buildBody(
                      screen,
                      chartData: <CartesianSeries<dynamic, dynamic>>[
                        ColumnSeries<ShopVisitorChartData, String>(
                          dataSource: controller.data,
                          xValueMapper: (ShopVisitorChartData data, _) =>
                              data.x,
                          yValueMapper: (ShopVisitorChartData data, _) =>
                              data.y,
                          name: 'Orders',
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          isTrackVisible: true,
                          trackBorderWidth: 0,
                          color: Theme.of(screen.context).primaryColor,
                        )
                      ],
                    )[index];
                  },
                  listType: FlutterDashboardListType.Grid,
                ),
              ),
            ),
            SliverVisibility(
              visible: !deletionStatusController.isVisible.value,
              sliver: const SliverToBoxAdapter(
                child: DashboardAlertsPanel(),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.activeUserCount.value,
                  title: 'Active Users',
                  color: const Color(0xff006E1B),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/active_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffE5F6FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.inActiveUserCount.value,
                  title: 'Inactive Users',
                  color: const Color(0xff2C71FF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/pending_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffF6F3FF),
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.requestedUser.value,
                  title: 'Requested Users',
                  color: const Color(0xff6955BF),
                  icon: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: Image.asset(
                      'assets/all_user.png',
                      scale: 1,
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    ];
  }

  _buildTileItem({
    required int totalCount,
    required String title,
    required Widget icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      dense: true,
      title: Text(
        "$totalCount".replaceAllMapped(numberFormatterRegex, formatNumberCount),
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyLarge?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}

List<Widget> _buildBody(ResponsiveScreen screen, {required dynamic chartData}) {
  return [
    Center(
      child: SizedBox(
        width: 800,
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance',
                  textScaleFactor: Get.textScaleFactor,
                  style: DefaultTextStyle.of(screen.context).style.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        letterSpacing: 0.4,
                      ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    // dropdownWidth: 120,
                    customButton: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Theme.of(screen.context).disabledColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              IconlyLight.calendar,
                              size: 14,
                              color: Theme.of(screen.context).disabledColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Today',
                              textScaleFactor: Get.textScaleFactor,
                              style: DefaultTextStyle.of(screen.context)
                                  .style
                                  .copyWith(
                                    color:
                                        Theme.of(screen.context).disabledColor,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              IconlyLight.arrow_down_2,
                              size: 14,
                              color: Theme.of(screen.context).disabledColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    items: <String>[
                      '01/12/2020',
                      '01/12/2021',
                      '01/12/2022',
                      '01/12/2023'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      print(value);
                    },
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.transparent,
              height: 50,
            ),
            SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                plotAreaBorderColor: Colors.transparent,
                primaryXAxis: CategoryAxis(
                  isVisible: true,
                  axisLine: AxisLine(
                    width: 1,
                    color: Theme.of(screen.context).disabledColor,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  interval: 100,
                  axisLine: AxisLine(
                    width: 1,
                    color: Theme.of(screen.context).disabledColor,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: chartData,
              ),
            ),
          ],
        ),
      ),
    ),
    Center(
      child: SizedBox(
        height: 350,
        width: 350,
        child: SfDateRangePicker(
          minDate: startDate,
          maxDate: endDate,
          showActionButtons: false,
          showTodayButton: false,
          enablePastDates: true,
          view: DateRangePickerView.month,
          viewSpacing: 5,
          showNavigationArrow: true,
          todayHighlightColor: Theme.of(screen.context).primaryColor,
          selectionColor: Theme.of(screen.context).primaryColor,
          // backgroundColor: DarkChatTheme().backgroundColor,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            print(args.value);
          },
        ),
      ),
    ),
  ];
}
