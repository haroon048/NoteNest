import 'package:flutter_test/flutter_test.dart';
import 'package:note_nest/widgets/app_logo.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AppLogo renders properly smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AppLogo())));

    expect(find.byType(AppLogo), findsOneWidget);
  });
}
