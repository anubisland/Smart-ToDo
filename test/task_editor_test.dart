import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo/app.dart';

void main() {
  testWidgets('task editor presents Arabic labels in RTL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TaskEditor(lang: 'ar')),
        ),
      ),
    );
    expect(find.text('ما الذي تريد إنجازه؟'), findsOneWidget);
    expect(find.text('الأولوية'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('ما الذي تريد إنجازه؟'))),
      TextDirection.rtl,
    );
  });
}
