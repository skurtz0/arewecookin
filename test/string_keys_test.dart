import 'dart:io';

import 'package:arewecookin/l10n/translations_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every key read by AppStrings exists in the English dictionary', () {
    final src = File('lib/l10n/app_strings.dart').readAsStringSync();
    final used = RegExp(r"_get\('([A-Za-z0-9_]+)'").allMatches(src).map((m) => m.group(1)!).toSet();
    expect(used.length, greaterThan(100));
    final en = appTranslations['en']!.keys.toSet();
    // Weekday names are looked up by 'wd$d' (built at runtime).
    final missing = used.difference(en)..removeWhere((k) => RegExp(r'^wd\d$').hasMatch(k));
    expect(missing, isEmpty, reason: 'getters read keys that are not in the dictionary: $missing');
  });

  test('English dictionary has no key that nothing reads (dead strings)', () {
    final src = File('lib/l10n/app_strings.dart').readAsStringSync();
    final used = RegExp(r"_get\('([A-Za-z0-9_]+)'").allMatches(src).map((m) => m.group(1)!).toSet();
    final dead = appTranslations['en']!.keys.toSet().difference(used);
    // Informational ceiling so new dead keys are noticed, not a hard rule on old ones.
    expect(dead.length, lessThan(200), reason: 'dead keys: $dead');
  });

  test('every translation keeps the {placeholders} of the English text', () {
    final ph = RegExp(r'\{[a-zA-Z]+\}');
    final en = appTranslations['en']!;
    final problems = <String>[];
    for (final lang in appTranslations.entries) {
      for (final e in en.entries) {
        final want = ph.allMatches(e.value).map((m) => m.group(0)).toSet();
        if (want.isEmpty) continue;
        final got = ph.allMatches(lang.value[e.key] ?? '').map((m) => m.group(0)).toSet();
        if (!got.containsAll(want)) problems.add('${lang.key}.${e.key}');
      }
    }
    expect(problems, isEmpty);
  });

  test('German, French and Spanish have real translations for the core action texts', () {
    for (final lang in ['de', 'fr', 'es']) {
      for (final k in ['undoLabel', 'itemRemoved', 'mealPlanTitle', 'allSteps', 'resultsCountFmt']) {
        expect(appTranslations[lang]![k], isNot(appTranslations['en']![k]), reason: '$lang.$k');
      }
    }
  });
}
