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
