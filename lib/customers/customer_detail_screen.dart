import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../orders/order_details.dart';
import '../theme/app_theme.dart';
import 'customer_list_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerSummary customer;

  const CustomerDetailScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    final format = DateFormat.yMMMd('en_US');
    final time = DateFormat.jm();

    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Customer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          dark ? Colors.white12 : AppColors.orangeTint10,
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name, style: AppText.heading(context)),
                          const SizedBox(height: 4),
                          Text(customer.phone, style: AppText.body(context)),
                          if (customer.address.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(customer.address,
                                style: AppText.caption(context)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Orders',
                      value: '${customer.orderCount}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Total spent',
                      value: '₹${customer.totalSpent}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<num?>(
                      future: fetchLoyaltyPoints(customer.uid),
                      builder: (context, snapshot) {
                        final points = snapshot.data;
                        return _StatCard(
                          label: 'Loyalty points',
                          value: points == null
                              ? (snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '…'
                                  : '—')
                              : points.toStringAsFixed(0),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Recent orders', style: AppText.heading(context)),
              const SizedBox(height: 12),
              ...customer.orders.map((order) {
                final booking = order['booking'];
                String dateStr = '';
                try {
                  final dt = DateTime.fromMicrosecondsSinceEpoch(booking);
                  dateStr = '${format.format(dt)}  ${time.format(dt)}';
                } catch (_) {}
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrderDetails(mp: order)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateStr, style: AppText.bodyStrong(context)),
                              const SizedBox(height: 4),
                              Text('${order['status'] ?? ''}',
                                  style: AppText.caption(context)),
                            ],
                          ),
                        ),
                        Text('₹${order['total']}',
                            style: AppText.bodyStrong(context)),
                        const SizedBox(width: 10),
                        Icon(Icons.chevron_right,
                            color: AppColors.shade40),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption(context)),
          const SizedBox(height: 6),
          Text(value, style: AppText.display(context)),
        ],
      ),
    );
  }
}
