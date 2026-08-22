import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../models/Shop.dart';
import '../../../../models/UserType.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/data_service.dart';

/// Backs the "Notifications" page (formerly a Contact Us stub): lets shop
/// admins/region admins/super admins compose a message that gets written
/// to the `Notifications` Firestore collection for the client app to pick
/// up, and shows a history of what's already been sent.
class ContactUsController extends GetxController {
  final DataService _dataService = DataService.to;
  final AuthService _authService = AuthService.to;

  final FormGroup composeForm = FormGroup({
    'title': FormControl<String>(validators: [Validators.required]),
    'body': FormControl<String>(validators: [Validators.required]),
  });

  final RxBool isLoadingShops = true.obs;
  final RxBool isSending = false.obs;
  final RxBool isLoadingHistory = true.obs;
  final RxList<Shop> availableShops = <Shop>[].obs;
  final Rx<Shop?> selectedShop = Rx<Shop?>(null);
  final RxBool sendToAllShops = true.obs;
  final RxList<Map<String, dynamic>> notificationHistory =
      <Map<String, dynamic>>[].obs;

  bool get canTargetMultipleShops =>
      _authService.user.value?.user_type != UserType.SHOP_ADMIN;

  String? get _ownShopId {
    final List<String?> shops = _authService.user.value?.shops() ?? [];
    return shops.isNotEmpty ? shops.first : null;
  }

  @override
  void onInit() {
    _loadShops();
    _loadHistory();
    super.onInit();
  }

  Future<void> _loadShops() async {
    isLoadingShops(true);
    if (!canTargetMultipleShops) {
      // Shop Admins only ever notify their own shop's customers.
      sendToAllShops(false);
      isLoadingShops(false);
      return;
    }
    final List<Map<Shop, dynamic>> shopMaps = await _dataService.FetchShopIds();
    availableShops.assignAll(shopMaps.map((m) => m.keys.first));
    isLoadingShops(false);
  }

  Future<void> _loadHistory() async {
    isLoadingHistory(true);
    final List<Map<String, dynamic>> history =
        await _dataService.fetchNotifications();
    notificationHistory.assignAll(history);
    isLoadingHistory(false);
  }

  Future<void> refreshHistory() => _loadHistory();

  Future<void> send() async {
    if (composeForm.invalid) {
      composeForm.markAllAsTouched();
      return;
    }
    if (sendToAllShops.value == false && selectedShop.value == null) {
      Get.snackbar(
        'Pick a shop',
        'Choose a shop to notify, or switch to "All Shops".',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isSending(true);
    final String title = composeForm.control('title').value.toString();
    final String body = composeForm.control('body').value.toString();

    final bool success = await _dataService.sendNotification(
      title: title,
      body: body,
      targetType: sendToAllShops.value ? 'all' : 'shop',
      targetShopId: sendToAllShops.value ? null : (selectedShop.value?.id ?? _ownShopId),
      targetShopName: sendToAllShops.value ? null : selectedShop.value?.name,
    );
    isSending(false);

    if (success) {
      composeForm.reset();
      selectedShop.value = null;
      Get.snackbar(
        'Notification Sent',
        'Your message is now visible to customers.',
        duration: const Duration(seconds: 5),
      );
      await _loadHistory();
    } else {
      Get.snackbar(
        'Failed to send',
        'Something went wrong, please try again.',
        duration: const Duration(seconds: 5),
      );
    }
  }
}
