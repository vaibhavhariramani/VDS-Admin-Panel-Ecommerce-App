import 'package:get/get.dart';

import '../controllers/storefront_controller.dart';

class StorefrontBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorefrontController>(() => StorefrontController());
  }
}
