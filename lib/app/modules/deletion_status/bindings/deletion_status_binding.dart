import 'package:get/get.dart';

import '../controllers/deletion_status_controller.dart';

class DeletionStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeletionStatusController>(
      () => DeletionStatusController(),
    );
  }
}
