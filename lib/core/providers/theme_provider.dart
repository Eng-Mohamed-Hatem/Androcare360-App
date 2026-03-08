import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Mode Notifier - إدارة حالة الوضع المظلم
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    unawaited(_loadThemeMode());
  }

  static const String _themeModeKey = 'theme_mode';

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, newMode == ThemeMode.dark);
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, mode == ThemeMode.dark);
  }

  /// Check if dark mode is enabled
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (
    ref,
  ) => ThemeModeNotifier(),
);
