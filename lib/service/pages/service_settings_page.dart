import 'package:flutter/material.dart';
import '../../business/business_settings_page.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_localizations.dart';
import 'service_services_page.dart';

// ============================================================================
// SERVICE SETTINGS PAGE (Matching Restaurant Settings & Theme)
// ============================================================================

class ServiceSettingsPage extends StatefulWidget {
  const ServiceSettingsPage({super.key});

  @override
  State<ServiceSettingsPage> createState() => _ServiceSettingsPageState();
}

class _ServiceSettingsPageState extends State<ServiceSettingsPage> {
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
                // Service Center Profile Hero Card
                _buildServiceProfileCard(),
                const SizedBox(height: 16),
                _buildBusinessSettingsCard(context),
                const SizedBox(height: 16),

                // Language Selector Card (English <-> Somali)
                _buildSectionTitle(context.tr('settings_language')),
                _buildLanguageCard(context),
                const SizedBox(height: 20),

                // Services Management Shortcut (Highlighted)
                _buildSectionTitle('Maamulka Adeegyada (Manage Services)'),
                _buildServicesManagementCard(context),
                const SizedBox(height: 20),

                // POS & Billing Settings
                _buildSectionTitle('Xisaabaadka & POS-ka (Billing & Rates)'),
                _buildBillingSettingsCard(),
                const SizedBox(height: 20),

                // Preferences & Hardware
                _buildSectionTitle('Dookhyada Guud (Preferences)'),
                _buildPreferencesCard(),
                const SizedBox(height: 20),

                // System & Cache
                _buildSectionTitle('Nidaamka & Kaydka (System)'),
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
            color: Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.business, color: Color(0xFF4F46E5), size: 24),
        ),
        title: Text(
          context.tr('business_settings_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
        ),
        subtitle: Text(
          context.tr('business_settings_desc'),
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF4F46E5)),
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

  Widget _buildServiceProfileCard() {
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
              color: const Color(0xFFEEF2FF),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/gashi_logo_indigo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/gashi_logo_indigo.jpeg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.build_circle,
                  color: Color(0xFF4F46E5),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xarunta Adeegyada Gashi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Laanta Dhexe - Hargeysa, Somaliland',
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
                      color: isSomali ? const Color(0xFFEEF2FF) : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSomali ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
                        width: isSomali ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: isSomali ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Af-Soomaali',
                          style: TextStyle(
                            fontWeight: isSomali ? FontWeight.bold : FontWeight.normal,
                            color: isSomali ? const Color(0xFF4F46E5) : const Color(0xFF1D2338),
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
                      color: !isSomali ? const Color(0xFFEEF2FF) : const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isSomali ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
                        width: !isSomali ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          !isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: !isSomali ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'English',
                          style: TextStyle(
                            fontWeight: !isSomali ? FontWeight.bold : FontWeight.normal,
                            color: !isSomali ? const Color(0xFF4F46E5) : const Color(0xFF1D2338),
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

  Widget _buildServicesManagementCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7D2FE)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.04),
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
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.miscellaneous_services_outlined, color: Color(0xFF4F46E5), size: 24),
          ),
          title: const Text(
            'Maamulka Adeegyada (Services Catalog)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
          ),
          subtitle: const Text(
            'Kala saar, fiiri qiimaha, farsamo-yaqaannada iyo muddooyinka',
            style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF4F46E5)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ServiceServicesPage(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lacagta Koowaad (Currency):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isDense: true,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                      DropdownMenuItem(value: 'SLSH', child: Text('SLSH (Slsh)')),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Heerka Cashuurta (Tax Rate):', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
              Text('${_taxRate.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sarifka SLSH/\$1 (Exchange Rate):', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
              Text('${_exchangeRate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} SLSH',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4F46E5))),
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
            title: const Text('Dhawaaqa Dalabka (Order Sound)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Dhawaaq marka dalabka la xaqiijiyo', style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _soundEnabled,
            activeThumbColor: const Color(0xFF4F46E5),
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Daabacaad Toos ah (Auto-print Receipt)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Daabac rasiidka marka lacagta la qabto', style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _autoPrintReceipt,
            activeThumbColor: const Color(0xFF4F46E5),
            onChanged: (val) => setState(() => _autoPrintReceipt = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
            title: const Text('Nooca Nidaamka (App Version)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Text('v2.4.0 (Build 12)', style: TextStyle(fontSize: 13, color: Color(0xFF8E99AF), fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFFEF4444)),
            title: const Text('Nadiifi Kaydka Kumeel-gaadhka ah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFEF4444))),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kaydka kumeel-gaadhka ah si guul leh ayaa loo nadiifiyay!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

