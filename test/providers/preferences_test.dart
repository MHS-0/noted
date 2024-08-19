// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noted/providers/preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noted/constants.dart';

import '../path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Preferences Test', () {
    final preferences = Preferences.instance();
    PathProviderPlatform.instance = FakePathProviderPlatform();

    test('Test that the system theme and locale are the default', () async {
      SharedPreferences.setMockInitialValues(Map.fromIterable([]));
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);

      if (!kIsWeb && Platform.localeName.contains('fa')) {
        expect(preferences.locale.languageCode, 'fa');
      } else {
        expect(preferences.locale.languageCode, 'en');
      }
    });

    test('Test for saved theme preferences', () async {
      await SharedPreferences.getInstance()
        ..clear();
      SharedPreferences.setMockInitialValues({themeModeKey: systemThemeValue});
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);

      SharedPreferences.setMockInitialValues({themeModeKey: lightThemeValue});
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.light);

      SharedPreferences.setMockInitialValues({themeModeKey: darkThemeValue});
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.dark);
    });

    test('Test for saved locale preferences', () async {
      await SharedPreferences.getInstance()
        ..clear();
      SharedPreferences.setMockInitialValues({localeKey: englishLocaleValue});
      await preferences.load();
      expect(preferences.locale.languageCode, 'en');

      SharedPreferences.setMockInitialValues({localeKey: persianLocaleValue});
      await preferences.load();
      expect(preferences.locale.languageCode, 'fa');
    });

    test('Test for setting preferred theme', () async {
      final sp = await SharedPreferences.getInstance()
        ..clear();
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);
      preferences.setTheme(ThemeMode.dark);
      expect(preferences.themeMode, ThemeMode.dark);
      expect(sp.getString(themeModeKey), darkThemeValue);

      await sp.clear();
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);
      preferences.setTheme(ThemeMode.light);
      expect(preferences.themeMode, ThemeMode.light);
      expect(sp.getString(themeModeKey), lightThemeValue);

      await sp.clear();
      await preferences.load();
      expect(preferences.themeMode, ThemeMode.system);
      preferences.setTheme(ThemeMode.system);
      expect(preferences.themeMode, ThemeMode.system);
      expect(sp.getString(themeModeKey), systemThemeValue);
    });

    test('Test for setting preferred locale', () async {
      final sp = await SharedPreferences.getInstance()
        ..clear();
      await preferences.load();
      expect(preferences.locale, isNotNull);
      preferences.setLocale(const Locale('fa'));
      expect(preferences.locale.languageCode, 'fa');
      expect(sp.getString(localeKey), persianLocaleValue);

      await sp.clear();
      await preferences.load();
      expect(preferences.locale, isNotNull);
      preferences.setLocale(const Locale('en'));
      expect(preferences.locale.languageCode, 'en');
      expect(sp.getString(localeKey), englishLocaleValue);
    });
  });
}
