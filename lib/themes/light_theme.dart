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
        displayLarge: AppTheme.globalTextTheme.displayLarge?.copyWith(
          color: LightColors.primary_color,
        ),
        displayMedium: AppTheme.globalTextTheme.displayMedium?.copyWith(
          color: LightColors.primary_color,
        ),
        displaySmall: AppTheme.globalTextTheme.displaySmall?.copyWith(
          color: LightColors.primary_color,
        ),
        headlineMedium: AppTheme.globalTextTheme.headlineMedium?.copyWith(
          color: LightColors.primary_color,
        ),
        headlineSmall: AppTheme.globalTextTheme.headlineSmall?.copyWith(
          color: LightColors.primary_color,
        ),
        titleLarge: AppTheme.globalTextTheme.titleLarge?.copyWith(
          color: LightColors.primary_color,
        ),
        bodyLarge: AppTheme.globalTextTheme.bodyLarge?.copyWith(
          color: LightColors.primary_color,
        ),
        bodyMedium: AppTheme.globalTextTheme.bodyMedium?.copyWith(
          color: LightColors.primary_color,
        ),
        titleMedium: AppTheme.globalTextTheme.titleMedium?.copyWith(
          color: LightColors.light_text1,
        ),
        titleSmall: AppTheme.globalTextTheme.titleSmall?.copyWith(
          color: LightColors.light_text1,
        ),
        bodySmall: AppTheme.globalTextTheme.bodySmall?.copyWith(
          color: LightColors.light_text1,
        ),
        labelLarge: AppTheme.globalTextTheme.labelLarge?.copyWith(
          color: LightColors.light_text2,
        ),
        labelSmall: AppTheme.globalTextTheme.labelSmall?.copyWith(
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
        toolbarTextStyle: _textTheme.headlineMedium?.copyWith(
          color: LightColors.primary_color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleTextStyle: _textTheme.headlineMedium?.copyWith(
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
          labelStyle: _textTheme.labelLarge?.copyWith(
            color: LightColors.primary_color,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          labelColor: LightColors.primary_color,
          unselectedLabelColor: LightColors.light_text1,
          unselectedLabelStyle: _textTheme.labelLarge?.copyWith(
            color: LightColors.light_text1,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      );
}
