import 'package:flutter/material.dart';

import '../../../themes/app_theme.dart';

/// Replaces assets/drawer_logo.png, a leftover illustration from this
/// app's previous "E-mart" branding with that name drawn directly into the
/// image's pixels — not something a string/theme change can fix. Used for
/// both the drawer header and the login screen's brand panel (see
/// AppConfig.dashboardConfig's brandLogo in app_configs.dart), so this
/// stays legible at very different sizes rather than being a fixed
/// illustration tuned for one specific size.
class BrandMark extends StatelessWidget {
  const BrandMark({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double side = constraints.biggest.shortestSide.isFinite
            ? constraints.biggest.shortestSide
            : 120;
        final double iconSize = side.clamp(48, 220) * 0.4;
        final double fontSize = side.clamp(48, 220) * 0.14;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize * 1.6,
                height: iconSize * 1.6,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.storefront_rounded, color: Colors.white, size: iconSize),
              ),
              SizedBox(height: fontSize * 0.4),
              Text(
                'Local Bazaar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
