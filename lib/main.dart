import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'retail/retail_view.dart';
import 'pharmacy/pharmacy_view.dart';
import 'restaurant/restaurant_view.dart';
import 'service/service_view.dart';
import 'business/business_controller.dart';
import 'business/business_profile.dart';
import 'business/business_setup_view.dart';
import 'l10n/app_language.dart';
import 'l10n/app_localizations.dart';
import 'general_features/repository/gashi_repository.dart';
import 'general_features/onboarding/pages/dynamic_onboarding_wizard_page.dart';
import 'general_features/onboarding/pages/dynamic_business_dashboard_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BusinessController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'SME',
          debugShowCheckedModeBanner: false,
          locale: AppLanguage.instance.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            AppLocalizations.materialDelegate,
            AppLocalizations.cupertinoDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5200)),
            useMaterial3: true,
            fontFamily: 'Sora',
          ),
          home: const BusinessHome(),
        );
      },
    );
  }
}

/// Shows business setup until the owner has created a business, then opens
/// the pages for the business type they picked.
class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BusinessController.instance,
      builder: (context, _) {
        final profile = BusinessController.instance.profile;
        if (profile == null) return const BusinessSetupView();
        return switch (profile.type) {
          BusinessType.shop => const RetailView(),
          BusinessType.restaurant => const RestaurantView(),
          BusinessType.pharmacy => const PharmacyView(),
          BusinessType.serviceProvider => const ServiceView(),
        };
      },
    );
  }
}

/// Direct module selector and launcher for custom & demo industry suites
class ModuleSelectionView extends StatelessWidget {
  const ModuleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(
          context.tr('select_module'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 18, color: Color(0xFFFF5200)),
              label: Text(
                AppLanguage.instance.isSomali ? 'SO' : 'EN',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () {
                AppLanguage.instance.toggleLanguage();
              },
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: GashiRepository.instance,
        builder: (context, _) {
          final businesses = GashiRepository.instance.businesses;
          final customBusinesses = businesses.where((b) => b.id > 10).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Dynamic Business Onboarding Hero Card
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const DynamicOnboardingWizardPage(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D2338), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5200).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFF5200),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Smart Onboarding',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Custom business category, operations & dynamic module selection.',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),

              // Configured Custom Businesses (if any exist)
              if (customBusinesses.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Ganacsiyadaada Diyaarka ah (Configured Businesses)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                ...customBusinesses.map((b) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: b.businessType.softBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: b.logoUrl.isNotEmpty
                            ? Image.asset(b.logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(b.businessType.icon, color: b.businessType.primaryColor))
                            : Icon(b.businessType.icon, color: b.businessType.primaryColor),
                      ),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text('${b.categoryName} • ${b.activeModules.length} Active Modules'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => DynamicBusinessDashboardView(business: b),
                        ),
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Demo Industry Suites (Tijaabada Hore)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1F3F6)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.storefront, color: Colors.deepPurple, size: 28),
                  title: Text(context.tr('retail'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(context.tr('retail_subtitle')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RetailView(),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1F3F6)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.local_pharmacy, color: Colors.teal, size: 28),
                  title: Text(context.tr('pharmacy'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(context.tr('pharmacy_subtitle')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const PharmacyView(),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1F3F6)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                  title: Text(context.tr('restaurant'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(context.tr('restaurant_subtitle')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RestaurantView(),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFF1F3F6)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/gashi_logo_indigo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/gashi_logo_indigo.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Text(context.tr('services_module'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(context.tr('services_module_subtitle')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ServiceView(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
