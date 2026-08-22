import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../../models/Permission.dart';
import '../../../../services/auth_service.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/billing_controller.dart';
import 'create_bill_view.dart';
import 'users_table_dialog.dart';

class BillingView extends GetResponsiveView<BillingController> {
  BillingView({Key? key}) : super(key: key);

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
          _BillButtons(),
          
        ],
      ),
    );
  }

  /// The Billing route itself is nav-menu gated to roles that carry
  /// `pos.access` by default (see `kDefaultPermissionsByRole` and
  /// `AuthService.enableOrDisableRoutes`), but a user reaching this tile
  /// (e.g. via a stale bookmark, or once an admin revokes just this one
  /// permission from an otherwise Shop Admin user) should still be turned
  /// away here rather than being able to start a bill.
  Widget _BillButtons() {
    final bool canUsePos = AuthService.to.hasPermission(Permission.posAccess);
    return SliverVisibility(
      visible: true,
      sliver: PaddingWrapper(
        isSliverItem: true,
        topPadding: screen.isDesktop ? 50 : 20,
        horizontalPadding: screen.isDesktop ? 60 : 20,
        child: canUsePos
            ? FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: 1,
                mainAxisSpacing: screen.isPhone ? 20 : 50,
                crossAxisSpacing: screen.isPhone ? 20 : 50,
                gridDelegate: FlutterDashboardGridDelegates.columns_1(
                  width: screen.width,
                  length: 1,
                ),
                buildItem: (BuildContext context, int index) {
                  return _cardItems()[index];
                },
                listType: FlutterDashboardListType.Grid,
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "Your account doesn't have POS access. Ask your admin to grant it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _cardItems() {
    return [
      _buildCard(
        text: 'Start Billing',
        onPressed: () {
          controller.clearBill();
          // Dismissible by clicking outside, same as every other dialog in
          // the app — nothing is committed until "Create Bill" is tapped,
          // so closing early just loses the in-progress cart.
          Get.dialog(const CreateBillView());
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


  List<Widget> _buildTiles() {
    return [
      CommonCard(
        height: 120,
        // gradient: AppColors.gradient1,
        color: const Color(0xffD5E8CF),
        onTap: () {
          controller.loadAllUsers();
          Get.dialog(const UsersTableDialog());
        },
        child: Center(
          child: !controller.isloading.value
              ? _buildTileItem(
                  totalCount: controller.totalUserCount.value,
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
