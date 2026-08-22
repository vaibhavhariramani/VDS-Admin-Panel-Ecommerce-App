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

  /// Date Of order column index in the online orders table.
  static const int dateColumnIndex = 1;
  final RxInt sortColumnIndex = dateColumnIndex.obs;
  /// Defaults to descending (most recent order first).
  final RxBool sortAscending = false.obs;

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
    sortOnlineOrdersByDate(ascending: sortAscending.value);
    isLoading(false);
  }

  /// Sorts the online orders table by Date Of order. Nulls (orders missing
  /// a date) always sort to the end, regardless of direction.
  void sortOnlineOrdersByDate({required bool ascending}) {
    sortAscending.value = ascending;
    sortColumnIndex.value = dateColumnIndex;
    OnlineordersData.sort((a, b) {
      final DateTime? dateA = a?.dateOfOrder;
      final DateTime? dateB = b?.dateOfOrder;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
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
