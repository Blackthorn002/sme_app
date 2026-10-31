import 'package:flutter/material.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_localizations.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../services/currency_service.dart';

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
  bool _soundEnabled = true;
  bool _autoPrintReceipt = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.businessType.primaryColor;

    return AnimatedBuilder(
      animation: Listenable.merge([
        AppLanguage.instance,
        GashiRepository.instance,
        CurrencyService.instance,
      ]),
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

                // Feature Modules / Screen Toggles
                _buildSectionTitle('Habaynta Qaybaha & Shaashadaha (Feature Toggles)'),
                _buildFeatureTogglesCard(business, repo, themeColor),
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
      child: Column(
        children: [
          Row(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2338),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showEditBusinessNameDialog(business, themeColor),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.edit_outlined, size: 18, color: themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Laan 1 • Nooca: ${business.businessType.name.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E99AF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        Text(
                          '1 USD = ${CurrencyService.instance.dailyExchangeRate.toStringAsFixed(0)} SLSh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F3F6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF8E99AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Magaca iyo qaybaha aad halkan ku habayso waxay toos uga muuqanayaan shaashadaha dukaankaaga.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTogglesCard(
      Business business, GashiRepository repo, Color themeColor) {
    final List<_FeatureItemConfig> featureConfigs = _getFeaturesForBusinessType(widget.businessType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Qaybaha Shaqada (Modules)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1D2338),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${featureConfigs.where((f) => business.isFeatureEnabled(f.key)).length} Firfircoon',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featureConfigs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
            itemBuilder: (context, index) {
              final item = featureConfigs[index];
              final isEnabled = business.isFeatureEnabled(item.key);

              return SwitchListTile(
                value: isEnabled,
                activeThumbColor: themeColor,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? themeColor.withValues(alpha: 0.12)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: isEnabled ? themeColor : const Color(0xFF9CA3AF),
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? const Color(0xFF1D2338) : const Color(0xFF9CA3AF),
                  ),
                ),
                subtitle: Text(
                  item.description,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                ),
                onChanged: (val) {
                  repo.toggleBusinessFeature(business.id, item.key, val);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<_FeatureItemConfig> _getFeaturesForBusinessType(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return const [
          _FeatureItemConfig(
            key: 'pos',
            title: 'POS / Dalab Cusub',
            description: 'Dalab-qaadashada miisaska, safaariga iyo takeaway-ga',
            icon: Icons.restaurant,
          ),
          _FeatureItemConfig(
            key: 'sales',
            title: 'Diiwaanka Iibka',
            description: 'Taariikhda lacag-bixinta, rasiidhada iyo dakhliga',
            icon: Icons.receipt_long_outlined,
          ),
          _FeatureItemConfig(
            key: 'menus',
            title: 'Maamulka Menu-yada',
            description: 'Kala doorashada menu subax, galab, caweys & cabitaano',
            icon: Icons.menu_book_outlined,
          ),
          _FeatureItemConfig(
            key: 'credits',
            title: 'Deymaha Macaamiisha',
            description: 'Diiwaanka gashiga, waqtiga bixinta & fariimaha xasuusinta',
            icon: Icons.people_outline,
          ),
          _FeatureItemConfig(
            key: 'orders',
            title: 'Dalabaadkii u Dambeeyay',
            description: 'Liiska dalabaadka miisaska ee shaashadda koowaad',
            icon: Icons.list_alt,
          ),
          _FeatureItemConfig(
            key: 'metrics',
            title: 'Kaadhadhka Xisaabta Maanta',
            description: 'Guud-mar degdeg ah ee dakhliga iyo macaamiisha maanta',
            icon: Icons.analytics_outlined,
          ),
        ];
      case BusinessType.pharmacy:
        return const [
          _FeatureItemConfig(
            key: 'pos',
            title: 'POS-ka Daawooyinka',
            description: 'Iibka degdegga ah iyo rasiidhada daawada',
            icon: Icons.local_pharmacy_outlined,
          ),
          _FeatureItemConfig(
            key: 'sales',
            title: 'Diiwaanka Iibka',
            description: 'Taariikhda iibka daawooyinka iyo lacag-qabashada',
            icon: Icons.receipt_long_outlined,
          ),
          _FeatureItemConfig(
            key: 'inventory',
            title: 'Kaydka Daawooyinka',
            description: 'Tirakoobka daawada iyo taariikhda dhicitaanka',
            icon: Icons.inventory_2_outlined,
          ),
          _FeatureItemConfig(
            key: 'credits',
            title: 'Deymaha Macaamiisha',
            description: 'Diiwaanka gashiga bukaanada iyo fariimaha xasuusinta',
            icon: Icons.people_outline,
          ),
          _FeatureItemConfig(
            key: 'medical_records',
            title: 'Diiwaanka Bukaanada & Refill',
            description: 'Bukaanada cudurada joogtada ah & dib-u-buuxinta (Refill)',
            icon: Icons.medical_information_outlined,
          ),
          _FeatureItemConfig(
            key: 'metrics',
            title: 'Kaadhadhka Xisaabta Maanta',
            description: 'Dakhliga maanta iyo tirada daawooyinka la iibiyay',
            icon: Icons.analytics_outlined,
          ),
        ];
      case BusinessType.service:
        return const [
          _FeatureItemConfig(
            key: 'pos',
            title: 'POS-ka Shaqada Cusub',
            description: 'Furista shaqooyinka dayactirka iyo adeeg bixinta',
            icon: Icons.point_of_sale,
          ),
          _FeatureItemConfig(
            key: 'sales',
            title: 'Diiwaanka Iibka',
            description: 'Warbixinta lacagaha shaqooyinka laga qabtay',
            icon: Icons.receipt_long_outlined,
          ),
          _FeatureItemConfig(
            key: 'services',
            title: 'Adeegyada & Shaqooyinka Socda',
            description: 'Liiska adeegyada la qabto iyo kormeerka shaqooyinka',
            icon: Icons.handyman_outlined,
          ),
          _FeatureItemConfig(
            key: 'credits',
            title: 'Deymaha Macaamiisha',
            description: 'Lacagaha hadhay iyo xasuusinta gashiga dayactirka',
            icon: Icons.people_outline,
          ),
          _FeatureItemConfig(
            key: 'metrics',
            title: 'Kaadhadhka Xisaabta Maanta',
            description: 'Dakhliga guud iyo tirada shaqooyinka dhameystirmay',
            icon: Icons.analytics_outlined,
          ),
        ];
      case BusinessType.retail:
      case BusinessType.barbershop:
        return const [
          _FeatureItemConfig(
            key: 'pos',
            title: 'POS-ka Iibka Dukaanka',
            description: 'Iibinta alaabta dukaanka iyo qaadashada lacagaha',
            icon: Icons.shopping_bag_outlined,
          ),
          _FeatureItemConfig(
            key: 'sales',
            title: 'Diiwaanka Iibka',
            description: 'Warbixinta iyo taariikhda iibka dukaanka',
            icon: Icons.receipt_long_outlined,
          ),
          _FeatureItemConfig(
            key: 'inventory',
            title: 'Kaydka Alaabta',
            description: 'Tirakoobka bakhaarka, alaabta yaraatay iyo soo iibsiga',
            icon: Icons.inventory_2_outlined,
          ),
          _FeatureItemConfig(
            key: 'credits',
            title: 'Deymaha & Gashiga',
            description: 'Lacagaha dibadda kaga maqan dukaanka iyo xasuusinta',
            icon: Icons.people_outline,
          ),
          _FeatureItemConfig(
            key: 'metrics',
            title: 'Kaadhadhka Xisaabta Maanta',
            description: 'Dakhliga maanta, faa\'iidada iyo tirada iibka',
            icon: Icons.analytics_outlined,
          ),
        ];
    }
  }

  void _showEditBusinessNameDialog(Business business, Color themeColor) {
    final controller = TextEditingController(text: business.name);
    final suggestions = _getNameSuggestions(business.businessType);

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.storefront, color: themeColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Magaca Ganacsiga',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gali magaca dhabta ah ee ganacsigaaga si uu uga muuqdo rasiidhada iyo shaashadda guud:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Magaca Ganacsiga',
                    hintText: 'Tusaale: Makhaayadda Hilaac',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Talooyin Magacyo (Suggestions):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8E99AF)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: suggestions.map((name) {
                    return ActionChip(
                      backgroundColor: const Color(0xFFF1F3F6),
                      label: Text(
                        name,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1D2338)),
                      ),
                      onPressed: () {
                        controller.text = name;
                        setDialogState(() {});
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Jooji', style: TextStyle(color: Color(0xFF8E99AF))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  GashiRepository.instance.updateBusinessName(business.id, newName);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Magaca ganacsiga waxa loo beddelay: "$newName"'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: const Text('Badbaadi'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getNameSuggestions(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return const [
          'Makhaayadda Xamdi',
          'Sultan Cafe & Grill',
          'Hilaac Fastfood',
          'Kulan Restaurant & Lounge',
        ];
      case BusinessType.pharmacy:
        return const [
          'Farmashiyaha Shaafi',
          'Al-Najax Pharmacy',
          'Barwaaqo Drugstore',
          'Shifo Health & Pharma',
        ];
      case BusinessType.retail:
        return const [
          'Dukaanka Guuleed',
          'Tawakal Supermarket',
          'Hodan Mini Market',
          'Tarsan Electronics & Retail',
        ];
      case BusinessType.barbershop:
        return const [
          'Saloonka Quruxda',
          'Modern Barber & Spa',
          'VIP Barbershop',
          'Classic Hair & Style',
        ];
      case BusinessType.service:
        return const [
          'Garaashka Daacad',
          'Xarunta Dayactirka Casriga',
          'Al-Amiin Tech Repair',
          'Smart Service Center',
        ];
    }
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
          InkWell(
            onTap: () => _showDailyExchangeRateDialog(themeColor),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sarifka Maanta (Daily Exchange Rate):',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '1 USD = ${CurrencyService.instance.dailyExchangeRate.toStringAsFixed(0)} SLSh (Dynamic Variable)',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${CurrencyService.instance.dailyExchangeRate.toStringAsFixed(0)} SLSh',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDailyExchangeRateDialog(Color themeColor) {
    final ctrl = TextEditingController(
      text: CurrencyService.instance.dailyExchangeRate.toStringAsFixed(0),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Beddel Sarifka Maanta (Exchange Rate)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gali sicirka sarifka Shilin Soomaaliga / Somaliland Shilling ee maanta (1 USD):',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Sicirka (SLSh)',
                suffixText: 'SLSh',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sicirro Degdeg Ah (Quick Presets):',
              style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [8400.0, 8500.0, 8600.0, 8700.0].map((rate) {
                return ActionChip(
                  label: Text('${rate.toInt()} SLSh'),
                  onPressed: () => ctrl.text = rate.toInt().toString(),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Jooji', style: TextStyle(color: Color(0xFF8E99AF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newRate = double.tryParse(ctrl.text.trim());
              if (newRate != null && newRate > 0) {
                CurrencyService.instance.updateExchangeRate(newRate);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sarifka maanta waxa loo cusboonaysiiyay 1 USD = ${newRate.toStringAsFixed(0)} SLSh'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Cusboonaysii'),
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

class _FeatureItemConfig {
  final String key;
  final String title;
  final String description;
  final IconData icon;

  const _FeatureItemConfig({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });
}

