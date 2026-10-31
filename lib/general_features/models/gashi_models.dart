import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============================================================================
// GASHI PLATFORM PRODUCTION POSTGRESQL MODELS
// ============================================================================

enum BusinessType {
  retail,
  pharmacy,
  restaurant,
  service,
  barbershop;

  static BusinessType fromString(String val) {
    return BusinessType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => BusinessType.retail,
    );
  }

  Color get primaryColor {
    switch (this) {
      case BusinessType.pharmacy:
        return const Color(0xFFEF4444); // Medical Red
      case BusinessType.restaurant:
        return const Color(0xFFFF5200); // Warm Orange
      case BusinessType.retail:
        return const Color(0xFF10B981); // Emerald Green
      case BusinessType.service:
      case BusinessType.barbershop:
        return const Color(0xFF4F46E5); // Indigo
    }
  }

  Color get softBgColor {
    switch (this) {
      case BusinessType.pharmacy:
        return const Color(0xFFFFF5F5);
      case BusinessType.restaurant:
        return const Color(0xFFFFF7F2);
      case BusinessType.retail:
        return const Color(0xFFE6F7F0);
      case BusinessType.service:
      case BusinessType.barbershop:
        return const Color(0xFFEEF2FF);
    }
  }

  IconData get icon {
    switch (this) {
      case BusinessType.pharmacy:
        return Icons.local_pharmacy;
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.retail:
        return Icons.storefront;
      case BusinessType.service:
        return Icons.build_circle_outlined;
      case BusinessType.barbershop:
        return Icons.content_cut;
    }
  }
}

// 1. BUSINESS & USERS
class Business {
  final int id;
  final String name;
  final BusinessType businessType;
  final String currency; // 'USD' or 'SLSh'
  final String language; // 'so' or 'en'
  final double taxRate; // e.g. 0.0 or 5.0
  final DateTime createdAt;
  final Map<String, bool> enabledFeatures; // Feature toggles (modules)

  // Dynamic Onboarding & Module Selection Attributes
  final String categoryId;
  final String categoryName;
  final String subcategoryId;
  final String subcategoryName;
  final List<String> operations;
  final List<String> activeModules;
  final List<String> activeAddOns;
  final String country;
  final String city;
  final String timeZone;
  final String phone;
  final String email;
  final String fiscalYearStart;
  final int employeeCount;
  final int branchCount;
  final String logoUrl;

  const Business({
    required this.id,
    required this.name,
    required this.businessType,
    this.currency = 'USD',
    this.language = 'so',
    this.taxRate = 0.0,
    required this.createdAt,
    this.enabledFeatures = const {},
    this.categoryId = 'retail_shops',
    this.categoryName = 'Retail & Shops',
    this.subcategoryId = 'general_store',
    this.subcategoryName = 'General Store',
    this.operations = const [],
    this.activeModules = const ['pos', 'inventory', 'sales', 'credits'],
    this.activeAddOns = const [],
    this.country = 'Somalia / Somaliland',
    this.city = 'Hargeisa',
    this.timeZone = 'UTC+3 (EAT)',
    this.phone = '',
    this.email = '',
    this.fiscalYearStart = 'January',
    this.employeeCount = 1,
    this.branchCount = 1,
    this.logoUrl = '',
  });

