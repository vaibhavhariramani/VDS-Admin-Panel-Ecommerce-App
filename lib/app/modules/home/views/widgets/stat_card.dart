import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../../../../themes/app_theme.dart';
import '../../../../widgets/components/common_card.dart';

/// One dashboard stat card's content. Deliberately just data, not a
/// pre-built widget — [StatCard] below is the one place that turns this
/// into UI, shared by every role's dashboard instead of each role
/// duplicating its own card layout.
class StatCardData {
  final int count;
  final String title;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const StatCardData({
    required this.count,
    required this.title,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}

class StatCard extends StatelessWidget {
  final StatCardData data;
  const StatCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      height: 120,
      color: data.backgroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.count}'.replaceAllMapped(numberFormatterRegex, formatNumberCount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: data.color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: data.color),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
        ],
      ),
    );
  }
}
