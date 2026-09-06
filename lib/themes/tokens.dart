part of './app_theme.dart';

/// Spacing/radius/elevation scale for the admin panel. Mirrors the naming
/// convention already used in the Client app's own token system
/// (AppSpacing/AppRadius there too) so the platform's design language reads
/// consistently across apps, even though each is its own Flutter project
/// with its own copy of these constants.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

/// Semantic colors for status chips, alerts, and data visualization —
/// separate from AppColors' brand palette so "what does this status mean"
/// stays consistent regardless of which specific brand color happens to be
/// in use.
class AppSemanticColors {
  AppSemanticColors._();

  static const Color info = Color(0xff2C71FF);
  static const Color infoBg = Color(0xffE5F6FF);
  static const Color success = Color(0xff1FAE5E);
  static const Color successBg = Color(0xffD5E8CF);
  static const Color warning = Color(0xffB4790C);
  static const Color warningBg = Color(0xffFDF2E3);
  static const Color danger = Color(0xffD8373B);
  static const Color dangerBg = Color(0xffFBE7E7);
  static const Color neutral = Color(0xff6955BF);
  static const Color neutralBg = Color(0xffF6F3FF);
}
