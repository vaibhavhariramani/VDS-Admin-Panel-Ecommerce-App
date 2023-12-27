import 'package:get/get.dart';

import '../controllers/hot_deals_controller.dart';

class HotDealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HotDealsController>(
      () => HotDealsController(),
    );
  }
}
