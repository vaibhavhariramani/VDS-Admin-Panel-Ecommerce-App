import 'package:get/get.dart';

import '../controllers/scheduled_products_controller.dart';

class ScheduledProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduledProductsController>(
      () => ScheduledProductsController(),
    );
  }
}
