import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../products_listing/controllers/products_listing_controller.dart';
// import '../products_listing/products_listing/controllers/products_listing_controller.dart';

class PicViewerProductLising
    extends GetResponsiveView<ProductsListingController> {
  double radius;
  RxString imageurl;
  RxBool loading;
  PicViewerProductLising(this.radius, this.imageurl, this.loading, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double defaultRadius = Get.height * 0.15;
    return SizedBox(
      height: Get.height * 0.3,
      width: Get.width * 0.1,
      child: Center(
        child: SizedBox.square(
          dimension: Get.width * 0.4,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () {
                  controller.pickImage(imageurl, loading);
                },
                child: Obx(
                  () => loading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Material(
                          elevation: 2,
                          // color: Theme.of(context).cardColor,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 2.0 * radius,
                              minHeight: 2.0 * radius,
                              maxWidth: 2.0 * radius,
                              maxHeight: 2.0 * radius,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageurl.value,
                              progressIndicatorBuilder: (_, __, ___) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (_, __, ___) => Padding(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                  "assets/img.png",
                                  scale: 1,
                                  height: 100,
                                  // color: Theme.of(screen.context).iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              // Positioned(
              //   right: 10,
              //   bottom: 10,
              //   child: IconButton(
              //     onPressed: controller.pickImage,
              //     icon: const Icon(IconlyLight.editSquare),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
