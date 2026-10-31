import 'package:flutter/material.dart';
import 'package:sme/l10n/app_language.dart';
import 'package:sme/general_features/models/gashi_models.dart';
import 'package:sme/general_features/onboarding/models/onboarding_models.dart';
import 'package:sme/general_features/pages/general_pos_page.dart';
import 'package:sme/general_features/pages/general_inventory_page.dart';
import 'package:sme/general_features/pages/general_sales_page.dart';
import 'package:sme/general_features/pages/general_credits_page.dart';
import 'package:sme/general_features/pages/general_settings_page.dart';
import 'package:sme/restaurant/pages/restaurant_menu_page.dart';
import 'package:sme/pharmacy/medical_records/patient_medical_records_page.dart';
import 'package:sme/service/pages/service_services_page.dart';
import 'dynamic_onboarding_wizard_page.dart';

// ============================================================================
// DYNAMIC PERSONALIZED BUSINESS DASHBOARD VIEW
// Renders strictly according to customer's activated modules
// ============================================================================

class DynamicBusinessDashboardView extends StatefulWidget {
  final Business business;
  final BusinessConfig? config;

  const DynamicBusinessDashboardView({
    super.key,
    required this.business,
    this.config,
  });

  @override
  State<DynamicBusinessDashboardView> createState() =>
      _DynamicBusinessDashboardViewState();
}

class _DynamicTabItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget widget;

  const _DynamicTabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.widget,
  });
}

