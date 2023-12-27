import 'package:flutter/material.dart';
import '../../../../widgets/utils/padding_wrapper.dart';
import '../../../../widgets/utils/shimmer_helper.dart';
import '../../components/products_header.dart';
import '../controllers/hot_deals_controller.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'hot_deals_card.dart';

class HotDealsView extends GetResponsiveView<HotDealsController> {
  HotDealsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;

    return Obx(
      () => FlutterDashboardListView(
        shrinkWrap: true,
        scrollController: ScrollController(),
        slivers: [
          // SliverVisibility(
          //   visible: !controller.isLoading.value && controller.hotdealProducts.isEmpty,
          //   sliver: PaddingWrapper(
          //     isSliverItem: true,
          //     topPadding: 5,
          //     horizontalPadding: screen.isDesktop ? 40 : 10,
          //     child: const Text('No data to show'),
          //   ),
          // ),
          SliverVisibility(
            visible: controller.isLoading.value,
            sliver: PaddingWrapper(
              isSliverItem: true,
              topPadding: 5,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              child: ShimmerHelper.buildGridShimmer(
                sliverItem: true,
                screen: screen,
                showIcon: true,
              ),
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.hotdealProducts.isNotEmpty,
            sliver: ProductsHeader(
              title: 'Hot Deals',
              subTitle: "Deals Listed",
              totalCount: controller.hotdealProducts.length,
              actions: const [
                // DropdownButtonHideUnderline(
                //   child: DropdownButton2(
                //     dropdownWidth: 120,
                //     customButton: DecoratedBox(
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(8.0),
                //         border: Border.all(
                //           color: Theme.of(screen.context).disabledColor,
                //         ),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 10,
                //           vertical: 10,
                //         ),
                //         child: Row(
                //           children: [
                //             Text(
                //               'Today',
                //               textScaleFactor: Get.textScaleFactor,
                //               style: DefaultTextStyle.of(screen.context).style.copyWith(
                //                     color: Theme.of(screen.context).disabledColor,
                //                     fontSize: 14,
                //                   ),
                //             ),
                //             const SizedBox(
                //               width: 10,
                //             ),
                //             Icon(
                //               IconlyLight.arrow_down_2,
                //               size: 14,
                //               color: Theme.of(screen.context).disabledColor,
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //     items: <String>['01/12/2020', '01/12/2021', '01/12/2022', '01/12/2023'].map((String value) {
                //       return DropdownMenuItem<String>(
                //         value: value,
                //         child: Text(value),
                //       );
                //     }).toList(),
                //     onChanged: (String? value) {
                //       print(value);
                //     },
                //   ),
                // ),
                // const SizedBox(
                //   width: 10,
                // ),
                // ExportButton(),
              ],
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.hotdealProducts.isNotEmpty,
            sliver: PaddingWrapper(
              isSliverItem: true,
              topPadding: 5,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: controller.hotdealProducts.length,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                gridDelegate: !screen.isDesktop
                    ? screen.width <= 756
                        ? FlutterDashboardGridDelegates.columns_2(
                            width: screen.width,
                            length: 4,
                          )
                        : FlutterDashboardGridDelegates.columns_3(
                            width: screen.width,
                            length: 4,
                          )
                    : screen.width <= 1700
                        ? screen.width <= 1450
                            ? screen.width <= 1240
                                ? FlutterDashboardGridDelegates.columns_2(
                                    width: screen.width,
                                    length: 4,
                                  )
                                : FlutterDashboardGridDelegates.columns_3(
                                    width: screen.width,
                                    length: 4,
                                  )
                            : FlutterDashboardGridDelegates.columns_4(
                                width: screen.width,
                                length: 4,
                              )
                        : FlutterDashboardGridDelegates.columns_5(
                            width: screen.width,
                            length: 4,
                          ),
                buildItem: (BuildContext context, int index) {
                  return HotDealProductCard(
                    isPublishedListItem: true,
                    productItem: controller.hotdealProducts[index],
                  );
                },
                listType: FlutterDashboardListType.Grid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
