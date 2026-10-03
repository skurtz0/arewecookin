import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
    this.isRtl = false,
  });
}

class AppLanguages {
  static const List<AppLanguage> all = [
    // 1. English (Default)
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      locale: Locale('en'),
    ),
    // 2. Turkish
    AppLanguage(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flag: '🇹🇷',
      locale: Locale('tr'),
    ),
    // 3. German
    AppLanguage(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      locale: Locale('de'),
    ),
    // 4. French
    AppLanguage(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      locale: Locale('fr'),
    ),
    // 5. Spanish
    AppLanguage(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
      locale: Locale('es'),
    ),
    // 6. Italian
    AppLanguage(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      flag: '🇮🇹',
      locale: Locale('it'),
    ),
    // 7. Portuguese (Brazil)
    AppLanguage(
      code: 'pt_BR',
      name: 'Portuguese (Brazil)',
      nativeName: 'Português (Brasil)',
      flag: '🇧🇷',
      locale: Locale('pt', 'BR'),
    ),
    // 8. Russian
    AppLanguage(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      flag: '🇷🇺',
      locale: Locale('ru'),
    ),
    // 9. Simplified Chinese
    AppLanguage(
      code: 'zh_CN',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      flag: '🇨🇳',
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    ),
    // 10. Traditional Chinese
    AppLanguage(
      code: 'zh_TW',
      name: 'Chinese (Traditional)',
      nativeName: '繁體中文',
      flag: '🇹🇼',
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    ),
    // 11. Japanese
    AppLanguage(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
      locale: Locale('ja'),
    ),
    // 12. Korean
    AppLanguage(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flag: '🇰🇷',
      locale: Locale('ko'),
    ),
    // 13. Arabic (RTL)
    AppLanguage(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      locale: Locale('ar'),
      isRtl: true,
    ),
    // 14. Polish
    AppLanguage(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
      flag: '🇵🇱',
      locale: Locale('pl'),
    ),
    // 15. Vietnamese
    AppLanguage(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      flag: '🇻🇳',
      locale: Locale('vi'),
    ),
    // 16. Malay
    AppLanguage(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
      locale: Locale('ms'),
    ),
    // 17. Finnish
    AppLanguage(
      code: 'fi',
      name: 'Finnish',
      nativeName: 'Suomi',
      flag: '🇫🇮',
      locale: Locale('fi'),
    ),
    // 18. Estonian
    AppLanguage(
      code: 'et',
      name: 'Estonian',
      nativeName: 'Eesti',
      flag: '🇪🇪',
      locale: Locale('et'),
    ),
    // 19. Ukrainian
    AppLanguage(
      code: 'uk',
      name: 'Ukrainian',
      nativeName: 'Українська',
      flag: '🇺🇦',
      locale: Locale('uk'),
    ),
    // 20. Hindi (India)
    AppLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      locale: Locale('hi'),
    ),
  ];

  static List<Locale> get supportedLocales => all.map((l) => l.locale).toList();

  static AppLanguage? findByCode(String code) {
    final clean = code.toLowerCase().replaceAll('-', '_');
    for (final l in all) {
      if (l.code.toLowerCase() == clean) return l;
    }
    // Also match languageCode
    for (final l in all) {
      if (l.locale.languageCode.toLowerCase() == clean) return l;
    }
    return null;
  }

  static AppLanguage? findByLocale(Locale locale) {
    // 1. Exact match with country / script if available
    for (final l in all) {
      if (l.locale == locale) return l;
    }

    // 2. Special handling for Chinese
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK') {
        return findByCode('zh_TW');
      }
      return findByCode('zh_CN');
    }

    // 3. Special handling for Portuguese
    if (locale.languageCode == 'pt') {
      return findByCode('pt_BR');
    }

    // 4. Match by languageCode
    for (final l in all) {
      if (l.locale.languageCode == locale.languageCode) return l;
    }

    return null;
  }

  /// Resolves device locale against the 20 supported languages, fallback to English
  static Locale resolveLocale(Locale? deviceLocale) {
    if (deviceLocale != null) {
      final match = findByLocale(deviceLocale);
      if (match != null) {
        return match.locale;
      }
    }
    return const Locale('en');
  }

  static bool isRtlLocale(Locale locale) {
    return locale.languageCode == 'ar';
  }
}
