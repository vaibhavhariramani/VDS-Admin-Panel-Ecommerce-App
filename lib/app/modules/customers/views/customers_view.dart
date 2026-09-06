import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import '../../../../themes/app_theme.dart';
import '../controllers/customers_controller.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Customers'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadCustomers)],
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or phone',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ),
              Expanded(child: _buildList(context)),
            ],
          );
        }),
      );

  Widget _buildList(BuildContext context) {
    final customers = controller.visibleCustomers;
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.grey),
            const SizedBox(height: AppSpacing.md),
            Text(
              controller.customers.isEmpty ? 'No customer accounts found.' : 'No customers match your search.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final name = (customer['fullname'] ?? customer['name'] ?? 'Customer').toString();
        final email = (customer['email'] ?? '').toString();
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(email.isEmpty ? 'No email address' : email),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDetails(context, customer),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> customer) {
    String value(String key, [String alternate = '']) =>
        (customer[key] ?? (alternate.isEmpty ? null : customer[alternate]) ?? 'Not provided').toString();
    Get.dialog(AlertDialog(
      title: Text(value('fullname', 'name')),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Email', value('email')),
            _DetailRow('Phone', value('phone', 'phone_number')),
            _DetailRow('Country', value('Country', 'country')),
            _DetailRow('Customer ID', value('id')),
          ],
        ),
      ),
      actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
