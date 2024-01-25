import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../../home/views/home_view.dart';
import '../controllers/billing_controller.dart';

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
        style: Theme.of(screen.context).textTheme.bodyText1?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 32,
            ),
      ),
      subtitle: Text(
        title,
        textScaleFactor: Get.textScaleFactor,
        style: Theme.of(screen.context).textTheme.bodyText1?.copyWith(
              // color: AppColors.white,
              color: color,
              fontSize: 14,
            ),
      ),
      trailing: icon,
    );
  }
}
