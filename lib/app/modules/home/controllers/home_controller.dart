import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Product.dart';
import '../../../../models/UserStatus.dart';
import '../../../../models/UserType.dart';
import '../../../../models/Users.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';
import '../../../../services/fetch_data.dart';

class ShopVisitorChartData {
  ShopVisitorChartData(this.x, this.y);
  String? x;
  double? y;

  ShopVisitorChartData.fromJson(Map<String, dynamic> json) {
    x = json['month'];
    y = json['visitors'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['month'] = x;
    data['visitors'] = y;
    return data;
  }
}

/// Any of these substrings (case-insensitive) marks an order as "just
/// placed, not yet actioned" — covers both the admin panel's own
/// `'Order Placed'` convention and the client app's `'placed'`.
bool isPlacedStatus(String? status) =>
    status != null && status.toLowerCase().contains('placed');

class HomeController extends GetxController {
  final AuthService _authService = AuthService.to;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxInt activeUserCount = 0.obs;
  RxInt inActiveUserCount = 0.obs;
  RxInt requestedUser = 0.obs;
  final RxBool isloading = false.obs;
  Users? get user => _authService.user.value;
  final AuthService userService = AuthService.to;
  UserType get userType => _authService.userType.value;

  /// Orders placed in each of the last 12 months, for the shop currently
  /// in scope (or across all shops for roles above Shop Admin). Was
  /// previously a hardcoded "Visitors" dataset — there's no visitor
  /// tracking in this app at all, so order volume is the closest real
  /// metric available for that chart.
  final RxList<ShopVisitorChartData> data = <ShopVisitorChartData>[].obs;
  final RxBool isLoadingChart = false.obs;

  final RxBool isLoadingAlerts = false.obs;
  final RxList<Map<String, dynamic>> newlyPlacedOrders =
      <Map<String, dynamic>>[].obs;
  final RxList<Product> lowStockProducts = <Product>[].obs;
  final RxList<Product> expiringSoonProducts = <Product>[].obs;

  static const int _lowStockThreshold = 5;
  static const int _expiringSoonWindowDays = 7;

  bool _hasShownNewOrderPopup = false;
  bool _hasLoadedDashboardData = false;

  Future<void> userCountActive() async {
    // isloading(true);
    await DataService.to
        .GetUserCount(
          status: UserStatus.ACTIVE,
          userType: UserType.CUSTOMER,
        )
        .then(
          (value) => activeUserCount(
            value,
          ),
        );
    // isloading(false);
  }

  Future<void> userCountInactive() async {
    await DataService.to
        .GetUserCount(
          status: UserStatus.INACTIVE,
          userType: UserType.CUSTOMER,
        )
        .then(
          (value) => inActiveUserCount(
            value,
          ),
        );
  }

  void _fetchdata() async {
    userCountActive();
    userCountInactive();
    final Users currentUser = userService.user.value ??
        await userService.user.stream.firstWhere((u) => u != null) as Users;
    await DataService.to.FetchInvitedUserData(id: currentUser.id);
    requestedUser(DataService.to.invitedUserCount);
  }

  DateTime? _resolveOrderDate(Map<String, dynamic> orderData) {
    final dynamic dateOfOrder = orderData['dateOfOrder'];
    if (dateOfOrder is Timestamp) return dateOfOrder.toDate();
    final dynamic booking = orderData['booking'];
    if (booking is Timestamp) return booking.toDate();
    if (booking is int) return DateTime.fromMicrosecondsSinceEpoch(booking);
    return null;
  }

