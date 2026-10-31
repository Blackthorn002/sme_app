import 'package:flutter/material.dart';
import '../business/business_controller.dart';
import '../business/business_profile.dart';
import '../business/business_settings_page.dart';
import '../general_features/models/gashi_models.dart' as gashi_models;
import '../general_features/pages/general_credits_page.dart';
import '../general_features/pages/general_inventory_page.dart';
import '../general_features/pages/general_pos_page.dart';
import '../general_features/pages/general_sales_page.dart';
import '../general_features/repository/gashi_repository.dart';
import '../general_features/services/currency_service.dart';
import '../l10n/app_localizations.dart';
import 'fake_data/retail_dashboard_data.dart';

// ============================================================================
// RETAIL MAIN VIEW WIDGET
// ============================================================================

class RetailView extends StatefulWidget {
  final RetailHeaderData headerData;
  final RetailBannerData bannerData;
  final List<RetailMetricItem> metricsData;
  final List<RetailQuickAction> quickActionsData;
  final List<RetailOrderItem> ordersData;

  const RetailView({
    super.key,
    this.headerData = sampleRetailHeader,
    this.bannerData = sampleRetailBanner,
    this.metricsData = sampleRetailMetrics,
    this.quickActionsData = sampleRetailQuickActions,
    this.ordersData = sampleRetailOrders,
  });

  @override
  State<RetailView> createState() => _RetailViewState();
}

