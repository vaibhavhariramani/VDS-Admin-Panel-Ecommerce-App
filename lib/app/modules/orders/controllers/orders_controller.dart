import 'package:get/get.dart';
import 'package:vdsadmin/models/Orders.dart';

import '../../../../services/fetch_data.dart';

class OrdersController extends GetxController {
  //TODO: Implement OrdersController
  RxBool showOnlineOrdersTable = false.obs;
  RxBool showOfflineOrdersTable = false.obs;
  RxBool isLoading = false.obs;
  final count = 0.obs;
  final FetchService _fetchData = FetchService.to;

  get isInviting => null;

  RxList<Orders?> OnlineordersData = RxList<Orders>();
  @override
  void onInit() {
    _fetch();
    super.onInit();
  }

  void _fetch() async {
    await _fetchOnlineOrders();
  }

  Future<void> _fetchOnlineOrders() async {
    print("\n");
    print("Fetching All orders ");
    OnlineordersData.clear();
    isLoading(true).obs;
    await Future.delayed(1000.milliseconds, () async {
      await _fetchData
          .fetchOnlineOrdersUsingShopId()
          .then((RxList<Orders?> response) {
        OnlineordersData = response;
      });

      isLoading(false);
    });
    print("Online orders Data is Fetched -----------");
    print(OnlineordersData.first);
    isLoading(false).obs;
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
