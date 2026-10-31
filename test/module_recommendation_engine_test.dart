import 'package:flutter_test/flutter_test.dart';
import 'package:sme/general_features/onboarding/models/onboarding_models.dart';
import 'package:sme/general_features/onboarding/engine/module_recommendation_engine.dart';
import 'package:sme/general_features/repository/gashi_repository.dart';

void main() {
  group('Module Recommendation & Visibility Engine Tests', () {
    test('1. Retail category hides restaurant, pharmacy, and manufacturing modules', () {
      final visibility = ModuleRecommendationEngine.computeModuleVisibility(
        categoryId: 'retail_shops',
        subcategoryId: 'clothing_store',
        selectedOperations: ['sell_physical_products', 'manage_stock'],
        selectedModuleIds: {'pos'},
      );

      // Must be visible/recommended or selected
      expect(visibility['pos'], equals(ModuleVisibilityState.selected));
      expect(visibility['inventory'], equals(ModuleVisibilityState.recommended));
      expect(visibility['purchasing'], equals(ModuleVisibilityState.recommended));
      expect(visibility['accounting'], equals(ModuleVisibilityState.recommended));
      expect(visibility['crm'], equals(ModuleVisibilityState.recommended));

      // Unrelated industry modules MUST BE HIDDEN
      expect(visibility['restaurant_management'], equals(ModuleVisibilityState.hidden));
      expect(visibility['pharmacy_management'], equals(ModuleVisibilityState.hidden));
      expect(visibility['manufacturing_management'], equals(ModuleVisibilityState.hidden));
    });

    test('2. Restaurant category shows restaurant management and hides pharmacy & manufacturing', () {
      final visibility = ModuleRecommendationEngine.computeModuleVisibility(
        categoryId: 'restaurant_food',
        subcategoryId: 'restaurant',
        selectedOperations: ['manage_restaurant_tables'],
        selectedModuleIds: {},
      );

      expect(visibility['restaurant_management'], equals(ModuleVisibilityState.recommended));
      expect(visibility['pos'], equals(ModuleVisibilityState.recommended));
      expect(visibility['inventory'], equals(ModuleVisibilityState.recommended));

      // Unrelated modules hidden
      expect(visibility['pharmacy_management'], equals(ModuleVisibilityState.hidden));
      expect(visibility['manufacturing_management'], equals(ModuleVisibilityState.hidden));
    });

    test('3. Pharmacy category shows pharmacy management and hides restaurant & manufacturing', () {
      final visibility = ModuleRecommendationEngine.computeModuleVisibility(
        categoryId: 'pharmacy_healthcare',
        subcategoryId: 'community_pharmacy',
        selectedOperations: ['track_medicine_batches'],
        selectedModuleIds: {},
      );

      expect(visibility['pharmacy_management'], equals(ModuleVisibilityState.recommended));
      expect(visibility['pos'], equals(ModuleVisibilityState.recommended));
      expect(visibility['inventory'], equals(ModuleVisibilityState.recommended));

      expect(visibility['restaurant_management'], equals(ModuleVisibilityState.hidden));
      expect(visibility['manufacturing_management'], equals(ModuleVisibilityState.hidden));
    });

    test('4. Service category hides inventory/purchasing unless goods operations are selected', () {
      // Pure service with NO physical goods
      final pureServiceVisibility = ModuleRecommendationEngine.computeModuleVisibility(
        categoryId: 'service_business',
        subcategoryId: 'consulting',
        selectedOperations: ['provide_services', 'manage_appointments'],
        selectedModuleIds: {},
      );

      expect(pureServiceVisibility['service_management'], equals(ModuleVisibilityState.recommended));
      expect(pureServiceVisibility['crm'], equals(ModuleVisibilityState.recommended));
      expect(pureServiceVisibility['accounting'], equals(ModuleVisibilityState.recommended));

      // Inventory & Purchasing should be hidden for pure service
      expect(pureServiceVisibility['inventory'], equals(ModuleVisibilityState.hidden));
      expect(pureServiceVisibility['purchasing'], equals(ModuleVisibilityState.hidden));
      expect(pureServiceVisibility['pharmacy_management'], equals(ModuleVisibilityState.hidden));
      expect(pureServiceVisibility['restaurant_management'], equals(ModuleVisibilityState.hidden));

      // Service that ALSO sells physical products
      final serviceWithGoods = ModuleRecommendationEngine.computeModuleVisibility(
        categoryId: 'service_business',
        subcategoryId: 'repair_maintenance',
        selectedOperations: ['provide_services', 'sell_physical_products', 'manage_stock'],
        selectedModuleIds: {},
      );

      expect(serviceWithGoods['inventory'], equals(ModuleVisibilityState.recommended));
      expect(serviceWithGoods['purchasing'], equals(ModuleVisibilityState.recommended));
      expect(serviceWithGoods['pos'], equals(ModuleVisibilityState.recommended));
    });

    test('5. Mandatory Dependencies: Purchasing automatically includes Inventory', () {
      final res = ModuleRecommendationEngine.resolveDependencies({'purchasing'});

      expect(res.effectiveSelectedIds.contains('inventory'), isTrue);
      expect(res.autoIncludedDependencies['inventory'], equals('purchasing'));
      expect(res.explanations['inventory'], contains('Purchasing requires Inventory'));
    });

    test('6. Mandatory Dependencies: Restaurant Management automatically includes POS & Inventory', () {
      final res = ModuleRecommendationEngine.resolveDependencies({'restaurant_management'});

      expect(res.effectiveSelectedIds.contains('pos'), isTrue);
      expect(res.effectiveSelectedIds.contains('inventory'), isTrue);
      expect(res.autoIncludedDependencies['pos'], equals('restaurant_management'));
      expect(res.autoIncludedDependencies['inventory'], equals('restaurant_management'));
    });

    test('7. Mandatory Dependencies: Pharmacy Management automatically includes POS & Inventory', () {
      final res = ModuleRecommendationEngine.resolveDependencies({'pharmacy_management'});

      expect(res.effectiveSelectedIds.contains('pos'), isTrue);
      expect(res.effectiveSelectedIds.contains('inventory'), isTrue);
    });

    test('8. Mandatory Dependencies: Manufacturing Management automatically includes Inventory', () {
      final res = ModuleRecommendationEngine.resolveDependencies({'manufacturing_management'});

      expect(res.effectiveSelectedIds.contains('inventory'), isTrue);
    });

    test('9. Deselection blocking: Cannot deselect Inventory when Purchasing or Restaurant is active', () {
      final activeWithPurchasing = {'purchasing', 'inventory'};
      final blockReason = ModuleRecommendationEngine.canDeselectModule('inventory', activeWithPurchasing);

      expect(blockReason, isNotNull);
      expect(blockReason, contains('Purchasing & Supplier Management'));

      // If only standalone inventory is active, it CAN be removed
      final standaloneInventory = {'inventory', 'crm'};
      final allowed = ModuleRecommendationEngine.canDeselectModule('inventory', standaloneInventory);
      expect(allowed, isNull);
    });

    test('10. Add-ons eligibility check according to active modules', () {
      final scanner = ModuleRecommendationEngine.addOnCatalog.firstWhere((a) => a.id == 'ai_product_scanner');
      final salesAi = ModuleRecommendationEngine.addOnCatalog.firstWhere((a) => a.id == 'ai_sales_insights');
      final assistant = ModuleRecommendationEngine.addOnCatalog.firstWhere((a) => a.id == 'ai_business_assistant');

      // Scanner requires inventory
      expect(ModuleRecommendationEngine.isAddOnAvailable(scanner, {}), isFalse);
      expect(ModuleRecommendationEngine.isAddOnAvailable(scanner, {'inventory'}), isTrue);

      // Sales AI requires pos
      expect(ModuleRecommendationEngine.isAddOnAvailable(salesAi, {}), isFalse);
      expect(ModuleRecommendationEngine.isAddOnAvailable(salesAi, {'pos'}), isTrue);

      // General assistant has no module requirement
      expect(ModuleRecommendationEngine.isAddOnAvailable(assistant, {}), isTrue);
    });

    test('11. GashiRepository registers onboarded business and manages entitlements', () {
      final repo = GashiRepository.instance;
      final initialCount = repo.businesses.length;

      final testConfig = BusinessConfig(
        id: 9999,
        businessName: 'Supermarket Al-Nuur',
        categoryId: 'supermarket_grocery',
        categoryName: 'Supermarket & Grocery',
        subcategoryId: 'supermarket',
        subcategoryName: 'Supermarket',
        operations: ['sell_physical_products', 'manage_stock', 'purchase_suppliers'],
        selectedModules: ['pos', 'inventory', 'purchasing', 'accounting'],
        selectedAddOns: ['ai_product_scanner', 'whatsapp_receipts'],
        country: 'Somalia / Somaliland',
        city: 'Hargeisa',
        currency: 'USD',
        timeZone: 'UTC+3 (EAT)',
        phone: '+252 63 4112233',
        email: 'alnuur@gashi.com',
        fiscalYearStart: 'January',
        employeeCount: 8,
        branchCount: 2,
        createdAt: DateTime.now(),
      );

      final created = repo.createOnboardedBusiness(testConfig);

      expect(repo.businesses.length, equals(initialCount + 1));
      expect(created.name, equals('Supermarket Al-Nuur'));
      expect(repo.isModuleActive(9999, 'pos'), isTrue);
      expect(repo.isModuleActive(9999, 'inventory'), isTrue);
      expect(repo.isModuleActive(9999, 'restaurant_management'), isFalse);

      final entitled = repo.getEntitledModules(9999);
      expect(entitled, containsAll(['pos', 'inventory', 'purchasing', 'accounting']));

      final addOns = repo.getEntitledAddOns(9999);
      expect(addOns, containsAll(['ai_product_scanner', 'whatsapp_receipts']));
    });
  });
}

