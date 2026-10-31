import 'package:flutter/material.dart';
import '../models/onboarding_models.dart';

// ============================================================================
// GASHI CONFIGURABLE MODULE RECOMMENDATION & DEPENDENCY ENGINE
// ============================================================================

class ModuleRecommendationEngine {
  // --------------------------------------------------------------------------
  // 1. BUSINESS CATEGORIES CATALOG
  // --------------------------------------------------------------------------
  static const List<BusinessCategory> categories = [
    BusinessCategory(
      id: 'retail_shops',
      name: 'Retail & Shops',
      description: 'Clothing, hardware, electronics, cosmetics, and general merchandise retail.',
      icon: Icons.storefront_rounded,
      color: Color(0xFF10B981), // Emerald Green
    ),
    BusinessCategory(
      id: 'pharmacy_healthcare',
      name: 'Pharmacy & Healthcare Retail',
      description: 'Pharmacies, medical supplies, dispensaries, and clinical health retail.',
      icon: Icons.local_pharmacy_rounded,
      color: Color(0xFFEF4444), // Medical Red
    ),
    BusinessCategory(
      id: 'restaurant_food',
      name: 'Restaurant & Food Business',
      description: 'Restaurants, cafes, bakeries, fast food, catering, and dine-in hospitality.',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF5200), // Gashi Warm Orange
    ),
    BusinessCategory(
      id: 'wholesale_distribution',
      name: 'Wholesale & Distribution',
      description: 'B2B wholesale trading, warehouse distribution, and large batch supply.',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF0284C7), // Blue
    ),
    BusinessCategory(
      id: 'supermarket_grocery',
      name: 'Supermarket & Grocery',
      description: 'Supermarkets, mini-markets, grocery stores, and fresh food provisions.',
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFF059669), // Forest Green
    ),
    BusinessCategory(
      id: 'service_business',
      name: 'Service Business',
      description: 'Consulting, equipment repairs, cleaning, technical IT, and agency services.',
      icon: Icons.build_circle_rounded,
      color: Color(0xFF4F46E5), // Indigo
    ),
    BusinessCategory(
      id: 'beauty_personal_care',
      name: 'Beauty & Personal Care',
      description: 'Hair salons, barbershops, beauty spas, cosmetic studios, and wellness.',
      icon: Icons.content_cut_rounded,
      color: Color(0xFFD946EF), // Fuchsia
    ),
    BusinessCategory(
      id: 'electronics_technology',
      name: 'Electronics & Technology',
      description: 'Mobile phone shops, computer retail, tech accessories, and solar devices.',
      icon: Icons.devices_other_rounded,
      color: Color(0xFF2563EB), // Royal Blue
    ),
    BusinessCategory(
      id: 'manufacturing_production',
      name: 'Manufacturing & Production',
      description: 'Food & beverage factories, garment workshops, assembly, and carpentry.',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFFEA580C), // Deep Orange
    ),
    BusinessCategory(
      id: 'other_business',
      name: 'Other Business',
      description: 'General commercial enterprise, import/export, brokerage, and custom setups.',
      icon: Icons.business_center_rounded,
      color: Color(0xFF6B7280), // Slate Gray
    ),
  ];

  // --------------------------------------------------------------------------
  // 2. SUBCATEGORIES CATALOG
  // --------------------------------------------------------------------------
  static const List<BusinessSubcategory> subcategories = [
    // Retail & Shops
    BusinessSubcategory(id: 'clothing_store', categoryId: 'retail_shops', name: 'Clothing Store', icon: Icons.checkroom_rounded),
    BusinessSubcategory(id: 'general_store', categoryId: 'retail_shops', name: 'General Store', icon: Icons.store_rounded),
    BusinessSubcategory(id: 'hardware_shop', categoryId: 'retail_shops', name: 'Hardware Shop', icon: Icons.home_repair_service_rounded),
    BusinessSubcategory(id: 'cosmetics_shop', categoryId: 'retail_shops', name: 'Cosmetics Shop', icon: Icons.brush_rounded),
    BusinessSubcategory(id: 'mobile_shop', categoryId: 'retail_shops', name: 'Mobile Phone Shop', icon: Icons.phone_android_rounded),
    BusinessSubcategory(id: 'furniture_store', categoryId: 'retail_shops', name: 'Furniture Store', icon: Icons.chair_rounded),
    BusinessSubcategory(id: 'electronics_retail', categoryId: 'retail_shops', name: 'Electronics Shop', icon: Icons.tv_rounded),

    // Pharmacy & Healthcare
    BusinessSubcategory(id: 'community_pharmacy', categoryId: 'pharmacy_healthcare', name: 'Community Pharmacy', icon: Icons.local_pharmacy_rounded),
    BusinessSubcategory(id: 'medical_supplies', categoryId: 'pharmacy_healthcare', name: 'Medical Supplies', icon: Icons.medical_services_rounded),
    BusinessSubcategory(id: 'health_products', categoryId: 'pharmacy_healthcare', name: 'Health Products Store', icon: Icons.health_and_safety_rounded),

    // Restaurant & Food
    BusinessSubcategory(id: 'restaurant', categoryId: 'restaurant_food', name: 'Restaurant (Dine-in)', icon: Icons.restaurant_rounded),
    BusinessSubcategory(id: 'cafe', categoryId: 'restaurant_food', name: 'Cafe & Coffee Shop', icon: Icons.local_cafe_rounded),
    BusinessSubcategory(id: 'fast_food', categoryId: 'restaurant_food', name: 'Fast Food', icon: Icons.fastfood_rounded),
    BusinessSubcategory(id: 'bakery', categoryId: 'restaurant_food', name: 'Bakery & Pastry', icon: Icons.bakery_dining_rounded),
    BusinessSubcategory(id: 'catering', categoryId: 'restaurant_food', name: 'Catering Service', icon: Icons.dinner_dining_rounded),
    BusinessSubcategory(id: 'food_delivery', categoryId: 'restaurant_food', name: 'Cloud Kitchen & Delivery', icon: Icons.delivery_dining_rounded),

    // Wholesale & Distribution
    BusinessSubcategory(id: 'fmcg_wholesale', categoryId: 'wholesale_distribution', name: 'FMCG & Food Wholesale', icon: Icons.inventory_2_rounded),
    BusinessSubcategory(id: 'building_materials', categoryId: 'wholesale_distribution', name: 'Building Materials Wholesale', icon: Icons.construction_rounded),
    BusinessSubcategory(id: 'general_distribution', categoryId: 'wholesale_distribution', name: 'General Goods Distribution', icon: Icons.local_shipping_rounded),
    BusinessSubcategory(id: 'import_export', categoryId: 'wholesale_distribution', name: 'Import & Export Hub', icon: Icons.flight_takeoff_rounded),

    // Supermarket & Grocery
    BusinessSubcategory(id: 'supermarket', categoryId: 'supermarket_grocery', name: 'Supermarket', icon: Icons.store_rounded),
    BusinessSubcategory(id: 'mini_market', categoryId: 'supermarket_grocery', name: 'Mini Market', icon: Icons.shopping_bag_rounded),
    BusinessSubcategory(id: 'grocery_store', categoryId: 'supermarket_grocery', name: 'Grocery Store', icon: Icons.shopping_basket_rounded),
    BusinessSubcategory(id: 'fresh_produce', categoryId: 'supermarket_grocery', name: 'Fresh Fruits & Vegetables', icon: Icons.eco_rounded),

    // Service Business
    BusinessSubcategory(id: 'consulting', categoryId: 'service_business', name: 'Consulting & Advisory', icon: Icons.psychology_rounded),
    BusinessSubcategory(id: 'repair_maintenance', categoryId: 'service_business', name: 'Repair & Maintenance', icon: Icons.build_rounded),
    BusinessSubcategory(id: 'cleaning_service', categoryId: 'service_business', name: 'Cleaning Services', icon: Icons.cleaning_services_rounded),
    BusinessSubcategory(id: 'education_training', categoryId: 'service_business', name: 'Education & Training', icon: Icons.school_rounded),
    BusinessSubcategory(id: 'it_services', categoryId: 'service_business', name: 'IT & Software Services', icon: Icons.terminal_rounded),
    BusinessSubcategory(id: 'professional_services', categoryId: 'service_business', name: 'Professional Services', icon: Icons.work_rounded),

    // Beauty & Personal Care
    BusinessSubcategory(id: 'salon_hairdresser', categoryId: 'beauty_personal_care', name: 'Hair & Beauty Salon', icon: Icons.face_retouching_natural_rounded),
    BusinessSubcategory(id: 'barbershop', categoryId: 'beauty_personal_care', name: 'Barbershop', icon: Icons.content_cut_rounded),
    BusinessSubcategory(id: 'spa_wellness', categoryId: 'beauty_personal_care', name: 'Spa & Wellness Center', icon: Icons.spa_rounded),
    BusinessSubcategory(id: 'skincare_clinic', categoryId: 'beauty_personal_care', name: 'Skincare & Cosmetics Studio', icon: Icons.auto_awesome_rounded),

    // Electronics & Technology
    BusinessSubcategory(id: 'phone_computer_sales', categoryId: 'electronics_technology', name: 'Smartphones & Computer Sales', icon: Icons.devices_rounded),
    BusinessSubcategory(id: 'tech_repairs', categoryId: 'electronics_technology', name: 'Gadget & Hardware Repairs', icon: Icons.electrical_services_rounded),
    BusinessSubcategory(id: 'solar_electrical', categoryId: 'electronics_technology', name: 'Solar Energy & Electrical', icon: Icons.solar_power_rounded),

    // Manufacturing & Production
    BusinessSubcategory(id: 'food_production', categoryId: 'manufacturing_production', name: 'Food & Beverage Processing', icon: Icons.soup_kitchen_rounded),
    BusinessSubcategory(id: 'garment_textile', categoryId: 'manufacturing_production', name: 'Garments & Tailoring Workshop', icon: Icons.straighten_rounded),
    BusinessSubcategory(id: 'metal_woodworking', categoryId: 'manufacturing_production', name: 'Carpentry & Metal Fabrication', icon: Icons.handyman_rounded),
    BusinessSubcategory(id: 'packaging_assembly', categoryId: 'manufacturing_production', name: 'Assembly & Packaging', icon: Icons.all_inbox_rounded),

    // Other Business
    BusinessSubcategory(id: 'general_enterprise', categoryId: 'other_business', name: 'General Enterprise', icon: Icons.domain_rounded),
    BusinessSubcategory(id: 'agency_brokerage', categoryId: 'other_business', name: 'Agency & Brokerage', icon: Icons.handshake_rounded),
    BusinessSubcategory(id: 'custom_business', categoryId: 'other_business', name: 'Custom Commercial Venture', icon: Icons.lightbulb_rounded),
  ];

  // --------------------------------------------------------------------------
  // 3. BUSINESS OPERATIONS CATALOG
  // --------------------------------------------------------------------------
  static const List<BusinessOperation> operations = [
    BusinessOperation(
      id: 'sell_physical_products',
      title: 'Sell physical products',
      description: 'Retail or wholesale merchandise requiring checkouts, SKUs, or barcodes.',
      icon: Icons.inventory_rounded,
    ),
    BusinessOperation(
      id: 'provide_services',
      title: 'Provide services',
      description: 'Labor, appointments, repairs, technical services, or billable hours.',
      icon: Icons.design_services_rounded,
    ),
    BusinessOperation(
      id: 'purchase_suppliers',
      title: 'Purchase from suppliers',
      description: 'Acquiring products from external vendors with supplier tracking.',
      icon: Icons.shopping_bag_outlined,
    ),
    BusinessOperation(
      id: 'manage_stock',
      title: 'Manage stock',
      description: 'Real-time stock counts, reorder warnings, and movement tracking.',
      icon: Icons.warehouse_rounded,
    ),
    BusinessOperation(
      id: 'sell_on_credit',
      title: 'Sell on credit',
      description: 'Issuing goods or services on credit with deferred repayment terms.',
      icon: Icons.request_quote_rounded,
    ),
    BusinessOperation(
      id: 'manage_customer_debts',
      title: 'Manage customer debts',
      description: 'Tracking customer balances, credit limits, and collection records.',
      icon: Icons.account_balance_wallet_outlined,
    ),
    BusinessOperation(
      id: 'manage_supplier_debts',
      title: 'Manage supplier debts',
      description: 'Managing payables, supplier credit balances, and due dates.',
      icon: Icons.receipt_long_rounded,
    ),
    BusinessOperation(
      id: 'manage_appointments',
      title: 'Manage appointments',
      description: 'Booking slots, technician schedules, and customer visits.',
      icon: Icons.event_available_rounded,
    ),
    BusinessOperation(
      id: 'manage_employees',
      title: 'Manage employees',
      description: 'Staff payroll, attendance, commissions, and access rights.',
      icon: Icons.badge_rounded,
    ),
    BusinessOperation(
      id: 'operate_multiple_branches',
      title: 'Operate multiple branches',
      description: 'Running two or more physical locations or retail stores.',
      icon: Icons.hub_rounded,
    ),
    BusinessOperation(
      id: 'manage_warehouses',
      title: 'Manage warehouses',
      description: 'Multi-location storage, inter-warehouse transfers, and bulk space.',
      icon: Icons.store_mall_directory_rounded,
    ),
    BusinessOperation(
      id: 'manufacture_products',
      title: 'Manufacture products',
      description: 'Assembling raw materials into finished sellable products.',
      icon: Icons.precision_manufacturing_rounded,
    ),
    BusinessOperation(
      id: 'give_loans',
      title: 'Give loans',
      description: 'Lending funds with structured installments and repayment terms.',
      icon: Icons.payments_rounded,
    ),
    BusinessOperation(
      id: 'borrow_money',
      title: 'Borrow money',
      description: 'Tracking debts owed to external financiers or investors.',
      icon: Icons.credit_score_rounded,
    ),
    BusinessOperation(
      id: 'manage_restaurant_tables',
      title: 'Manage restaurant tables and orders',
      description: 'Dine-in tables, takeaway tickets, delivery dispatches, and kitchen flow.',
      icon: Icons.table_restaurant_rounded,
    ),
    BusinessOperation(
      id: 'track_medicine_batches',
      title: 'Track medicine batches and expiry dates',
      description: 'Dosages, batch numbers, prescription validation, and expiry alerts.',
      icon: Icons.medication_liquid_rounded,
    ),
  ];

  // --------------------------------------------------------------------------
  // 4. CORE GASHI MODULE CATALOG (12 Modules)
  // --------------------------------------------------------------------------
  static const List<GashiModule> moduleCatalog = [
    // 1. POS & Sales Management
    GashiModule(
      id: 'pos',
      code: 'pos',
      name: 'POS & Sales Management',
      description: 'High-speed cashier checkout, mobile payments (Zaad, e-Dahab, Kaash), receipt printing, and daily sales closing.',
      features: [
        'Rapid barcode scanning & touch catalog',
        'Zaad, e-Dahab, Kaashplus, and cash integration',
        'Thermal receipt printing & digital receipts',
        'Offline sales caching with automatic cloud sync',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'service_business',
        'beauty_personal_care',
        'electronics_technology',
        'manufacturing_production',
        'other_business',
      ],
      supportedOperations: [
        'sell_physical_products',
        'sell_on_credit',
        'manage_restaurant_tables',
        'provide_services',
      ],
      dependencies: [],
      relatedModules: ['inventory', 'crm', 'accounting'],
      optionalIntegrations: ['accounting', 'whatsapp_receipts', 'ai_sales_insights'],
      baseMonthlyPrice: 15.0,
      icon: Icons.point_of_sale_rounded,
      color: Color(0xFF10B981),
    ),

    // 2. Inventory Management
    GashiModule(
      id: 'inventory',
      code: 'inventory',
      name: 'Inventory Management',
      description: 'Track stock balances, low-stock notifications, stock receipts, audit adjustments, and dynamic item attributes.',
      features: [
        'Multi-unit conversion (boxes, units, kg)',
        'Low-stock alerts & minimum reorder levels',
        'Stock movement history & audit adjustments',
        'Custom product fields (IMEI, sizes, brands)',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'electronics_technology',
        'manufacturing_production',
        'beauty_personal_care',
        'other_business',
        'service_business', // if they sell parts/goods
      ],
      supportedOperations: [
        'manage_stock',
        'sell_physical_products',
        'purchase_suppliers',
        'manage_warehouses',
        'manufacture_products',
        'track_medicine_batches',
      ],
      dependencies: [],
      relatedModules: ['purchasing', 'pos', 'accounting'],
      optionalIntegrations: ['accounting', 'ai_product_scanner', 'ai_inventory_insights'],
      baseMonthlyPrice: 15.0,
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF0284C7),
    ),

    // 3. Purchasing & Supplier Management
    GashiModule(
      id: 'purchasing',
      code: 'purchasing',
      name: 'Purchasing & Supplier Management',
      description: 'Manage vendor procurement, purchase orders, supplier balances, incoming stock receiving, and payable schedules.',
      features: [
        'Supplier directory & credit balance tracking',
        'Purchase orders & goods-received notes',
        'Automated cost-price recalculation',
        'Supplier debt repayment history',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'electronics_technology',
        'manufacturing_production',
        'beauty_personal_care',
        'other_business',
        'service_business',
      ],
      supportedOperations: [
        'purchase_suppliers',
        'manage_supplier_debts',
        'manage_stock',
      ],
      // Mandatory: Purchasing strictly requires Inventory to track incoming products
      dependencies: ['inventory'],
      relatedModules: ['inventory', 'accounting', 'pos'],
      optionalIntegrations: ['accounting', 'remote_accountant'],
      baseMonthlyPrice: 12.0,
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF8B5CF6),
    ),

    // 4. Accounting & Finance
    GashiModule(
      id: 'accounting',
      code: 'accounting',
      name: 'Accounting & Finance',
      description: 'Comprehensive general ledger, automated profit & loss, cashflow statement, operational expenses, and balance sheets.',
      features: [
        'Automated real-time profit & loss statements',
        'Expense logging across categories',
        'Multi-currency cash accounts (USD & SLSh)',
        'Chart of accounts & financial health ratios',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'service_business',
        'beauty_personal_care',
        'electronics_technology',
        'manufacturing_production',
        'other_business',
      ],
      supportedOperations: [
        'sell_on_credit',
        'manage_customer_debts',
        'manage_supplier_debts',
        'give_loans',
        'borrow_money',
        'purchase_suppliers',
      ],
      dependencies: [],
      relatedModules: ['pos', 'purchasing', 'hr_payroll'],
      optionalIntegrations: ['remote_accountant', 'zakat_calculator', 'ai_financial_insights'],
      baseMonthlyPrice: 20.0,
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0D9488),
    ),

    // 5. CRM & Customer Management
    GashiModule(
      id: 'crm',
      code: 'crm',
      name: 'CRM & Customer Management',
      description: 'Customer profiles, contact history, customer debts (Deyn), deposit balances, loyalty rewards, and statement exports.',
      features: [
        'Customer credit limits & unpaid debt tracking',
        'Prepaid deposit balance management',
        'Statement generator with 1-tap WhatsApp sharing',
        'VIP customer purchase frequency analytics',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'service_business',
        'beauty_personal_care',
        'electronics_technology',
        'manufacturing_production',
        'other_business',
      ],
      supportedOperations: [
        'sell_on_credit',
        'manage_customer_debts',
        'provide_services',
        'manage_appointments',
      ],
      dependencies: [],
      relatedModules: ['pos', 'accounting'],
      optionalIntegrations: ['whatsapp_integration', 'advanced_reports'],
      baseMonthlyPrice: 10.0,
      icon: Icons.people_alt_rounded,
      color: Color(0xFF3B82F6),
    ),

    // 6. Loan Management
    GashiModule(
      id: 'loan',
      code: 'loan',
      name: 'Loan Management',
      description: 'Manage formal credit lines, lending schedules, debt repayment installments, interest/service fee tracking, and overdue alerts.',
      features: [
        'Loan agreement generation & disbursement records',
        'Structured installment repayment calculator',
        'Overdue debt alerts & default prevention',
        'Guarantor details and collateral documentation',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'wholesale_distribution',
        'service_business',
        'other_business',
      ],
      supportedOperations: [
        'give_loans',
        'borrow_money',
        'manage_customer_debts',
      ],
      dependencies: [],
      relatedModules: ['accounting', 'crm'],
      optionalIntegrations: ['accounting', 'advanced_reports'],
      baseMonthlyPrice: 15.0,
      icon: Icons.payments_rounded,
      color: Color(0xFFF59E0B),
    ),

    // 7. HR & Payroll
    GashiModule(
      id: 'hr_payroll',
      code: 'hr_payroll',
      name: 'HR & Payroll',
      description: 'Staff directory, role-based access control (Cashier, Manager, Accountant), monthly salary calculation, deductions, and commissions.',
      features: [
        'Staff profiles & role permissions management',
        'Automated monthly salary disbursement slips',
        'Sales staff commission tracking from POS',
        'Staff advance repayments & deduction records',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'service_business',
        'beauty_personal_care',
        'electronics_technology',
        'manufacturing_production',
        'other_business',
      ],
      supportedOperations: [
        'manage_employees',
      ],
      dependencies: [],
      relatedModules: ['accounting'],
      optionalIntegrations: ['accounting'],
      baseMonthlyPrice: 15.0,
      icon: Icons.badge_rounded,
      color: Color(0xFF6366F1),
    ),

    // 8. Branch & Warehouse Management
    GashiModule(
      id: 'branch_warehouse',
      code: 'branch_warehouse',
      name: 'Branch & Warehouse Management',
      description: 'Multi-location inventory tracking, inter-branch stock transfers, warehouse logistics, and aggregated enterprise reports.',
      features: [
        'Centralized multi-store administration',
        'Branch-to-branch stock transfer manifests',
        'Location-specific stock availability lookups',
        'Consolidated vs. individual branch P&L',
      ],
      supportedCategories: [
        'retail_shops',
        'pharmacy_healthcare',
        'restaurant_food',
        'wholesale_distribution',
        'supermarket_grocery',
        'electronics_technology',
        'manufacturing_production',
        'beauty_personal_care',
        'other_business',
      ],
      supportedOperations: [
        'operate_multiple_branches',
        'manage_warehouses',
      ],
      // If user manages multi-branches or warehouses with stock, inventory is a requirement
      dependencies: [],
      relatedModules: ['inventory', 'pos', 'accounting'],
      optionalIntegrations: ['inventory', 'accounting'],
      baseMonthlyPrice: 20.0,
      icon: Icons.hub_rounded,
      color: Color(0xFF475569),
    ),

    // 9. Service Management
    GashiModule(
      id: 'service_management',
      code: 'service_management',
      name: 'Service Management',
      description: 'Work order tickets, technician assignments, repair status tracking, appointment calendars, and service labor billing.',
      features: [
        'Job ticket workflow (Pending -> In Progress -> Completed)',
        'Technician assignment and labor tracking',
        'Spare parts consumption from inventory',
        'Customer repair progress SMS/WhatsApp updates',
      ],
      supportedCategories: [
        'service_business',
        'beauty_personal_care',
        'electronics_technology',
        'other_business',
      ],
      supportedOperations: [
        'provide_services',
        'manage_appointments',
      ],
      dependencies: [],
      relatedModules: ['crm', 'pos', 'accounting'],
      optionalIntegrations: ['pos', 'inventory', 'whatsapp_integration'],
      baseMonthlyPrice: 18.0,
      icon: Icons.miscellaneous_services_rounded,
      color: Color(0xFF4F46E5),
    ),

    // 10. Restaurant Management
    GashiModule(
      id: 'restaurant_management',
      code: 'restaurant_management',
      name: 'Restaurant Management',
      description: 'Table dining layout, kitchen order display (KOT), takeaway ticketing, delivery dispatch, menu combos, and dish recipes.',
      features: [
        'Visual floor plan with active table status',
        'Order dispatching (Dine-in, Takeaway, Delivery)',
        'Menu categories & dish modifiers (spicy, drink combo)',
        'Kitchen display screen / ticket print dispatch',
      ],
      supportedCategories: [
        'restaurant_food',
      ],
      supportedOperations: [
        'manage_restaurant_tables',
      ],
      // Mandatory: Restaurant requires POS and Inventory
      dependencies: ['pos', 'inventory'],
      relatedModules: ['purchasing', 'accounting', 'hr_payroll'],
      optionalIntegrations: ['purchasing', 'accounting'],
      baseMonthlyPrice: 25.0,
      icon: Icons.restaurant_menu_rounded,
      color: Color(0xFFFF5200),
    ),

    // 11. Pharmacy Management
    GashiModule(
      id: 'pharmacy_management',
      code: 'pharmacy_management',
      name: 'Pharmacy Management',
      description: 'Batch tracking, drug expiry alerts, prescription records, generic drug cross-referencing, dosage logs, and regulatory compliance.',
      features: [
        'Batch number & strict expiry date tracking',
        'Prescription validation & doctor file archive',
        'Generic drug alternatives cross-matching',
        'Controlled substance audit trails',
      ],
      supportedCategories: [
        'pharmacy_healthcare',
      ],
      supportedOperations: [
        'track_medicine_batches',
      ],
      // Mandatory: Pharmacy strictly requires POS and Inventory
      dependencies: ['pos', 'inventory'],
      relatedModules: ['purchasing', 'accounting', 'crm'],
      optionalIntegrations: ['purchasing', 'accounting'],
      baseMonthlyPrice: 25.0,
      icon: Icons.medical_information_rounded,
      color: Color(0xFFEF4444),
    ),

    // 12. Manufacturing Management
    GashiModule(
      id: 'manufacturing_management',
      code: 'manufacturing_management',
      name: 'Manufacturing Management',
      description: 'Bill of materials (BOM), production work orders, raw material consumption, batch cost calculation, and finished goods assembly.',
      features: [
        'Bill of materials (BOM) recipe creator',
        'Automated raw material stock deduction on assembly',
        'Per-batch unit cost calculation & labor overhead',
        'Production staging & finished product QC',
      ],
      supportedCategories: [
        'manufacturing_production',
        'other_business',
      ],
      supportedOperations: [
        'manufacture_products',
      ],
      // Mandatory: Manufacturing strictly requires Inventory for materials & finished goods
      dependencies: ['inventory'],
      relatedModules: ['purchasing', 'accounting', 'branch_warehouse'],
      optionalIntegrations: ['purchasing', 'accounting', 'pos'],
      baseMonthlyPrice: 30.0,
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFFEA580C),
    ),
  ];

  // --------------------------------------------------------------------------
  // 5. MODULAR ADD-ONS CATALOG
  // --------------------------------------------------------------------------
  static const List<ModuleAddOn> addOnCatalog = [
    // Inventory-related
    ModuleAddOn(
      id: 'ai_product_scanner',
      name: 'AI Product Scanner',
      description: 'Instantly populate title, category, and pricing by pointing your camera at packaging.',
      category: 'inventory',
      requiredModuleId: 'inventory',
      monthlyPrice: 5.0,
      icon: Icons.camera_alt_rounded,
      badge: 'AI Smart',
    ),
    ModuleAddOn(
      id: 'ai_inventory_insights',
      name: 'AI Inventory Insights',
      description: 'Predict out-of-stock dates, seasonal demand surges, and dead capital items.',
      category: 'inventory',
      requiredModuleId: 'inventory',
      monthlyPrice: 8.0,
      icon: Icons.insights_rounded,
      badge: 'AI Analytics',
    ),

    // POS-related
    ModuleAddOn(
      id: 'ai_sales_insights',
      name: 'AI Sales Insights',
      description: 'Automated daily cashier performance audits, top basket combinations, and peak hours.',
      category: 'pos',
      requiredModuleId: 'pos',
      monthlyPrice: 6.0,
      icon: Icons.trending_up_rounded,
      badge: 'AI Sales',
    ),
    ModuleAddOn(
      id: 'whatsapp_receipts',
      name: 'WhatsApp Receipts',
      description: 'Deliver official branded digital receipts directly to customer WhatsApp automatically upon payment.',
      category: 'pos',
      requiredModuleId: 'pos',
      monthlyPrice: 4.0,
      icon: Icons.chat_bubble_rounded,
      badge: 'WhatsApp',
    ),

    // Accounting-related
    ModuleAddOn(
      id: 'ai_financial_insights',
      name: 'AI Financial Insights',
      description: 'Smart anomalies detection, cashflow runout projections, and margin leak warnings.',
      category: 'accounting',
      requiredModuleId: 'accounting',
      monthlyPrice: 9.0,
      icon: Icons.auto_graph_rounded,
      badge: 'AI Finance',
    ),
    ModuleAddOn(
      id: 'remote_accountant',
      name: 'Remote Human Accountant',
      description: 'Certified CPA reviews your books monthly, prepares tax reports, and audits ledger reconciliations.',
      category: 'accounting',
      requiredModuleId: 'accounting',
      monthlyPrice: 40.0,
      icon: Icons.support_agent_rounded,
      badge: 'Pro Service',
    ),
    ModuleAddOn(
      id: 'zakat_calculator',
      name: 'Islamic Zakat Calculator',
      description: 'Automatically calculates net Nisab thresholds on inventory, receivables, cash, and deducts liabilities.',
      category: 'accounting',
      requiredModuleId: 'accounting',
      monthlyPrice: 5.0,
      icon: Icons.mosque_rounded,
      badge: 'Sharia Compliant',
    ),

    // General Add-ons
    ModuleAddOn(
      id: 'ai_business_assistant',
      name: 'AI Business Assistant',
      description: 'Natural language chat assistant: ask "Which items made the most profit today?" or "Who owes the most debt?".',
      category: 'general',
      monthlyPrice: 10.0,
      icon: Icons.smart_toy_rounded,
      badge: 'AI Assistant',
    ),
    ModuleAddOn(
      id: 'ai_business_autopilot',
      name: 'AI Business Autopilot',
      description: 'Automates customer debt reminder texts, auto-reorders low stock from suppliers, and flags fraudulent refunds.',
      category: 'general',
      monthlyPrice: 15.0,
      icon: Icons.bolt_rounded,
      badge: 'Autopilot',
    ),
    ModuleAddOn(
      id: 'advanced_analytics',
      name: 'Advanced Analytics & BI',
      description: 'Executive dashboards, heatmaps, gross margin breakdown per department, and growth projections.',
      category: 'general',
      monthlyPrice: 12.0,
      icon: Icons.bar_chart_rounded,
      badge: 'Analytics',
    ),
    ModuleAddOn(
      id: 'whatsapp_integration',
      name: 'WhatsApp Business API Integration',
      description: 'Send automated payment reminders, promotion broadcasts, and appointment booking confirmations.',
      category: 'general',
      monthlyPrice: 8.0,
      icon: Icons.send_rounded,
      badge: 'Integration',
    ),
    ModuleAddOn(
      id: 'advanced_reports',
      name: 'Advanced Custom Reports & Export',
      description: 'Export customized CSV/Excel/PDF reports with company letterhead, barcodes, and custom columns.',
      category: 'general',
      monthlyPrice: 6.0,
      icon: Icons.picture_as_pdf_rounded,
      badge: 'Reporting',
    ),
    ModuleAddOn(
      id: 'api_integration',
      name: 'Gashi Webhook & Developer API',
      description: 'Sync sales and stock with your e-commerce website (WooCommerce, Shopify, custom web portals).',
      category: 'general',
      monthlyPrice: 20.0,
      icon: Icons.api_rounded,
      badge: 'Developers',
    ),
  ];

  // --------------------------------------------------------------------------
  // 6. CORE LOGIC: MODULE ELIGIBILITY & VISIBILITY
  // --------------------------------------------------------------------------

  /// Determines whether a module is eligible to be shown in the UI at all.
  /// If false, this module MUST REMAIN HIDDEN from the customer's interface.
  static bool isModuleEligible({
    required GashiModule module,
    required String categoryId,
    required String subcategoryId,
    required List<String> selectedOperations,
    required Set<String> currentlySelectedModules,
  }) {
    // 1. Industry-specific module isolation
    if (module.id == 'restaurant_management') {
      return categoryId == 'restaurant_food' ||
          selectedOperations.contains('manage_restaurant_tables');
    }
    if (module.id == 'pharmacy_management') {
      return categoryId == 'pharmacy_healthcare' ||
          selectedOperations.contains('track_medicine_batches');
    }
    if (module.id == 'manufacturing_management') {
      return categoryId == 'manufacturing_production' ||
          selectedOperations.contains('manufacture_products');
    }
    if (module.id == 'service_management') {
      return categoryId == 'service_business' ||
          categoryId == 'beauty_personal_care' ||
          selectedOperations.contains('provide_services') ||
          selectedOperations.contains('manage_appointments');
    }

    // 2. Loan Management: only eligible if lending operations are relevant or in eligible categories
    if (module.id == 'loan') {
      final hasLendingOps = selectedOperations.contains('give_loans') ||
          selectedOperations.contains('borrow_money') ||
          selectedOperations.contains('manage_customer_debts');
      if (hasLendingOps) return true;
      // In restaurant or beauty, do not show loans unless explicit lending operation
      if (categoryId == 'restaurant_food' || categoryId == 'beauty_personal_care') {
        return false;
      }
      return module.supportedCategories.contains(categoryId);
    }

    // 3. Service Business special rules:
    // "Hide Inventory and Purchasing when the business does not sell or purchase physical goods."
    if (categoryId == 'service_business' && (module.id == 'inventory' || module.id == 'purchasing')) {
      final dealsWithGoods = selectedOperations.contains('sell_physical_products') ||
          selectedOperations.contains('manage_stock') ||
          selectedOperations.contains('purchase_suppliers') ||
          selectedOperations.contains('manage_warehouses');
      if (!dealsWithGoods) {
        return false;
      }
    }

    // 4. POS module for service business:
    // "POS & Sales if the business also sells products or needs checkout."
    if (categoryId == 'service_business' && module.id == 'pos') {
      final needsPos = selectedOperations.contains('sell_physical_products') ||
          selectedOperations.contains('sell_on_credit') ||
          selectedOperations.contains('provide_services');
      if (!needsPos) return false;
    }

    // 5. General check against supportedCategories and supportedOperations
    final matchesCategory = module.supportedCategories.contains(categoryId);
    final matchesOperation = module.supportedOperations.any((op) => selectedOperations.contains(op));

    // If an already selected module requires or recommends this module, make it visible!
    final isDependencyOfSelected = currentlySelectedModules.any((selectedId) {
      final parent = moduleCatalog.firstWhere((m) => m.id == selectedId, orElse: () => module);
      return parent.dependencies.contains(module.id) || parent.relatedModules.contains(module.id);
    });

    return matchesCategory || matchesOperation || isDependencyOfSelected;
  }

  /// Calculates the visibility state (selected, recommended, hidden) for every module
  static Map<String, ModuleVisibilityState> computeModuleVisibility({
    required String categoryId,
    required String subcategoryId,
    required List<String> selectedOperations,
    required Set<String> selectedModuleIds,
  }) {
    final Map<String, ModuleVisibilityState> result = {};

    for (final module in moduleCatalog) {
      if (selectedModuleIds.contains(module.id)) {
        result[module.id] = ModuleVisibilityState.selected;
        continue;
      }

      final eligible = isModuleEligible(
        module: module,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        selectedOperations: selectedOperations,
        currentlySelectedModules: selectedModuleIds,
      );

      if (!eligible) {
        result[module.id] = ModuleVisibilityState.hidden;
      } else {
        result[module.id] = ModuleVisibilityState.recommended;
      }
    }

    return result;
  }

  // --------------------------------------------------------------------------
  // 7. CORE LOGIC: MANDATORY DEPENDENCY RESOLUTION
  // --------------------------------------------------------------------------

  /// Resolves all mandatory dependencies for the currently selected modules.
  /// If Module A requires Module B, Module B is automatically included and marked as Required.
  static DependencyResolutionResult resolveDependencies(Set<String> chosenIds) {
    final Set<String> effective = Set<String>.from(chosenIds);
    final Map<String, String> autoIncluded = {};
    final Map<String, String> explanations = {};

    bool addedAny = true;
    while (addedAny) {
      addedAny = false;
      for (final id in List<String>.from(effective)) {
        final module = moduleCatalog.firstWhere(
          (m) => m.id == id,
          orElse: () => moduleCatalog.first,
        );

        for (final depId in module.dependencies) {
          if (!effective.contains(depId)) {
            effective.add(depId);
            autoIncluded[depId] = id;
            explanations[depId] = _getDependencyExplanation(depId, id);
            addedAny = true;
          }
        }
      }
    }

    return DependencyResolutionResult(
      effectiveSelectedIds: effective,
      autoIncludedDependencies: autoIncluded,
      explanations: explanations,
    );
  }

  /// Clear, human explanation for why a dependency was automatically included
  static String _getDependencyExplanation(String childId, String parentId) {
    if (childId == 'inventory' && parentId == 'purchasing') {
      return 'Purchasing requires Inventory Management to store, count, and track incoming stock from suppliers.';
    }
    if (childId == 'pos' && parentId == 'restaurant_management') {
      return 'Restaurant Management requires POS & Sales to manage table checks, order billing, and payment processing.';
    }
    if (childId == 'inventory' && parentId == 'restaurant_management') {
      return 'Restaurant Management requires Inventory Management to track kitchen ingredients and beverage supplies.';
    }
    if (childId == 'pos' && parentId == 'pharmacy_management') {
      return 'Pharmacy Management requires POS & Sales to process medicine sales, receipts, and cashier payments.';
    }
    if (childId == 'inventory' && parentId == 'pharmacy_management') {
      return 'Pharmacy Management requires Inventory Management to manage medicine batches, stock levels, and drug shelves.';
    }
    if (childId == 'inventory' && parentId == 'manufacturing_management') {
      return 'Manufacturing requires Inventory Management to record raw materials consumption and finished product output.';
    }
    return '${getModuleName(parentId)} requires ${getModuleName(childId)} as a mandatory dependency.';
  }

  /// Helper to get module name by ID
  static String getModuleName(String id) {
    final match = moduleCatalog.where((m) => m.id == id);
    return match.isNotEmpty ? match.first.name : id;
  }

  /// Helper to check if a module can be safely removed by the user.
  /// Returns null if removable, or an explanation string if blocked by an active dependent.
  static String? canDeselectModule(String moduleIdToRemove, Set<String> currentSelectedIds) {
    for (final id in currentSelectedIds) {
      if (id == moduleIdToRemove) continue;
      final parent = moduleCatalog.firstWhere((m) => m.id == id, orElse: () => moduleCatalog.first);
      if (parent.dependencies.contains(moduleIdToRemove)) {
        return 'Cannot remove "${getModuleName(moduleIdToRemove)}" because "${parent.name}" requires it to function properly.';
      }
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // 8. ADD-ON ELIGIBILITY LOGIC
  // --------------------------------------------------------------------------

  /// Evaluates an add-on's readiness given the currently selected modules.
  /// Returns a tuple-like Map with status and prerequisite reason.
  static bool isAddOnAvailable(ModuleAddOn addOn, Set<String> selectedModuleIds) {
    if (addOn.requiredModuleId == null) return true;
    return selectedModuleIds.contains(addOn.requiredModuleId);
  }

  /// Explanation of what module must be activated first for an add-on
  static String getAddOnRequirementMessage(ModuleAddOn addOn) {
    if (addOn.requiredModuleId == null) return 'Ready to activate';
    final reqName = getModuleName(addOn.requiredModuleId!);
    return 'Requires "$reqName" module to be activated first';
  }

  // --------------------------------------------------------------------------
  // 9. DEFAULT MODULE RECOMMENDATIONS BY BUSINESS PROFILE
  // --------------------------------------------------------------------------

  /// Computes default recommended modules when user first enters Step 4
  static Set<String> computeInitialRecommendedSelection({
    required String categoryId,
    required List<String> selectedOperations,
  }) {
    final Set<String> initial = {'pos'};

    switch (categoryId) {
      case 'retail_shops':
      case 'supermarket_grocery':
      case 'electronics_technology':
        initial.addAll(['pos', 'inventory', 'purchasing', 'accounting', 'crm']);
        break;
      case 'pharmacy_healthcare':
        initial.addAll(['pharmacy_management', 'pos', 'inventory', 'purchasing', 'accounting', 'crm']);
        break;
      case 'restaurant_food':
        initial.addAll(['restaurant_management', 'pos', 'inventory', 'purchasing', 'accounting']);
        break;
      case 'wholesale_distribution':
        initial.addAll(['pos', 'inventory', 'purchasing', 'accounting', 'crm', 'branch_warehouse']);
        break;
      case 'service_business':
      case 'beauty_personal_care':
        initial.addAll(['service_management', 'crm', 'accounting']);
        if (selectedOperations.contains('sell_physical_products') || selectedOperations.contains('manage_stock')) {
          initial.addAll(['pos', 'inventory']);
        }
        break;
      case 'manufacturing_production':
        initial.addAll(['manufacturing_management', 'inventory', 'purchasing', 'accounting']);
        if (selectedOperations.contains('sell_physical_products')) {
          initial.add('pos');
        }
        break;
      default:
        initial.addAll(['pos', 'accounting', 'crm']);
        break;
    }

    if (selectedOperations.contains('manage_employees')) {
      initial.add('hr_payroll');
    }
    if (selectedOperations.contains('operate_multiple_branches') || selectedOperations.contains('manage_warehouses')) {
      initial.add('branch_warehouse');
    }
    if (selectedOperations.contains('give_loans') || selectedOperations.contains('borrow_money')) {
      initial.add('loan');
    }

    // Resolve any mandatory dependencies automatically
    return resolveDependencies(initial).effectiveSelectedIds;
  }
}

