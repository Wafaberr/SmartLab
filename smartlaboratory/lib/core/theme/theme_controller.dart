import 'package:flutter/material.dart';
import 'package:smartlaboratory/core/storage/shared_perefs_service.dart';

class ThemeController extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';

  bool _isDark = false;
  bool _hasUserChangedTheme = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final savedValue = await SharedPerefsService.instance.getBool(_darkModeKey);
    if (_hasUserChangedTheme) return;
    _isDark = savedValue ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDark == enabled) return;
    _isDark = enabled;
    _hasUserChangedTheme = true;
    notifyListeners();
    await SharedPerefsService.instance.setBool(_darkModeKey, enabled);
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required super.notifier, required super.child});

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found in context');
    return scope!.notifier!;
  }
}
