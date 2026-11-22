import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instruction text size in cooking mode (index into [sizes]). Remembered on the device.
class CookTextSizeNotifier extends Notifier<int> {
  static const _prefKey = 'cook_text_size_v1';
  static const sizes = [18.0, 22.0, 26.0];

  @override
  int build() {
    _load();
    return 0;
  }

  double get size => sizes[state];

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_prefKey);
      if (v != null && v >= 0 && v < sizes.length) state = v;
    } catch (_) {}
  }

  /// Next size, wrapping back to the smallest.
  void cycle() {
    state = (state + 1) % sizes.length;
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefKey, state);
      } catch (_) {}
    }();
  }
}

final cookTextSizeProvider = NotifierProvider<CookTextSizeNotifier, int>(CookTextSizeNotifier.new);
