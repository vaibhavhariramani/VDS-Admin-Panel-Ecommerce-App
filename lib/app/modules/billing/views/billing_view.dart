import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:get/get.dart';
import 'package:vdsadmin/app/modules/billing/views/widgets/createItem.dart';

import '../../../../constants/constants.dart';
import '../../../../models/Product.dart';
import '../../../../models/invoice.dart';
import '../../../../themes/app_theme.dart';
import '../../../widgets/components/common_card.dart';
import '../../../widgets/utils/padding_wrapper.dart';
import '../../deletion_status/views/deletion_status_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/order_details.dart';
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
          SliverVisibility(
            visible: !deletionStatusController.isVisible.value,
            sliver: PaddingWrapper(
                isSliverItem: true,
                horizontalPadding: 20,
                topPadding: 20,
                child: FlutterDashboardListView(
                  slivers: [
                    Expanded(
                      // height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                              imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/atus-kart.appspot.com/o/static%2Fbasket.png?alt=media&token=4ca7a331-90d3-4ce0-8113-0226e577085e',
                              width: 120,
                              height: 120),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 12),
                            child: Text('No items in your cart!',
                                style: TextStyle(color: Colors.grey)),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 60, right: 60),
                            child: Text(
                              "We are looking to provide our services for you",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ), // ListView(
          //   // shrinkWrap: true,
          //   physics: BouncingScrollPhysics(),
          //   children: [

          // ListView.builder(
          //   // shrinkWrap: true,
          //   scrollDirection: Axis.vertical,
          //   physics: const BouncingScrollPhysics(),
          //   itemBuilder: buildProductItem,
          //   itemCount: controller.products.length,
          // ),
          // Center(
          //   // Add visiblity detector to handle barcode
          //   // values only when widget is visible
          //   child: VisibilityDetector(
          //     onVisibilityChanged: (VisibilityInfo info) {
          //       controller.visible = info.visibleFraction > 0;
          //     },
          //     key: Key('visible-detector-key'),
          //     child: BarcodeKeyboardListener(
          //       bufferDuration: Duration(milliseconds: 200),
          //       onBarcodeScanned: (barcode) {
          //         controller.productfetcher((barcode));
          //       },
          //       // child: SizedBox(
          //       //   height: 1,
          //       // ),
          //       child: Column(
          //         children: <Widget>[
          //           Text(
          //             controller.barcode == null
          //                 ? 'Waiting for new BARCODE'
          //                 : 'BARCODE: ${controller.barcode}',
          //             style: Theme.of(context).textTheme.headline5,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          //   ],
          // ),
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
