part of 'app_theme.dart';

class DarkColors {}

class DarkAppTheme {
  static TextTheme get _textTheme =>
      AppTheme.globalThemeData.textTheme.copyWith(
        headline1: AppTheme.globalTextTheme.headline1?.copyWith(
          color: LightColors.light_text2,
        ),
        headline2: AppTheme.globalTextTheme.headline2?.copyWith(
          color: LightColors.light_text2,
        ),
        headline3: AppTheme.globalTextTheme.headline3?.copyWith(
          color: LightColors.light_text2,
        ),
        headline4: AppTheme.globalTextTheme.headline4?.copyWith(
          color: LightColors.light_text2,
        ),
        headline5: AppTheme.globalTextTheme.headline5?.copyWith(
          color: LightColors.light_text2,
        ),
        headline6: AppTheme.globalTextTheme.headline6?.copyWith(
          color: LightColors.light_text2,
        ),
        bodyText1: AppTheme.globalTextTheme.bodyText1?.copyWith(
          color: LightColors.light_text2,
        ),
        bodyText2: AppTheme.globalTextTheme.bodyText2?.copyWith(
          color: LightColors.light_text2,
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

  static AppBarTheme get _appBarTheme =>
      AppTheme.globalThemeData.appBarTheme.copyWith(
        iconTheme: const IconThemeData(
          color: LightColors.light_text2,
        ),
        toolbarTextStyle:
            AppTheme.globalThemeData.appBarTheme.toolbarTextStyle?.copyWith(
          color: LightColors.light_text2,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleTextStyle:
            AppTheme.globalThemeData.appBarTheme.titleTextStyle?.copyWith(
          color: LightColors.light_text2,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  static TextSelectionThemeData get _textSelectionTheme =>
      const TextSelectionThemeData(
        cursorColor: LightColors.light_text1,
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

  static ThemeData get themeData => ThemeData.dark().copyWith(
        primaryColor: ThemeData.dark().primaryColor,
        appBarTheme: _appBarTheme,
        iconTheme: const IconThemeData(
          color: LightColors.light_text2,
        ),
        dividerColor: AppTheme.globalThemeData.dividerColor,
        cardColor: ThemeData.dark().cardColor,
        canvasColor: ThemeData.dark().canvasColor,
        scaffoldBackgroundColor: ThemeData.dark().scaffoldBackgroundColor,
        textTheme: _textTheme,
        indicatorColor: LightColors.light_text2,
        textSelectionTheme: _textSelectionTheme,
        tabBarTheme: TabBarTheme(
          labelStyle: _textTheme.button?.copyWith(
            color: LightColors.light_text2,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          labelColor: LightColors.light_text2,
          unselectedLabelColor: LightColors.light_text1,
          unselectedLabelStyle: _textTheme.button?.copyWith(
            color: LightColors.light_text1,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
        inputDecorationTheme: _inputTheme,
      );
}
