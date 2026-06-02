import 'package:flutter_test/flutter_test.dart';

import 'package:cadenceiq_app/main.dart';

void main() {
  testWidgets('CadenceIQ splash shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const CadenceIQApp());
    await tester.pump();
    expect(find.text('CadenceIQ'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
