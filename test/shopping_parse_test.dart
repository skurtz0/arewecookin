import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quick-add text is split into amount, unit and name', () {
    var i = ShoppingItem.parse('2 kg süt');
    expect([i.amount, i.unit, i.name], ['2', 'kg', 'süt']);
    i = ShoppingItem.parse('1,5 l süt');
    expect([i.amount, i.unit, i.name], ['1.5', 'l', 'süt']);
    i = ShoppingItem.parse('3 yumurta');
    expect([i.amount, i.unit, i.name], ['3', '', 'yumurta']);
    i = ShoppingItem.parse('3 büyük domates');
    expect([i.amount, i.unit, i.name], ['3', '', 'büyük domates']);
    i = ShoppingItem.parse('süt');
    expect([i.amount, i.unit, i.name], ['', '', 'süt']);
    i = ShoppingItem.parse('7up');
    expect(i.name, '7up');
  });

  test('several items can be typed at once; decimal commas stay intact', () {
    final items = ShoppingItem.parseMany('süt, 2 kg un; yumurta\n1,5 l su');
    expect(items.map((e) => e.name), ['süt', 'un', 'yumurta', 'su']);
    expect(items[1].amount, '2');
    expect(items[3].amount, '1.5');
    expect(ShoppingItem.parseMany(' , ;'), isEmpty);
  });
}