  bool isFeatureEnabled(String featureKey) {
    return enabledFeatures[featureKey] ?? true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'business_type': businessType.name,
        'currency': currency,
        'language': language,
        'tax_rate': taxRate,
        'created_at': createdAt.toIso8601String(),
        'enabled_features': enabledFeatures,
        'category_id': categoryId,
        'category_name': categoryName,
        'subcategory_id': subcategoryId,
        'subcategory_name': subcategoryName,
        'operations': operations,
        'active_modules': activeModules,
        'active_add_ons': activeAddOns,
        'country': country,
        'city': city,
        'time_zone': timeZone,
        'phone': phone,
        'email': email,
        'fiscal_year_start': fiscalYearStart,
        'employee_count': employeeCount,
        'branch_count': branchCount,
        'logo_url': logoUrl,
      };

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as int,
      name: json['name'] as String,
      businessType: BusinessType.fromString(json['business_type'] as String),
      currency: json['currency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'so',
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      enabledFeatures: json['enabled_features'] != null
          ? Map<String, bool>.from(json['enabled_features'] as Map)
          : const {},
      categoryId: json['category_id'] as String? ?? 'retail_shops',
      categoryName: json['category_name'] as String? ?? 'Retail & Shops',
      subcategoryId: json['subcategory_id'] as String? ?? 'general_store',
      subcategoryName: json['subcategory_name'] as String? ?? 'General Store',
      operations: (json['operations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      activeModules: (json['active_modules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['pos', 'inventory', 'sales', 'credits'],
      activeAddOns: (json['active_add_ons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      country: json['country'] as String? ?? 'Somalia / Somaliland',
      city: json['city'] as String? ?? 'Hargeisa',
      timeZone: json['time_zone'] as String? ?? 'UTC+3 (EAT)',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fiscalYearStart: json['fiscal_year_start'] as String? ?? 'January',
      employeeCount: json['employee_count'] as int? ?? 1,
      branchCount: json['branch_count'] as int? ?? 1,
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }

  Business copyWith({
    int? id,
    String? name,
    BusinessType? businessType,
    String? currency,
    String? language,
    double? taxRate,
    DateTime? createdAt,
    Map<String, bool>? enabledFeatures,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    List<String>? operations,
    List<String>? activeModules,
    List<String>? activeAddOns,
    String? country,
    String? city,
    String? timeZone,
    String? phone,
    String? email,
    String? fiscalYearStart,
    int? employeeCount,
    int? branchCount,
    String? logoUrl,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      taxRate: taxRate ?? this.taxRate,
      createdAt: createdAt ?? this.createdAt,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      operations: operations ?? this.operations,
      activeModules: activeModules ?? this.activeModules,
      activeAddOns: activeAddOns ?? this.activeAddOns,
      country: country ?? this.country,
      city: city ?? this.city,
      timeZone: timeZone ?? this.timeZone,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      employeeCount: employeeCount ?? this.employeeCount,
      branchCount: branchCount ?? this.branchCount,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

class GashiPaymentMethods {
  static const String zaad = 'Zaad';
  static const String edahab = 'e-Dahab';
  static const String kaashplus = 'Kaashplus';
  static const String cash = 'Kaash';
  static const String debt = 'Deyn';

  static const List<String> normalPayments = [zaad, edahab, kaashplus, cash];
  static const List<String> all = [zaad, edahab, kaashplus, cash, debt];
}

// 2. DYNAMIC FIELD DEFINITION (Customization Engine)
class BusinessFieldDefinition {
  final int id;
  final String businessType; // pharmacy, restaurant, retail, service
  final String targetEntity; // inventory, pos, customer_profile
  final String fieldKey; // e.g. expiryDate, tableNumber, imeiNumber
  final String fieldLabel;
  final String fieldType; // text, number, image, list, boolean, date
  final bool isRequired;

  const BusinessFieldDefinition({
    required this.id,
    required this.businessType,
    required this.targetEntity,
    required this.fieldKey,
    required this.fieldLabel,
    this.fieldType = 'text',
    this.isRequired = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_type': businessType,
        'target_entity': targetEntity,
        'field_key': fieldKey,
        'field_label': fieldLabel,
        'field_type': fieldType,
        'is_required': isRequired,
      };

  factory BusinessFieldDefinition.fromJson(Map<String, dynamic> json) {
    return BusinessFieldDefinition(
      id: json['id'] as int,
      businessType: json['business_type'] as String,
      targetEntity: json['target_entity'] as String,
      fieldKey: json['field_key'] as String,
      fieldLabel: json['field_label'] as String,
      fieldType: json['field_type'] as String? ?? 'text',
      isRequired: json['is_required'] as bool? ?? false,
    );
  }
}

// 3. PRODUCTS (With JSONB custom_attributes)
class Product {
  final int id;
  final int businessId;
  final String name;
  final int? categoryId;
  final String categoryName;
  final bool trackInventory; // false for restaurant dishes (POS only) and services
  final int stockQuantity;
  final double costPrice;
  final double sellingPrice;
  final int? supplierId;
  final String unit; // 'xabbo', 'baakidh', 'kiilo', etc.
  final String imageUrl;
  final Map<String, dynamic> customAttributes; // dynamic fields from definitions
  final bool isArchived;
  final bool isSynced;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    this.categoryId,
    this.categoryName = 'General',
    this.trackInventory = true,
    this.stockQuantity = 0,
    this.costPrice = 0.0,
    required this.sellingPrice,
    this.supplierId,
    this.unit = 'xabbo',
    this.imageUrl = '',
    this.customAttributes = const {},
    this.isArchived = false,
    this.isSynced = true,
  });

  Product copyWith({
    int? id,
    int? businessId,
    String? name,
    int? categoryId,
    String? categoryName,
    bool? trackInventory,
    int? stockQuantity,
    double? costPrice,
    double? sellingPrice,
    int? supplierId,
    String? unit,
    String? imageUrl,
    Map<String, dynamic>? customAttributes,
    bool? isArchived,
    bool? isSynced,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      trackInventory: trackInventory ?? this.trackInventory,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierId: supplierId ?? this.supplierId,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      customAttributes: customAttributes ?? this.customAttributes,
      isArchived: isArchived ?? this.isArchived,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'category_id': categoryId,
        'track_inventory': trackInventory,
        'stock_quantity': stockQuantity,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'supplier_id': supplierId,
        'unit': unit,
        'image_url': imageUrl,
        'custom_attributes': customAttributes,
        'is_archived': isArchived,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      name: json['name'] as String,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String? ?? 'General',
      trackInventory: json['track_inventory'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      supplierId: json['supplier_id'] as int?,
      unit: json['unit'] as String? ?? 'xabbo',
      imageUrl: json['image_url'] as String? ?? '',
      customAttributes: json['custom_attributes'] != null
          ? Map<String, dynamic>.from(json['custom_attributes'] as Map)
          : {},
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }
}

// 3.5 SUPPLIERS & STOCK MOVEMENTS (Production Inventory Schema)
class Supplier {
  final int id;
  final int businessId;
  final String name;
  final String phone;
  final double balanceOwed;

  const Supplier({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.balanceOwed = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'balance_owed': balanceOwed,
      };

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      balanceOwed: (json['balance_owed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Supplier copyWith({
    int? id,
    int? businessId,
    String? name,
    String? phone,
    double? balanceOwed,
  }) {
    return Supplier(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balanceOwed: balanceOwed ?? this.balanceOwed,
    );
  }
}

class StockMovement {
  final int id;
  final int businessId;
  final int productId;
  final String type; // 'sale', 'stock_receipt', 'adjustment', 'return'
  final int quantity;
  final String notes;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.type,
    required this.quantity,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      productId: json['product_id'] as int,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

// 4. CUSTOMERS & TRANSACTIONS (Credits & Repayments)
class Customer {
  final int id;
  final int businessId;
  final String name;
  final String phone;
  final double totalDebt;
  final double paidDebt;
  final double currentCreditBalance;
  final double depositBalance;
  final DateTime? dueDate;
  final String reminderMode; // 'after_days', 'daily'
  final int reminderDays; // e.g. 1, 3, 7, 14, 30
  final String status; // 'unpaid', 'partial', 'cleared'
  final String notes;
  final DateTime? createdAt;
  final Map<String, dynamic> customAttributes;

  const Customer({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    double? totalDebt,
    this.paidDebt = 0.0,
    this.currentCreditBalance = 0.0,
    this.depositBalance = 0.0,
    this.dueDate,
    this.reminderMode = 'after_days',
    this.reminderDays = 7,
    this.status = 'unpaid',
    this.notes = '',
    this.createdAt,
    this.customAttributes = const {},
  }) : totalDebt = totalDebt ?? currentCreditBalance;

  bool get isCleared => currentCreditBalance <= 0.001;

  bool get isOverdue {
    if (dueDate == null || isCleared) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today.isAfter(due);
  }

  bool get isDueToday {
    if (dueDate == null || isCleared) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today.isAtSameMomentAs(due);
  }

  bool get isDueSoon {
    if (dueDate == null || isCleared || isOverdue) return false;
    return daysUntilDue >= 0 && daysUntilDue <= 3;
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  DateTime? get lastRemindedAt {
    final raw = customAttributes['last_reminded_at'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  int get notificationCount {
    return (customAttributes['notification_count'] as int?) ?? 0;
  }

  String generateSomaliReminderMessage({String? storeName, double? exchangeRate}) {
    final amountFormatted = '\$${currentCreditBalance.toStringAsFixed(2)}';
    String slshNote = '';
    if (exchangeRate != null && exchangeRate > 0) {
      final slshVal = NumberFormat('#,##0').format((currentCreditBalance * exchangeRate).round());
      slshNote = ' (ama $slshVal SLSh)';
    }
    final dueStr = formattedDueDate.isNotEmpty ? formattedDueDate : 'hadda';
    final signOff = storeName != null ? ' - Mahadsanid, $storeName' : ' - Mahadsanid';
    
    if (isOverdue) {
      return 'Asc $name, waxaan ku xasuusinaynaa in waqtigii deynta dukaanka ee dhan $amountFormatted$slshNote uu dhaafay ($dueStr). Fadlan ku bixi sida ugu dhakhsaha badan.$signOff';
    } else if (isDueToday) {
      return 'Asc $name, waxaan ku xasuusinaynaa in deynta dukaanka ee dhan $amountFormatted$slshNote ay maanta ku egtahay. Fadlan soo bixi waqtiga.$signOff';
    } else {
      return 'Asc $name, waxaan ku xasuusinaynaa deynta dukaanka kuugu hadhsan oo dhan $amountFormatted$slshNote inay ku egtahay $dueStr. Fadlan diyaarso.$signOff';
    }
  }

  String get reminderDescription {
    if (reminderMode == 'daily') {
      return 'Maalin kasta (Laga bilaabo maalinta 1-aad)';
    } else {
      return 'Xusuusin $reminderDays maalmood kadib';
    }
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    return DateFormat('dd MMM yyyy').format(dueDate!);
  }

  String get statusLabel {
    if (isCleared) return 'Dhammaystiray';
    if (paidDebt > 0) return 'Qayb bixiyay';
    return 'Aan bixin';
  }

  Color get statusColor {
    if (isCleared) return const Color(0xFF10B981);
    if (paidDebt > 0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color get statusBg {
    if (isCleared) return const Color(0xFFE6F7F0);
    if (paidDebt > 0) return const Color(0xFFFEF3C7);
    return const Color(0xFFFDE8E8);
  }

  Customer copyWith({
    int? id,
    int? businessId,
    String? name,
    String? phone,
    double? totalDebt,
    double? paidDebt,
    double? currentCreditBalance,
    double? depositBalance,
    DateTime? dueDate,
    String? reminderMode,
    int? reminderDays,
    String? status,
    String? notes,
    DateTime? createdAt,
    Map<String, dynamic>? customAttributes,
  }) {
    return Customer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalDebt: totalDebt ?? this.totalDebt,
      paidDebt: paidDebt ?? this.paidDebt,
      currentCreditBalance: currentCreditBalance ?? this.currentCreditBalance,
      depositBalance: depositBalance ?? this.depositBalance,
      dueDate: dueDate ?? this.dueDate,
      reminderMode: reminderMode ?? this.reminderMode,
      reminderDays: reminderDays ?? this.reminderDays,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'total_debt': totalDebt,
        'paid_debt': paidDebt,
        'current_credit_balance': currentCreditBalance,
        'deposit_balance': depositBalance,
        'due_date': dueDate?.toIso8601String(),
        'reminder_mode': reminderMode,
        'reminder_days': reminderDays,
        'status': status,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
        'custom_attributes': customAttributes,
      };

  factory Customer.fromJson(Map<String, dynamic> json) {
    final balance = (json['current_credit_balance'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total_debt'] as num?)?.toDouble() ?? balance;
    final paid = (json['paid_debt'] as num?)?.toDouble() ?? 0.0;

    return Customer(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      totalDebt: total,
      paidDebt: paid,
      currentCreditBalance: balance,
      depositBalance: (json['deposit_balance'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      reminderMode: json['reminder_mode'] as String? ?? 'after_days',
      reminderDays: json['reminder_days'] as int? ?? 7,
      status: json['status'] as String? ?? (balance <= 0 ? 'cleared' : 'unpaid'),
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      customAttributes: json['custom_attributes'] != null
          ? Map<String, dynamic>.from(json['custom_attributes'] as Map)
          : {},
    );
  }
}

class CustomerTransaction {
  final int id;
  final int businessId;
  final int customerId;
  final String type; // 'deposit', 'deduction', 'credit_sale', 'repayment'
  final double amount;
  final String notes;
  final String paymentMethod;
  final DateTime createdAt;

  const CustomerTransaction({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.type,
    required this.amount,
    this.notes = '',
    this.paymentMethod = 'Cash',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'customer_id': customerId,
        'type': type,
        'amount': amount,
        'notes': notes,
        'payment_method': paymentMethod,
        'created_at': createdAt.toIso8601String(),
      };

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerTransaction(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      customerId: json['customer_id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

// 5. SALES & SALE ITEMS
class SaleItem {
  final int id;
  final int saleId;
  final int? productId; // nullable for POS-only items like restaurant dishes
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
      };

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as int,
      saleId: json['sale_id'] as int,
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class Sale {
  final int id;
  final int businessId;
  final int? customerId;
  final String customerName;
  final String orderType; // 'Miis', 'Safaari', 'Delivery', 'standard'
  final String? deliveryLocation;
  final double totalAmount;
  final double discount;
  final double paidAmount;
  final String paymentStatus; // 'paid', 'partial', 'credit'
  final String paymentMethod; // 'zaad', 'edahab', 'evc_plus', 'cash'
  final Map<String, dynamic> customAttributes;
  final List<SaleItem> items;
  final DateTime createdAt;
  final bool isSynced;

  const Sale({
    required this.id,
    required this.businessId,
    this.customerId,
    this.customerName = 'Walk-in Customer',
    this.orderType = 'standard',
    this.deliveryLocation,
    required this.totalAmount,
    this.discount = 0.0,
    required this.paidAmount,
    required this.paymentStatus,
    this.paymentMethod = 'cash',
    this.customAttributes = const {},
    required this.items,
    required this.createdAt,
    this.isSynced = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'customer_id': customerId,
        'customer_name': customerName,
        'order_type': orderType,
        'delivery_location': deliveryLocation,
        'total_amount': totalAmount,
        'discount': discount,
        'paid_amount': paidAmount,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        'custom_attributes': customAttributes,
        'items': items.map((i) => i.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String? ?? 'Walk-in Customer',
      orderType: json['order_type'] as String? ?? 'standard',
      deliveryLocation: json['delivery_location'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      customAttributes: json['custom_attributes'] != null
          ? Map<String, dynamic>.from(json['custom_attributes'] as Map)
          : {},
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => SaleItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

// 6. SERVICE JOBS (PostgreSQL `service_jobs` Schema)
// Matches:
// CREATE TABLE service_jobs (
//     id BIGSERIAL PRIMARY KEY,
//     business_id BIGINT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
//     customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
//     service_id BIGINT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
//     assigned_staff_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
//     status VARCHAR(32) NOT NULL, -- pending, in_progress, completed, delivered
//     total_amount NUMERIC(12, 2) NOT NULL,
//     deposit_paid NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
//     balance_due NUMERIC(12, 2) NOT NULL,
//     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
// );

class ServiceJob {
  final int id;
  final int businessId;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int serviceId;
  final String serviceName;
  final String? assignedStaff; // Technician
  final String status; // 'pending', 'in_progress', 'completed', 'delivered'
  final double totalAmount;
  final double depositPaid;
  final double balanceDue;
  final String? referenceInfo; // Plate #, Device Model, Measurement
  final String? notes;
  final DateTime createdAt;
  final DateTime? estimatedCompletion;

  const ServiceJob({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.customerName,
    this.customerPhone = '',
    required this.serviceId,
    required this.serviceName,
    this.assignedStaff,
    this.status = 'pending',
    required this.totalAmount,
    this.depositPaid = 0.0,
    double? balanceDue,
    this.referenceInfo,
    this.notes,
    required this.createdAt,
    this.estimatedCompletion,
  }) : balanceDue = balanceDue ?? (totalAmount - depositPaid);

  bool get isPaidInFull => balanceDue <= 0.001;

  String get statusLabelSomali {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'Ku jira Shaqada';
      case 'completed':
        return 'Diyaar (Dhammaaday)';
      case 'delivered':
        return 'La Bixiyay';
      case 'pending':
      default:
        return 'Sugaya Bilow';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return const Color(0xFF2563EB); // Blue
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'delivered':
        return const Color(0xFF6B7280); // Gray
      case 'pending':
      default:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  Color get statusBgColor {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return const Color(0xFFEFF6FF);
      case 'completed':
        return const Color(0xFFE6F7F0);
      case 'delivered':
        return const Color(0xFFF3F4F6);
      case 'pending':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  ServiceJob copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? customerName,
    String? customerPhone,
    int? serviceId,
    String? serviceName,
    String? assignedStaff,
    String? status,
    double? totalAmount,
    double? depositPaid,
    double? balanceDue,
    String? referenceInfo,
    String? notes,
    DateTime? createdAt,
    DateTime? estimatedCompletion,
  }) {
    return ServiceJob(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      depositPaid: depositPaid ?? this.depositPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      referenceInfo: referenceInfo ?? this.referenceInfo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'service_id': serviceId,
        'service_name': serviceName,
        'assigned_staff': assignedStaff,
        'status': status,
        'total_amount': totalAmount,
        'deposit_paid': depositPaid,
        'balance_due': balanceDue,
        'reference_info': referenceInfo,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'estimated_completion': estimatedCompletion?.toIso8601String(),
      };

  factory ServiceJob.fromJson(Map<String, dynamic> json) {
    return ServiceJob(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String? ?? 'Macmiil',
      customerPhone: json['customer_phone'] as String? ?? '',
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String? ?? 'Adeeg',
      assignedStaff: json['assigned_staff'] as String?,
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['total_amount'] as num).toDouble(),
      depositPaid: (json['deposit_paid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json['balance_due'] as num?)?.toDouble(),
      referenceInfo: json['reference_info'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      estimatedCompletion: json['estimated_completion'] != null
          ? DateTime.parse(json['estimated_completion'] as String)
          : null,
    );
  }
}

