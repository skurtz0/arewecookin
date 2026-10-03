import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
export '../l10n/app_strings.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('tr');
  }

  void setLocale(String languageCode) {
    if (state.languageCode != languageCode) {
      state = Locale(languageCode);
    }
  }

  void toggleLocale() {
    state = state.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale.languageCode);
});
