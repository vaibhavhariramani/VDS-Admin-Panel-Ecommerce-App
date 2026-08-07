import 'package:flutter/material.dart';
import 'package:vdsadmin/orders/offlineorders2.dart';
import 'package:vdsadmin/orders/onlineorders2.dart';

class Orderspage extends StatelessWidget {
  const Orderspage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff17191c) : const Color(0xffF5F6F8),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: const Color(0xffF3AB0D),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              final children = [
                _OrderTypeCard(
                  title: 'Online Orders',
                  subtitle: 'Orders placed by customers on the app',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFFE44E4F),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Orders2())),
                ),
                SizedBox(width: isNarrow ? 0 : 20, height: isNarrow ? 20 : 0),
                _OrderTypeCard(
                  title: 'Offline Orders',
                  subtitle: 'Walk-in bills created in-store',
                  icon: Icons.storefront_outlined,
                  color: const Color(0xFF6674F1),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OfflineOrders2())),
                ),
              ];
              return isNarrow
                  ? Column(children: children)
                  : IntrinsicHeight(child: Row(children: children.map((c) {
                      if (c is _OrderTypeCard) return Expanded(child: c);
                      return c;
                    }).toList()));
            }),
          ),
        ),
      ),
    );
  }
}

class _OrderTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OrderTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 220,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('View orders', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
