import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared design tokens for the admin panel, inspired by DESIGN-shopify.md's
/// structure (pill buttons, soft-shadow cards, thin display type) but
/// recolored to the app's existing orange + white brand instead of
/// black/mint.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xffF3AB0D); // brand orange
  static const Color primaryDark = Color(0xffD6900A);
  static const Color ink = Color(0xff1A1A1A);
  static const Color onPrimary = Colors.white;

  static const Color canvasLight = Colors.white;
  static const Color canvasCream = Color(0xffFFFBF2);
  static const Color canvasNight = Color(0xff141414);
  static const Color canvasNightElevated = Color(0xff1F1F1F);

  static const Color orangeTint10 = Color(0xffFFF1D6); // featured chip fill
  static const Color orangeTint20 = Color(0xffFFE3AD);

  static const Color hairlineLight = Color(0xffE4E4E7);
  static const Color hairlineDark = Color(0xff2A2A2A);

  static const Color shade30 = Color(0xffD4D4D8);
  static const Color shade40 = Color(0xffA1A1AA);
  static const Color shade50 = Color(0xff71717A);
  static const Color shade60 = Color(0xff52525B);

  // Card accent colors (kept for iconography/tags, muted vs the old vivid
  // tile fills so they read as accents on a light canvas, not full fills).
  static const Color accentRed = Color(0xFFE44E4F);
  static const Color accentBlue = Color(0xFF6674F1);
  static const Color accentTeal = Color(0xFF08B499);
  static const Color accentAmber = Color(0xFFE67E49);
  static const Color accentCyan = Color(0xFF02A9C7);
  static const Color accentIndigo = Color(0xFF3D5AFE);
  static const Color accentPink = Color(0xFFBA779A);
  static const Color accentSlate = Color(0xFF546E7A);
  static const Color accentGreen = Color(0xFF2E7D32);
}

class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class AppText {
  AppText._();

  static TextStyle display(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.3,
        color: color ?? _ink(context),
      );

  static TextStyle heading(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? _ink(context),
      );

  static TextStyle body(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color ?? _ink(context),
      );

  static TextStyle bodyStrong(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? _ink(context),
      );

  static TextStyle caption(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color ?? _muted(context),
      );

  static Color _ink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : AppColors.ink;

  static Color _muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : AppColors.shade50;
}

/// True on dark mode; small helper so screens don't repeat the check.
bool isDarkMode(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color appCanvas(BuildContext context) =>
    isDarkMode(context) ? AppColors.canvasNight : AppColors.canvasCream;

Color appSurface(BuildContext context) =>
    isDarkMode(context) ? AppColors.canvasNightElevated : AppColors.canvasLight;

Color appHairline(BuildContext context) =>
    isDarkMode(context) ? AppColors.hairlineDark : AppColors.hairlineLight;

/// Pill-shaped primary button — the single CTA shape across the redesign.
class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? color;

  const PillButton({
    Key? key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.filled = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    if (filled) {
      final fg = bg.computeLuminance() > 0.5 ? AppColors.ink : Colors.white;
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: _content(fg),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: bg,
        side: BorderSide(color: bg),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      child: _content(bg),
    );
  }

  Widget _content(Color fg) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: fg)),
      ],
    );
  }
}

/// Soft-shadow card container matching the light-track `card-pricing` /
/// `card-feature-cinematic` treatment, recolored to the orange/white brand.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode(context);
    return Material(
      color: appSurface(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: appHairline(context)),
            boxShadow: dark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
