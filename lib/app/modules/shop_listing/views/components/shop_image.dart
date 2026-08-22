import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/Shop.dart';

class ShopImageCard extends StatelessWidget {
  Rx<Shop> shopItem;
  ShopImageCard(this.shopItem);
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          width:
              //  (screen.isPhone || screen.context.isSmallTablet) &&
              //               !screen.context.isLargeTablet?
              //               double.maxFinite:
              270,
          height: 210,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: CachedNetworkImage(
            imageUrl: shopItem.value.img_token ?? '',
            progressIndicatorBuilder: (context, url, progress) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).indicatorColor,
              ),
            ),
            fit: BoxFit.fill,
          ),
        ));
  }
}
