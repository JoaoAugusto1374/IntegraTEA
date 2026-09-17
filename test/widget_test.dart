import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projeto/main.dart';

void main() {
  testWidgets('Cuidar+ shows splash screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const CuidarApp());

    expect(find.text('Cuidar+'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
