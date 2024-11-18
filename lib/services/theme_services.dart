import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _themeKey =
      'isDarkTheme'; // Key untuk menyimpan preferensi tema di storage

  // Method untuk mendapatkan tema yang sedang aktif
  ThemeMode get theme => Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Method untuk toggle tema
  void switchTheme() {
    bool isDarkMode = Get.isDarkMode;
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    GetStorage().write(_themeKey, !isDarkMode);
  }

  // Load tema dari storage
  void loadThemeFromStorage() {
    bool? isDarkMode = GetStorage().read(_themeKey);
    if (isDarkMode != null) {
      Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    }
  }
}