class _DynamicBusinessDashboardViewState
    extends State<DynamicBusinessDashboardView> {
  int _currentIndex = 0;
  late List<_DynamicTabItem> _tabs;

  @override
  void initState() {
    super.initState();
    _buildTabs();
  }

  void _buildTabs() {
    final activeModules = widget.business.activeModules;
    final List<_DynamicTabItem> items = [];

    // 1. Home / Overview
    items.add(
      _DynamicTabItem(
        id: 'overview',
        label: 'Home',
        icon: Icons.home_filled,
        widget: _buildOverviewTab(),
      ),
    );

    // 2. POS Module (if activated)
    if (activeModules.contains('pos')) {
      items.add(
        _DynamicTabItem(
          id: 'pos',
          label: 'POS',
          icon: Icons.point_of_sale_rounded,
          widget: GeneralPosPage(
            businessId: widget.business.id,
            businessType: widget.business.businessType,
          ),
        ),
      );
    }

    // 3. Inventory Module (if activated)
    if (activeModules.contains('inventory')) {
      items.add(
        _DynamicTabItem(
          id: 'inventory',
          label: 'Kaydka',
          icon: Icons.inventory_2_outlined,
          widget: GeneralInventoryPage(
            businessId: widget.business.id,
            businessType: widget.business.businessType,
          ),
        ),
      );
    }

    // 4. Restaurant Tables & Menu (if Restaurant Management activated)
    if (activeModules.contains('restaurant_management')) {
      items.add(
        const _DynamicTabItem(
          id: 'restaurant_menu',
          label: 'Menu',
          icon: Icons.restaurant_menu_rounded,
          widget: RestaurantMenuPage(),
        ),
      );
    }

    // 5. Pharmacy Prescriptions & Patient Batches (if Pharmacy Management activated)
    if (activeModules.contains('pharmacy_management')) {
      items.add(
        const _DynamicTabItem(
          id: 'pharmacy_records',
          label: 'Dhakhtar',
          icon: Icons.medical_services_outlined,
          widget: PatientMedicalRecordsPage(),
        ),
      );
    }

    // 6. Service Jobs & Bookings (if Service Management activated)
    if (activeModules.contains('service_management')) {
      items.add(
        const _DynamicTabItem(
          id: 'services',
          label: 'Adeegyo',
          icon: Icons.build_circle_outlined,
          widget: ServiceServicesPage(),
        ),
      );
    }

    // 7. Sales & Orders History (if POS or CRM or Accounting activated)
    if (activeModules.contains('pos') || activeModules.contains('accounting')) {
      items.add(
        _DynamicTabItem(
          id: 'sales',
          label: 'Iibka',
          icon: Icons.receipt_long_outlined,
          widget: GeneralSalesPage(
            businessId: widget.business.id,
            businessType: widget.business.businessType,
          ),
        ),
      );
    }

    // 8. Credits & Debts (if CRM or Loan or Credit sales activated)
    if (activeModules.contains('crm') ||
        activeModules.contains('loan') ||
        widget.business.operations.contains('manage_customer_debts') ||
        widget.business.operations.contains('sell_on_credit')) {
      items.add(
        _DynamicTabItem(
          id: 'credits',
          label: 'Deyn',
          icon: Icons.people_outline_rounded,
          widget: GeneralCreditsPage(
            businessId: widget.business.id,
            businessType: widget.business.businessType,
          ),
        ),
      );
    }

    // 9. General Settings Tab
    items.add(
      _DynamicTabItem(
        id: 'settings',
        label: 'Hagaajinta',
        icon: Icons.settings_outlined,
        widget: GeneralSettingsPage(
          businessId: widget.business.id,
          businessType: widget.business.businessType,
        ),
      ),
    );

    _tabs = items;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.business.businessType.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: widget.business.logoUrl.isNotEmpty
                ? Image.asset(
                    widget.business.logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.storefront, color: themeColor),
                  )
                : Icon(Icons.storefront, color: themeColor),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.business.name,
              style: const TextStyle(
                color: Color(0xFF1D2338),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${widget.business.subcategoryName} • ${widget.business.city}',
              style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reconfigure Setup',
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF6B7280), size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DynamicOnboardingWizardPage(),
                ),
              );
            },
          ),
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
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs.map((t) => t.widget).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: themeColor,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: _tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final themeColor = widget.business.businessType.primaryColor;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized Welcome Hero Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, themeColor.withValues(alpha: 0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.business.categoryName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kusoo Dhawoow, ${widget.business.name}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Habkaaga gaarka ah ee Gashi wuxuu shaqada ku bilaabay ${widget.business.activeModules.length} module oo gaar kuu ah.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Active Modules Badges Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Qaybahaaga Firfircoon (Active Modules)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2338),
                ),
              ),
              Text(
                '${widget.business.activeModules.length} Active',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.business.activeModules.map((modCode) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F3F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: themeColor),
                    const SizedBox(width: 6),
                    Text(
                      modCode.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Quick Shortcuts Grid
          const Text(
            'Ficillada Degdegga ah (Quick Actions)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2338),
            ),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              if (widget.business.activeModules.contains('pos'))
                _buildQuickActionCard(
                  icon: Icons.point_of_sale_rounded,
                  title: 'Furo POS-ka',
                  subtitle: 'Iibi hadda',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    final posIndex = _tabs.indexWhere((t) => t.id == 'pos');
                    if (posIndex != -1) setState(() => _currentIndex = posIndex);
                  },
                ),
              if (widget.business.activeModules.contains('inventory'))
                _buildQuickActionCard(
                  icon: Icons.add_box_outlined,
                  title: 'Ku Dar Alaab',
                  subtitle: 'Kayd cusub',
                  color: const Color(0xFF0284C7),
                  onTap: () {
                    final invIndex = _tabs.indexWhere((t) => t.id == 'inventory');
                    if (invIndex != -1) setState(() => _currentIndex = invIndex);
                  },
                ),
              if (widget.business.activeModules.contains('restaurant_management'))
                _buildQuickActionCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Maamul Menuga',
                  subtitle: 'Cuntooyinka',
                  color: const Color(0xFFFF5200),
                  onTap: () {
                    final rIndex = _tabs.indexWhere((t) => t.id == 'restaurant_menu');
                    if (rIndex != -1) setState(() => _currentIndex = rIndex);
                  },
                ),
              if (widget.business.activeModules.contains('pharmacy_management'))
                _buildQuickActionCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Warqadaha Dhakhtarka',
                  subtitle: 'Bukhaanka',
                  color: const Color(0xFFEF4444),
                  onTap: () {
                    final pIndex = _tabs.indexWhere((t) => t.id == 'pharmacy_records');
                    if (pIndex != -1) setState(() => _currentIndex = pIndex);
                  },
                ),
              _buildQuickActionCard(
                icon: Icons.receipt_long_rounded,
                title: 'Warbixinta Iibka',
                subtitle: 'Dalabaadka maanta',
                color: const Color(0xFF6366F1),
                onTap: () {
                  final salesIndex = _tabs.indexWhere((t) => t.id == 'sales');
                  if (salesIndex != -1) setState(() => _currentIndex = salesIndex);
                },
              ),
              _buildQuickActionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Deymaha Macaamiisha',
                subtitle: 'Liiska deymaha',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  final credIndex = _tabs.indexWhere((t) => t.id == 'credits');
                  if (credIndex != -1) setState(() => _currentIndex = credIndex);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Business Details Summary Card
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
                const Text(
                  'Faahfaahinta Ganacsiga (Configuration)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Lacagta (Currency):', widget.business.currency),
                _buildDetailRow('Magaalada (City):', widget.business.city),
                _buildDetailRow('Dalka (Country):', widget.business.country),
                _buildDetailRow('Shaqaalaha (Employees):', '${widget.business.employeeCount} Staff'),
                _buildDetailRow('Laamaha (Branches):', '${widget.business.branchCount} Branch'),
                if (widget.business.phone.isNotEmpty)
                  _buildDetailRow('Telefoonka (Phone):', widget.business.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F3F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8E99AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
        ],
      ),
    );
  }
}

