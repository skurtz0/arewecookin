import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_languages.dart';
import '../l10n/app_strings.dart';

export '../l10n/app_languages.dart';
export '../l10n/app_strings.dart';

const String _kLocalePrefKey = 'selected_locale_code';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return _resolveInitialLocale();
  }

  /// Detects device locale and maps to one of the 20 supported languages.
  /// If unsupported or null, defaults to English ('en').
  Locale _resolveInitialLocale() {
    try {
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      if (locales.isNotEmpty) {
        return AppLanguages.resolveLocale(locales.first);
      }
    } catch (_) {}
    return const Locale('en');
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_kLocalePrefKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        final lang = AppLanguages.findByCode(savedCode);
        if (lang != null && state != lang.locale) {
          state = lang.locale;
        }
      }
    } catch (_) {
      // Ignored in headless/test environments
    }
  }

  Future<void> setLocale(String code) async {
    final lang = AppLanguages.findByCode(code);
    if (lang != null) {
      state = lang.locale;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLocalePrefKey, lang.code);
      } catch (_) {}
    } else {
      state = Locale(code);
    }
  }

  Future<void> setLocaleFromLocale(Locale locale) async {
    final lang = AppLanguages.findByLocale(locale);
    state = lang?.locale ?? locale;
    if (lang != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLocalePrefKey, lang.code);
      } catch (_) {}
    }
  }

  void toggleLocale() {
    setLocale(state.languageCode == 'tr' ? 'en' : 'tr');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  final appLang = AppLanguages.findByLocale(locale);
  final code = appLang?.code ??
      (locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode);
  return AppStrings(code);
});

final currentLanguageProvider = Provider<AppLanguage>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLanguages.findByLocale(locale) ??
      AppLanguages.findByCode('en')!;
});
