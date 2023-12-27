import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import '../../../themes/app_theme.dart';
import '../utils/padding_wrapper.dart';

class UsersHeader extends GetResponsiveView {
  final String title;
  final bool showBackButton;
  RxBool? showFilter;
  Function()? onPressBackButton = () {};
  Function()? onFilter = () {};
  Function()? onCreateNew = () {};
  UsersHeader({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.showFilter,
    this.onPressBackButton,
    this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return PaddingWrapper(
      isSliverItem: true,
      horizontalPadding: screen.isDesktop ? 50 : 20,
      topPadding: 20,
      bottomPadding: 10,
      child: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showBackButton
                ? IconButton(
                    onPressed: onPressBackButton,
                    icon: const Icon(Icons.arrow_back_ios))
                : Container(),
            Text(
              title,
              style: DefaultTextStyle.of(screen.context).style.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 0.4,
                    color: Theme.of(context).primaryColor,
                  ),
              textScaleFactor: Get.textScaleFactor,
              textAlign: TextAlign.left,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MaterialButton(
                  onPressed: () {},
                  height: 50,
                  minWidth: 120,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(screen.context).disabledColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.filter,
                        size: 14,
                        color: Theme.of(screen.context).disabledColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Filter',
                        textScaleFactor: Get.textScaleFactor,
                        style:
                            DefaultTextStyle.of(screen.context).style.copyWith(
                                  color: Theme.of(screen.context).disabledColor,
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                // ExportButton(),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  onPressed: onCreateNew,
                  height: 50,
                  minWidth: 120,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Create New'.tr,
                    textScaleFactor: Get.textScaleFactor,
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
            // Visibility(visible: showFilter!, child: Text('Hello World'))
          ],
        ),
      ),
    );
  }
}

class UsersHeaderWithoutExport extends GetResponsiveView {
  final String title2;
  final bool showBackButton;
  Function()? onCreateNew = () {};
  UsersHeaderWithoutExport({
    Key? key,
    required this.title2,
    this.showBackButton = false,
    this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return PaddingWrapper(
      isSliverItem: true,
      horizontalPadding: screen.isDesktop ? 50 : 20,
      topPadding: 20,
      bottomPadding: 10,
      child: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showBackButton
                ? IconButton(
                    onPressed: () {}, icon: const Icon(Icons.arrow_back_ios))
                : Container(),
            Text(
              title2,
              style: DefaultTextStyle.of(screen.context).style.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 0.4,
                    color: Theme.of(context).primaryColor,
                  ),
              textScaleFactor: Get.textScaleFactor,
              textAlign: TextAlign.left,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MaterialButton(
                  onPressed: () {},
                  height: 50,
                  minWidth: 120,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(screen.context).disabledColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.filter,
                        size: 14,
                        color: Theme.of(screen.context).disabledColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Filter',
                        textScaleFactor: Get.textScaleFactor,
                        style:
                            DefaultTextStyle.of(screen.context).style.copyWith(
                                  color: Theme.of(screen.context).disabledColor,
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  onPressed: onCreateNew,
                  height: 50,
                  minWidth: 120,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Create New'.tr,
                    textScaleFactor: Get.textScaleFactor,
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
