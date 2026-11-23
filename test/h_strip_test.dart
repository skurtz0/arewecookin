import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/widgets/h_strip.dart';

Widget _app(double width) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: HStrip(
                height: 48,
                builder: (c) => ListView.builder(
                  controller: c,
                  scrollDirection: Axis.horizontal,
                  itemCount: 40,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.all(4), child: Chip(label: Text('item $i'))),
                ),
              ),
            ),
          ),
        ),
      ),
    );

double _offset(WidgetTester t) => (t.widget<ListView>(find.byType(ListView)).controller!).offset;

void main() {
  testWidgets('a vertical mouse wheel over the strip scrolls it sideways', (tester) async {
    await tester.pumpWidget(_app(700));
    expect(_offset(tester), 0);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(find.byType(HStrip))));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
    await tester.pump();
    expect(_offset(tester), 120);
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, -500)));
    await tester.pump();
    expect(_offset(tester), 0);
  });

  testWidgets('wide screens show arrows that scroll the strip', (tester) async {
    await tester.pumpWidget(_app(700));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(_offset(tester), greaterThan(100));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  });

  testWidgets('narrow phones show no arrows', (tester) async {
    await tester.pumpWidget(_app(360));
    await tester.pump();
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
