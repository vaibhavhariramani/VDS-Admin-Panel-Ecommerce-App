part of 'app_theme.dart';

class LightColors {
  static const Color primary_color = Color(0xff121212);
  static const Color light_text1 = Color(0xff79747e);
  static const Color light_text2 = Color(0xffe5e5e5);
  static const Color disabled1 = Color(0xffe5e5e5);
  static const Color disabled2 = Color(0xffc9c5ca);

  static const Color ice_blue_two = Color(0xfffafdff);
  static const Color steel_grey_50 = Color(0x80798288);
  static const Color white_57 = Color(0x91ffffff);
  static const Color white_15 = Color(0x26ffffff);
}

class LightAppTheme {
  static TextTheme get _textTheme =>
      AppTheme.globalThemeData.textTheme.copyWith(
        headline1: AppTheme.globalTextTheme.headline1?.copyWith(
          color: LightColors.primary_color,
        ),
        headline2: AppTheme.globalTextTheme.headline2?.copyWith(
          color: LightColors.primary_color,
        ),
        headline3: AppTheme.globalTextTheme.headline3?.copyWith(
          color: LightColors.primary_color,
        ),
        headline4: AppTheme.globalTextTheme.headline4?.copyWith(
          color: LightColors.primary_color,
        ),
        headline5: AppTheme.globalTextTheme.headline5?.copyWith(
          color: LightColors.primary_color,
        ),
        headline6: AppTheme.globalTextTheme.headline6?.copyWith(
          color: LightColors.primary_color,
        ),
        bodyText1: AppTheme.globalTextTheme.bodyText1?.copyWith(
          color: LightColors.primary_color,
        ),
        bodyText2: AppTheme.globalTextTheme.bodyText2?.copyWith(
          color: LightColors.primary_color,
        ),
        subtitle1: AppTheme.globalTextTheme.subtitle1?.copyWith(
          color: LightColors.light_text1,
        ),
        subtitle2: AppTheme.globalTextTheme.subtitle2?.copyWith(
          color: LightColors.light_text1,
        ),
        caption: AppTheme.globalTextTheme.caption?.copyWith(
          color: LightColors.light_text1,
        ),
        button: AppTheme.globalTextTheme.button?.copyWith(
          color: LightColors.light_text2,
        ),
        overline: AppTheme.globalTextTheme.overline?.copyWith(
          color: LightColors.light_text1,
        ),
      );

  static TextSelectionThemeData get _textSelectionTheme =>
      const TextSelectionThemeData(
        cursorColor: LightColors.primary_color,
      );

  static InputDecorationTheme get _inputTheme => AppTheme.globalThemeData
      .copyWith(
        textSelectionTheme: _textSelectionTheme,
      )
      .inputDecorationTheme
      .copyWith(
        hintStyle: AppTheme.globalFontStyle.copyWith(
          color: LightColors.light_text1,
          fontSize: 16,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
      );

  static AppBarTheme get _appBarTheme =>
      AppTheme.globalThemeData.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: LightColors.primary_color,
        ),
        toolbarTextStyle: _textTheme.headline4?.copyWith(
          color: LightColors.primary_color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleTextStyle: _textTheme.headline4?.copyWith(
          color: LightColors.primary_color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  static ThemeData get themeData => ThemeData.light().copyWith(
        primaryColor: LightColors.primary_color,
        appBarTheme: _appBarTheme,
        inputDecorationTheme: _inputTheme,
        textTheme: _textTheme,
        brightness: Brightness.light,
        iconTheme: const IconThemeData(
          color: LightColors.primary_color,
        ),
        disabledColor: LightColors.steel_grey_50,
        indicatorColor: LightColors.primary_color,
        dividerColor: AppTheme.globalThemeData.dividerColor,
        cardColor: AppTheme.globalThemeData.cardColor,
        canvasColor: AppTheme.globalThemeData.canvasColor,
        scaffoldBackgroundColor:
            AppTheme.globalThemeData.scaffoldBackgroundColor,
        textSelectionTheme: _textSelectionTheme,
        tabBarTheme: TabBarTheme(
          labelStyle: _textTheme.button?.copyWith(
            color: LightColors.primary_color,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          labelColor: LightColors.primary_color,
          unselectedLabelColor: LightColors.light_text1,
          unselectedLabelStyle: _textTheme.button?.copyWith(
            color: LightColors.light_text1,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      );
}
