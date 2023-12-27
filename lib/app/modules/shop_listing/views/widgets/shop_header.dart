import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../../themes/app_theme.dart';
import '../../../../widgets/utils/padding_wrapper.dart';
import '../../../merchants/controllers/merchants_controller.dart';
import '../../controllers/shop_listing_controller.dart';

class ShopListingHeader extends GetResponsiveView {
  final String title;
  final String subTitle;
  final int totalCount;
  VoidCallback? onCreateNew;
  final List<Widget> actions;
  ShopListingHeader({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.totalCount,
    required this.actions,
    this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MerchantsController merchantsController = Get.find<MerchantsController>();
    screen.context = context;
    ShopListingController shopListingController = Get.find();
    MerchantsController controller = Get.put(MerchantsController());
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
            // Visibility(
            //   visible: merchantsController.shopGridView.isTrue && !shopListingController.createNewShop.value,
            //   child: IconButton(
            //       onPressed: () {
            //         merchantsController.shopGridView.toggle();
            //       },
            //       icon: Icon(Icons.arrow_back_ios)),
            // ),
            Visibility(
              visible: shopListingController.createNewShop.value,
              child: IconButton(
                  onPressed: () {
                    shopListingController.createNewShop.toggle();
                  },
                  icon: Icon(Icons.arrow_back_ios)),
            ),
            Visibility(
              visible: controller.shopGridView.value &&
                  !shopListingController.createNewShop.value,
              child: IconButton(
                  onPressed: () {
                    controller.shopGridView.toggle();
                  },
                  icon: Icon(Icons.arrow_back_ios)),
            ),
            RichText(
              textScaleFactor: Get.textScaleFactor,
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const TextSpan(
                    text: '\n',
                  ),
                  TextSpan(
                    text: '$totalCount $subTitle',
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.4,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: actions,
            ),
            const SizedBox(
              width: 10,
            ),
            MaterialButton(
              onPressed: onCreateNew,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Theme.of(context).primaryColor,
              child: Text(
                'Create New Shop'.tr,
                textScaleFactor: Get.textScaleFactor,
                style: DefaultTextStyle.of(screen.context).style.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