  /// Loads the order-volume chart and the "new orders" / "stock alerts"
  /// panel together, since both read the same `OnlineOrders`/`Products`
  /// data for the current shop. Guarded so `HomeView.build()` calling
  /// `controller.onInit()` on every rebuild doesn't refire this on a loop.
  Future<void> loadDashboardData({bool force = false}) async {
    if (_hasLoadedDashboardData && !force) return;
    _hasLoadedDashboardData = true;
    isLoadingChart(true);
    isLoadingAlerts(true);

    // `AuthService.userType` defaults to UserType.ADMIN until the
    // post-login Firestore profile fetch resolves it to the real role.
    // onInit() used to read it immediately, so a Shop Admin was briefly
    // (mis)treated as platform Admin - which made _loadOrderTrendAndAlerts
    // below skip its shopId filter and pull every shop's OnlineOrders into
    // this admin's "New Orders" popup. Waiting for the resolved user first
    // means `userType` is always the real role by the time it's read here.
    if (userService.user.value == null) {
      await userService.user.stream.firstWhere((u) => u != null);
    }

    final String? shopId = userType == UserType.SHOP_ADMIN
        ? await FetchService.to.fetchShopId()
        : null;

    if (userType == UserType.SHOP_ADMIN && shopId == null) {
      // Shop Admin with no resolvable shop: nothing to show, and
      // definitely not every other shop's orders/stock as a fallback.
      isLoadingChart(false);
      isLoadingAlerts(false);
      return;
    }

    await Future.wait([
      _loadOrderTrendAndAlerts(shopId),
      if (shopId != null) _loadStockAlerts(shopId),
    ]);

    isLoadingChart(false);
    isLoadingAlerts(false);

    if (newlyPlacedOrders.isNotEmpty && !_hasShownNewOrderPopup) {
      _hasShownNewOrderPopup = true;
      Get.dialog(
        AlertDialog(
          title: const Text('New Orders'),
          content: Text(
            '${newlyPlacedOrders.length} order${newlyPlacedOrders.length == 1 ? '' : 's'} '
            'placed and awaiting action.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadOrderTrendAndAlerts(String? shopId) async {
    try {
      Query<Object?> query = _firestore.collection('OnlineOrders');
      if (shopId != null) {
        query = query.where('shopId', isEqualTo: shopId);
      }
      final QuerySnapshot<Object?> snapshot = await query.get();

      final DateTime now = DateTime.now();
      final List<DateTime> months = List.generate(
        12,
        (int i) => DateTime(now.year, now.month - (11 - i)),
      );
      final Map<String, int> counts = {
        for (final DateTime m in months) DateFormat('yyyy-MM').format(m): 0,
      };

      final List<Map<String, dynamic>> placedOrders = [];
      for (final QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime? orderDate = _resolveOrderDate(data);
        if (orderDate != null) {
          final String key =
              DateFormat('yyyy-MM').format(DateTime(orderDate.year, orderDate.month));
          if (counts.containsKey(key)) {
            counts[key] = counts[key]! + 1;
          }
        }
        if (isPlacedStatus(data['status']?.toString())) {
          placedOrders.add({'id': doc.id, ...data});
        }
      }

      data.assignAll(
        months.map(
          (DateTime m) => ShopVisitorChartData(
            DateFormat('MMM').format(m),
            counts[DateFormat('yyyy-MM').format(m)]!.toDouble(),
          ),
        ),
      );
      newlyPlacedOrders.assignAll(placedOrders);
    } catch (e) {
      print('Error loading order trend: $e');
    }
  }

  Future<void> _loadStockAlerts(String shopId) async {
    try {
      final List<Product> products =
          await FetchService.to.fetchAllProductsByShop(shopId);
      final DateTime now = DateTime.now();
      final DateTime soonCutoff =
          now.add(const Duration(days: _expiringSoonWindowDays));

      lowStockProducts.assignAll(
        products.where((Product p) => p.count <= _lowStockThreshold),
      );
      expiringSoonProducts.assignAll(
        products.where((Product p) {
          final DateTime? expiresOn = p.expires_on;
          return expiresOn != null &&
              expiresOn.isAfter(now) &&
              expiresOn.isBefore(soonCutoff);
        }),
      );
    } catch (e) {
      print('Error loading stock alerts: $e');
    }
  }

  @override
  void onReady() {
    if (userType == UserType.ADMIN) {
      // FlutterDashboardNavService.to.enabledRoutes.addEntries(const [
      //   MapEntry("Dashboard", true), //Firstpage alsways need to be enabled
      //   MapEntry("Products", false),
      //   MapEntry("Help", false),
      // ]);
    }
    super.onReady();
  }

  @override
  void onInit() {
    _fetchdata();
    loadDashboardData();
    super.onInit();
  }

  @override
  void onClose() {}
}
