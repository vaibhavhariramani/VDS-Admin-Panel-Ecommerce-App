import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

import 'components/brand_mark.dart';

class CustomDrawerHeader extends FlutterDashboardDrawerHeaderDelegate {
  @override
  double get height => Get.context!.isPhone ? 130 : 160;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const DrawerHeader(
      child: BrandMark(),
    );
  }
}
