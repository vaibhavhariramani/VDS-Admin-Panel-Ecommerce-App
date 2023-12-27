// import 'package:emart/app/modules/products/components/image_viewer_for_product.dart';
// import 'package:emart/app/modules/products/products_listing/controllers/products_listing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vdsadmin/app/modules/products/components/image_viewer_for_product.dart';

import '../../controllers/products_listing_controller.dart';

class buildProductImagesRow
    extends GetResponsiveView<ProductsListingController> {
  buildProductImagesRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildImageCard(
            controller.productImageUrl0, controller.isPicUploading0),
        const SizedBox(
          width: 30,
        ),
        _buildImageCard(
            controller.productImageUrl1, controller.isPicUploading1),
        const SizedBox(
          width: 30,
        ),
        _buildImageCard(
            controller.productImageUrl2, controller.isPicUploading2),
      ],
    );
  }

  Widget _buildImageCard(RxString imageUrl, RxBool loading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          // decoration: BoxDecoration(),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 12, 2, 54),
              width: 2,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          color: Theme.of(screen.context).scaffoldBackgroundColor,
          child: InkWell(
            onTap: () {
              controller.pickImage(imageUrl, loading);
            },
            child: PicViewerProductLising(20, imageUrl, loading),
          ),
        ),
      ],
    );
  }
}
