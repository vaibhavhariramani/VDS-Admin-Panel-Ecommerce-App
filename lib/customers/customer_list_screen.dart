import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'customer_detail_screen.dart';

class CustomerSummary {
  final String phoneKey;
  final String name;
  final String phone;
  final String address;
  final num totalSpent;
  final List<Map<String, dynamic>> orders;

  CustomerSummary({
    required this.phoneKey,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalSpent,
    required this.orders,
  });

  int get orderCount => orders.length;
}

String normalizePhone(String? raw) {
  if (raw == null) return '';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _query = '';

  List<CustomerSummary> _buildCustomers(List<QueryDocumentSnapshot> docs) {
    final byPhone = <String, List<Map<String, dynamic>>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = data['id'] ?? doc.id;
      final key = normalizePhone(data['phone']?.toString());
      if (key.isEmpty) continue;
      byPhone.putIfAbsent(key, () => []).add(data);
    }

    final customers = <CustomerSummary>[];
    byPhone.forEach((key, orders) {
      orders.sort((a, b) =>
          ((b['booking'] ?? 0) as num).compareTo((a['booking'] ?? 0) as num));
      final latest = orders.first;
      final name = (latest['customerName'] != null &&
              latest['customerName'].toString().isNotEmpty)
          ? latest['customerName'].toString()
          : (latest['name']?.toString().isNotEmpty == true
              ? latest['name'].toString()
              : 'Customer');
      final totalSpent = orders.fold<num>(
          0, (sum, o) => sum + ((o['total'] ?? 0) as num));
      customers.add(CustomerSummary(
        phoneKey: key,
        name: name,
        phone: latest['phone']?.toString() ?? key,
        address: latest['address']?.toString() ?? '',
        totalSpent: totalSpent,
        orders: orders,
      ));
    });

    customers.sort((a, b) => b.orders.first['booking']
        .compareTo(a.orders.first['booking']));
    return customers;
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var customers = _buildCustomers(snapshot.data!.docs);
          if (_query.trim().isNotEmpty) {
            final q = _query.trim().toLowerCase();
            customers = customers
                .where((c) =>
                    c.name.toLowerCase().contains(q) || c.phone.contains(q))
                .toList();
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${customers.length} customer${customers.length == 1 ? '' : 's'}',
                        style: AppText.heading(context)),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: AppText.body(context),
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone',
                        hintStyle:
                            AppText.body(context, color: AppColors.shade50),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: appSurface(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: appHairline(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: customers.isEmpty
                          ? Center(
                              child: Text('No customers found',
                                  style: AppText.body(context,
                                      color: AppColors.shade50)))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 140,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final c = customers[index];
                                return AppCard(
                                  padding: const EdgeInsets.all(16),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CustomerDetailScreen(customer: c),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: dark
                                            ? Colors.white12
                                            : AppColors.orangeTint10,
                                        child: Text(
                                          c.name.isNotEmpty
                                              ? c.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(c.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: AppText.bodyStrong(
                                                    context)),
                                            const SizedBox(height: 4),
                                            Text(c.phone,
                                                style: AppText.caption(
                                                    context)),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: dark
                                                    ? Colors.white12
                                                    : AppColors.orangeTint10,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.pill),
                                              ),
                                              child: Text(
                                                '${c.orderCount} order${c.orderCount == 1 ? '' : 's'}',
                                                style: AppText.caption(
                                                    context,
                                                    color:
                                                        AppColors.primaryDark),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
