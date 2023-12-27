import 'package:get/get.dart';

import '../controllers/shop_listing_controller.dart';

class ShopListingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopListingController>(
      () => ShopListingController(),
    );
  }
}
