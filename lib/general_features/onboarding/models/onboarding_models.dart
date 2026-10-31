import 'package:flutter/material.dart';

// ============================================================================
// DYNAMIC BUSINESS ONBOARDING & CONDITIONAL MODULE SELECTION MODELS
// ============================================================================

/// Step 1: Business Category
class BusinessCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const BusinessCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Step 2: Specific Business Type / Subcategory
class BusinessSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final IconData icon;

  const BusinessSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
  });
}

/// Step 3: Business Operation
class BusinessOperation {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const BusinessOperation({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Visibility status of a module in the dynamic module selection UI
enum ModuleVisibilityState {
  /// Currently selected by the user (or required dependency)
  selected,

  /// Highly relevant / recommended based on business category, operations, or selections
  recommended,

  /// Incompatible or unrelated: MUST NOT appear in the selection interface
  hidden,
}

/// Step 4: Gashi Core Module
class GashiModule {
  final String id;
  final String code;
  final String name;
  final String description;
  final List<String> features;
  final List<String> supportedCategories;
  final List<String> supportedOperations;
  final List<String> dependencies; // Mandatory modules that MUST be active
  final List<String> relatedModules; // Recommended when this module is picked
  final List<String> optionalIntegrations;
  final double baseMonthlyPrice;
  final IconData icon;
  final Color color;

  const GashiModule({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.features,
    required this.supportedCategories,
    required this.supportedOperations,
    this.dependencies = const [],
    this.relatedModules = const [],
    this.optionalIntegrations = const [],
    this.baseMonthlyPrice = 0.0,
    required this.icon,
    required this.color,
  });
}

/// Step 4 / Add-ons: Modular Enhancements & AI Features
class ModuleAddOn {
  final String id;
  final String name;
  final String description;
  final String category; // 'inventory', 'pos', 'accounting', 'general'
  final String? requiredModuleId; // e.g., 'inventory', 'pos', 'accounting'
  final double monthlyPrice;
  final IconData icon;
  final String badge;

  const ModuleAddOn({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.requiredModuleId,
    required this.monthlyPrice,
    required this.icon,
    this.badge = 'Add-on',
  });
}

/// Dependency resolution outcome
class DependencyResolutionResult {
  final Set<String> effectiveSelectedIds;
  final Map<String, String> autoIncludedDependencies; // childModuleId -> parentModuleId
  final Map<String, String> explanations; // childModuleId -> explanation message

  const DependencyResolutionResult({
    required this.effectiveSelectedIds,
    required this.autoIncludedDependencies,
    required this.explanations,
  });
}

/// Step 5 & 6: Completed Business Configuration
class BusinessConfig {
  final int id;
  final String businessName;
  final String logoUrl;
  final String categoryId;
  final String categoryName;
  final String subcategoryId;
  final String subcategoryName;
  final List<String> operations;
  final List<String> selectedModules;
  final Map<String, String> autoDependencies; // childId -> parentId
  final List<String> selectedAddOns;
  final String country;
  final String city;
  final String currency;
  final String timeZone;
  final String phone;
  final String email;
  final String fiscalYearStart;
  final int employeeCount;
  final int branchCount;
  final DateTime createdAt;

  const BusinessConfig({
    required this.id,
    required this.businessName,
    this.logoUrl = '',
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.operations,
    required this.selectedModules,
    this.autoDependencies = const {},
    required this.selectedAddOns,
    required this.country,
    required this.city,
    required this.currency,
    required this.timeZone,
    required this.phone,
    required this.email,
    required this.fiscalYearStart,
    required this.employeeCount,
    required this.branchCount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_name': businessName,
        'logo_url': logoUrl,
        'category_id': categoryId,
        'category_name': categoryName,
        'subcategory_id': subcategoryId,
        'subcategory_name': subcategoryName,
        'operations': operations,
        'selected_modules': selectedModules,
        'auto_dependencies': autoDependencies,
        'selected_add_ons': selectedAddOns,
        'country': country,
        'city': city,
        'currency': currency,
        'time_zone': timeZone,
        'phone': phone,
        'email': email,
        'fiscal_year_start': fiscalYearStart,
        'employee_count': employeeCount,
        'branch_count': branchCount,
        'created_at': createdAt.toIso8601String(),
      };

  factory BusinessConfig.fromJson(Map<String, dynamic> json) {
    return BusinessConfig(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      businessName: json['business_name'] as String? ?? 'Gashi Business',
      logoUrl: json['logo_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? 'retail_shops',
      categoryName: json['category_name'] as String? ?? 'Retail & Shops',
      subcategoryId: json['subcategory_id'] as String? ?? 'general_store',
      subcategoryName: json['subcategory_name'] as String? ?? 'General Store',
      operations: (json['operations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      selectedModules: (json['selected_modules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      autoDependencies: (json['auto_dependencies'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      selectedAddOns: (json['selected_add_ons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      country: json['country'] as String? ?? 'Somalia / Somaliland',
      city: json['city'] as String? ?? 'Hargeisa',
      currency: json['currency'] as String? ?? 'USD',
      timeZone: json['time_zone'] as String? ?? 'UTC+3 (EAT)',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fiscalYearStart: json['fiscal_year_start'] as String? ?? 'January',
      employeeCount: json['employee_count'] as int? ?? 1,
      branchCount: json['branch_count'] as int? ?? 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}

