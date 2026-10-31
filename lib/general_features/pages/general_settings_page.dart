import 'package:flutter/material.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_localizations.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../onboarding/pages/dynamic_onboarding_wizard_page.dart';
import '../onboarding/engine/module_recommendation_engine.dart';

// ============================================================================
// GENERAL SETTINGS PAGE (Configurable Across All Business Types)
// ============================================================================

class GeneralSettingsPage extends StatefulWidget {
  final int businessId;
  final BusinessType businessType;

  const GeneralSettingsPage({
    super.key,
    required this.businessId,
    required this.businessType,
  });

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  String _selectedCurrency = 'USD';
  final double _exchangeRate = 8500.0;
  bool _soundEnabled = true;
  bool _autoPrintReceipt = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.businessType.primaryColor;

    return AnimatedBuilder(
      animation: Listenable.merge([AppLanguage.instance, GashiRepository.instance]),
      builder: (context, _) {
        final repo = GashiRepository.instance;
        final business = repo.getBusinessByType(widget.businessType) ??
            Business(
              id: widget.businessId,
              name: '${widget.businessType.name.toUpperCase()} Business',
              businessType: widget.businessType,
              createdAt: DateTime.now(),
            );

        final fieldDefs = repo.getFieldDefinitions(
            widget.businessType.name, 'inventory');

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
                // Business Profile Hero
                _buildProfileCard(business, themeColor),
                const SizedBox(height: 16),

                // Dynamic Onboarding & Modules Card
                _buildSectionTitle('Qaybaha Firfircoon & Onboarding (Modules & Setup)'),
                _buildModuleManagementCard(context, business, repo, themeColor),
                const SizedBox(height: 20),

                // Offline & Cloud Sync Card
                _buildSectionTitle('Nidaamka Offline-ka & Sync-ga (Cloud Sync)'),
                _buildSyncManagerCard(repo, themeColor),
                const SizedBox(height: 20),

                // Dynamic Column Engine Shortcut Card
                _buildSectionTitle('Habaynta Tiirarka Dukaanka (Dynamic Columns)'),
                _buildDynamicColumnsCard(fieldDefs, themeColor),
                const SizedBox(height: 20),

                // Language Selector Card (English <-> Somali)
                _buildSectionTitle(context.tr('settings_language')),
                _buildLanguageCard(context, themeColor),
                const SizedBox(height: 20),

                // POS & Billing Settings
                _buildSectionTitle('Xisaabaadka & POS-ka (Billing & Rates)'),
                _buildBillingSettingsCard(business, themeColor),
                const SizedBox(height: 20),

                // General Preferences
                _buildSectionTitle('Dookhyada Guud (Preferences)'),
                _buildPreferencesCard(themeColor),
                const SizedBox(height: 20),

                // System & Cache
                _buildSectionTitle('Nidaamka & Kaydka (System)'),
                _buildSystemCard(context, business),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
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

  Widget _buildProfileCard(Business business, Color themeColor) {
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
              color: widget.businessType.softBgColor,
            ),
            child: Icon(widget.businessType.icon, color: themeColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Branch 1 • Type: ${business.businessType.name.toUpperCase()}',
                  style: const TextStyle(
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
                    'Active (Furan)',
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

  Widget _buildModuleManagementCard(
      BuildContext context, Business business, GashiRepository repo, Color themeColor) {
    final activeModules = repo.getEntitledModules(business.id);

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5200).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFFFF5200), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xulashada Qaybaha (Active Modules)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${activeModules.length} Modules Authorized',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: activeModules.map((m) {
              final name = ModuleRecommendationEngine.getModuleName(m);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2338),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const DynamicOnboardingWizardPage(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFFF5200)),
              label: const Text(
                'Bilow Onboarding Cusub (Reconfigure Suite)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncManagerCard(GashiRepository repo, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            activeThumbColor: themeColor,
            title: Text(
              repo.isOnline ? 'Network: Online Mode' : 'Network: Offline Mode',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              repo.isOnline
                  ? 'All changes sync directly to cloud database'
                  : 'Changes are safely stored locally on device',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
            ),
            value: repo.isOnline,
            onChanged: (_) => repo.toggleConnectivity(),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Sync Queue',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
                    const SizedBox(height: 2),
                    Text(
                      '${repo.pendingSyncCount} changes waiting',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: repo.isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(repo.isSyncing ? 'Syncing...' : 'Sync Now'),
                  onPressed: repo.pendingSyncCount == 0 || repo.isSyncing || !repo.isOnline
                      ? null
                      : () => repo.syncPendingData(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicColumnsCard(
      List<BusinessFieldDefinition> fieldDefs, Color themeColor) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Columns (${fieldDefs.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Stored in PostgreSQL custom_attributes',
                style: TextStyle(fontSize: 10, color: themeColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: fieldDefs.map((def) {
              return Chip(
                backgroundColor: widget.businessType.softBgColor,
                side: BorderSide(color: themeColor.withValues(alpha: 0.3)),
                label: Text(
                  '${def.fieldLabel} (${def.fieldType})',
                  style: TextStyle(fontSize: 11, color: themeColor, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, Color themeColor) {
    final isSomali = AppLanguage.instance.isSomali;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => AppLanguage.instance.setSomali(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSomali ? widget.businessType.softBgColor : const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSomali ? themeColor : const Color(0xFFE5E7EB),
                    width: isSomali ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: isSomali ? themeColor : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Af-Soomaali',
                      style: TextStyle(
                        fontWeight: isSomali ? FontWeight.bold : FontWeight.normal,
                        color: isSomali ? themeColor : const Color(0xFF1D2338),
                        fontSize: 13,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSomali ? widget.businessType.softBgColor : const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !isSomali ? themeColor : const Color(0xFFE5E7EB),
                    width: !isSomali ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !isSomali ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: !isSomali ? themeColor : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'English',
                      style: TextStyle(
                        fontWeight: !isSomali ? FontWeight.bold : FontWeight.normal,
                        color: !isSomali ? themeColor : const Color(0xFF1D2338),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSettingsCard(Business business, Color themeColor) {
    final taxRate = business.taxRate;

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
              const Text('Primary Currency:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              DropdownButtonHideUnderline(
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
            ],
          ),
          const Divider(height: 20),
          InkWell(
            onTap: () => _showTaxRateDialog(business, themeColor),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Business Tax Rate:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        taxRate == 0.0
                            ? '0% Tax (No tax applied at POS)'
                            : '${taxRate.toStringAsFixed(1)}% applied on subtotal',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: taxRate == 0.0
                              ? const Color(0xFFF3F4F6)
                              : themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          taxRate == 0.0 ? '0.0% (No Tax)' : '${taxRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: taxRate == 0.0 ? const Color(0xFF6B7280) : themeColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exchange Rate (1 USD):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${_exchangeRate.toStringAsFixed(0)} SLSH',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaxRateDialog(Business business, Color themeColor) {
    final ctrl = TextEditingController(text: business.taxRate.toStringAsFixed(0));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Tax Rate (%)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set tax rate for this business. If set to 0%, no tax will be added to sales.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [0.0, 5.0, 10.0].map((rate) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text('${rate.toStringAsFixed(0)}%'),
                    onPressed: () {
                      GashiRepository.instance.updateBusinessTaxRate(business.id, rate);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Custom Tax Rate (%)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final parsed = double.tryParse(ctrl.text.trim()) ?? 0.0;
              GashiRepository.instance.updateBusinessTaxRate(business.id, parsed.clamp(0.0, 100.0));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            activeThumbColor: themeColor,
            title: const Text('Order & Scanner Beep',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Play sound on POS actions',
                style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _soundEnabled,
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            activeThumbColor: themeColor,
            title: const Text('Auto-print Receipt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Automatically print receipt on payment',
                style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
            value: _autoPrintReceipt,
            onChanged: (val) => setState(() => _autoPrintReceipt = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, Business business) {
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
              leading: const Icon(Icons.cleaning_services_outlined,
                  color: Color(0xFF4B5563)),
              title: const Text('Clear Image Cache',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Free up local storage on device',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                PaintingBinding.instance.imageCache.clear();
                PaintingBinding.instance.imageCache.clearLiveImages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF4B5563)),
              title: const Text('About Gashi Platform',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Multi-tenant SME Business Suite v1.0.0',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: business.name,
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 Gashi Platform Production Engine',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

