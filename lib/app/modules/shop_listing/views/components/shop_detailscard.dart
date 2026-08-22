import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../../../../models/Shop.dart';
import '../../controllers/shop_listing_controller.dart';
import '../widgets/shop_branding_dialog.dart';

class ShopDetailsCard extends GetResponsiveView<ShopListingController> {
  final Rx<Shop> shopItem;

  ShopDetailsCard(this.shopItem);
  @override
  Widget build(BuildContext context) {
    Get.log(controller.index.toString());
    return Obx(() => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: context.isPhone
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: context.isPhone
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(shopItem.value.name!,
                        textScaleFactor: Get.textScaleFactor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w600)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          content: SizedBox(
                            width: Get.width * 0.4,
                            height: Get.height * 0.8,
                            child: ShopBrandingDialog(
                              shop: shopItem.value,
                              onSaved: () => controller.onInit(),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Branding'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Managed By ',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    controller
                            .allShops1[controller.index].values.first?.fullname
                            ?.toString() ??
                        'Manager',
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Contact:  ',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    shopItem.value.phn_number?.toString() ?? 'Phone number',
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Email:  ',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    controller.allShops1[controller.index].values.first?.email
                            ?.toString() ??
                        'e-mail',
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // RatingBarIndicator(
                        //   rating: shopItem.value.rating!,
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
                          shopItem.value.rating?.toString() ?? '4.5',
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
                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: const [
                  //     Icon(
                  //       IconlyBold.star,
                  //       color: Color(0xFFFF9F43),
                  //       size: 14,
                  //     ),
                  //     Icon(
                  //       IconlyBold.star,
                  //       color: Color(0xFFFF9F43),
                  //       size: 14,
                  //     ),
                  //     Icon(
                  //       IconlyBold.star,
                  //       color: Color(0xFFFF9F43),
                  //       size: 14,
                  //     ),
                  //     Icon(
                  //       IconlyBold.star,
                  //       color: Color(0xFFFF9F43),
                  //       size: 14,
                  //     ),
                  //     Icon(
                  //       IconlyLight.star,
                  //       // color: Colors.black,
                  //       size: 14,
                  //     ),
                  //   ],
                  // ),
                  // Text(
                  //   shopItem.value.rating?.toString() ?? '4.5',
                  //   textScaleFactor: Get.textScaleFactor,
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
              ),
              Text(
                shopItem.value.phy_address?.toString() ?? 'Address',
                textScaleFactor: Get.textScaleFactor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ));
  }
}
