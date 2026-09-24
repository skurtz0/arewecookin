import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AreWeCookinApp(),
      ),
    );

    expect(find.text('AreWeCookin 🍳'), findsOneWidget);
  });
}
