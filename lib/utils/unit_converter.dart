/// Metric -> US customary conversion for ingredient amounts.
/// Kitchen units (cup, tbsp, tsp, pieces...) are left as they are.
class UnitConverter {
  UnitConverter._();

  /// Returns the converted amount and unit label, or null when [unit] is not a metric unit.
  static ({double amount, String unit})? toImperial(double amount, String unit) {
    switch (unit.trim().toLowerCase()) {
      case 'g':
      case 'gr':
      case 'gram':
        return amount >= 453.6
            ? (amount: amount / 453.592, unit: 'lb')
            : (amount: amount / 28.3495, unit: 'oz');
      case 'kg':
        return (amount: amount * 2.20462, unit: 'lb');
      case 'ml':
        return (amount: amount / 29.5735, unit: 'fl oz');
      case 'l':
      case 'lt':
      case 'litre':
      case 'liter':
        return (amount: amount * 1.05669, unit: 'qt');
      case 'cm':
        return (amount: amount / 2.54, unit: 'in');
    }
    return null;
  }

  /// Compact number text: whole numbers without decimals, otherwise one decimal.
  static String format(double v) {
    if ((v - v.roundToDouble()).abs() < 0.05) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}
