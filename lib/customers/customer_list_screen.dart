import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'customer_detail_screen.dart';

class CustomerSummary {
  final String phoneKey;
  final String name;
  final String phone;
  final String address;
  final String uid;
  final num totalSpent;
  final List<Map<String, dynamic>> orders;

  CustomerSummary({
    required this.phoneKey,
    required this.name,
    required this.phone,
    required this.address,
    required this.uid,
    required this.totalSpent,
    required this.orders,
  });

  int get orderCount => orders.length;
}

/// Available (spendable) loyalty points for [uid], or null if they have no
/// ClubCards/{cardId} doc yet (see lib/loyalty/club_card_api.dart - a card's
/// doc id is the printed/QR value, but it carries a `uid` field pointing
/// back to the owning customer, which is what this looks up by).
Future<num?> fetchLoyaltyPoints(String uid) async {
  if (uid.isEmpty) return null;
  final snap = await FirebaseFirestore.instance
      .collection('ClubCards')
      .where('uid', isEqualTo: uid)
      .limit(1)
      .get();
  if (snap.docs.isEmpty) return null;
  final data = snap.docs.first.data();
  final points = (data['points'] as num?) ?? 0;
  final converted = (data['convertedPoints'] as num?) ?? 0;
  return points - converted;
}

String normalizePhone(String? raw) {
  if (raw == null) return '';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

/// Aggregates raw Orders docs into one CustomerSummary per customer,
/// grouped by normalized phone. Shared by CustomerListScreen and the
/// Notification page's "Send Individual" screen.
List<CustomerSummary> buildCustomerSummaries(List<QueryDocumentSnapshot> docs) {
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
    final totalSpent =
        orders.fold<num>(0, (sum, o) => sum + ((o['total'] ?? 0) as num));
    customers.add(CustomerSummary(
      phoneKey: key,
      name: name,
      phone: latest['phone']?.toString() ?? key,
      address: latest['address']?.toString() ?? '',
      uid: latest['user']?.toString() ?? '',
      totalSpent: totalSpent,
      orders: orders,
    ));
  });

  customers.sort(
      (a, b) => b.orders.first['booking'].compareTo(a.orders.first['booking']));
  return customers;
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _query = '';
  final Map<String, Future<num?>> _loyaltyCache = {};

  Future<num?> _loyaltyPointsFor(String uid) {
    if (uid.isEmpty) return Future.value(null);
    return _loyaltyCache.putIfAbsent(uid, () => fetchLoyaltyPoints(uid));
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
          var customers = buildCustomerSummaries(snapshot.data!.docs);
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
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
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
                                              FutureBuilder<num?>(
                                                future: _loyaltyPointsFor(c.uid),
                                                builder: (context, snap) {
                                                  final points = snap.data;
                                                  if (points == null) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: dark
                                                          ? Colors.white12
                                                          : AppColors.accentAmber
                                                              .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.pill),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.star,
                                                            size: 12,
                                                            color: AppColors
                                                                .accentAmber),
                                                        const SizedBox(width: 3),
                                                        Text(
                                                          '${points.toStringAsFixed(0)} pts',
                                                          style: AppText.caption(
                                                              context,
                                                              color: AppColors
                                                                  .accentAmber),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              ],
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
