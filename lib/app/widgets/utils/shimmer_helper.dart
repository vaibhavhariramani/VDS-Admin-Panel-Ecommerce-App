import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerShapeType {
  Rectangle,
  Square,
  Circle,
}

class ShimmerHelper {
  static Widget buildCircleShimmer({
    double radius = 40.0,
    bool showIcon = false,
  }) {
    return Material(
      shape: const CircleBorder(),
      color: showIcon
          ? Theme.of(Get.context!).secondaryHeaderColor
          : Theme.of(Get.context!).scaffoldBackgroundColor,
      elevation: 3,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Shimmer.fromColors(
        baseColor: showIcon
            ? Colors.transparent
            : Theme.of(Get.context!).secondaryHeaderColor,
        highlightColor: Theme.of(Get.context!).splashColor,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 2.0 * radius,
            minWidth: 2.0 * radius,
            maxWidth: 2.0 * radius,
            maxHeight: 2.0 * radius,
          ),
          decoration: BoxDecoration(
            color: showIcon ? Colors.transparent : Colors.white,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.hardEdge,
          child: Visibility(
            visible: showIcon,
            child: Center(
              child: Image.asset(
                'assets/icons/logo.png',
                color: Theme.of(Get.context!).disabledColor,
                scale: 1,
                fit: BoxFit.scaleDown,
                height: 60,
                width: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildBasicShimmer({
    double height = 120,
    double width = double.infinity,
    bool showIcon = false,
    double? horizontalPadding,
    double? verticalPadding,
    double? logoWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? Get.width * 0.001,
        vertical: verticalPadding ?? Get.height * 0.01,
      ),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: showIcon
            ? Theme.of(Get.context!).secondaryHeaderColor
            : Theme.of(Get.context!).scaffoldBackgroundColor,
        elevation: 3,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Shimmer.fromColors(
          baseColor: showIcon
              ? Colors.transparent
              : Theme.of(Get.context!).secondaryHeaderColor,
          highlightColor: Theme.of(Get.context!).splashColor,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: showIcon ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                color: Theme.of(Get.context!).disabledColor,
                scale: 1,
                fit: BoxFit.scaleDown,
                height: 60,
                width: logoWidth ?? 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildListShimmer({
    item_count = 10,
    item_height = 120.0,
    bool sliverItem = false,
    bool showIcon = false,
    ShimmerShapeType shape = ShimmerShapeType.Rectangle,
  }) {
    if (sliverItem) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 0.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: shape == ShimmerShapeType.Circle
                  ? ShimmerHelper.buildCircleShimmer()
                  : ShimmerHelper.buildBasicShimmer(
                      height: item_height,
                      showIcon: showIcon,
                    ),
            );
          },
          childCount: item_count,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: item_count,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return shape == ShimmerShapeType.Circle
              ? ShimmerHelper.buildCircleShimmer()
              : Padding(
                  padding: const EdgeInsets.only(
                    top: 0.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: ShimmerHelper.buildBasicShimmer(
                    height: item_height,
                    showIcon: showIcon,
                  ),
                );
        },
      );
    }
  }

  static Widget buildGridShimmer({
    item_count = 10,
    item_height = 320,
    bool sliverItem = false,
    SliverGridDelegateWithFixedCrossAxisCount? gridDelegate,
    bool showIcon = false,
    ShimmerShapeType shape = ShimmerShapeType.Rectangle,
    required ResponsiveScreen screen,
  }) {
    // if (sliverItem) {
    // return SliverGrid(
    //   gridDelegate: gridDelegate ??
    //       const SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: 2,
    //         crossAxisSpacing: 10,
    //         mainAxisSpacing: 10,
    //         childAspectRatio: 0.8,
    //       ),
    //   delegate: SliverChildBuilderDelegate(
    //     (BuildContext context, int index) {
    //       return shape == ShimmerShapeType.Circle
    //           ? ShimmerHelper.buildCircleShimmer()
    //           : ShimmerHelper.buildBasicShimmer(
    //               height: item_height,
    //               showIcon: showIcon,
    //               logoWidth: Get.width * 0.3,
    //             );
    //     },
    //     childCount: item_count,
    //   ),
    // );

    return FlutterDashboardListView.grid(
      isSliverItem: sliverItem,
      childCount: item_count,
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
        return shape == ShimmerShapeType.Circle
            ? ShimmerHelper.buildCircleShimmer()
            : ShimmerHelper.buildBasicShimmer(
                height: item_height,
                showIcon: showIcon,
                logoWidth: Get.width * 0.3,
              );
      },
      listType: FlutterDashboardListType.Grid,
    );

    // } else {
    //   return GridView.builder(
    //     itemCount: item_count,
    //     gridDelegate: gridDelegate ??
    //         const SliverGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 2,
    //           crossAxisSpacing: 10,
    //           mainAxisSpacing: 10,
    //           childAspectRatio: 0.8,
    //         ),
    //     padding: const EdgeInsets.all(8),
    //     physics: const NeverScrollableScrollPhysics(),
    //     shrinkWrap: true,
    //     itemBuilder: (context, index) {
    //       return shape == ShimmerShapeType.Circle
    //           ? ShimmerHelper.buildCircleShimmer()
    //           : Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: ShimmerHelper.buildBasicShimmer(
    //                 height: item_height,
    //                 showIcon: showIcon,
    //                 logoWidth: Get.width * 0.3,
    //               ),
    //             );
    //     },
    //   );
    // }
  }
}
