/// Countries that have curated recipes (cuisine id = Turkish name).
class WorldCountry {
  final String id;
  final String en;
  final String flag;
  const WorldCountry(this.id, this.en, this.flag);
}

class WorldCountries {
  WorldCountries._();

  static const List<WorldCountry> all = [
  WorldCountry('Arjantin', 'Argentina', '🇦🇷'),
  WorldCountry('Avustralya', 'Australia', '🇦🇺'),
  WorldCountry('Avusturya', 'Austria', '🇦🇹'),
  WorldCountry('Brezilya', 'Brazil', '🇧🇷'),
  WorldCountry('Bulgaristan', 'Bulgaria', '🇧🇬'),
  WorldCountry('Kamboçya', 'Cambodia', '🇰🇭'),
  WorldCountry('Kanada', 'Canada', '🇨🇦'),
  WorldCountry('Çin', 'China', '🇨🇳'),
  WorldCountry('Kolombiya', 'Colombia', '🇨🇴'),
  WorldCountry('Küba', 'Cuba', '🇨🇺'),
  WorldCountry('Mısır', 'Egypt', '🇪🇬'),
  WorldCountry('Etiyopya', 'Ethiopia', '🇪🇹'),
  WorldCountry('Fransa', 'France', '🇫🇷'),
  WorldCountry('Gürcistan', 'Georgia', '🇬🇪'),
  WorldCountry('Almanya', 'Germany', '🇩🇪'),
  WorldCountry('Yunanistan', 'Greece', '🇬🇷'),
  WorldCountry('Macaristan', 'Hungary', '🇭🇺'),
  WorldCountry('Hindistan', 'India', '🇮🇳'),
  WorldCountry('Endonezya', 'Indonesia', '🇮🇩'),
  WorldCountry('İran', 'Iran', '🇮🇷'),
  WorldCountry('İrlanda', 'Ireland', '🇮🇪'),
  WorldCountry('İtalya', 'Italy', '🇮🇹'),
  WorldCountry('Jamaika', 'Jamaica', '🇯🇲'),
  WorldCountry('Japonya', 'Japan', '🇯🇵'),
  WorldCountry('Lübnan', 'Lebanon', '🇱🇧'),
  WorldCountry('Meksika', 'Mexico', '🇲🇽'),
  WorldCountry('Fas', 'Morocco', '🇲🇦'),
  WorldCountry('Nepal', 'Nepal', '🇳🇵'),
  WorldCountry('Hollanda', 'Netherlands', '🇳🇱'),
  WorldCountry('Nijerya', 'Nigeria', '🇳🇬'),
  WorldCountry('Pakistan', 'Pakistan', '🇵🇰'),
  WorldCountry('Peru', 'Peru', '🇵🇪'),
  WorldCountry('Filipinler', 'Philippines', '🇵🇭'),
  WorldCountry('Polonya', 'Poland', '🇵🇱'),
  WorldCountry('Portekiz', 'Portugal', '🇵🇹'),
  WorldCountry('Romanya', 'Romania', '🇷🇴'),
  WorldCountry('Rusya', 'Russia', '🇷🇺'),
  WorldCountry('Sırbistan', 'Serbia', '🇷🇸'),
  WorldCountry('Singapur', 'Singapore', '🇸🇬'),
  WorldCountry('Güney Afrika', 'South Africa', '🇿🇦'),
  WorldCountry('Güney Kore', 'South Korea', '🇰🇷'),
  WorldCountry('İspanya', 'Spain', '🇪🇸'),
  WorldCountry('İsveç', 'Sweden', '🇸🇪'),
  WorldCountry('İsviçre', 'Switzerland', '🇨🇭'),
  WorldCountry('Tayvan', 'Taiwan', '🇹🇼'),
  WorldCountry('Tayland', 'Thailand', '🇹🇭'),
  WorldCountry('Tunus', 'Tunisia', '🇹🇳'),
  WorldCountry('Ukrayna', 'Ukraine', '🇺🇦'),
  WorldCountry('Birleşik Krallık', 'United Kingdom', '🇬🇧'),
  WorldCountry('ABD', 'United States', '🇺🇸'),
  WorldCountry('Özbekistan', 'Uzbekistan', '🇺🇿'),
  WorldCountry('Vietnam', 'Vietnam', '🇻🇳'),
  ];

  static WorldCountry? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Display label (flag + localized name); unknown cuisines are returned unchanged.
  static String label(String id, bool turkish) {
    final c = byId(id);
    if (c == null) return id;
    return turkish ? c.id : c.en;
  }
}
