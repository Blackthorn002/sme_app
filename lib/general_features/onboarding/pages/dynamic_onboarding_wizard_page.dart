import 'package:flutter/material.dart';
import 'package:sme/l10n/app_language.dart';
import 'package:sme/l10n/app_localizations.dart';
import 'package:sme/general_features/onboarding/models/onboarding_models.dart';
import 'package:sme/general_features/onboarding/engine/module_recommendation_engine.dart';
import 'package:sme/general_features/repository/gashi_repository.dart';
import 'dynamic_business_dashboard_view.dart';

// ============================================================================
// GASHI DYNAMIC BUSINESS ONBOARDING & CONDITIONAL MODULE SELECTION WIZARD
// ============================================================================

class DynamicOnboardingWizardPage extends StatefulWidget {
  const DynamicOnboardingWizardPage({super.key});

  @override
  State<DynamicOnboardingWizardPage> createState() =>
      _DynamicOnboardingWizardPageState();
}

class _DynamicOnboardingWizardPageState
    extends State<DynamicOnboardingWizardPage> {
  int _currentStep = 1;
  final int _totalSteps = 6;

  // Step 1: Category
  String _selectedCategoryId = 'retail_shops';

  // Step 2: Specific Type (Subcategory)
  String _selectedSubcategoryId = 'clothing_store';

  // Step 3: Operations (Multi-select)
  final Set<String> _selectedOperations = {
    'sell_physical_products',
    'purchase_suppliers',
    'manage_stock',
    'sell_on_credit',
    'manage_customer_debts',
  };

  // Step 4: Selected Modules & Add-ons
  Set<String> _selectedModuleIds = {};
  Map<String, String> _autoIncludedDependencies = {}; // childId -> parentId
  Map<String, String> _dependencyExplanations = {}; // childId -> reason
  final Set<String> _selectedAddOnIds = {'ai_business_assistant'};

  // Step 5: Business Configuration Controllers & Fields
  final _nameController = TextEditingController(text: 'Dukaanka Gashi');
  final _phoneController = TextEditingController(text: '+252 63 4567890');
  final _emailController = TextEditingController(text: 'info@gashibusiness.com');
  String _selectedCountry = 'Somalia / Somaliland';
  String _selectedCity = 'Hargeisa';
  String _selectedCurrency = 'USD';
  String _selectedTimeZone = 'UTC+3 (EAT)';
  String _selectedFiscalStart = 'January';
  int _employeeCount = 4;
  int _branchCount = 1;
  String _selectedLogo = 'assets/gashi_logo_green.png';

  final List<String> _logoOptions = [
    'assets/gashi_logo_green.png',
    'assets/gashi_logo_orange.png',
    'assets/gashi_logo_indigo.png',
    'assets/gashi_logo_red.png',
  ];

  @override
  void initState() {
    super.initState();
    _recalculateModulesForProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _recalculateModulesForProfile() {
    final initial = ModuleRecommendationEngine.computeInitialRecommendedSelection(
      categoryId: _selectedCategoryId,
      selectedOperations: _selectedOperations.toList(),
    );
    final res = ModuleRecommendationEngine.resolveDependencies(initial);
    setState(() {
      _selectedModuleIds = res.effectiveSelectedIds;
      _autoIncludedDependencies = res.autoIncludedDependencies;
      _dependencyExplanations = res.explanations;
    });
  }

  void _onCategoryChanged(String newCategoryId) {
    setState(() {
      _selectedCategoryId = newCategoryId;
      // Pick first matching subcategory
      final validSubs = ModuleRecommendationEngine.subcategories
          .where((s) => s.categoryId == newCategoryId);
      if (validSubs.isNotEmpty) {
        _selectedSubcategoryId = validSubs.first.id;
      }

      // Adjust default suggested operations based on category
      if (newCategoryId == 'restaurant_food') {
        _selectedOperations.add('manage_restaurant_tables');
        _selectedOperations.remove('track_medicine_batches');
        _selectedOperations.remove('manufacture_products');
        _selectedLogo = 'assets/gashi_logo_orange.png';
      } else if (newCategoryId == 'pharmacy_healthcare') {
        _selectedOperations.add('track_medicine_batches');
        _selectedOperations.remove('manage_restaurant_tables');
        _selectedOperations.remove('manufacture_products');
        _selectedLogo = 'assets/gashi_logo_red.png';
      } else if (newCategoryId == 'manufacturing_production') {
        _selectedOperations.add('manufacture_products');
        _selectedOperations.remove('manage_restaurant_tables');
        _selectedOperations.remove('track_medicine_batches');
        _selectedLogo = 'assets/gashi_logo_orange.png';
      } else if (newCategoryId == 'service_business' || newCategoryId == 'beauty_personal_care') {
        _selectedOperations.add('provide_services');
        _selectedOperations.add('manage_appointments');
        _selectedLogo = 'assets/gashi_logo_indigo.png';
      } else {
        _selectedLogo = 'assets/gashi_logo_green.png';
      }

      _recalculateModulesForProfile();
    });
  }

  void _toggleOperation(String opId) {
    setState(() {
      if (_selectedOperations.contains(opId)) {
        _selectedOperations.remove(opId);
      } else {
        _selectedOperations.add(opId);
      }
      _recalculateModulesForProfile();
    });
  }

  void _toggleModuleSelection(String moduleId) {
    final isSelected = _selectedModuleIds.contains(moduleId);

    if (isSelected) {
      // Check if another selected module strictly requires this module
      final blockReason = ModuleRecommendationEngine.canDeselectModule(
        moduleId,
        _selectedModuleIds,
      );

      if (blockReason != null) {
        _showDependencyAlert(
          title: 'Required Dependency',
          message: blockReason,
          icon: Icons.lock_outline_rounded,
          color: Colors.amber.shade800,
        );
        return;
      }

      setState(() {
        _selectedModuleIds.remove(moduleId);
        _autoIncludedDependencies.remove(moduleId);
        _dependencyExplanations.remove(moduleId);

        // Also clean up any auto-included child modules if no longer needed
        final rechecked = ModuleRecommendationEngine.resolveDependencies(_selectedModuleIds);
        _selectedModuleIds = rechecked.effectiveSelectedIds;
        _autoIncludedDependencies = rechecked.autoIncludedDependencies;
        _dependencyExplanations = rechecked.explanations;
      });
    } else {
      // Add module and automatically resolve all its mandatory dependencies
      final nextSet = Set<String>.from(_selectedModuleIds)..add(moduleId);
      final res = ModuleRecommendationEngine.resolveDependencies(nextSet);

      final newlyAddedDeps = res.effectiveSelectedIds.difference(_selectedModuleIds)
        ..remove(moduleId);

      setState(() {
        _selectedModuleIds = res.effectiveSelectedIds;
        _autoIncludedDependencies = res.autoIncludedDependencies;
        _dependencyExplanations = res.explanations;
      });

      if (newlyAddedDeps.isNotEmpty) {
        final depNames = newlyAddedDeps
            .map((id) => ModuleRecommendationEngine.getModuleName(id))
            .join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1D2338),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFFF5200)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Automatically included required modules: $depNames',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showDependencyAlert({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D2338),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  double _calculateEstimatedMonthlyPrice() {
    double total = 0.0;
    for (final id in _selectedModuleIds) {
      final m = ModuleRecommendationEngine.moduleCatalog.firstWhere(
        (mod) => mod.id == id,
        orElse: () => ModuleRecommendationEngine.moduleCatalog.first,
      );
      total += m.baseMonthlyPrice;
    }
    for (final id in _selectedAddOnIds) {
      final a = ModuleRecommendationEngine.addOnCatalog.firstWhere(
        (add) => add.id == id,
        orElse: () => ModuleRecommendationEngine.addOnCatalog.first,
      );
      total += a.monthlyPrice;
    }
    return total;
  }

  void _completeOnboardingAndActivate() {
    final cat = ModuleRecommendationEngine.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );
    final sub = ModuleRecommendationEngine.subcategories.firstWhere(
      (s) => s.id == _selectedSubcategoryId,
      orElse: () => ModuleRecommendationEngine.subcategories.first,
    );

    final config = BusinessConfig(
      id: DateTime.now().millisecondsSinceEpoch,
      businessName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'My Gashi Business',
      logoUrl: _selectedLogo,
      categoryId: _selectedCategoryId,
      categoryName: cat.name,
      subcategoryId: _selectedSubcategoryId,
      subcategoryName: sub.name,
      operations: _selectedOperations.toList(),
      selectedModules: _selectedModuleIds.toList(),
      autoDependencies: _autoIncludedDependencies,
      selectedAddOns: _selectedAddOnIds.toList(),
      country: _selectedCountry,
      city: _selectedCity,
      currency: _selectedCurrency,
      timeZone: _selectedTimeZone,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      fiscalYearStart: _selectedFiscalStart,
      employeeCount: _employeeCount,
      branchCount: _branchCount,
      createdAt: DateTime.now(),
    );

    // Persist and register entitlements in GashiRepository
    final createdBusiness = GashiRepository.instance.createOnboardedBusiness(config);

    // Show celebratory confirmation and navigate directly to personalized dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Success! "${config.businessName}" activated with ${config.selectedModules.length} customized modules.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DynamicBusinessDashboardView(
          business: createdBusiness,
          config: config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = ModuleRecommendationEngine.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gashi Business Onboarding',
              style: TextStyle(
                color: Color(0xFF1D2338),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              'Step $_currentStep of $_totalSteps • ${_getStepTitle()}',
              style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16, color: Color(0xFFFF5200)),
              label: Text(
                AppLanguage.instance.isSomali ? 'SO' : 'EN',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              onPressed: () => AppLanguage.instance.toggleLanguage(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: _currentStep / _totalSteps,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _buildCurrentStepContent(cat),
              ),
            ),
            _buildBottomNavigationControls(cat),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Business Category';
      case 2:
        return 'Business Type';
      case 3:
        return 'Business Operations';
      case 4:
        return 'Dynamic Module Selection';
      case 5:
        return 'Business Configuration';
      case 6:
        return 'Review & Activation';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent(BusinessCategory cat) {
    switch (_currentStep) {
      case 1:
        return _buildStep1CategorySelection();
      case 2:
        return _buildStep2SubcategorySelection(cat);
      case 3:
        return _buildStep3OperationsSelection(cat);
      case 4:
        return _buildStep4DynamicModuleSelection(cat);
      case 5:
        return _buildStep5BusinessConfiguration(cat);
      case 6:
        return _buildStep6ReviewAndActivation(cat);
      default:
        return const SizedBox.shrink();
    }
  }

  // --------------------------------------------------------------------------
  // STEP 1: BUSINESS CATEGORY
  // --------------------------------------------------------------------------
  Widget _buildStep1CategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: Icons.store_mall_directory_rounded,
          title: 'What type of business do you operate?',
          subtitle: 'Choose the industry that best describes your business. Gashi uses this to prepare your specialized operational tools.',
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 18),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ModuleRecommendationEngine.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final category = ModuleRecommendationEngine.categories[index];
            final isSelected = category.id == _selectedCategoryId;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onCategoryChanged(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? category.color : const Color(0xFFF1F3F6),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color
                            : category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: isSelected ? Colors.white : category.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? category.color : const Color(0xFF1D2338),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? category.color : const Color(0xFFD1D5DB),
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: BUSINESS TYPE (SUBCATEGORY)
  // --------------------------------------------------------------------------
  Widget _buildStep2SubcategorySelection(BusinessCategory cat) {
    final filtered = ModuleRecommendationEngine.subcategories
        .where((s) => s.categoryId == _selectedCategoryId)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: cat.icon,
          title: 'Select your specific business type',
          subtitle: 'Showing specialized subcategories for ${cat.name}. This fine-tunes your workflows, units, and inventory defaults.',
          color: cat.color,
        ),
        const SizedBox(height: 18),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final sub = filtered[index];
            final isSelected = sub.id == _selectedSubcategoryId;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _selectedSubcategoryId = sub.id;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? cat.color : const Color(0xFFF1F3F6),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cat.color.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        sub.icon,
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        sub.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? cat.color : const Color(0xFF1D2338),
                        ),
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? cat.color : const Color(0xFFD1D5DB),
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 3: BUSINESS OPERATIONS
  // --------------------------------------------------------------------------
  Widget _buildStep3OperationsSelection(BusinessCategory cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: Icons.checklist_rounded,
          title: 'How does your business operate?',
          subtitle: 'Select all daily activities your business performs. Gashi dynamically configures your required modules based on these answers.',
          color: cat.color,
        ),
        const SizedBox(height: 18),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ModuleRecommendationEngine.operations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final op = ModuleRecommendationEngine.operations[index];
            final isSelected = _selectedOperations.contains(op.id);

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _toggleOperation(op.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? cat.color : const Color(0xFFF1F3F6),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cat.color.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withValues(alpha: 0.15)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        op.icon,
                        color: isSelected ? cat.color : const Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            op.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? cat.color : const Color(0xFF1D2338),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            op.description,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      activeColor: cat.color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      onChanged: (_) => _toggleOperation(op.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 4: DYNAMIC MODULE SELECTION (CONDITIONAL VISIBILITY)
  // --------------------------------------------------------------------------
  Widget _buildStep4DynamicModuleSelection(BusinessCategory cat) {
    // 1. Compute visibility states for all 12 modules
    final visibilityMap = ModuleRecommendationEngine.computeModuleVisibility(
      categoryId: _selectedCategoryId,
      subcategoryId: _selectedSubcategoryId,
      selectedOperations: _selectedOperations.toList(),
      selectedModuleIds: _selectedModuleIds,
    );

    // Filter out HIDDEN modules: they must NEVER appear!
    final visibleModules = ModuleRecommendationEngine.moduleCatalog.where((m) {
      final state = visibilityMap[m.id];
      return state != ModuleVisibilityState.hidden;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: Icons.dashboard_customize_rounded,
          title: 'Dynamic Module Selection',
          subtitle: 'Only management modules relevant to your business profile are displayed below. Unrelated industry modules are hidden.',
          color: cat.color,
        ),
        const SizedBox(height: 16),

        // Live stats ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D2338),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedModuleIds.length} Modules Selected',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Text(
                'Est. \$${_calculateEstimatedMonthlyPrice().toStringAsFixed(0)}/mo',
                style: const TextStyle(
                  color: Color(0xFFFF5200),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section: Visible Core Modules
        Text(
          'Available Modules (${visibleModules.length} relevant)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2338),
          ),
        ),
        const SizedBox(height: 10),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleModules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final module = visibleModules[index];
            final isSelected = _selectedModuleIds.contains(module.id);
            final isAutoRequired = _autoIncludedDependencies.containsKey(module.id);
            final parentModuleId = _autoIncludedDependencies[module.id];
            final explanation = _dependencyExplanations[module.id];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? module.color : const Color(0xFFF1F3F6),
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: module.color.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card header & toggle
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: module.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(module.icon, color: module.color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      module.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? module.color : const Color(0xFF1D2338),
                                      ),
                                    ),
                                  ),
                                  // Base Price tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '\$${module.baseMonthlyPrice.toInt()}/mo',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                module.description,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Required Dependency Ribbon if auto-included
                  if (isAutoRequired && explanation != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_clock_rounded, color: Colors.amber.shade800, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'MANDATORY DEPENDENCY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (parentModuleId != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(Required by ${ModuleRecommendationEngine.getModuleName(parentModuleId)})',
                                        style: TextStyle(fontSize: 10, color: Colors.amber.shade800),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  explanation,
                                  style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Features Bullet Points
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: module.features.map((f) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 13, color: module.color),
                                const SizedBox(width: 4),
                                Text(
                                  f,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isSelected && isAutoRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Locked: Mandatory Requirement',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              )
                            else if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: module.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Activated',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: module.color,
                                  ),
                                ),
                              )
                            else
                              const Text(
                                'Recommended for your business',
                                style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                              ),

                            // Select / Deselect Button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? module.color : Colors.white,
                                foregroundColor: isSelected ? Colors.white : module.color,
                                side: BorderSide(color: module.color),
                                elevation: 0,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _toggleModuleSelection(module.id),
                              icon: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                size: 16,
                              ),
                              label: Text(
                                isSelected ? 'Active' : 'Add Module',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Section: Add-ons & AI Enhancements
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Optional Add-ons & AI Tools',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2338),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5200).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AI Powered',
                style: TextStyle(
                  color: Color(0xFFFF5200),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ModuleRecommendationEngine.addOnCatalog.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final addon = ModuleRecommendationEngine.addOnCatalog[index];
            final isAvailable = ModuleRecommendationEngine.isAddOnAvailable(
              addon,
              _selectedModuleIds,
            );
            final isChecked = _selectedAddOnIds.contains(addon.id) && isAvailable;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isChecked ? const Color(0xFFFF5200) : const Color(0xFFF1F3F6),
                  width: isChecked ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFFFF5200).withValues(alpha: 0.1)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      addon.icon,
                      color: isAvailable ? const Color(0xFFFF5200) : const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              addon.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? const Color(0xFF1D2338) : const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                addon.badge,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          addon.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isAvailable ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          ),
                        ),
                        if (!isAvailable) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFFEF4444)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ModuleRecommendationEngine.getAddOnRequirementMessage(addon),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              // Quick activate prerequisite button
                              if (addon.requiredModuleId != null)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 20),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _toggleModuleSelection(addon.requiredModuleId!),
                                  child: Text(
                                    'Activate ${ModuleRecommendationEngine.getModuleName(addon.requiredModuleId!)}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+\$${addon.monthlyPrice.toInt()}/mo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? const Color(0xFF1D2338) : const Color(0xFF9CA3AF),
                        ),
                      ),
                      Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFFFF5200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: isAvailable
                            ? (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedAddOnIds.add(addon.id);
                                  } else {
                                    _selectedAddOnIds.remove(addon.id);
                                  }
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 5: BUSINESS CONFIGURATION
  // --------------------------------------------------------------------------
  Widget _buildStep5BusinessConfiguration(BusinessCategory cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: Icons.tune_rounded,
          title: 'Business Configuration',
          subtitle: 'Enter your business identification, localization, branches, and currency parameters.',
          color: cat.color,
        ),
        const SizedBox(height: 18),

        // Logo Picker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F3F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Business Brand Theme & Logo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: _logoOptions.map((logoPath) {
                  final isSelected = _selectedLogo == logoPath;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedLogo = logoPath;
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? cat.color : const Color(0xFFE5E7EB),
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: Image.asset(
                          logoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.business_rounded),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Text Fields Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F3F6)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Business Name *',
                  hintText: 'e.g. Dukaanka Gashi Burao',
                  prefixIcon: const Icon(Icons.storefront_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Business Phone Number',
                  hintText: '+252 63 4567890',
                  prefixIcon: const Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Business Email Address',
                  hintText: 'info@business.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Regional & Fiscal Settings
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F3F6)),
          ),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  prefixIcon: const Icon(Icons.public_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Somalia / Somaliland', child: Text('Somalia / Somaliland')),
                  DropdownMenuItem(value: 'Djibouti', child: Text('Djibouti')),
                  DropdownMenuItem(value: 'Kenya', child: Text('Kenya')),
                  DropdownMenuItem(value: 'Ethiopia', child: Text('Ethiopia')),
                  DropdownMenuItem(value: 'United Arab Emirates', child: Text('United Arab Emirates')),
                  DropdownMenuItem(value: 'United States / UK', child: Text('United States / UK')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCountry = val);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'City / Region',
                  prefixIcon: const Icon(Icons.location_city_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Hargeisa', child: Text('Hargeisa')),
                  DropdownMenuItem(value: 'Mogadishu', child: Text('Mogadishu')),
                  DropdownMenuItem(value: 'Burao', child: Text('Burao')),
                  DropdownMenuItem(value: 'Garowe', child: Text('Garowe')),
                  DropdownMenuItem(value: 'Bosaso', child: Text('Bosaso')),
                  DropdownMenuItem(value: 'Berbera', child: Text('Berbera')),
                  DropdownMenuItem(value: 'Kismayo', child: Text('Kismayo')),
                  DropdownMenuItem(value: 'Nairobi', child: Text('Nairobi')),
                  DropdownMenuItem(value: 'Djibouti City', child: Text('Djibouti City')),
                  DropdownMenuItem(value: 'Dubai', child: Text('Dubai')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                        DropdownMenuItem(value: 'SLSh', child: Text('SLSh (Somaliland)')),
                        DropdownMenuItem(value: 'SOS', child: Text('SOS (Somali Shilling)')),
                        DropdownMenuItem(value: 'KES', child: Text('KES (Kenya)')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCurrency = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedTimeZone,
                      decoration: InputDecoration(
                        labelText: 'Time Zone',
                        prefixIcon: const Icon(Icons.access_time_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'UTC+3 (EAT)', child: Text('UTC+3 (EAT)')),
                        DropdownMenuItem(value: 'UTC+0 (GMT)', child: Text('UTC+0 (GMT)')),
                        DropdownMenuItem(value: 'UTC+4 (GST)', child: Text('UTC+4 (GST)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTimeZone = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _employeeCount,
                      decoration: InputDecoration(
                        labelText: 'Employees',
                        prefixIcon: const Icon(Icons.people_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1-2')),
                        DropdownMenuItem(value: 4, child: Text('3-10')),
                        DropdownMenuItem(value: 15, child: Text('11-30')),
                        DropdownMenuItem(value: 50, child: Text('30+')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _employeeCount = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _branchCount,
                      decoration: InputDecoration(
                        labelText: 'Branches',
                        prefixIcon: const Icon(Icons.hub_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 Branch')),
                        DropdownMenuItem(value: 2, child: Text('2-5 Branches')),
                        DropdownMenuItem(value: 6, child: Text('6+ Branches')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _branchCount = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // STEP 6: REVIEW AND ACTIVATION
  // --------------------------------------------------------------------------
  Widget _buildStep6ReviewAndActivation(BusinessCategory cat) {
    final sub = ModuleRecommendationEngine.subcategories.firstWhere(
      (s) => s.id == _selectedSubcategoryId,
      orElse: () => ModuleRecommendationEngine.subcategories.first,
    );

    final estMonthly = _calculateEstimatedMonthlyPrice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroBanner(
          icon: Icons.rocket_launch_rounded,
          title: 'Review & Activate Setup',
          subtitle: 'Verify your customized Gashi suite before launching. You can change modules or settings anytime from the Settings page.',
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),

        // 1. Business Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F3F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6B7280)),
                    onPressed: () => setState(() => _currentStep = 5),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Image.asset(
                      _selectedLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.business_rounded),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.trim().isNotEmpty
                              ? _nameController.text.trim()
                              : 'My Gashi Business',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${cat.name} • ${sub.name}',
                          style: TextStyle(color: cat.color, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_selectedCity, $_selectedCountry • Currency: $_selectedCurrency',
                          style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Active Modules Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F3F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Management Modules (${_selectedModuleIds.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6B7280)),
                    onPressed: () => setState(() => _currentStep = 4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedModuleIds.map((modId) {
                  final m = ModuleRecommendationEngine.moduleCatalog.firstWhere(
                    (item) => item.id == modId,
                    orElse: () => ModuleRecommendationEngine.moduleCatalog.first,
                  );
                  final isRequired = _autoIncludedDependencies.containsKey(modId);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: m.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(m.icon, size: 14, color: m.color),
                        const SizedBox(width: 6),
                        Text(
                          m.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: m.color,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.lock_outline_rounded, size: 12, color: Colors.amber),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Add-ons Summary
        if (_selectedAddOnIds.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F3F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Add-ons (${_selectedAddOnIds.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6B7280)),
                      onPressed: () => setState(() => _currentStep = 4),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedAddOnIds.map((addonId) {
                    final a = ModuleRecommendationEngine.addOnCatalog.firstWhere(
                      (item) => item.id == addonId,
                      orElse: () => ModuleRecommendationEngine.addOnCatalog.first,
                    );
                    return Chip(
                      avatar: Icon(a.icon, size: 14, color: const Color(0xFFFF5200)),
                      label: Text(a.name, style: const TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFFFF7ED),
                      side: BorderSide(color: Colors.orange.shade200),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 4. Subscription & Pricing Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D2338), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Plan Total',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '\$${estMonthly.toStringAsFixed(2)} / month',
                    style: const TextStyle(
                      color: Color(0xFFFF5200),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(color: Colors.white24),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Includes free offline cache, cloud backup, and unlimited local receipts.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // BOTTOM NAVIGATION BAR (Back & Continue Buttons)
  // --------------------------------------------------------------------------
  Widget _buildBottomNavigationControls(BusinessCategory cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F3F6))),
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
            ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == _totalSteps ? const Color(0xFF10B981) : cat.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              if (_currentStep < _totalSteps) {
                setState(() {
                  _currentStep++;
                });
              } else {
                _completeOnboardingAndActivate();
              }
            },
            icon: Icon(
              _currentStep == _totalSteps ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              size: 18,
            ),
            label: Text(
              _currentStep == _totalSteps ? 'Activate Business' : 'Continue',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // REUSABLE HERO BANNER
  // --------------------------------------------------------------------------
  Widget _buildHeroBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

