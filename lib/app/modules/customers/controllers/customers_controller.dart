import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

/// Read-only customer directory. Customer accounts are shared across the
/// platform, so this screen intentionally never edits their profile data.
class CustomersController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;

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
