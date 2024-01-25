import 'package:get/get.dart';

class BillingController extends GetxController {
  //TODO: Implement BillingController
  final RxBool isloading = false.obs;
  final count = 0.obs;
  RxInt activeUserCount = 0.obs;
  RxInt inActiveUserCount = 0.obs;
  RxInt requestedUser = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
