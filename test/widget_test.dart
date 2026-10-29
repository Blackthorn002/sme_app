import 'package:flutter_test/flutter_test.dart';
import 'package:sme/main.dart';
import 'package:sme/l10n/app_language.dart';

void main() {
  testWidgets('module selector renders and displays modules', (tester) async {
    // Set English for test text expectations
    AppLanguage.instance.setEnglish();

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Select a Module'), findsOneWidget);
    expect(find.text('Retail'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Services & Repairs'), findsOneWidget);
  });
}
