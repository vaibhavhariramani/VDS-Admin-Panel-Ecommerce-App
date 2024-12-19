import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../../../models/Shop.dart';
import '../../../../../models/Users.dart';
import '../../../../../themes/app_theme.dart';
import '../../../../widgets/components/common_card.dart';
import '../../controllers/shop_listing_controller.dart';

class ShopCard extends GetResponsiveView<ShopListingController> {
  final bool isMasterListItem;
  final bool isScheduledListItem;
  final bool isPublishedListItem;
  final Map<Shop, Users?> shopItem;
  final int index;
  // final VoidCallback? onSchedulePressed;
  // final VoidCallback? onPublishPressed;
  // final VoidCallback? onCancleressed;

  ShopCard({
    Key? key,
    this.isMasterListItem = false,
    this.isScheduledListItem = false,
    this.isPublishedListItem = false,
    // this.onSchedulePressed,
    // this.onPublishPressed,
    // this.onCancleressed,
    required this.index,
    required this.shopItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screen.context = context;
    return CommonCard(
      height: 450,
      width: 380,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: shopItem.keys.first.img_token![0],
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).indicatorColor,
                  ),
                ),
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textScaleFactor: Get.textScaleFactor,
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: shopItem.keys.first.name,
                          style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: 14,
                              ),
                        ),
                        const TextSpan(
                          text: '\n',
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   '${shopItem.keys.first.email}',
                  //   style: DefaultTextStyle.of(context).style.copyWith(
                  //         fontSize: 14,
                  //       ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Managed By ',
                          style: TextStyle(fontSize: 11),
                        ),
                        Expanded(
                          child: Text(
                            shopItem.values.first!.fullname!,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.red),
                            maxLines: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // RatingBarIndicator(
                        //   rating: shopItem.keys.first.rating!,
                        //   itemBuilder: (context, index) => const Icon(
                        //     Icons.star,
                        //     color: Colors.amber,
                        //   ),
                        //   itemCount: 5,
                        //   itemSize: 15.0,
                        //   direction: Axis.horizontal,
                        // ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '(${shopItem.keys.first.rating})',
                          textScaleFactor: Get.textScaleFactor,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 10,
            ),
            MaterialButton(
              onPressed: () async {
                // controller.shopdetail = shopItem.keys.first.ProductsShop!;
                print(shopItem.keys.first.id);
                controller.shopdetails(shopItem.keys.first);
                controller.showShopDetails(true);
                controller.index = index;
                await controller.fetchAllProductsbyCat(shopItem.keys.first.id!);
                // controller.showShopDetails(true);
              },
              color: Theme.of(screen.context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 46,
              minWidth: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Details",
                    textScaleFactor: Get.textScaleFactor,
                    style: DefaultTextStyle.of(screen.context).style.copyWith(
                          fontSize: Theme.of(screen.context)
                              .textTheme
                              .labelLarge
                              ?.fontSize,
                          color: AppColors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
