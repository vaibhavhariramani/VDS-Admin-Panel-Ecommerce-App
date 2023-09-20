part of './app_theme.dart';

class AppColors {
  static const Color primaryColor = Color(0xffDF0019);
  static const Color white = Color(0xffF1F1F2);
  static const Color black = Color(0xff242222);
  static const Color green = Color(0xff2ED47A);
  static const Color greencard = Color(0xffD5E8CF);
  static const Color greentext = Color(0xff006E1B);
  static const Color yellow = Color(0xffFF9F43);
  static const Color grey = Color(0xff6E6B7B);
  static const Color grey2 = Color(0xff525F7F);
  static const Color purple = Color(0xff7367F0);
  static const Color bluecard = Color(0xffE5F6FF);
  static const Color bluetext = Color(0xff2C71FF);

  static Gradient gradient1 = LinearGradient(
    colors: <Color>[
      const Color(0xFFEA5455),
      const Color(0xFFEA5455).withOpacity(0.7),
    ],
    begin: const FractionalOffset(0.0, 0.0),
    end: const FractionalOffset(1.0, 1.0),
    stops: const <double>[0.0, 1.0],
    tileMode: TileMode.clamp,
  );
}
