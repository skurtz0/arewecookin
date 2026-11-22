import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// true = show US customary units (oz, lb, fl oz, in); false = metric. Remembered on the device.
class UnitSystemNotifier extends Notifier<bool> {
  static const _prefKey = 'imperial_units_v1';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getBool(_prefKey);
      if (v != null) state = v;
    } catch (_) {}
  }

  void set(bool imperial) {
    state = imperial;
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKey, imperial);
      } catch (_) {}
    }();
  }
}

final imperialUnitsProvider = NotifierProvider<UnitSystemNotifier, bool>(UnitSystemNotifier.new);
