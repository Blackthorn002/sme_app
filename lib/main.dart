import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'retail/retail_view.dart';
import 'pharmacy/pharmacy_view.dart';
import 'restaurant/restaurant_view.dart';
import 'service/service_view.dart';
import 'l10n/app_language.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          ),
          home: const ModuleSelectionView(),
        );
      },
    );
  }
}

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
          // Quick Language Toggle in Module Selector
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
      ),
    );
  }
}
