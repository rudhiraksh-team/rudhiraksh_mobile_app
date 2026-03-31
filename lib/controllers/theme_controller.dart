import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  // Key for storing theme mode in GetStorage
  static const String _key = 'themeMode';

  // Storage instance
  final _box = GetStorage();

  // Reactive theme mode variable
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();

    // Load theme mode from storage
    _loadThemeFromBox();
  }

  // Method to Load theme mode from GetStorage
  void _loadThemeFromBox() {
    String? savedTheme = _box.read(_key);

    if (savedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.light;
    }

    Get.changeThemeMode(themeMode.value);
  }

  // Method to Save theme mode to GetStorage
  void _saveThemeToBox(ThemeMode mode) {
    String value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    if (mode == ThemeMode.system) value = 'system';

    _box.write(_key, value);
  }

  // Public methods to set light theme
  void setLightTheme() {
    themeMode.value = ThemeMode.light;
    _saveThemeToBox(ThemeMode.light);
    Get.changeThemeMode(ThemeMode.light);
  }

  // Public methods to set dark theme
  void setDarkTheme() {
    themeMode.value = ThemeMode.dark;
    _saveThemeToBox(ThemeMode.dark);
    Get.changeThemeMode(ThemeMode.dark);
  }

  // Public method to toggle between light and dark themes
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      setDarkTheme();
    } else {
      setLightTheme();
    }
  }

  bool get isDark => themeMode.value == ThemeMode.dark;
}