class _RetailViewState extends State<RetailView> {
  BusinessModule _currentModule = BusinessModule.home;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.headerData.currencies.first;
  }

  void _goTo(BusinessModule module) {
    if (!BusinessController.instance.modulesFor(BusinessType.shop).contains(module)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('module_disabled'))),
      );
      return;
    }
    setState(() => _currentModule = module);
  }

  Widget _buildModulePage(
    BusinessModule module,
    String businessName,
    GashiRepository repo,
    int businessId,
  ) {
    return switch (module) {
      BusinessModule.pos => const GeneralPosPage(
          businessId: 2,
          businessType: gashi_models.BusinessType.retail,
        ),
      BusinessModule.inventory => const GeneralInventoryPage(
          businessId: 2,
          businessType: gashi_models.BusinessType.retail,
        ),
      BusinessModule.credits => const GeneralCreditsPage(
          businessId: 2,
          businessType: gashi_models.BusinessType.retail,
        ),
      BusinessModule.sales => const GeneralSalesPage(
          businessId: 2,
          businessType: gashi_models.BusinessType.retail,
        ),
      BusinessModule.more => const BusinessSettingsPage(),
      _ => _buildDashboardPage(businessName, repo, businessId),
    };
  }

  BottomNavigationBarItem _buildNavItem(BusinessModule module) {
    return switch (module) {
      BusinessModule.pos => const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'POS'),
      BusinessModule.inventory => const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Kaydka'),
      BusinessModule.credits => const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Credits'),
      BusinessModule.more => const BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      _ => const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        BusinessController.instance,
        GashiRepository.instance,
        CurrencyService.instance,
      ]),
      builder: (context, _) {
        final repo = GashiRepository.instance;
        final business = repo.getBusinessByType(gashi_models.BusinessType.retail);
        final businessId = business?.id ?? 2;
        final businessName = BusinessController.instance.profile?.name ??
            business?.name ??
            widget.headerData.appName;

        final modules = BusinessController.instance.modulesFor(BusinessType.shop);
        final currentIndex =
            modules.contains(_currentModule) ? modules.indexOf(_currentModule) : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          body: SafeArea(
            child: IndexedStack(
              index: currentIndex,
              children: [
                for (final module in modules)
                  KeyedSubtree(
                    key: ValueKey(module),
                    child: _buildModulePage(module, businessName, repo, businessId),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                _currentModule = modules[index];
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF10B981), // Green Theme
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [for (final module in modules) _buildNavItem(module)],
          ),
        );
      },
    );
  }

  void _navigateToKey(String key) {
    switch (key) {
      case 'pos':
        _goTo(BusinessModule.pos);
        break;
      case 'inventory':
        _goTo(BusinessModule.inventory);
        break;
      case 'credits':
        _goTo(BusinessModule.credits);
        break;
      case 'sales':
        _goTo(BusinessModule.sales);
        break;
      case 'settings':
        _goTo(BusinessModule.more);
        break;
      default:
        _goTo(BusinessModule.home);
    }
  }

  Widget _buildDashboardPage(String businessName, GashiRepository repo, int businessId) {
    final showMetrics = repo.isBusinessFeatureEnabled(businessId, 'metrics');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildTopHeader(businessName),
          const SizedBox(height: 16),

          // Green Hero Banner Card
          _buildHeroBanner(businessName),
          const SizedBox(height: 16),

          // 2x2 Metric Cards Grid
          if (showMetrics) ...[
            _buildMetricsGrid(),
            const SizedBox(height: 20),
          ],

          // Quick Actions Section ("Degdegsiimo")
          _buildQuickActionsSection(repo, businessId),
          const SizedBox(height: 20),

          // Recent Orders Section ("Dalabadki u dambeyay")
          _buildRecentOrdersSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTopHeader(String businessName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Logo + Name
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/gashi_logo_green.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/gashi_logo.jpeg',
                  color: const Color(0xFF10B981),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                    height: 1.1,
                  ),
                ),
                Text(
                  widget.headerData.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E99AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Currency Switcher & Notifications
        Row(
          children: [
            // Pill Container
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: widget.headerData.currencies
                    .map((code) => _buildCurrencyOption(code))
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),

            // Notification Bell with Red Dot
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF1D2338),
                    size: 26,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyOption(String code) {
    final isSelected = _selectedCurrency == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          code,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF1D2338) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(String businessName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)], // Green gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 12,
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
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.bannerData.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Gashi Logo Graphic (White alpha overlay)
          Image.asset(
            'assets/gashi_logo_green.png',
            width: 60,
            height: 60,
            color: Colors.white.withValues(alpha: 0.4),
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.storefront,
              size: 60,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = widget.metricsData;
    if (metrics.length < 4) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(metrics[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(metrics[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(metrics[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(metrics[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(RetailMetricItem metric) {
    final isSalesMetric = metric.label.contains('Iibka');
    return GestureDetector(
      onTap: isSalesMetric
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const GeneralSalesPage(
                    businessId: 2,
                    businessType: gashi_models.BusinessType.retail,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSalesMetric
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : const Color(0xFFF1F3F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: metric.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(metric.icon, color: metric.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ],
              ),
            ),
            if (isSalesMetric)
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(GashiRepository repo, int businessId) {
    final List<_RetailQuickActionMapping> actionMappings = [
      if (repo.isBusinessFeatureEnabled(businessId, 'pos') && widget.quickActionsData.isNotEmpty)
        _RetailQuickActionMapping(
          key: 'pos',
          action: widget.quickActionsData[0],
        ),
      if (repo.isBusinessFeatureEnabled(businessId, 'inventory') && widget.quickActionsData.length > 1)
        _RetailQuickActionMapping(
          key: 'inventory',
          action: widget.quickActionsData[1],
        ),
      if (repo.isBusinessFeatureEnabled(businessId, 'credits') && widget.quickActionsData.length > 2)
        _RetailQuickActionMapping(
          key: 'credits',
          action: widget.quickActionsData[2],
        ),
    ];

    if (actionMappings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Degdegsiimo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2338),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actionMappings.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mapping = actionMappings[index];
              final action = mapping.action;
              final isPrimary = action.isPrimary;

              return GestureDetector(
onTap: () => _navigateToKey(mapping.key),
                child: isPrimary
                    ? Container(
                        width: 96,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green primary
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(action.icon, color: Colors.white, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              action.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: 96,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F3F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(action.icon, color: const Color(0xFF10B981), size: 28),
                            const SizedBox(height: 10),
                            Text(
                              action.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF1D2338),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection() {
    final orders = widget.ordersData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dalabadki u dambeyay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2338),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const GeneralSalesPage(
                      businessId: 2,
                      businessType: gashi_models.BusinessType.retail,
                    ),
                  ),
                );
              },
              child: Row(
                children: const [
                  Text(
                    'Eeg Dhamaan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Order List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = orders[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const GeneralSalesPage(
                      businessId: 2,
                      businessType: gashi_models.BusinessType.retail,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F3F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Order ID & Time Column
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circle Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.icon,
                      color: const Color(0xFF4B5563),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Order Type Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '\$${order.price.toStringAsFixed(order.price.truncateToDouble() == order.price ? 0 : 2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: order.statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.statusText,
                      ),
                    ),
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
}



class _RetailQuickActionMapping {
  final String key;
  final RetailQuickAction action;

  const _RetailQuickActionMapping({
    required this.key,
    required this.action,
  });
}
