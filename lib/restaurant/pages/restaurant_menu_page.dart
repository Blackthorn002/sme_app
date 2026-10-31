import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../../general_features/services/currency_service.dart';
import '../../l10n/app_localizations.dart';
import '../fake_data/restaurant_pos_data.dart';
import '../services/restaurant_menu_controller.dart';

// ============================================================================
// RESTAURANT MULTI-MENU MANAGEMENT PAGE
// Supports:
// - Seeing different restaurant menus (Morning, Afternoon, Dinner, Drinks)
// - Enabling and disabling specific menus (e.g. morning menu, afternoon menu)
// - Real-time sync with POS: disabled menus are automatically hidden/locked in POS
// - Adding, editing, and toggling dishes within each menu
// ============================================================================

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSectionId = 'morning'; // 'morning', 'afternoon', 'dinner', 'drinks'

  // Preset food images for quick selection
  static const List<Map<String, String>> _presetImages = [
    {
      'title': 'Canjeero & Beer',
      'url': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Bariis & Hilib Geel',
      'url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Digaag & Bariis',
      'url': 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Baasto Saldaata',
      'url': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Suqaar & Chapati',
      'url': 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Maraq & Hilib',
      'url': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Sambusa Hilib',
      'url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Caano Geel / Sharaab',
      'url': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Shaah Somali',
      'url': 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        RestaurantMenuController.instance,
        CurrencyService.instance,
      ]),
      builder: (context, _) {
        final controller = RestaurantMenuController.instance;
        final sections = controller.menuSections;
        final currentSection = sections.firstWhere(
          (s) => s.id == _selectedSectionId,
          orElse: () => sections.first,
        );

        final sectionItems = controller.getItemsForSection(currentSection.id);
        final filteredItems = sectionItems.where((item) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = item.name.toLowerCase().contains(query) ||
              (item.tag?.toLowerCase().contains(query) ?? false) ||
              (item.note?.toLowerCase().contains(query) ?? false);
          return matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: Color(0xFF1D2338)),
                    onPressed: () => Navigator.maybePop(context),
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('menu_page_title'),
                  style: const TextStyle(
                    color: Color(0xFF1D2338),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${sections.length} menu oo kala duwan • ${controller.activeMenuItems.length} cunto furan POS-ka',
                  style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 11),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ku dar Cunto Cusub',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                onPressed: () => _openCreateMenuModal(context, currentSection.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // 1. Menu Sections Switcher Pills (Morning, Afternoon, Dinner, Drinks)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: sections.map((section) {
                      final isSelected = _selectedSectionId == section.id;
                      final isEnabled = section.isEnabled;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSectionId = section.id;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF5200)
                                  : (isEnabled
                                      ? const Color(0xFFF3F4F6)
                                      : const Color(0xFFFEE2E2)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFF5200)
                                    : (isEnabled
                                        ? const Color(0xFFE5E7EB)
                                        : const Color(0xFFFECACA)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  section.icon,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : (isEnabled
                                          ? const Color(0xFF4B5563)
                                          : const Color(0xFFDC2626)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  section.somaliTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isEnabled
                                            ? const Color(0xFF1D2338)
                                            : const Color(0xFFDC2626)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isEnabled
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 2. Active Menu Status & Enable/Disable Toggle Card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: currentSection.isEnabled
                        ? const Color(0xFFFFD8BF)
                        : const Color(0xFFFECACA),
                    width: 1.5,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: currentSection.isEnabled
                            ? const Color(0xFFFFF7F2)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        currentSection.icon,
                        color: currentSection.isEnabled
                            ? currentSection.color
                            : const Color(0xFFDC2626),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                currentSection.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2338),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${currentSection.timeRange} • ${sectionItems.length} cunto',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF8E99AF)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: currentSection.isEnabled
                                  ? const Color(0xFFE6F7F0)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentSection.isEnabled
                                  ? '🟢 Menu-gu Waa Furan Yahay (Active in POS)'
                                  : '🔴 Menu-gu Waa La Damiyay (Disabled in POS)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: currentSection.isEnabled
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Main Toggle Switch for this Menu
                    Column(
                      children: [
                        Switch(
                          value: currentSection.isEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFFFF5200),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFF9CA3AF),
                          onChanged: (val) {
                            controller.toggleMenuSection(currentSection.id, val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val
                                    ? '${currentSection.somaliTitle} hadda waa la furay (Available in POS)!'
                                    : '${currentSection.somaliTitle} hadda waa la damiyay (Hidden from POS)!'),
                                backgroundColor: val
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFDC2626),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        Text(
                          currentSection.isEnabled ? 'Daaran' : 'Daran',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: currentSection.isEnabled
                                ? const Color(0xFFFF5200)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Raadi cunto ku jirta ${currentSection.somaliTitle}...',
                            hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close,
                              size: 18, color: Color(0xFF9CA3AF)),
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Dishes List for Selected Menu
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Ma jiro cunto ku jirta ${currentSection.somaliTitle}.',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6B7280)),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5200),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('Ku dar Cunto ${currentSection.somaliTitle}'),
                              onPressed: () =>
                                  _openCreateMenuModal(context, currentSection.id),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isMenuDisabled = !currentSection.isEnabled;

                          return Opacity(
                            opacity: isMenuDisabled ? 0.6 : (item.isAvailable ? 1.0 : 0.65),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isMenuDisabled
                                      ? const Color(0xFFFECACA)
                                      : const Color(0xFFF1F3F6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppCachedImage(
                                    imageUrl: item.imageUrl,
                                    width: 76,
                                    height: 76,
                                    borderRadius: BorderRadius.circular(12),
                                    loadingColor: const Color(0xFFFF5200),
                                    fallbackIcon: Icons.restaurant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D2338),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              CurrencyService.instance.format(item.price),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF5200),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                currentSection.somaliTitle,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF4B5563),
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            if (item.tag != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFF4ED),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item.tag!,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFFFF5200),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            if (isMenuDisabled)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEE2E2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Menu-gu waa xidhan yahay',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFFDC2626),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (item.note != null &&
                                            item.note!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.note!,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Edit & Delete actions
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: 'Wax ka beddel',
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18, color: Color(0xFF6B7280)),
                                        onPressed: () => _openEditMenuModal(
                                            context, item, currentSection.id),
                                      ),
                                      IconButton(
                                        tooltip: 'Tirtir cuntadan',
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Color(0xFFEF4444)),
                                        onPressed: () {
                                          controller.deleteMenuItem(item.id);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Cuntada ${item.name} waa la tirtiray!'),
                                              backgroundColor:
                                                  const Color(0xFFEF4444),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Create Menu Modal
  void _openCreateMenuModal(BuildContext context, String defaultSectionId) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedSection = defaultSectionId;
    String selectedImage = _presetImages.first['url']!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setMState) {
            final sections = RestaurantMenuController.instance.menuSections;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ku dar Cunto Cusub',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text('Dooro Menu-ga ay ka tirsan tahay:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: sections.map((s) {
                        final isSel = selectedSection == s.id;
                        return ChoiceChip(
                          label: Text(s.somaliTitle),
                          selected: isSel,
                          selectedColor: const Color(0xFFFF5200),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setMState(() => selectedSection = s.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    const Text('Magaca Cuntada:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tusaale: Bariis iyo Hilib Geel',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Qiimaha (\$ USD):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Tusaale: 7.50',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Sawirka Cuntada (Dooro):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetImages.length,
                        separatorBuilder: (c, i) => const SizedBox(width: 8),
                        itemBuilder: (c, i) {
                          final img = _presetImages[i];
                          final isSel = selectedImage == img['url'];
                          return GestureDetector(
                            onTap: () =>
                                setMState(() => selectedImage = img['url']!),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFFFF5200)
                                      : const Color(0xFFE5E7EB),
                                  width: isSel ? 3 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(img['url']!,
                                    fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Calaamad Gaar ah (Tag - Ikhtiyaari):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: tagCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tusaale: Caanka ah, Kulul, Fresh',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Faahfaahin Dheeraad ah (Note):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Xog ku saabsan sida loo diyaariyo...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5200),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text) ?? 0.0;
                          if (name.isEmpty || price <= 0) return;

                          RestaurantMenuController.instance.addMenuItem(
                            name: name,
                            price: price,
                            category: selectedSection == 'drinks'
                                ? 'Cabitaan'
                                : (selectedSection == 'morning'
                                    ? 'Quraac'
                                    : (selectedSection == 'dinner'
                                        ? 'Casho'
                                        : 'Cuntooyinka')),
                            imageUrl: selectedImage,
                            menuSectionId: selectedSection,
                            tag: tagCtrl.text.trim().isNotEmpty
                                ? tagCtrl.text.trim()
                                : null,
                            note: noteCtrl.text.trim().isNotEmpty
                                ? noteCtrl.text.trim()
                                : null,
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cuntada $name si guul leh ayaa loogu daray menu-ga!'),
                              backgroundColor: const Color(0xFFFF5200),
                            ),
                          );
                        },
                        child: const Text('Keydi Cuntada (Save Food)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Edit Menu Modal
  void _openEditMenuModal(
      BuildContext context, RestaurantMenuItem item, String sectionId) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(2));
    final tagCtrl = TextEditingController(text: item.tag ?? '');
    final noteCtrl = TextEditingController(text: item.note ?? '');
    String selectedSection = item.menuSectionId;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setEState) {
            final sections = RestaurantMenuController.instance.menuSections;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wax Ka Beddel: ${item.name}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text('Menu-ga ay ka tirsan tahay:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: sections.map((s) {
                        final isSel = selectedSection == s.id;
                        return ChoiceChip(
                          label: Text(s.somaliTitle),
                          selected: isSel,
                          selectedColor: const Color(0xFFFF5200),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setEState(() => selectedSection = s.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    const Text('Magaca Cuntada:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Qiimaha (\$ USD):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Calaamad (Tag):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: tagCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text('Faahfaahin (Note):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5200),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text) ?? 0.0;
                          if (name.isEmpty || price <= 0) return;

                          final updated = item.copyWith(
                            name: name,
                            price: price,
                            menuSectionId: selectedSection,
                            tag: tagCtrl.text.trim().isNotEmpty
                                ? tagCtrl.text.trim()
                                : null,
                            note: noteCtrl.text.trim().isNotEmpty
                                ? noteCtrl.text.trim()
                                : null,
                          );

                          RestaurantMenuController.instance.updateMenuItem(updated);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cuntada $name waa la cusboonaysiiyay!'),
                              backgroundColor: const Color(0xFFFF5200),
                            ),
                          );
                        },
                        child: const Text('Keydi Isbeddelka',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
