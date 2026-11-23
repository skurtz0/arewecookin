import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/data/world_countries.dart';

void main() {
  test('only Turkey uses the Turkish flag, and every flag is unique', () {
    for (final c in WorldCountries.all) {
      if (c.id != 'Türk Mutfağı') expect(c.flag, isNot('🇹🇷'), reason: c.id);
    }
    final flags = WorldCountries.all.map((c) => c.flag).toList();
    expect(flags.toSet().length, flags.length);
  });
  test('well-known cuisines have the right flag', () {
    expect(WorldCountries.byId('İtalya')!.flag, '🇮🇹');
    expect(WorldCountries.byId('Japonya')!.flag, '🇯🇵');
    expect(WorldCountries.byId('ABD')!.flag, '🇺🇸');
    expect(WorldCountries.byId('Tayland')!.flag, '🇹🇭');
  });
}
