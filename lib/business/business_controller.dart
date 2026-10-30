import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'business_profile.dart';

class BusinessController extends ChangeNotifier {
  static final BusinessController instance = BusinessController._internal();

  BusinessController._internal();

  static const _storageKey = 'business_profile';

  BusinessProfile? _profile;

  BusinessProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  /// Loads the saved business profile, if the owner has already set one up.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      _profile = BusinessProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable data from an older version: start setup again.
      _profile = null;
    }
    notifyListeners();
  }

  /// Pages to show for a business of [type]. Falls back to every page of that
  /// type when the view is opened without a matching profile.
  List<BusinessModule> modulesFor(BusinessType type) {
    final current = _profile;
    if (current == null || current.type != type) return type.spec.modules;
    return current.enabledModules;
  }

  Future<void> createBusiness({
    required String name,
    required BusinessType type,
    required Set<BusinessModule> optionalModules,
    required String mainBranchName,
  }) async {
    final mainBranch = Branch(id: _newId(), name: mainBranchName.trim());
    _profile = BusinessProfile(
      name: name.trim(),
      type: type,
      enabledOptionalModules: optionalModules.intersection(type.spec.optionalModules),
      branches: [mainBranch],
      activeBranchId: mainBranch.id,
    );
    await _save();
  }

  Future<void> rename(String name) => _update((p) => p.copyWith(name: name.trim()));

  Future<void> setModuleEnabled(BusinessModule module, bool enabled) {
    return _update((p) {
      final modules = Set<BusinessModule>.from(p.enabledOptionalModules);
      enabled ? modules.add(module) : modules.remove(module);
      return p.copyWith(enabledOptionalModules: modules);
    });
  }

  Future<void> addBranch({required String name, String location = ''}) {
    return _update((p) => p.copyWith(
          branches: [...p.branches, Branch(id: _newId(), name: name.trim(), location: location.trim())],
        ));
  }

  Future<void> updateBranch(Branch branch) {
    return _update((p) => p.copyWith(
          branches: [for (final b in p.branches) b.id == branch.id ? branch : b],
        ));
  }

  /// Removes a branch. The last remaining branch cannot be removed.
  Future<void> removeBranch(String id) {
    return _update((p) {
      if (p.branches.length <= 1) return p;
      final branches = p.branches.where((b) => b.id != id).toList();
      return p.copyWith(
        branches: branches,
        activeBranchId: p.activeBranchId == id ? branches.first.id : p.activeBranchId,
      );
    });
  }

  Future<void> setActiveBranch(String id) => _update((p) => p.copyWith(activeBranchId: id));

  /// Deletes the business profile so setup starts again.
  Future<void> reset() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _update(BusinessProfile Function(BusinessProfile) change) async {
    final current = _profile;
    if (current == null) return;
    _profile = change(current);
    await _save();
  }

  Future<void> _save() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profile!.toJson()));
  }

  String _newId() => 'branch_${DateTime.now().microsecondsSinceEpoch}';
}
