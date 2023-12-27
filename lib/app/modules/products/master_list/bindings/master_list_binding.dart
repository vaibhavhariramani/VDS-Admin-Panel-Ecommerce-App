import 'package:get/get.dart';

import '../controllers/master_list_controller.dart';

class MasterListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterListController>(
      () => MasterListController(),
    );
  }
}
