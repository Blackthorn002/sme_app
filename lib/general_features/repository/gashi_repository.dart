import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gashi_models.dart';
import '../onboarding/models/onboarding_models.dart';

// ============================================================================
// GASHI PLATFORM PRODUCTION POSTGRESQL SCHEMA REFERENCE
// ==========================================
// -- Enable UUID extension if needed in future
// CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
// 
// -- 1. USERS & CORE PLATFORM
// CREATE TABLE users (
//     id BIGSERIAL PRIMARY KEY,
//     phone_number VARCHAR(32) NOT NULL UNIQUE,
//     full_name VARCHAR(255) NOT NULL,
//     password_hash VARCHAR(255) NOT NULL,
//     is_active BOOLEAN NOT NULL DEFAULT TRUE,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE businesses (
//     id BIGSERIAL PRIMARY KEY,
//     name VARCHAR(255) NOT NULL,
//     business_type VARCHAR(64) NOT NULL, -- retail, pharmacy, restaurant, service, barbershop
//     currency VARCHAR(10) NOT NULL DEFAULT 'USD', -- USD or SLSh
//     language VARCHAR(10) NOT NULL DEFAULT 'so',
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE business_users (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
//     role VARCHAR(32) NOT NULL, -- owner, cashier, accountant, staff
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
//     CONSTRAINT idx_business_user_unique UNIQUE (business_id, user_id)
// );
// 
// -- 2. MODULES & SUBSCRIPTIONS
// CREATE TABLE modules (
//     id BIGSERIAL PRIMARY KEY,
//     code VARCHAR(64) NOT NULL UNIQUE, -- pos, inventory, credit, expenses, services, suppliers
//     name VARCHAR(255) NOT NULL,
//     base_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00
// );
// 
// CREATE TABLE business_subscriptions (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     status VARCHAR(32) NOT NULL, -- active, expired, suspended, awaiting_payment
//     billing_period VARCHAR(32) NOT NULL, -- monthly, annual
//     start_date TIMESTAMP WITH TIME ZONE NOT NULL,
//     end_date TIMESTAMP WITH TIME ZONE NOT NULL
// );
// 
// CREATE TABLE business_entitlements (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     module_id BIGINT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
//     is_active BOOLEAN NOT NULL DEFAULT TRUE,
//     CONSTRAINT idx_business_module_unique UNIQUE (business_id, module_id)
// );
// 
// CREATE TABLE payment_requests (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     amount NUMERIC(12, 2) NOT NULL,
//     currency VARCHAR(10) NOT NULL,
//     payment_method VARCHAR(32) NOT NULL, -- zaad, edahab, bank_transfer
//     reference_number VARCHAR(128) NOT NULL,
//     proof_url TEXT NOT NULL, -- Cloudflare R2 URL
//     status VARCHAR(32) NOT NULL DEFAULT 'pending', -- pending, approved, rejected
//     reviewed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
//     reviewed_at TIMESTAMP WITH TIME ZONE
// );
// 
// -- 3. DYNAMIC CUSTOMIZATION ENGINE
// CREATE TABLE business_field_definitions (
//     id BIGSERIAL PRIMARY KEY,
//     business_type VARCHAR(64) NOT NULL, -- pharmacy, restaurant, retail
//     target_entity VARCHAR(64) NOT NULL, -- inventory, pos, customer_profile
//     field_key VARCHAR(64) NOT NULL, -- e.g. expiryDate, tableNumber
//     field_label VARCHAR(255) NOT NULL,
//     field_type VARCHAR(32) NOT NULL, -- text, number, image, list, boolean
//     is_required BOOLEAN NOT NULL DEFAULT FALSE
// );
// 
// -- 4. OPERATIONAL TABLES
// CREATE TABLE suppliers (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     name VARCHAR(255) NOT NULL,
//     phone VARCHAR(32),
//     balance_owed NUMERIC(12, 2) NOT NULL DEFAULT 0.00
// );
// 
// CREATE TABLE products (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     name VARCHAR(255) NOT NULL,
//     category_id BIGINT,
//     track_inventory BOOLEAN NOT NULL DEFAULT TRUE, -- FALSE for restaurant (dishes/menu items are POS-only) and services
//     stock_quantity INT DEFAULT NULL, -- NULL or not tracked when track_inventory = FALSE
//     cost_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     selling_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     supplier_id BIGINT REFERENCES suppliers(id) ON DELETE SET NULL,
//     unit VARCHAR(32) NOT NULL DEFAULT 'pcs',
//     custom_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
//     is_archived BOOLEAN NOT NULL DEFAULT FALSE
// );
// 
// CREATE TABLE stock_movements (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
//     type VARCHAR(32) NOT NULL, -- sale, stock_receipt, adjustment, return
//     quantity INT NOT NULL,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE customers (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     name VARCHAR(255) NOT NULL,
//     phone VARCHAR(32),
//     current_credit_balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     deposit_balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00
// );
// 
// CREATE TABLE customer_transactions (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
//     type VARCHAR(32) NOT NULL, -- deposit, deduction, credit_sale, repayment
//     amount NUMERIC(12, 2) NOT NULL,
//     notes TEXT,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE sales (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
//     customer_name VARCHAR(255) DEFAULT 'Walk-in Customer',
//     order_type VARCHAR(32) DEFAULT 'standard', -- Miis (dine-in), Safaari (takeaway), Delivery (geyn), standard
//     delivery_location TEXT, -- Only for delivery orders (address / location)
//     total_amount NUMERIC(12, 2) NOT NULL,
//     discount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     paid_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     payment_status VARCHAR(32) NOT NULL, -- paid, partial, credit
//     payment_method VARCHAR(32) NOT NULL DEFAULT 'cash',
//     custom_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE sale_items (
//     id BIGSERIAL PRIMARY KEY,
//     sale_id BIGINT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
//     product_id BIGINT REFERENCES products(id) ON DELETE SET NULL, -- NULL for restaurant menu dishes (POS-only, no inventory)
//     product_name VARCHAR(255) NOT NULL,
//     quantity INT NOT NULL DEFAULT 1,
//     unit_price NUMERIC(12, 2) NOT NULL,
//     total NUMERIC(12, 2) NOT NULL
// );
// 
// CREATE TABLE services (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     name VARCHAR(255) NOT NULL,
//     price NUMERIC(12, 2) NOT NULL
// );
// 
// CREATE TABLE service_jobs (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
//     service_id BIGINT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
//     assigned_staff_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
//     status VARCHAR(32) NOT NULL, -- pending, in_progress, completed
//     total_amount NUMERIC(12, 2) NOT NULL,
//     deposit_paid NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     balance_due NUMERIC(12, 2) NOT NULL,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// CREATE TABLE expenses (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     category VARCHAR(128) NOT NULL,
//     amount NUMERIC(12, 2) NOT NULL,
//     payment_method VARCHAR(32) NOT NULL,
//     notes TEXT,
//     expense_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
//     recorded_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE
// );
// 
// CREATE TABLE audit_logs (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
//     action VARCHAR(255) NOT NULL,
//     entity_type VARCHAR(128) NOT NULL,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );
// 
// -- ==========================================
// -- INDEXES FOR MULTI-TENANT & HIGH PERFORMANCE
// -- ==========================================
// CREATE INDEX idx_products_business ON products(business_id);
// CREATE INDEX idx_products_custom_attributes ON products USING gin(custom_attributes);
// CREATE INDEX idx_sales_business ON sales(business_id);
// CREATE INDEX idx_sales_customer ON sales(customer_id);
// CREATE INDEX idx_sales_custom_attributes ON sales USING gin(custom_attributes);
// CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
// CREATE INDEX idx_customer_tx_customer ON customer_transactions(customer_id);
// CREATE INDEX idx_field_defs_type_entity ON business_field_definitions(business_type, target_entity);
// ============================================================================

class GashiRepository extends ChangeNotifier {
  static final GashiRepository instance = GashiRepository._internal();
  GashiRepository._internal() {
    _seedInitialData();
  }

  // Connectivity & Sync Status
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // In-Memory Database (Offline Cache)
  final List<Business> _businesses = [];
  final List<BusinessFieldDefinition> _fieldDefinitions = [];
  final List<Product> _products = [];
  final List<Supplier> _suppliers = [];
  final List<StockMovement> _stockMovements = [];
  final List<Customer> _customers = [];
  final List<CustomerTransaction> _customerTransactions = [];
  final List<Sale> _sales = [];

  // Toggle online/offline for testing or when device connectivity changes
  void toggleConnectivity() {
    _isOnline = !_isOnline;
    if (_isOnline && _pendingSyncCount > 0) {
      syncPendingData();
    }
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // BUSINESSES
  // --------------------------------------------------------------------------
  List<Business> get businesses => List.unmodifiable(_businesses);

  Business? getBusinessByType(BusinessType type) {
    try {
      return _businesses.firstWhere((b) => b.businessType == type);
    } catch (_) {
      return null;
    }
  }

  Business? getBusinessById(int id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateBusinessTaxRate(int businessId, double taxRate) {
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      _businesses[index] = _businesses[index].copyWith(taxRate: taxRate);
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // DYNAMIC ONBOARDING & MODULE ENTITLEMENT ENGINE
  // --------------------------------------------------------------------------
  final Map<int, List<String>> _businessEntitlements = {};
  final Map<int, List<String>> _businessAddOns = {};

  /// Creates and registers a newly onboarded business from the dynamic setup wizard
  Business createOnboardedBusiness(BusinessConfig config) {
    // Map category ID to existing BusinessType enum for backwards compatibility
    BusinessType type = BusinessType.retail;
    if (config.categoryId == 'pharmacy_healthcare') {
      type = BusinessType.pharmacy;
    } else if (config.categoryId == 'restaurant_food') {
      type = BusinessType.restaurant;
    } else if (config.categoryId == 'service_business' || config.categoryId == 'beauty_personal_care') {
      type = BusinessType.service;
    }

    final newBusiness = Business(
      id: config.id,
      name: config.businessName,
      businessType: type,
      currency: config.currency,
      language: 'so',
      taxRate: 0.0,
      createdAt: config.createdAt,
      categoryId: config.categoryId,
      categoryName: config.categoryName,
      subcategoryId: config.subcategoryId,
      subcategoryName: config.subcategoryName,
      operations: config.operations,
      activeModules: config.selectedModules,
      activeAddOns: config.selectedAddOns,
      country: config.country,
      city: config.city,
      timeZone: config.timeZone,
      phone: config.phone,
      email: config.email,
      fiscalYearStart: config.fiscalYearStart,
      employeeCount: config.employeeCount,
      branchCount: config.branchCount,
      logoUrl: config.logoUrl,
    );

    _businesses.insert(0, newBusiness);
    _businessEntitlements[newBusiness.id] = List<String>.from(config.selectedModules);
    _businessAddOns[newBusiness.id] = List<String>.from(config.selectedAddOns);

    if (!_isOnline) _pendingSyncCount++;
    notifyListeners();
    return newBusiness;
  }

  /// Check whether a specific module is entitled & active for a business
  bool isModuleActive(int businessId, String moduleCode) {
    final modules = _businessEntitlements[businessId];
    if (modules != null) {
      return modules.contains(moduleCode);
    }
    final b = getBusinessById(businessId);
    if (b != null) {
      return b.activeModules.contains(moduleCode);
    }
    return true; // Default allow for demo businesses
  }

  /// Get list of active modules for a business
  List<String> getEntitledModules(int businessId) {
    if (_businessEntitlements.containsKey(businessId)) {
      return List.unmodifiable(_businessEntitlements[businessId]!);
    }
    final b = getBusinessById(businessId);
    if (b != null && b.activeModules.isNotEmpty) {
      return List.unmodifiable(b.activeModules);
    }
    return const ['pos', 'inventory', 'sales', 'credits'];
  }

  /// Get list of active add-ons for a business
  List<String> getEntitledAddOns(int businessId) {
    if (_businessAddOns.containsKey(businessId)) {
      return List.unmodifiable(_businessAddOns[businessId]!);
    }
    final b = getBusinessById(businessId);
    if (b != null && b.activeAddOns.isNotEmpty) {
      return List.unmodifiable(b.activeAddOns);
    }
    return const [];
  }

  /// Update active modules and add-ons for an existing business
  void updateBusinessEntitlements({
    required int businessId,
    required List<String> modules,
    required List<String> addOns,
  }) {
    _businessEntitlements[businessId] = List<String>.from(modules);
    _businessAddOns[businessId] = List<String>.from(addOns);

    final idx = _businesses.indexWhere((b) => b.id == businessId);
    if (idx != -1) {
      _businesses[idx] = _businesses[idx].copyWith(
        activeModules: modules,
        activeAddOns: addOns,
      );
    }

    if (!_isOnline) _pendingSyncCount++;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // DYNAMIC FIELD DEFINITIONS (Changeable Columns Engine)
  // --------------------------------------------------------------------------
  List<BusinessFieldDefinition> getFieldDefinitions(
      String businessType, String targetEntity) {
    return _fieldDefinitions
        .where((f) =>
            f.businessType == businessType && f.targetEntity == targetEntity)
        .toList();
  }

  void addFieldDefinition({
    required String businessType,
    required String targetEntity,
    required String fieldKey,
    required String fieldLabel,
    String fieldType = 'text',
    bool isRequired = false,
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch;
    _fieldDefinitions.add(
      BusinessFieldDefinition(
        id: newId,
        businessType: businessType,
        targetEntity: targetEntity,
        fieldKey: fieldKey,
        fieldLabel: fieldLabel,
        fieldType: fieldType,
        isRequired: isRequired,
      ),
    );
    notifyListeners();
  }

  void removeFieldDefinition(int definitionId) {
    _fieldDefinitions.removeWhere((f) => f.id == definitionId);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // PRODUCTS (Inventory)
  // --------------------------------------------------------------------------
  List<Product> getProducts(int businessId) {
    return _products
        .where((p) => p.businessId == businessId && !p.isArchived)
        .toList();
  }

  Product? getProductById(int productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  void addProduct(Product product) {
    final bool synced = _isOnline;
    final newProduct = product.copyWith(
      id: product.id <= 0 ? DateTime.now().millisecondsSinceEpoch : product.id,
      isSynced: synced,
    );
    _products.insert(0, newProduct);

    // Record initial stock receipt if stock > 0
    if (newProduct.stockQuantity > 0) {
      _stockMovements.insert(
        0,
        StockMovement(
          id: DateTime.now().millisecondsSinceEpoch,
          businessId: newProduct.businessId,
          productId: newProduct.id,
          type: 'stock_receipt',
          quantity: newProduct.stockQuantity,
          notes: 'Diiwaangelinta hore (Initial stock receipt)',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (!synced) _pendingSyncCount++;
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final oldProduct = _products[index];
      final bool synced = _isOnline;
      _products[index] = product.copyWith(isSynced: synced);

      // Log stock movement if stock was adjusted during edit
      if (oldProduct.stockQuantity != product.stockQuantity) {
        final delta = product.stockQuantity - oldProduct.stockQuantity;
        _stockMovements.insert(
          0,
          StockMovement(
            id: DateTime.now().millisecondsSinceEpoch,
            businessId: product.businessId,
            productId: product.id,
            type: delta > 0 ? 'stock_receipt' : 'adjustment',
            quantity: delta,
            notes: 'Wax ka beddelka alaabta (Product edit adjustment)',
            createdAt: DateTime.now(),
          ),
        );
      }

      if (!synced) _pendingSyncCount++;
      notifyListeners();
    }
  }

  void deleteProduct(int productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      // Soft-delete (archive) conforming to PostgreSQL is_archived column
      _products[index] = _products[index].copyWith(isArchived: true);
      if (!_isOnline) _pendingSyncCount++;
      notifyListeners();
    }
  }

  void adjustStock(int productId, int quantityDelta,
      {String type = 'adjustment', String notes = ''}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final p = _products[index];
      final newQty = (p.stockQuantity + quantityDelta).clamp(0, 999999);
      _products[index] = p.copyWith(stockQuantity: newQty, isSynced: _isOnline);

      // Record stock movement (conforming to PostgreSQL stock_movements)
      _stockMovements.insert(
        0,
        StockMovement(
          id: DateTime.now().millisecondsSinceEpoch,
          businessId: p.businessId,
          productId: p.id,
          type: type,
          quantity: quantityDelta,
          notes: notes.isNotEmpty
              ? notes
              : (quantityDelta > 0
                  ? 'Soo dejin (Stock In)'
                  : 'Dhimis (Stock Out)'),
          createdAt: DateTime.now(),
        ),
      );

      if (!_isOnline) _pendingSyncCount++;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // SUPPLIERS (PostgreSQL suppliers table)
  // --------------------------------------------------------------------------
  List<Supplier> getSuppliers(int businessId) {
    return _suppliers.where((s) => s.businessId == businessId).toList();
  }

  Supplier? getSupplierById(int supplierId) {
    try {
      return _suppliers.firstWhere((s) => s.id == supplierId);
    } catch (_) {
      return null;
    }
  }

  void addSupplier(Supplier supplier) {
    final newSupplier = supplier.copyWith(
      id: supplier.id <= 0 ? DateTime.now().millisecondsSinceEpoch : supplier.id,
    );
    _suppliers.insert(0, newSupplier);
    if (!_isOnline) _pendingSyncCount++;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // STOCK MOVEMENTS (PostgreSQL stock_movements table)
  // --------------------------------------------------------------------------
  List<StockMovement> getStockMovements(int productId) {
    return _stockMovements
        .where((m) => m.productId == productId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void recordStockMovement(StockMovement movement) {
    _stockMovements.insert(0, movement);
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // CUSTOMERS & CREDITS
  // --------------------------------------------------------------------------
  List<Customer> getCustomers(int businessId) {
    return _customers.where((c) => c.businessId == businessId).toList();
  }

  Customer? getCustomerById(int customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (_) {
      return null;
    }
  }

  Customer addCustomer(Customer customer) {
    final newCustomer = customer.copyWith(
      id: customer.id <= 0 ? DateTime.now().millisecondsSinceEpoch : customer.id,
    );
    _customers.insert(0, newCustomer);
    if (!_isOnline) _pendingSyncCount++;
    notifyListeners();
    return newCustomer;
  }

  void recordRepayment({
    required int businessId,
    required int customerId,
    required double amount,
    String paymentMethod = 'Zaad',
    String notes = '',
  }) {
    final customerIndex = _customers.indexWhere((c) => c.id == customerId);
    if (customerIndex >= 0) {
      final c = _customers[customerIndex];
      final newBalance = (c.currentCreditBalance - amount).clamp(0.0, double.infinity);
      _customers[customerIndex] = c.copyWith(currentCreditBalance: newBalance);

      _customerTransactions.insert(
        0,
        CustomerTransaction(
          id: DateTime.now().millisecondsSinceEpoch,
          businessId: businessId,
          customerId: customerId,
          type: 'repayment',
          amount: amount,
          notes: notes.isNotEmpty ? notes : 'Lacag bixin / Repayment',
          paymentMethod: paymentMethod,
          createdAt: DateTime.now(),
        ),
      );

      if (!_isOnline) _pendingSyncCount++;
      notifyListeners();
    }
  }

  List<CustomerTransaction> getCustomerTransactions(int customerId) {
    return _customerTransactions.where((t) => t.customerId == customerId).toList();
  }

  // --------------------------------------------------------------------------
  // SALES & POS CHECKOUT
  // --------------------------------------------------------------------------
  List<Sale> getSales(int businessId) {
    return _sales.where((s) => s.businessId == businessId).toList();
  }

  Sale recordSale({
    required int businessId,
    int? customerId,
    String customerName = 'Walk-in Customer',
    String orderType = 'standard',
    String? deliveryLocation,
    required double totalAmount,
    double discount = 0.0,
    required double paidAmount,
    required String paymentStatus, // 'paid', 'partial', 'credit'
    required String paymentMethod,
    Map<String, dynamic> customAttributes = const {},
    required List<SaleItem> items,
  }) {
    final saleId = DateTime.now().millisecondsSinceEpoch;
    final bool synced = _isOnline;

    final newSale = Sale(
      id: saleId,
      businessId: businessId,
      customerId: customerId,
      customerName: customerName,
      orderType: orderType,
      deliveryLocation: deliveryLocation,
      totalAmount: totalAmount,
      discount: discount,
      paidAmount: paidAmount,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      customAttributes: customAttributes,
      items: items,
      createdAt: DateTime.now(),
      isSynced: synced,
    );

    _sales.insert(0, newSale);

    // Deduct stock ONLY for products that track inventory (Retail/Pharmacy).
    // Restaurant menu dishes are POS-only and do not track inventory quantities.
    for (final item in items) {
      if (item.productId != null) {
        final product = getProductById(item.productId!);
        if (product != null && product.trackInventory) {
          adjustStock(
            item.productId!,
            -item.quantity,
            type: 'sale',
            notes: 'Iibka POS #${newSale.id.toString().substring(newSale.id.toString().length - 4)}',
          );
        }
      }
    }

    // If there is credit or partial payment on customer account
    if (paymentStatus != 'paid' && customerId != null) {
      final remainingDebt = (totalAmount - paidAmount).clamp(0.0, totalAmount);
      final customerIdx = _customers.indexWhere((c) => c.id == customerId);
      if (customerIdx >= 0) {
        final c = _customers[customerIdx];
        _customers[customerIdx] = c.copyWith(
          currentCreditBalance: c.currentCreditBalance + remainingDebt,
        );

        _customerTransactions.insert(
          0,
          CustomerTransaction(
            id: DateTime.now().millisecondsSinceEpoch + 1,
            businessId: businessId,
            customerId: customerId,
            type: 'credit_sale',
            amount: remainingDebt,
            notes: 'Iibka #${saleId.toString().substring(saleId.toString().length - 4)}',
            paymentMethod: paymentMethod,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    if (!synced) _pendingSyncCount++;
    notifyListeners();
    return newSale;
  }

  // --------------------------------------------------------------------------
  // BACKGROUND SYNC ENGINE (Offline -> Cloud Sync)
  // --------------------------------------------------------------------------
  Future<void> syncPendingData() async {
    if (_pendingSyncCount == 0 || _isSyncing || !_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    // Simulating background network synchronization with PostgreSQL backend
    await Future<void>.delayed(const Duration(seconds: 2));

    _pendingSyncCount = 0;
    _isSyncing = false;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // INITIAL SEED DATA (Strictly Conforming to PostgreSQL Schema)
  // --------------------------------------------------------------------------
  void _seedInitialData() {
    final now = DateTime.now();

    // 1. Businesses
    _businesses.addAll([
      Business(
        id: 1,
        name: 'Farmashiyaha Gashi',
        businessType: BusinessType.pharmacy,
        currency: 'USD',
        language: 'so',
        createdAt: now,
      ),
      Business(
        id: 2,
        name: 'Dukaanka Gashi',
        businessType: BusinessType.retail,
        currency: 'USD',
        language: 'so',
        createdAt: now,
      ),
      Business(
        id: 3,
        name: 'Makhaayadda Gashi',
        businessType: BusinessType.restaurant,
        currency: 'USD',
        language: 'so',
        createdAt: now,
      ),
      Business(
        id: 4,
        name: 'Adeegga & Dayactirka Gashi',
        businessType: BusinessType.service,
        currency: 'USD',
        language: 'so',
        createdAt: now,
      ),
    ]);

    // 2. Dynamic Field Definitions (Column Engine - PostgreSQL business_field_definitions)
    _fieldDefinitions.addAll([
      // Pharmacy Custom Fields
      const BusinessFieldDefinition(
        id: 101,
        businessType: 'pharmacy',
        targetEntity: 'inventory',
        fieldKey: 'expiry_date',
        fieldLabel: 'Taariikhda Dhicitaanka (Expiry Date)',
        fieldType: 'date',
        isRequired: true,
      ),
      const BusinessFieldDefinition(
        id: 102,
        businessType: 'pharmacy',
        targetEntity: 'inventory',
        fieldKey: 'dosage',
        fieldLabel: 'Xaddiga / Qiyaasta (Dosage e.g. 500mg)',
        fieldType: 'text',
        isRequired: false,
      ),
      const BusinessFieldDefinition(
        id: 103,
        businessType: 'pharmacy',
        targetEntity: 'inventory',
        fieldKey: 'batch_number',
        fieldLabel: 'Lambarka Dufcadda (Batch Number)',
        fieldType: 'text',
        isRequired: false,
      ),
      const BusinessFieldDefinition(
        id: 104,
        businessType: 'pharmacy',
        targetEntity: 'inventory',
        fieldKey: 'requires_prescription',
        fieldLabel: 'Warqad Dhakhtar (Prescription Required)',
        fieldType: 'boolean',
        isRequired: false,
      ),

      // Retail Custom Fields
      const BusinessFieldDefinition(
        id: 201,
        businessType: 'retail',
        targetEntity: 'inventory',
        fieldKey: 'barcode',
        fieldLabel: 'Baarkoodhka (Barcode / SKU)',
        fieldType: 'text',
        isRequired: false,
      ),
      const BusinessFieldDefinition(
        id: 202,
        businessType: 'retail',
        targetEntity: 'inventory',
        fieldKey: 'brand',
        fieldLabel: 'Summadda (Brand)',
        fieldType: 'text',
        isRequired: false,
      ),
      const BusinessFieldDefinition(
        id: 203,
        businessType: 'retail',
        targetEntity: 'inventory',
        fieldKey: 'size',
        fieldLabel: 'Cabbirka (Size e.g. S, M, L, XL, 32, 42)',
        fieldType: 'text',
        isRequired: false,
      ),
      const BusinessFieldDefinition(
        id: 204,
        businessType: 'retail',
        targetEntity: 'inventory',
        fieldKey: 'color',
        fieldLabel: 'Midabka (Color)',
        fieldType: 'text',
        isRequired: false,
      ),
    ]);

    // 3. Products with Custom Attributes (PostgreSQL products table)
    _products.addAll([
      // Pharmacy Products (Business 1)
      const Product(
        id: 1,
        businessId: 1,
        name: 'Panadol Advance',
        categoryName: 'Xanuun Baabiiye',
        stockQuantity: 150,
        costPrice: 1.20,
        sellingPrice: 2.50,
        supplierId: 1,
        unit: 'baakidh',
        imageUrl:
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'expiry_date': '2027-06-30',
          'dosage': '500mg',
          'batch_number': 'BCH-8821',
          'requires_prescription': false,
        },
      ),
      const Product(
        id: 2,
        businessId: 1,
        name: 'Amoxicillin Trihydrate',
        categoryName: 'Antibiotic',
        stockQuantity: 90,
        costPrice: 2.50,
        sellingPrice: 4.50,
        supplierId: 2,
        unit: 'baakidh',
        imageUrl:
            'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'expiry_date': '2026-11-15',
          'dosage': '250mg',
          'batch_number': 'AMX-4410',
          'requires_prescription': true,
        },
      ),
      const Product(
        id: 3,
        businessId: 1,
        name: 'Paracetamol Sirop (Sharoobo)',
        categoryName: 'Xanuun Baabiiye',
        stockQuantity: 75,
        costPrice: 0.80,
        sellingPrice: 1.80,
        supplierId: 1,
        unit: 'dhalo',
        imageUrl:
            'https://images.unsplash.com/photo-1550572017-edb3df163ab5?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'expiry_date': '2027-02-28',
          'dosage': '120mg/5ml',
          'batch_number': 'SYR-1029',
          'requires_prescription': false,
        },
      ),
      const Product(
        id: 4,
        businessId: 1,
        name: 'Vitamin C Chewable',
        categoryName: 'Fitamiin',
        stockQuantity: 200,
        costPrice: 1.50,
        sellingPrice: 3.00,
        supplierId: 2,
        unit: 'xabbo',
        imageUrl:
            'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'expiry_date': '2028-01-20',
          'dosage': '1000mg',
          'batch_number': 'VTC-9002',
          'requires_prescription': false,
        },
      ),
      const Product(
        id: 5,
        businessId: 1,
        name: 'Ibuprofen 400mg',
        categoryName: 'Xanuun Baabiiye',
        stockQuantity: 8,
        costPrice: 1.10,
        sellingPrice: 2.20,
        supplierId: 1,
        unit: 'falag',
        imageUrl:
            'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'expiry_date': '2026-09-10',
          'dosage': '400mg',
          'batch_number': 'IBU-3320',
          'requires_prescription': false,
        },
      ),

      // Retail Products (Business 2)
      const Product(
        id: 11,
        businessId: 2,
        name: 'Shaadh Cudbi ah (Cotton Shirt)',
        categoryName: 'Dhar',
        stockQuantity: 45,
        costPrice: 7.00,
        sellingPrice: 14.00,
        supplierId: 3,
        unit: 'xabbo',
        imageUrl:
            'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'barcode': '6001239841',
          'brand': 'Zara Style',
          'size': 'L',
          'color': 'Buluug (Blue)',
        },
      ),
      const Product(
        id: 12,
        businessId: 2,
        name: 'Surwaal Jeans Classic',
        categoryName: 'Dhar',
        stockQuantity: 30,
        costPrice: 11.00,
        sellingPrice: 22.00,
        supplierId: 3,
        unit: 'xabbo',
        imageUrl:
            'https://images.unsplash.com/photo-1542272604-780c96856592?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'barcode': '6001239855',
          'brand': 'Denim Co',
          'size': '32',
          'color': 'Madow (Black)',
        },
      ),
      const Product(
        id: 13,
        businessId: 2,
        name: 'Kabo Baati (Sneakers)',
        categoryName: 'Kabo',
        stockQuantity: 5,
        costPrice: 14.00,
        sellingPrice: 28.00,
        supplierId: 4,
        unit: 'joog',
        imageUrl:
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'barcode': '6009847120',
          'brand': 'SportPlus',
          'size': '42',
          'color': 'Caddaan (White)',
        },
      ),
      const Product(
        id: 14,
        businessId: 2,
        name: 'Coodh / Suudh Dhamaystiran',
        categoryName: 'Dhar',
        stockQuantity: 15,
        costPrice: 35.00,
        sellingPrice: 65.00,
        supplierId: 4,
        unit: 'joog',
        imageUrl:
            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'barcode': '6004729103',
          'brand': 'Royal Milano',
          'size': 'XL',
          'color': 'Kaki',
        },
      ),
      const Product(
        id: 15,
        businessId: 2,
        name: 'Koofiyad / Boorso Maqaar ah',
        categoryName: 'Agab',
        stockQuantity: 40,
        costPrice: 6.50,
        sellingPrice: 12.00,
        supplierId: 3,
        unit: 'xabbo',
        imageUrl:
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=400&q=80',
        customAttributes: {
          'barcode': '6003381920',
          'brand': 'Safari Leather',
          'size': 'Standard',
          'color': 'Bunni (Brown)',
        },
      ),
    ]);

    // 4. Customers & Credits
    _customers.addAll([
      const Customer(
        id: 1,
        businessId: 1,
        name: 'Axmed Maxamed Nuur',
        phone: '+252 63 4411223',
        currentCreditBalance: 45.0,
        depositBalance: 0.0,
      ),
      const Customer(
        id: 2,
        businessId: 1,
        name: 'Safiya Cabdi Xasan',
        phone: '+252 63 7788990',
        currentCreditBalance: 110.0,
        depositBalance: 0.0,
      ),
      const Customer(
        id: 3,
        businessId: 2,
        name: 'Khadar Cismaan Cali',
        phone: '+252 65 9911224',
        currentCreditBalance: 35.0,
        depositBalance: 0.0,
      ),
    ]);

    // 5. Suppliers (PostgreSQL suppliers table)
    _suppliers.addAll([
      const Supplier(
        id: 1,
        businessId: 1,
        name: 'Al-Baraka Pharma Supplies',
        phone: '+252 63 4421100',
        balanceOwed: 250.0,
      ),
      const Supplier(
        id: 2,
        businessId: 1,
        name: 'Hodan Medical Importers',
        phone: '+252 63 4455888',
        balanceOwed: 0.0,
      ),
      const Supplier(
        id: 3,
        businessId: 2,
        name: 'Gashi Wholesale Co.',
        phone: '+252 63 4112233',
        balanceOwed: 500.0,
      ),
      const Supplier(
        id: 4,
        businessId: 2,
        name: 'Beder General Trading',
        phone: '+252 63 4998877',
        balanceOwed: 120.0,
      ),
    ]);

    // 6. Stock Movements (PostgreSQL stock_movements table)
    _stockMovements.addAll([
      StockMovement(
        id: 1001,
        businessId: 1,
        productId: 1,
        type: 'stock_receipt',
        quantity: 150,
        notes: 'Xamuul cusub (Initial stock receipt)',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      StockMovement(
        id: 1002,
        businessId: 1,
        productId: 2,
        type: 'stock_receipt',
        quantity: 90,
        notes: 'Xamuul cusub (Initial stock receipt)',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      StockMovement(
        id: 1003,
        businessId: 2,
        productId: 11,
        type: 'stock_receipt',
        quantity: 45,
        notes: 'Kooto cusub (Supplier batch)',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ]);

    // 7. Initial Sales Records (Pharmacy, Retail & Restaurant POS orders across Today, This Week & This Month)
    _sales.addAll([
      // --- Pharmacy Sales (businessId: 1) ---
      Sale(
        id: 1001,
        businessId: 1,
        customerName: 'Maxamed Nuur Cali',
        orderType: 'standard',
        totalAmount: 4.50,
        paidAmount: 4.50,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        items: const [
          SaleItem(id: 101, saleId: 1001, productId: 1, productName: 'Panadol Advance', quantity: 2, unitPrice: 1.50, total: 3.00),
          SaleItem(id: 102, saleId: 1001, productId: 4, productName: 'Vitamin C Chewable', quantity: 1, unitPrice: 1.50, total: 1.50),
        ],
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      Sale(
        id: 1002,
        businessId: 1,
        customerName: 'Safiya Cabdi Xasan',
        orderType: 'standard',
        totalAmount: 6.50,
        paidAmount: 6.50,
        paymentStatus: 'paid',
        paymentMethod: 'e-Dahab',
        items: const [
          SaleItem(id: 103, saleId: 1002, productId: 2, productName: 'Amoxicillin Trihydrate', quantity: 1, unitPrice: 3.50, total: 3.50),
          SaleItem(id: 104, saleId: 1002, productId: 4, productName: 'Vitamin C Chewable', quantity: 2, unitPrice: 1.50, total: 3.00),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Sale(
        id: 1003,
        businessId: 1,
        customerName: 'Cali Xuseen Warsame',
        orderType: 'standard',
        totalAmount: 3.20,
        paidAmount: 3.20,
        paymentStatus: 'paid',
        paymentMethod: 'Kaash',
        items: const [
          SaleItem(id: 105, saleId: 1003, productId: 3, productName: 'Paracetamol Sirop (Sharoobo)', quantity: 2, unitPrice: 1.10, total: 2.20),
          SaleItem(id: 106, saleId: 1003, productId: 1, productName: 'Panadol Advance', quantity: 1, unitPrice: 1.00, total: 1.00),
        ],
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      Sale(
        id: 1004,
        businessId: 1,
        customerName: 'Khadra Maxamuud',
        orderType: 'standard',
        totalAmount: 10.50,
        paidAmount: 0.0,
        paymentStatus: 'credit',
        paymentMethod: 'Dayn',
        items: const [
          SaleItem(id: 107, saleId: 1004, productId: 2, productName: 'Amoxicillin Trihydrate', quantity: 3, unitPrice: 3.50, total: 10.50),
        ],
        createdAt: now.subtract(const Duration(days: 4, hours: 1)),
      ),
      Sale(
        id: 1005,
        businessId: 1,
        customerName: 'Faadumo Jaamac',
        orderType: 'standard',
        totalAmount: 8.00,
        paidAmount: 8.00,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        items: const [
          SaleItem(id: 108, saleId: 1005, productId: 5, productName: 'Ibuprofen 400mg', quantity: 4, unitPrice: 2.00, total: 8.00),
        ],
        createdAt: now.subtract(const Duration(days: 12)),
      ),

      // --- Retail Sales (businessId: 2) ---
      Sale(
        id: 2001,
        businessId: 2,
        customerName: 'Xasan Cabdilaahi',
        orderType: 'standard',
        totalAmount: 25.00,
        paidAmount: 25.00,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        items: const [
          SaleItem(id: 201, saleId: 2001, productId: 11, productName: 'Shaadh Cudbi ah (Cotton Shirt)', quantity: 1, unitPrice: 12.00, total: 12.00),
          SaleItem(id: 202, saleId: 2001, productId: 12, productName: 'Surwaal Jeans Classic', quantity: 1, unitPrice: 13.00, total: 13.00),
        ],
        createdAt: now.subtract(const Duration(minutes: 50)),
      ),
      Sale(
        id: 2002,
        businessId: 2,
        customerName: 'Nimco Cumar',
        orderType: 'standard',
        totalAmount: 22.00,
        paidAmount: 22.00,
        paymentStatus: 'paid',
        paymentMethod: 'e-Dahab',
        items: const [
          SaleItem(id: 203, saleId: 2002, productId: 13, productName: 'Kabo Baati (Sneakers)', quantity: 1, unitPrice: 22.00, total: 22.00),
        ],
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Sale(
        id: 2003,
        businessId: 2,
        customerName: 'Khadar Cismaan Cali',
        orderType: 'standard',
        totalAmount: 18.00,
        paidAmount: 0.0,
        paymentStatus: 'credit',
        paymentMethod: 'Dayn',
        items: const [
          SaleItem(id: 204, saleId: 2003, productId: 12, productName: 'Surwaal Jeans Classic', quantity: 1, unitPrice: 18.00, total: 18.00),
        ],
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      Sale(
        id: 2004,
        businessId: 2,
        customerName: 'Mustafe Cali Nuur',
        orderType: 'standard',
        totalAmount: 24.00,
        paidAmount: 24.00,
        paymentStatus: 'paid',
        paymentMethod: 'Kaash',
        items: const [
          SaleItem(id: 205, saleId: 2004, productId: 11, productName: 'Shaadh Cudbi ah (Cotton Shirt)', quantity: 2, unitPrice: 12.00, total: 24.00),
        ],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Sale(
        id: 2005,
        businessId: 2,
        customerName: 'Maryan Warsame',
        orderType: 'standard',
        totalAmount: 45.00,
        paidAmount: 45.00,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        items: const [
          SaleItem(id: 206, saleId: 2005, productId: 14, productName: 'Coodh / Suudh Dhamaystiran', quantity: 1, unitPrice: 45.00, total: 45.00),
        ],
        createdAt: now.subtract(const Duration(days: 14)),
      ),

      // --- Restaurant Sales (businessId: 3) ---
      Sale(
        id: 2049,
        businessId: 3,
        customerName: 'Axmed Cali',
        orderType: 'Miis',
        totalAmount: 17.50,
        paidAmount: 17.50,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        customAttributes: const {
          'title': 'Miiska 3',
          'typeLabel': 'Dine-in',
          'table': '3',
        },
        items: const [
          SaleItem(id: 1, saleId: 2049, productId: null, productName: 'Bariis iyo Hilib', quantity: 2, unitPrice: 7.00, total: 14.00),
          SaleItem(id: 2, saleId: 2049, productId: null, productName: 'Sharaab Avocado', quantity: 1, unitPrice: 3.50, total: 3.50),
        ],
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      Sale(
        id: 2048,
        businessId: 3,
        customerName: 'Nimco Jaamac',
        orderType: 'Safaari',
        totalAmount: 8.00,
        paidAmount: 8.00,
        paymentStatus: 'paid',
        paymentMethod: 'e-Dahab',
        customAttributes: const {
          'title': 'Safaari',
          'typeLabel': 'Takeaway',
        },
        items: const [
          SaleItem(id: 3, saleId: 2048, productId: null, productName: 'Baasto', quantity: 1, unitPrice: 5.00, total: 5.00),
          SaleItem(id: 4, saleId: 2048, productId: null, productName: 'Sambusa', quantity: 2, unitPrice: 1.50, total: 3.00),
        ],
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Sale(
        id: 2047,
        businessId: 3,
        customerName: 'Cabdiweli Xuseen',
        orderType: 'Delivery',
        deliveryLocation: 'Wadada 26 June, Guriga #14',
        totalAmount: 25.50,
        paidAmount: 25.50,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        customAttributes: const {
          'title': 'Delivery',
          'typeLabel': 'Geyn',
          'delivery_location': 'Wadada 26 June, Guriga #14',
        },
        items: const [
          SaleItem(id: 5, saleId: 2047, productId: null, productName: 'Bariis Chicken', quantity: 3, unitPrice: 6.50, total: 19.50),
          SaleItem(id: 6, saleId: 2047, productId: null, productName: 'Sharaab', quantity: 3, unitPrice: 2.00, total: 6.00),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Sale(
        id: 2046,
        businessId: 3,
        customerName: 'Maxamed Cumar',
        orderType: 'Miis',
        totalAmount: 9.50,
        paidAmount: 9.50,
        paymentStatus: 'paid',
        paymentMethod: 'Kaash',
        customAttributes: const {
          'title': 'Miiska 1',
          'typeLabel': 'Dine-in',
          'table': '1',
        },
        items: const [
          SaleItem(id: 7, saleId: 2046, productId: null, productName: 'Suqaar', quantity: 1, unitPrice: 8.00, total: 8.00),
          SaleItem(id: 8, saleId: 2046, productId: null, productName: 'Shaah Somali', quantity: 1, unitPrice: 1.50, total: 1.50),
        ],
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
      Sale(
        id: 2045,
        businessId: 3,
        customerName: 'Xaawo Maxamuud',
        orderType: 'Safaari',
        totalAmount: 7.00,
        paidAmount: 7.00,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        customAttributes: const {
          'title': 'Safaari',
          'typeLabel': 'Takeaway',
        },
        items: const [
          SaleItem(id: 9, saleId: 2045, productId: null, productName: 'Sambusa', quantity: 4, unitPrice: 1.25, total: 5.00),
          SaleItem(id: 10, saleId: 2045, productId: null, productName: 'Sharaab', quantity: 2, unitPrice: 1.00, total: 2.00),
        ],
        createdAt: now.subtract(const Duration(days: 4, hours: 3)),
      ),
      Sale(
        id: 2044,
        businessId: 3,
        customerName: 'Saleebaan Yuusuf',
        orderType: 'Miis',
        totalAmount: 12.00,
        paidAmount: 12.00,
        paymentStatus: 'paid',
        paymentMethod: 'Zaad',
        customAttributes: const {
          'title': 'Miiska 5',
          'typeLabel': 'Dine-in',
          'table': '5',
        },
        items: const [
          SaleItem(id: 11, saleId: 2044, productId: null, productName: 'Canjeero iyo Beer', quantity: 2, unitPrice: 5.00, total: 10.00),
          SaleItem(id: 12, saleId: 2044, productId: null, productName: 'Shaah', quantity: 2, unitPrice: 1.00, total: 2.00),
        ],
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ]);
  }
}

