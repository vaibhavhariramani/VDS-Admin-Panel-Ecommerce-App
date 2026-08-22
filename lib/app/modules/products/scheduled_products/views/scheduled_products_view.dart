import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../../../widgets/utils/padding_wrapper.dart';
import '../../../../widgets/utils/shimmer_helper.dart';
import '../../components/products_header.dart';
import '../../components/product_create_dialog.dart';
import '../controllers/scheduled_products_controller.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'scheduled_product_card.dart';

class ScheduledProductsView
    extends GetResponsiveView<ScheduledProductsController> {
  ScheduledProductsView({Key? key}) : super(key: key);
  @override
  ScheduledProductsController controller =
      Get.put(ScheduledProductsController());
  @override
  Widget build(BuildContext context) {
    screen.context = context;

    return Obx(
      () => FlutterDashboardListView(
        shrinkWrap: true,
        scrollController: ScrollController(),
        slivers: [
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
                controller.scheduledProducts.isNotEmpty,
            sliver: PaddingWrapper(
              isSliverItem: true,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              topPadding: 10,
              child: SliverToBoxAdapter(
                child: TextField(
                  onChanged: (String value) => controller.searchQuery.value = value,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name, barcode, or category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value,
            sliver: ProductsHeader(
              title: "Scheduled Products",
              subTitle: "Products Scheduled",
              totalCount: controller.visibleScheduledProducts.length,
              actions: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        content: SizedBox(
                          width: Get.width * 0.4,
                          height: Get.height * 0.8,
                          child: ProductCreateDialog(
                            shopId: controller.shopId.value,
                            onCreated: () => controller.onInit(),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Product'),
                ),
                const SizedBox(width: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    // dropdownWidth: 150,
                    customButton: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Theme.of(screen.context).disabledColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Obx(
                              () => Text(
                                controller.showGreenDeal.value == true
                                    ? 'Green Deal'
                                    : 'Hot Deal',
                                textScaleFactor: Get.textScaleFactor,
                                style: DefaultTextStyle.of(screen.context)
                                    .style
                                    .copyWith(
                                      color: Theme.of(screen.context)
                                          .disabledColor,
                                      fontSize: 14,
                                    ),
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
                    items:
                        <String>['Green Deal', 'Hot Deal'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      print(value);
                      if (value == 'Green Deal') {
                        controller.showGreenDeal.value = true;
                      } else {
                        controller.showGreenDeal.value = false;
                      }
                    },
                  ),
                ),
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
                //               style: DefaultTextStyle.of(screen.context)
                //                   .style
                //                   .copyWith(
                //                     color:
                //                         Theme.of(screen.context).disabledColor,
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
                //     items: <String>[
                //       '01/12/2020',
                //       '01/12/2021',
                //       '01/12/2022',
                //       '01/12/2023'
                //     ].map((String value) {
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
          // "No scheduled products at all" — previously shown unconditionally
          // whenever loading finished, so it rendered above the grid even
          // when there were scheduled products.
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.scheduledProducts.isEmpty,
            sliver: const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No scheduled products found.'),
                ),
              ),
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.scheduledProducts.isNotEmpty &&
                controller.visibleScheduledProducts.isEmpty,
            sliver: const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('No products match your search.')),
              ),
            ),
          ),
          SliverVisibility(
            visible: !controller.isLoading.value &&
                controller.visibleScheduledProducts.isNotEmpty,
            sliver: PaddingWrapper(
              isSliverItem: true,
              topPadding: 5,
              horizontalPadding: screen.isDesktop ? 40 : 10,
              child: FlutterDashboardListView.grid(
                isSliverItem: true,
                childCount: controller.visibleScheduledProducts.length,
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
                  return ScheduledProductCard(
                    productItem: controller.visibleScheduledProducts[index],
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

  // Widget _buildHeader() {
  //   return ;
  // }
}
