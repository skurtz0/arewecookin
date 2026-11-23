import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether a finished step timer plays the system alert sound (vibration and the on-screen
/// alert stay on either way). Remembered on the device.
class TimerSoundNotifier extends Notifier<bool> {
  static const _prefKey = 'timer_sound_v1';

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getBool(_prefKey);
      if (v != null) state = v;
    } catch (_) {}
  }

  void toggle() {
    state = !state;
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKey, state);
      } catch (_) {}
    }();
  }
}

final timerSoundProvider = NotifierProvider<TimerSoundNotifier, bool>(TimerSoundNotifier.new);
