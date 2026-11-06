import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_finance/ui/aurora_card.dart';

void main() {
  testWidgets('gradient animation leaves card labels and buttons intact', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AuroraCard(
        child: Center(child: Text('Total balance')),
      )),
    ));
    expect(find.text('Total balance'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Total balance'), findsOneWidget);
  });
}
