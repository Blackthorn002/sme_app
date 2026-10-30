import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sme/business/business_controller.dart';
import 'package:sme/business/business_profile.dart';
import 'package:sme/main.dart';
import 'package:sme/l10n/app_language.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Set English for test text expectations
    AppLanguage.instance.setEnglish();
    await BusinessController.instance.reset();
  });

  testWidgets('new owner goes through business setup', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Step 1: business name
    expect(find.text("What's your business called?"), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hodan Pharmacy');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: business type
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Service provider'), findsOneWidget);
    await tester.tap(find.text('Pharmacy'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: default pages and optional modules
    expect(find.text('Default pages'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Patients'), findsOneWidget);
    await tester.tap(find.text('Create business'));
    await tester.pump(const Duration(milliseconds: 100));

    final profile = BusinessController.instance.profile!;
    expect(profile.name, 'Hodan Pharmacy');
    expect(profile.type, BusinessType.pharmacy);
    expect(profile.branches.single.name, 'Main branch');
    expect(profile.enabledModules, isNot(contains(BusinessModule.patients)));

    // The pharmacy pages open without the optional Patients tab.
    final nav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(nav.items.map((i) => i.label), ['Home', 'POS', 'Kaydka', 'More']);
  });

  testWidgets('enabling an optional module adds its tab', (tester) async {
    await BusinessController.instance.createBusiness(
      name: 'Gashi Cafe',
      type: BusinessType.restaurant,
      optionalModules: {},
      mainBranchName: 'Hargeisa',
    );

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    List<String?> labels() =>
        tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).items.map((i) => i.label).toList();

    expect(labels(), ['Home', 'POS', 'Sales', 'More']);

    await BusinessController.instance.setModuleEnabled(BusinessModule.credits, true);
    await tester.pump();
    expect(labels(), ['Home', 'POS', 'Sales', 'Credits', 'More']);
  });

  test('branches are managed under one business profile', () async {
    final controller = BusinessController.instance;
    await controller.createBusiness(
      name: 'Hodan Mini Market',
      type: BusinessType.shop,
      optionalModules: {BusinessModule.credits, BusinessModule.patients},
      mainBranchName: 'Hargeisa',
    );

    // Only modules that belong to the business type are kept.
    expect(controller.profile!.enabledOptionalModules, {BusinessModule.credits});

    await controller.addBranch(name: 'Burao', location: 'Market street');
    final burao = controller.profile!.branches.last;
    await controller.setActiveBranch(burao.id);
    expect(controller.profile!.activeBranch.name, 'Burao');

    await controller.removeBranch(burao.id);
    expect(controller.profile!.activeBranch.name, 'Hargeisa');

    // The last branch can't be removed.
    await controller.removeBranch(controller.profile!.activeBranchId);
    expect(controller.profile!.branches, hasLength(1));

    // The profile survives an app restart.
    final saved = (await SharedPreferences.getInstance()).getString('business_profile');
    expect(saved, contains('Hodan Mini Market'));
  });
}
