import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

part './colors.dart';

part 'light_theme.dart';
part 'dark_theme.dart';

class AppTheme {
  static TextStyle globalFontStyle = GoogleFonts.poppins();
  static ThemeData get _lightTheme => ThemeData.light();

  static ThemeData get _darkTheme => ThemeData.dark();

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      );

  static CardTheme get cardTheme => const CardTheme(
        clipBehavior: Clip.antiAliasWithSaveLayer,
      );

  static DrawerThemeData get drawerTheme => DrawerThemeData(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      );

  static final TextTheme globalTextTheme =
      GoogleFonts.poppinsTextTheme().copyWith(
    headline1: globalFontStyle.copyWith(
      fontSize: 30,
    ),
    headline2: globalFontStyle.copyWith(
      fontSize: 28,
    ),
    headline3: globalFontStyle.copyWith(
      fontSize: 26,
    ),
    headline4: globalFontStyle.copyWith(
      fontSize: 24,
    ),
    headline5: globalFontStyle.copyWith(
      fontSize: 22,
    ),
    headline6: globalFontStyle.copyWith(
      fontSize: 20,
    ),
    subtitle1: globalFontStyle.copyWith(
      fontSize: 14,
    ),
    subtitle2: globalFontStyle.copyWith(
      fontSize: 12,
    ),
    bodyText1: globalFontStyle.copyWith(
      fontSize: 16,
    ),
    bodyText2: globalFontStyle.copyWith(
      fontSize: 14,
    ),
    caption: globalFontStyle.copyWith(
      fontSize: 12,
    ),
    button: globalFontStyle.copyWith(
      fontSize: 16,
    ),
    overline: globalFontStyle.copyWith(
      fontSize: 12,
    ),
  );

  static ThemeData get lightTheme => _lightTheme.copyWith(
        indicatorColor: Colors.green,
        primaryColor: const Color(0xff48BF91),
        appBarTheme: _appBarTheme.copyWith(
          titleTextStyle: ThemeData.light().appBarTheme.titleTextStyle?.apply(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: AppColors.black,
                backgroundColor: AppColors.black,
                decorationColor: AppColors.black,
              ),
          toolbarTextStyle: ThemeData.light().appBarTheme.titleTextStyle?.apply(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: AppColors.black,
                backgroundColor: AppColors.black,
                decorationColor: AppColors.black,
              ),
          iconTheme: ThemeData.light().iconTheme.copyWith(
                color: AppColors.black,
              ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          displayColor: AppColors.black,
          bodyColor: AppColors.black,
          decorationColor: AppColors.black,
        ),
        primaryTextTheme: GoogleFonts.poppinsTextTheme().apply(
          displayColor: AppColors.black,
          bodyColor: AppColors.black,
          decorationColor: AppColors.black,
        ),
        iconTheme: ThemeData.light().iconTheme.copyWith(
              color: AppColors.black,
            ),
        cardTheme: cardTheme.copyWith(
          color: AppColors.white,
        ),
        drawerTheme: drawerTheme.copyWith(
          backgroundColor: AppColors.white,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: _lightTheme.scaffoldBackgroundColor,
          unselectedLabelColor: _lightTheme.disabledColor,
        ),
        disabledColor: AppColors.grey,
      );

  static ThemeData get darkTheme => _darkTheme.copyWith(
        indicatorColor: AppColors.primaryColor,
        primaryColor: AppColors.primaryColor,
        appBarTheme: _appBarTheme.copyWith(
          titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle?.apply(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: AppColors.white,
                backgroundColor: AppColors.white,
                decorationColor: AppColors.white,
              ),
          toolbarTextStyle: ThemeData.dark().appBarTheme.titleTextStyle?.apply(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: AppColors.white,
                backgroundColor: AppColors.white,
                decorationColor: AppColors.white,
              ),
          iconTheme: ThemeData.dark().iconTheme.copyWith(
                color: AppColors.white,
              ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          displayColor: AppColors.white,
          bodyColor: AppColors.white,
          decorationColor: AppColors.white,
        ),
        primaryTextTheme: GoogleFonts.poppinsTextTheme().apply(
          displayColor: AppColors.white,
          bodyColor: AppColors.white,
          decorationColor: AppColors.white,
        ),
        iconTheme: ThemeData.dark().iconTheme.copyWith(
              color: AppColors.white,
            ),
        cardTheme: cardTheme.copyWith(
          color: AppColors.black,
        ),
        drawerTheme: drawerTheme.copyWith(
          backgroundColor: AppColors.black,
        ),
      );

  static ThemeData get globalThemeData => ThemeData(
        appBarTheme: _appBarTheme,
        fontFamily: globalFontStyle.fontFamily,
        dividerColor: Colors.transparent,
        textTheme: globalTextTheme,
        platform: TargetPlatform.iOS,
      );
}
