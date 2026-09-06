import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vdsadmin/models/Bill.dart';
import 'package:vdsadmin/models/Orders.dart';

import '../../../../services/fetch_data.dart';

class OrdersController extends GetxController {
  RxBool showOnlineOrdersTable = false.obs;
  RxBool showOfflineOrdersTable = false.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingOffline = false.obs;
  final FetchService _fetchData = FetchService.to;

  RxList<Orders?> OnlineordersData = RxList<Orders>();
  RxList<Bill> offlineOrdersData = RxList<Bill>();

  final RxString searchQuery = ''.obs;
  /// null = all statuses.
  final Rx<String?> statusFilter = Rx<String?>(null);

  /// What the table actually renders — [OnlineordersData] filtered by
  /// search (name/phone/address) and status, computed fresh each time
  /// either input changes rather than a second synced list to keep in
  /// step.
  List<Orders?> get visibleOrders {
    final String query = searchQuery.value.trim().toLowerCase();
    final String? status = statusFilter.value;
    return OnlineordersData.where((Orders? order) {
      if (order == null) return true;
      if (status != null && order.status != status) return false;
      if (query.isEmpty) return true;
      return (order.customerName?.toLowerCase().contains(query) ?? false) ||
          (order.customerNumber?.toLowerCase().contains(query) ?? false) ||
          (order.Address?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Order count per status, for the filter chips — computed from the full
  /// (unfiltered by status) list so a chip's count doesn't change just
  /// because another chip is selected.
  int countForStatus(String status) =>
      OnlineordersData.where((Orders? o) => o?.status == status).length;

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

  /// Permanently removes an order. There's no undo — the caller is
  /// expected to confirm with the admin first (see the delete icon's
  /// confirmation dialog in table_datasrc_orders.dart).
  Future<void> deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('OnlineOrders').doc(orderId).delete();
    OnlineordersData.removeWhere((Orders? o) => o?.orderId == orderId);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
