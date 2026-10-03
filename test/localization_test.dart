import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arewecookin/l10n/translations_data.dart';
import 'package:arewecookin/providers/locale_provider.dart';

void main() {
  test('locale provider test resolves to English by default in test', () {
    final container = ProviderContainer();
    final loc = container.read(localeProvider);
    expect(loc.languageCode, equals('en'));
  });

  test('AppLanguages defines exactly 20 languages', () {
    expect(AppLanguages.all.length, 20);
    expect(appTranslations.length, 20);
  });

  test('Every language in appTranslations has all required keys', () {
    final enKeys = appTranslations['en']!.keys.toSet();

    for (final lang in AppLanguages.all) {
      final dict = appTranslations[lang.code];
      expect(dict, isNotNull, reason: 'Missing translation dictionary for ${lang.code}');
      
      final missingKeys = enKeys.difference(dict!.keys.toSet());
      expect(missingKeys, isEmpty, reason: '${lang.code} is missing keys: $missingKeys');
    }
  });

  test('Arabic is marked RTL', () {
    final ar = AppLanguages.findByCode('ar');
    expect(ar, isNotNull);
    expect(ar!.isRtl, isTrue);
    expect(AppLanguages.isRtlLocale(const Locale('ar')), isTrue);
    expect(AppLanguages.isRtlLocale(const Locale('en')), isFalse);
  });

  test('AppLanguages.resolveLocale resolves correctly with English default fallback', () {
    // English
    expect(AppLanguages.resolveLocale(const Locale('en')), const Locale('en'));
    expect(AppLanguages.resolveLocale(const Locale('en', 'US')), const Locale('en'));

    // Turkish
    expect(AppLanguages.resolveLocale(const Locale('tr')), const Locale('tr'));
    expect(AppLanguages.resolveLocale(const Locale('tr', 'TR')), const Locale('tr'));

    // German
    expect(AppLanguages.resolveLocale(const Locale('de')), const Locale('de'));
    expect(AppLanguages.resolveLocale(const Locale('de', 'DE')), const Locale('de'));

    // French
    expect(AppLanguages.resolveLocale(const Locale('fr')), const Locale('fr'));

    // Spanish
    expect(AppLanguages.resolveLocale(const Locale('es')), const Locale('es'));

    // Italian
    expect(AppLanguages.resolveLocale(const Locale('it')), const Locale('it'));

    // Portuguese Brazil
    expect(AppLanguages.resolveLocale(const Locale('pt', 'BR')), const Locale('pt', 'BR'));
    expect(AppLanguages.resolveLocale(const Locale('pt')), const Locale('pt', 'BR'));

    // Russian
    expect(AppLanguages.resolveLocale(const Locale('ru')), const Locale('ru'));

    // Chinese Simplified
    expect(
      AppLanguages.resolveLocale(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN')),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    );

    // Chinese Traditional
    expect(
      AppLanguages.resolveLocale(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    );

    // Japanese
    expect(AppLanguages.resolveLocale(const Locale('ja')), const Locale('ja'));

    // Korean
    expect(AppLanguages.resolveLocale(const Locale('ko')), const Locale('ko'));

    // Arabic
    expect(AppLanguages.resolveLocale(const Locale('ar')), const Locale('ar'));

    // Polish
    expect(AppLanguages.resolveLocale(const Locale('pl')), const Locale('pl'));

    // Vietnamese
    expect(AppLanguages.resolveLocale(const Locale('vi')), const Locale('vi'));

    // Malay
    expect(AppLanguages.resolveLocale(const Locale('ms')), const Locale('ms'));

    // Finnish
    expect(AppLanguages.resolveLocale(const Locale('fi')), const Locale('fi'));

    // Estonian
    expect(AppLanguages.resolveLocale(const Locale('et')), const Locale('et'));

    // Ukrainian
    expect(AppLanguages.resolveLocale(const Locale('uk')), const Locale('uk'));

    // Hindi
    expect(AppLanguages.resolveLocale(const Locale('hi')), const Locale('hi'));

    // Unknown language falls back to English (default)
    expect(AppLanguages.resolveLocale(const Locale('is')), const Locale('en')); // Icelandic -> EN
    expect(AppLanguages.resolveLocale(const Locale('sw')), const Locale('en')); // Swahili -> EN
    expect(AppLanguages.resolveLocale(null), const Locale('en')); // null -> EN
  });

  test('AppStrings retrieves correct translations per language', () {
    final enStrings = AppStrings('en');
    expect(enStrings.tabDiscover, 'Discover');
    expect(enStrings.tabPantry, 'Pantry');
    expect(enStrings.tabAccount, 'Account');

    final trStrings = AppStrings('tr');
    expect(trStrings.tabDiscover, 'Keşfet');
    expect(trStrings.tabPantry, 'Kilerim');
    expect(trStrings.tabAccount, 'Hesabım');

    final deStrings = AppStrings('de');
    expect(deStrings.tabDiscover, 'Entdecken');
    expect(deStrings.tabPantry, 'Vorratskammer');
    expect(deStrings.tabAccount, 'Konto');

    final frStrings = AppStrings('fr');
    expect(frStrings.tabDiscover, 'Découvrir');
    expect(frStrings.tabPantry, 'Garde-manger');
    expect(frStrings.tabAccount, 'Compte');

    final arStrings = AppStrings('ar');
    expect(arStrings.tabDiscover, 'استكشف');
    expect(arStrings.tabPantry, 'المؤونة');
    expect(arStrings.tabAccount, 'حسابي');

    final hiStrings = AppStrings('hi');
    expect(hiStrings.tabDiscover, 'खोजें');
    expect(hiStrings.tabPantry, 'रसोई भंडार');
    expect(hiStrings.tabAccount, 'प्रोफ़ाइल');

    final jaStrings = AppStrings('ja');
    expect(jaStrings.tabDiscover, '見つける');
    expect(jaStrings.tabPantry, 'パントリー');
    expect(jaStrings.tabAccount, 'マイページ');

    final koStrings = AppStrings('ko');
    expect(koStrings.tabDiscover, '발견');
    expect(koStrings.tabPantry, '스마트 팬트리');
    expect(koStrings.tabAccount, '마이페이지');

    final zhCnStrings = AppStrings('zh_CN');
    expect(zhCnStrings.tabDiscover, '探索');
    expect(zhCnStrings.tabPantry, '智能储藏室');
    expect(zhCnStrings.tabAccount, '我的账户');

    final zhTwStrings = AppStrings('zh_TW');
    expect(zhTwStrings.tabDiscover, '探索');
    expect(zhTwStrings.tabPantry, '智能食材庫');
    expect(zhTwStrings.tabAccount, '個人帳戶');

    final ruStrings = AppStrings('ru');
    expect(ruStrings.tabDiscover, 'Обзор');
    expect(ruStrings.tabPantry, 'Кладовая');
    expect(ruStrings.tabAccount, 'Профиль');

    final esStrings = AppStrings('es');
    expect(esStrings.tabDiscover, 'Descubrir');
    expect(esStrings.tabPantry, 'Despensa');
    expect(esStrings.tabAccount, 'Cuenta');

    final itStrings = AppStrings('it');
    expect(itStrings.tabDiscover, 'Scopri');
    expect(itStrings.tabPantry, 'Dispensa');
    expect(itStrings.tabAccount, 'Profilo');

    final ptStrings = AppStrings('pt_BR');
    expect(ptStrings.tabDiscover, 'Descobrir');
    expect(ptStrings.tabPantry, 'Despensa');
    expect(ptStrings.tabAccount, 'Conta');

    final plStrings = AppStrings('pl');
    expect(plStrings.tabDiscover, 'Odkrywaj');
    expect(plStrings.tabPantry, 'Spiżarnia');
    expect(plStrings.tabAccount, 'Konto');

    final viStrings = AppStrings('vi');
    expect(viStrings.tabDiscover, 'Khám phá');
    expect(viStrings.tabPantry, 'Tủ bếp');
    expect(viStrings.tabAccount, 'Tài khoản');

    final msStrings = AppStrings('ms');
    expect(msStrings.tabDiscover, 'Terokai');
    expect(msStrings.tabPantry, 'Pantri');
    expect(msStrings.tabAccount, 'Akaun');

    final fiStrings = AppStrings('fi');
    expect(fiStrings.tabDiscover, 'Löydä');
    expect(fiStrings.tabPantry, 'Ruokakomero');
    expect(fiStrings.tabAccount, 'Tili');

    final etStrings = AppStrings('et');
    expect(etStrings.tabDiscover, 'Avasta');
    expect(etStrings.tabPantry, 'Sahver');
    expect(etStrings.tabAccount, 'Konto');

    final ukStrings = AppStrings('uk');
    expect(ukStrings.tabDiscover, 'Огляд');
    expect(ukStrings.tabPantry, 'Комора');
    expect(ukStrings.tabAccount, 'Профіль');
  });

  testWidgets('Arabic locale renders RTL text direction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLanguages.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            final strings = AppStrings('ar');
            return Scaffold(
              body: Column(
                children: [
                  Text(isRtl ? 'RTL_ACTIVE' : 'LTR_ACTIVE'),
                  Text(strings.tabDiscover),
                  Text(strings.tabPantry),
                  Text(strings.tabAccount),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('RTL_ACTIVE'), findsOneWidget);
    expect(find.text('استكشف'), findsOneWidget);
    expect(find.text('المؤونة'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });

  test('All 20 languages switch dynamically and provide non-empty strings', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (final lang in AppLanguages.all) {
      await container.read(localeProvider.notifier).setLocale(lang.code);
      final currentLoc = container.read(localeProvider);
      final strings = container.read(appStringsProvider);

      expect(currentLoc, equals(lang.locale));
      expect(strings.tabDiscover, isNotEmpty);
      expect(strings.tabPantry, isNotEmpty);
      expect(strings.tabAccount, isNotEmpty);
      expect(strings.searchPlaceholder, isNotEmpty);
      expect(strings.myAccount, isNotEmpty);
      expect(strings.smartPantry, isNotEmpty);
      expect(strings.startCooking, isNotEmpty);
    }
  });

  test('Language resolution falls back to English for unknown locales', () {
    expect(AppLanguages.resolveLocale(const Locale('xx')), const Locale('en'));
    expect(AppLanguages.resolveLocale(const Locale('is', 'IS')), const Locale('en'));
    expect(AppLanguages.resolveLocale(const Locale('sw', 'KE')), const Locale('en'));
    expect(AppLanguages.resolveLocale(null), const Locale('en'));
  });
}
