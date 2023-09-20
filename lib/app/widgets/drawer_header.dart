import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

class CustomDrawerHeader extends FlutterDashboardDrawerHeaderDelegate {
  @override
  double get height => Get.context!.isPhone ? 130 : 160;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DrawerHeader(
      child: Image.asset(
        'assets/drawer_logo.png',
        scale: 1,
      ),
    );
  }
}
