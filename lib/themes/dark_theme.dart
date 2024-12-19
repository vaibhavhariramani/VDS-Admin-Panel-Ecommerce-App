part of 'app_theme.dart';

class DarkColors {}

class DarkAppTheme {
  static TextTheme get _textTheme =>
      AppTheme.globalThemeData.textTheme.copyWith(
        displayLarge: AppTheme.globalTextTheme.displayLarge?.copyWith(
          color: LightColors.light_text2,
        ),
        displayMedium: AppTheme.globalTextTheme.displayMedium?.copyWith(
          color: LightColors.light_text2,
        ),
        displaySmall: AppTheme.globalTextTheme.displaySmall?.copyWith(
          color: LightColors.light_text2,
        ),
        headlineMedium: AppTheme.globalTextTheme.headlineMedium?.copyWith(
          color: LightColors.light_text2,
        ),
        headlineSmall: AppTheme.globalTextTheme.headlineSmall?.copyWith(
          color: LightColors.light_text2,
        ),
        titleLarge: AppTheme.globalTextTheme.titleLarge?.copyWith(
          color: LightColors.light_text2,
        ),
        bodyLarge: AppTheme.globalTextTheme.bodyLarge?.copyWith(
          color: LightColors.light_text2,
        ),
        bodyMedium: AppTheme.globalTextTheme.bodyMedium?.copyWith(
          color: LightColors.light_text2,
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
          labelStyle: _textTheme.labelLarge?.copyWith(
            color: LightColors.light_text2,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          labelColor: LightColors.light_text2,
          unselectedLabelColor: LightColors.light_text1,
          unselectedLabelStyle: _textTheme.labelLarge?.copyWith(
            color: LightColors.light_text1,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
          ),
          indicatorSize: TabBarIndicatorSize.label,
        ),
        inputDecorationTheme: _inputTheme,
      );
}
