import 'package:flutter/material.dart';
import '../business/business_controller.dart';
import '../business/business_profile.dart';
import '../business/business_settings_page.dart';
import '../general_features/models/gashi_models.dart' as gashi_models;
import '../general_features/pages/general_credits_page.dart';
import '../general_features/pages/general_sales_page.dart';
import '../general_features/repository/gashi_repository.dart';
import '../general_features/services/currency_service.dart';
import '../l10n/app_localizations.dart';
import 'pages/restaurant_pos_page.dart';
import 'pages/restaurant_menu_page.dart';
import 'fake_data/restaurant_dashboard_data.dart';

// ============================================================================
// RESTAURANT MAIN VIEW WIDGET
// ============================================================================

class RestaurantView extends StatefulWidget {
  final RestaurantHeaderData headerData;
  final RestaurantBannerData bannerData;
  final List<RestaurantMetricItem> metricsData;
  final List<RestaurantQuickAction> quickActionsData;
  final List<RestaurantOrderItem> ordersData;

  const RestaurantView({
    super.key,
    this.headerData = sampleRestaurantHeader,
    this.bannerData = sampleRestaurantBanner,
    this.metricsData = sampleRestaurantMetrics,
    this.quickActionsData = sampleRestaurantQuickActions,
    this.ordersData = sampleRestaurantOrders,
  });

  @override
  State<RestaurantView> createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  BusinessModule _currentModule = BusinessModule.home;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.headerData.currencies.first;
  }

  void _goTo(BusinessModule module) {
    if (!BusinessController.instance.modulesFor(BusinessType.restaurant).contains(module)) {
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
      BusinessModule.pos => const RestaurantPosPage(),
      BusinessModule.sales => const GeneralSalesPage(
          businessId: 3,
          businessType: gashi_models.BusinessType.restaurant,
        ),
      BusinessModule.credits => const GeneralCreditsPage(
          businessId: 3,
          businessType: gashi_models.BusinessType.restaurant,
        ),
      BusinessModule.more => const BusinessSettingsPage(),
      _ => _buildDashboardPage(businessName, repo, businessId),
    };
  }

  BottomNavigationBarItem _buildNavItem(BusinessModule module) {
    return switch (module) {
      BusinessModule.pos => const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'POS'),
      BusinessModule.sales => const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Sales'),
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
        final business = repo.getBusinessByType(gashi_models.BusinessType.restaurant);
        final businessId = business?.id ?? 3;
        final businessName = BusinessController.instance.profile?.name ??
            business?.name ??
            widget.headerData.appName;

        final modules = BusinessController.instance.modulesFor(BusinessType.restaurant);
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
            selectedItemColor: const Color(0xFFFF5200),
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
      case 'sales':
        _goTo(BusinessModule.sales);
        break;
      case 'menus':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const RestaurantMenuPage(),
          ),
        );
        break;
      case 'credits':
        _goTo(BusinessModule.credits);
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
    final showOrders = repo.isBusinessFeatureEnabled(businessId, 'orders');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildTopHeader(businessName),
          const SizedBox(height: 16),

          // Orange Hero Banner Card
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
          if (showOrders) ...[
            _buildRecentOrdersSection(),
            const SizedBox(height: 16),
          ],
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
                'assets/gashi_logo_orange.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/gashi_logo.jpeg',
                  color: const Color(0xFFFF5200),
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
          colors: [Color(0xFFFF5200), Color(0xFFFF7A00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5200).withValues(alpha: 0.25),
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
            'assets/gashi_logo_orange.png',
            width: 60,
            height: 60,
            color: Colors.white.withValues(alpha: 0.4),
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.restaurant,
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

  Widget _buildMetricCard(RestaurantMetricItem metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(GashiRepository repo, int businessId) {
    final List<_QuickActionMapping> actionMappings = [
      if (repo.isBusinessFeatureEnabled(businessId, 'pos') && widget.quickActionsData.isNotEmpty)
        _QuickActionMapping(
          key: 'pos',
          action: widget.quickActionsData[0],
        ),
      if (repo.isBusinessFeatureEnabled(businessId, 'sales') && widget.quickActionsData.length > 1)
        _QuickActionMapping(
          key: 'sales',
          action: widget.quickActionsData[1],
        ),
      if (repo.isBusinessFeatureEnabled(businessId, 'credits') && widget.quickActionsData.length > 2)
        _QuickActionMapping(
          key: 'credits',
          action: widget.quickActionsData[2],
        ),
      if (repo.isBusinessFeatureEnabled(businessId, 'menus') && widget.quickActionsData.length > 3)
        _QuickActionMapping(
          key: 'menus',
          action: widget.quickActionsData[3],
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
                          color: const Color(0xFFFF5200),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5200).withValues(alpha: 0.25),
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
                            Icon(action.icon, color: const Color(0xFFFF5200), size: 28),
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
                _goTo(BusinessModule.sales);
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
              onTap: () => _goTo(BusinessModule.sales),
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



class _QuickActionMapping {
  final String key;
  final RestaurantQuickAction action;

  const _QuickActionMapping({
    required this.key,
    required this.action,
  });
}
