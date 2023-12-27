import 'package:get/get.dart';

import '../controllers/published_products_controller.dart';

class PublishedProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublishedProductsController>(
      () => PublishedProductsController(),
    );
  }
}
