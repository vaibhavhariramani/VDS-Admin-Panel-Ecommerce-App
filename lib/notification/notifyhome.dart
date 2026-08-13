import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'notify.dart';
import 'send_notification.dart';

class Notificationpage extends StatelessWidget {
  const Notificationpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCanvas(context),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _NotifyTile(
                    title: 'Send All',
                    subtitle: 'Notify every customer at once',
                    icon: Icons.campaign_outlined,
                    color: AppColors.accentRed,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotifyAll())),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _NotifyTile(
                    title: 'Send Individual',
                    subtitle: 'Pick one or more customers to notify',
                    icon: Icons.person_search_outlined,
                    color: AppColors.accentIndigo,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const UserViewer())),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NotifyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppText.heading(context)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppText.caption(context)),
        ],
      ),
    );
  }
}
