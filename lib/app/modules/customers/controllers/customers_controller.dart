import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

/// Users docs that mark a staff/operational role - anyone whose `userType`
/// matches one of these is not a customer. The client app's own signup
/// flow never writes a `userType` field at all (see Users docs created by
/// Google/Facebook sign-in), so "customer" has to mean "not staff", not a
/// literal `userType == 'CUSTOMER'` match - that string is essentially
/// never actually stored, which is why this screen used to come back
/// empty for every real shop despite real customers existing.
const Set<String> _staffUserTypes = {
  'ADMIN',
  'COUNTRY_HEAD',
  'MERCHANT',
  'SHOP_ADMIN',
  'AFFILIATES',
  'RIDER',
};

/// Read-only customer directory. Customer accounts are shared across the
/// platform, so this screen intentionally never edits their profile data.
class CustomersController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;

  List<Map<String, dynamic>> get visibleCustomers {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((c) {
      final String name = (c['fullname'] ?? c['name'] ?? '').toString().toLowerCase();
      final String email = (c['email'] ?? '').toString().toLowerCase();
      final String phone = (c['phone'] ?? c['phone_number'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query) || phone.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading(true);
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      customers.assignAll(
        snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .where((c) => !_staffUserTypes.contains(c['userType']?.toString())),
      );
    } catch (error) {
      Get.log('Unable to load customers: $error');
      customers.clear();
    }
    isLoading(false);
  }
}
