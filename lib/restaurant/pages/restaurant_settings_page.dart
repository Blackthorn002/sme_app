import 'package:flutter/material.dart';
import '../../business/business_settings_page.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_localizations.dart';
import 'restaurant_menu_page.dart';

class RestaurantSettingsPage extends StatefulWidget {
  const RestaurantSettingsPage({super.key});

  @override
  State<RestaurantSettingsPage> createState() => _RestaurantSettingsPageState();
}

class _RestaurantSettingsPageState extends State<RestaurantSettingsPage> {
  String _selectedCurrency = 'USD';
  final double _taxRate = 5.0;
  final double _exchangeRate = 8500.0;
  bool _soundEnabled = true;
  bool _autoPrintReceipt = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('settings_title'),
                  style: const TextStyle(
                    color: Color(0xFF1D2338),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  context.tr('settings_subtitle'),
                  style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Profile Hero Card
                _buildRestaurantProfileCard(),
                const SizedBox(height: 16),
                _buildBusinessSettingsCard(context),
                const SizedBox(height: 16),

                // Language Selector Card (English <-> Somali)
                _buildSectionTitle(context.tr('settings_language')),
                _buildLanguageCard(context),
                const SizedBox(height: 20),

                // Menu Management Shortcut (Highlighted)
                _buildSectionTitle('Maamulka Cuntooyinka'),
                _buildMenuManagementCard(context),
                const SizedBox(height: 20),

                // POS & Billing Settings
                _buildSectionTitle('Xisaabaadka & POS-ka'),
                _buildBillingSettingsCard(),
                const SizedBox(height: 20),

                // Preferences & Hardware
                _buildSectionTitle('Dookhyada Guud'),
                _buildPreferencesCard(),
                const SizedBox(height: 20),

                // System & Cache
                _buildSectionTitle('Nidaamka & Kaydka'),
                _buildSystemCard(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildBusinessSettingsCard(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F3F6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFFF5200).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.business, color: Color(0xFFFF5200), size: 24),
        ),
        title: Text(
          context.tr('business_settings_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
        ),
        subtitle: Text(
          context.tr('business_settings_desc'),
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF5200)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const BusinessSettingsPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildRestaurantProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFFFF3EB),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/gashi_logo_orange.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.restaurant,
                color: Color(0xFFFF5200),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Makhaayadda Gashi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Laanta 1 - Hargeysa, Somaliland',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E99AF),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Furan (Active)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    final isSomali = AppLanguage.instance.isSomali;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('settings_language_desc'),
            style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => AppLanguage.instance.setSomali(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSomali ? const Color(0xFFFFF3EB) : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSomali ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
                        width: isSomali ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: isSomali ? const Color(0xFFFF5200) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Af-Soomaali',
                          style: TextStyle(
                            fontWeight: isSomali ? FontWeight.bold : FontWeight.normal,
                            color: isSomali ? const Color(0xFFFF5200) : const Color(0xFF1D2338),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => AppLanguage.instance.setEnglish(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: !isSomali ? const Color(0xFFFFF3EB) : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isSomali ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
                        width: !isSomali ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          !isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: !isSomali ? const Color(0xFFFF5200) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'English',
                          style: TextStyle(
                            fontWeight: !isSomali ? FontWeight.bold : FontWeight.normal,
                            color: !isSomali ? const Color(0xFFFF5200) : const Color(0xFF1D2338),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuManagementCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD8BF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5200).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu, color: Color(0xFFFF5200), size: 24),
        ),
        title: Text(
          context.tr('settings_menu_management'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
        ),
        subtitle: Text(
          context.tr('settings_menu_management_desc'),
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF5200)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const RestaurantMenuPage(),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildBillingSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          // Currency Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lacagta Koowaad (Currency):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                      DropdownMenuItem(value: 'SLSH', child: Text('SLSH (Shilling)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Tax Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Canshuurta (Tax Rate):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)),
              ),
              Text(
                '${_taxRate.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5200), fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24),

          // Exchange Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sarifka (1 USD = SLSH):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)),
              ),
              Text(
                '${_exchangeRate.toStringAsFixed(0)} SLSH',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2338), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            activeThumbColor: const Color(0xFFFF5200),
            title: const Text('Dhawaaqa Dalabka (Order Sound)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Dhawaaq samee markii dalab la xaqiijiyo', style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _soundEnabled,
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            activeThumbColor: const Color(0xFFFF5200),
            title: const Text('Si toos ah u daabac (Auto Print)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Rasiidka toos u daabac markii la bixiyo', style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _autoPrintReceipt,
            onChanged: (val) => setState(() => _autoPrintReceipt = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F3F6)),
        ),
        child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFF4B5563)),
            title: Text(context.tr('settings_clear_cache'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Nadiifi sawirrada ku kaydsan telefoonka', style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('settings_cache_cleared')),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF4B5563)),
            title: Text(context.tr('settings_about'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(context.tr('settings_version'), style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gashi Restaurant POS',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Gashi SME Business Suite',
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}
