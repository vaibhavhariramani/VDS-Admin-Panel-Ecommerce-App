import 'package:get/get.dart';
import 'package:vdsadmin/models/Bill.dart';
import 'package:vdsadmin/models/Orders.dart';

import '../../../../services/fetch_data.dart';

class OrdersController extends GetxController {
  RxBool showOnlineOrdersTable = false.obs;
  RxBool showOfflineOrdersTable = false.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingOffline = false.obs;
  final count = 0.obs;
  final FetchService _fetchData = FetchService.to;

  get isInviting => null;

  RxList<Orders?> OnlineordersData = RxList<Orders>();
  RxList<Bill> offlineOrdersData = RxList<Bill>();

  @override
  void onInit() {
    _fetch();
    super.onInit();
  }

  void _fetch() async {
    await _fetchOnlineOrders();
    await _fetchOfflineOrders();
  }

  Future<void> _fetchOnlineOrders() async {
    OnlineordersData.clear();
    isLoading(true);
    await _fetchData
        .fetchOnlineOrdersUsingShopId()
        .then((RxList<Orders?> response) {
      OnlineordersData = response;
    });
    isLoading(false);
  }

  Future<void> _fetchOfflineOrders() async {
    isLoadingOffline(true);
    try {
      final RxList<Bill> response =
          await _fetchData.fetchOfflineOrdersUsingShopId();
      offlineOrdersData = response;
    } finally {
      isLoadingOffline(false);
    }
  }

  /// Re-fetches offline orders — called when the Offline Orders tile is
  /// opened so a bill created since the page first loaded (e.g. a POS sale
  /// rung up moments ago in another tab) actually shows up.
  Future<void> refreshOfflineOrders() => _fetchOfflineOrders();

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
