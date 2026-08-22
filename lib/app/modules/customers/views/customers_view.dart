import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';
import '../controllers/customers_controller.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Customers'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadCustomers)]),
    body: Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.customers.isEmpty) return const Center(child: Text('No customer accounts found.'));
      return ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: controller.customers.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final customer = controller.customers[index];
          final name = (customer['fullname'] ?? customer['name'] ?? 'Customer').toString();
          final email = (customer['email'] ?? '').toString();
          return Card(child: ListTile(
            leading: CircleAvatar(child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
            title: Text(name), subtitle: Text(email.isEmpty ? 'No email address' : email), trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDetails(context, customer),
          ));
        },
      );
    }),
  );

  void _showDetails(BuildContext context, Map<String, dynamic> customer) {
    String value(String key, [String alternate = '']) => (customer[key] ?? customer[alternate] ?? 'Not provided').toString();
    Get.dialog(AlertDialog(title: Text(value('fullname', 'name')), content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Email: ${value('email')}'), const SizedBox(height: 10),
      Text('Phone: ${value('phone', 'phone_number')}'), const SizedBox(height: 10),
      Text('Country: ${value('Country', 'country')}'), const SizedBox(height: 10),
      Text('Customer ID: ${value('id')}'),
    ])), actions: [TextButton(onPressed: Get.back, child: const Text('Close'))]));
  }
}
