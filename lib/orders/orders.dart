import 'package:flutter/material.dart';
import 'package:vdsadmin/orders/offlineorders2.dart';
import 'package:vdsadmin/orders/onlineorders2.dart';
import 'package:vdsadmin/theme/app_theme.dart';

class Orderspage extends StatelessWidget {
  const Orderspage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppColors.primary,
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
                  color: AppColors.accentRed,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Orders2())),
                ),
                SizedBox(width: isNarrow ? 0 : 20, height: isNarrow ? 20 : 0),
                _OrderTypeCard(
                  title: 'Offline Orders',
                  subtitle: 'Walk-in bills created in-store',
                  icon: Icons.storefront_outlined,
                  color: AppColors.accentBlue,
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
    return SizedBox(
      height: 220,
      child: AppCard(
        padding: const EdgeInsets.all(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDarkMode(context) ? 0.24 : 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading(context)),
                const SizedBox(height: 6),
                Text(subtitle, style: AppText.caption(context)),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View orders',
                        style: AppText.bodyStrong(context, color: color)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: color, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
