import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

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
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Users').where('userType', isEqualTo: 'CUSTOMER').get();
      customers.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}));
    } catch (error) {
      Get.log('Unable to load customers: $error');
      customers.clear();
    }
    isLoading(false);
  }
}
