import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servings the user usually cooks for. Recipes open scaled to it unless the user picked another
/// number for that recipe. null = use each recipe's own servings. Remembered on the device.
class HouseholdServingsNotifier extends Notifier<int?> {
  static const _prefKey = 'household_servings_v1';
  bool _touched = false;

  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_prefKey);
      // A change made before the stored value arrived wins.
      if (v != null && !_touched) state = v.clamp(1, 99);
    } catch (_) {}
  }

  void set(int? servings) {
    _touched = true;
    state = servings?.clamp(1, 99);
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (state == null) {
          await prefs.remove(_prefKey);
        } else {
          await prefs.setInt(_prefKey, state!);
        }
      } catch (_) {}
    }();
  }
}

final householdServingsProvider =
    NotifierProvider<HouseholdServingsNotifier, int?>(HouseholdServingsNotifier.new);
