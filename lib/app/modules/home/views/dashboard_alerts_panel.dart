import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/Product.dart';
import '../controllers/home_controller.dart';

/// Sits below the dashboard's order-trend chart: new orders still awaiting
/// action, plus stock that's low or expiring soon. All three lists come
/// from [HomeController.loadDashboardData].
class DashboardAlertsPanel extends StatelessWidget {
  const DashboardAlertsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Obx(() {
      if (controller.isLoadingAlerts.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _AlertCard(
              title: 'New Orders',
              icon: Icons.receipt_long,
              color: Colors.blue,
              emptyText: 'No new orders waiting.',
              items: controller.newlyPlacedOrders
                  .map((Map<String, dynamic> o) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.shopping_bag_outlined),
                        title: Text(o['name']?.toString().isNotEmpty == true
                            ? o['name'].toString()
                            : (o['id']?.toString() ?? '')),
                        subtitle: Text('₹${o['total'] ?? 0}'),
                      ))
                  .toList(),
            ),
            _AlertCard(
              title: 'Low Stock',
              icon: Icons.inventory_2_outlined,
              color: Colors.orange,
              emptyText: 'No products running low.',
              items: controller.lowStockProducts
                  .map((Product p) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.warning_amber_outlined),
                        title: Text(p.name),
                        subtitle: Text('${p.count} left'),
                      ))
                  .toList(),
            ),
            _AlertCard(
              title: 'Expiring Soon',
              icon: Icons.hourglass_bottom,
              color: Colors.red,
              emptyText: 'Nothing expiring in the next 7 days.',
              items: controller.expiringSoonProducts
                  .map((Product p) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.event_busy_outlined),
                        title: Text(p.name),
                        subtitle: Text(
                          p.expires_on != null
                              ? p.expires_on!.toString().substring(0, 10)
                              : '',
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String emptyText;
  final List<Widget> items;

  const _AlertCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.emptyText,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$title (${items.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    emptyText,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView(
                    shrinkWrap: true,
                    children: items,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
