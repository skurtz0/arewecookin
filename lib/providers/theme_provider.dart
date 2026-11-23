import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

/// Light, dark or follow-the-system theme, kept on the device.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _prefKey = 'theme_mode_v1';
  Future<void> _ready = Future.value();
  bool _touched = false;

  @override
  ThemeMode build() {
    _ready = _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (_touched || saved == null) return;
      state = ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, state.name);
    } catch (_) {}
  }

  /// One tap: light becomes dark and dark becomes light (system counts as what it shows now).
  void toggle() {
    _touched = true;
    state = isDark(state) ? ThemeMode.light : ThemeMode.dark;
    _save();
  }

  void set(ThemeMode mode) {
    _touched = true;
    state = mode;
    _save();
  }
}

/// Whether [mode] shows the dark theme right now.
bool isDark(ThemeMode mode) =>
    mode == ThemeMode.dark ||
    (mode == ThemeMode.system && SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Sets the palette to the theme and rebuilds the whole tree, so widgets that read
/// [AppColors] (also inside const subtrees) pick up the change without losing state.
void applyThemeToPalette(ThemeMode mode) {
  final dark = isDark(mode);
  if (AppColors.dark == dark) return;
  AppColors.dark = dark;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
  });
}
