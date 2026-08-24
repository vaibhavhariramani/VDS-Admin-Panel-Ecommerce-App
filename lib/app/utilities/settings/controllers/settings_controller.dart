import 'package:flutter/material.dart';
import 'package:flutter_dashboard/flutter_dashboard.dart';

/// Key shared with [AppConfig.dashboardConfig] (app_configs.dart), which
/// reads it once at startup to pick the initial `themeMode` before this
/// controller (or any other GetX service) exists yet.
const String themeModeStorageKey = 'themeMode';

class SettingsController extends GetxController {
  final GetStorage _storage = GetStorage();

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode(_storage.read(themeModeStorageKey) == 'dark');
  }

  void toggleDarkMode(bool value) {
    isDarkMode(value);
    final ThemeMode mode = value ? ThemeMode.dark : ThemeMode.light;
    _storage.write(themeModeStorageKey, value ? 'dark' : 'light');
    Get.changeThemeMode(mode);
  }
}
