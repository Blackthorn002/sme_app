import 'package:flutter/material.dart';

// ============================================================================
// BUSINESS PROFILE MODEL
// The business type decides which pages Gashi turns on by default and which
// modules the owner can switch on later.
// ============================================================================

enum BusinessModule { home, pos, inventory, sales, credits, patients, more }

enum BusinessType { shop, restaurant, pharmacy, serviceProvider }

class BusinessTypeSpec {
  final String labelKey;
  final String subtitleKey;
  final IconData icon;
  final Color color;

  /// Every page this business type can show, in bottom navigation order.
  final List<BusinessModule> modules;

  /// Modules that start switched off and the owner can enable when needed.
  /// Everything else in [modules] is a default page and is always on.
  final Set<BusinessModule> optionalModules;

  const BusinessTypeSpec({
    required this.labelKey,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    required this.modules,
    required this.optionalModules,
  });
}

const Map<BusinessType, BusinessTypeSpec> businessTypeSpecs = {
  BusinessType.shop: BusinessTypeSpec(
    labelKey: 'type_shop',
    subtitleKey: 'type_shop_desc',
    icon: Icons.storefront,
    color: Color(0xFF10B981),
    modules: [
      BusinessModule.home,
      BusinessModule.pos,
      BusinessModule.inventory,
      BusinessModule.credits,
      BusinessModule.more,
    ],
    optionalModules: {BusinessModule.credits},
  ),
  BusinessType.restaurant: BusinessTypeSpec(
    labelKey: 'type_restaurant',
    subtitleKey: 'type_restaurant_desc',
    icon: Icons.restaurant,
    color: Color(0xFFFF5200),
    modules: [
      BusinessModule.home,
      BusinessModule.pos,
      BusinessModule.sales,
      BusinessModule.credits,
      BusinessModule.more,
    ],
    optionalModules: {BusinessModule.credits},
  ),
  BusinessType.pharmacy: BusinessTypeSpec(
    labelKey: 'type_pharmacy',
    subtitleKey: 'type_pharmacy_desc',
    icon: Icons.local_pharmacy,
    color: Color(0xFFEF4444),
    modules: [
      BusinessModule.home,
      BusinessModule.pos,
      BusinessModule.inventory,
      BusinessModule.patients,
      BusinessModule.more,
    ],
    optionalModules: {BusinessModule.patients},
  ),
  BusinessType.serviceProvider: BusinessTypeSpec(
    labelKey: 'type_service',
    subtitleKey: 'type_service_desc',
    icon: Icons.handyman,
    color: Color(0xFF4F46E5),
    modules: [
      BusinessModule.home,
      BusinessModule.pos,
      BusinessModule.sales,
      BusinessModule.credits,
      BusinessModule.more,
    ],
    optionalModules: {BusinessModule.credits},
  ),
};

extension BusinessTypeX on BusinessType {
  BusinessTypeSpec get spec => businessTypeSpecs[this]!;
}

const Map<BusinessModule, String> businessModuleLabelKeys = {
  BusinessModule.home: 'module_home',
  BusinessModule.pos: 'module_pos',
  BusinessModule.inventory: 'module_inventory',
  BusinessModule.sales: 'module_sales',
  BusinessModule.credits: 'module_credits',
  BusinessModule.patients: 'module_patients',
  BusinessModule.more: 'module_more',
};

const Map<BusinessModule, String> businessModuleDescKeys = {
  BusinessModule.home: 'module_home_desc',
  BusinessModule.pos: 'module_pos_desc',
  BusinessModule.inventory: 'module_inventory_desc',
  BusinessModule.sales: 'module_sales_desc',
  BusinessModule.credits: 'module_credits_desc',
  BusinessModule.patients: 'module_patients_desc',
  BusinessModule.more: 'module_more_desc',
};

class Branch {
  final String id;
  final String name;
  final String location;

  const Branch({required this.id, required this.name, this.location = ''});

  Branch copyWith({String? name, String? location}) {
    return Branch(id: id, name: name ?? this.name, location: location ?? this.location);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'location': location};

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      name: json['name'] as String,
      location: (json['location'] as String?) ?? '',
    );
  }
}

class BusinessProfile {
  final String name;
  final BusinessType type;
  final Set<BusinessModule> enabledOptionalModules;
  final List<Branch> branches;
  final String activeBranchId;

  const BusinessProfile({
    required this.name,
    required this.type,
    required this.enabledOptionalModules,
    required this.branches,
    required this.activeBranchId,
  });

  Branch get activeBranch =>
      branches.firstWhere((b) => b.id == activeBranchId, orElse: () => branches.first);

  bool isModuleEnabled(BusinessModule module) {
    final spec = type.spec;
    if (!spec.modules.contains(module)) return false;
    if (!spec.optionalModules.contains(module)) return true;
    return enabledOptionalModules.contains(module);
  }

  List<BusinessModule> get enabledModules => type.spec.modules.where(isModuleEnabled).toList();

  BusinessProfile copyWith({
    String? name,
    Set<BusinessModule>? enabledOptionalModules,
    List<Branch>? branches,
    String? activeBranchId,
  }) {
    return BusinessProfile(
      name: name ?? this.name,
      type: type,
      enabledOptionalModules: enabledOptionalModules ?? this.enabledOptionalModules,
      branches: branches ?? this.branches,
      activeBranchId: activeBranchId ?? this.activeBranchId,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'enabledOptionalModules': enabledOptionalModules.map((m) => m.name).toList(),
        'branches': branches.map((b) => b.toJson()).toList(),
        'activeBranchId': activeBranchId,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      name: json['name'] as String,
      type: BusinessType.values.byName(json['type'] as String),
      enabledOptionalModules: (json['enabledOptionalModules'] as List<dynamic>)
          .map((m) => BusinessModule.values.byName(m as String))
          .toSet(),
      branches: (json['branches'] as List<dynamic>)
          .map((b) => Branch.fromJson(b as Map<String, dynamic>))
          .toList(),
      activeBranchId: json['activeBranchId'] as String,
    );
  }
}
