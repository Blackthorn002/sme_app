import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../../l10n/app_localizations.dart';
import '../fake_data/restaurant_pos_data.dart';
import '../services/restaurant_menu_controller.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Dhammaan';

  // Preset food image URLs for quick selection when creating dishes
  static const List<Map<String, String>> _presetImages = [
    {
      'title': 'Bariis & Hilib',
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
      'title': 'Sambusa',
      'url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Sharaab / Cabitaan',
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
      animation: RestaurantMenuController.instance,
      builder: (context, _) {
        final allItems = RestaurantMenuController.instance.menuItems;
        final categories = RestaurantMenuController.instance.availableCategories;

        final filteredItems = allItems.where((item) {
          final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.tag?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          final matchesCat = _selectedCategory == 'Dhammaan' || item.category == _selectedCategory;
          return matchesSearch && matchesCat;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1D2338)),
              onPressed: () => Navigator.maybePop(context),
            ),
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
                  '${allItems.length} cunto ayaa diiwaangashan',
                  style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
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
                onPressed: () => _openCreateMenuModal(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Notice banner: Only created menus are used in POS
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD8BF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFFF5200), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('only_created_menus_note'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A3412),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
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
                            hintText: context.tr('pos_search_hint'),
                            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                        ),
                    ],
                  ),
                ),
              ),

              // Categories row
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: const Color(0xFFFF5200),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 6),

              // Menu Items List
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('no_menu_items'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5200),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _openCreateMenuModal(context),
                              icon: const Icon(Icons.add),
                              label: Text(context.tr('add_new_menu_item')),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cached Image
                                AppCachedImage(
                                  imageUrl: item.imageUrl,
                                  width: 72,
                                  height: 72,
                                  borderRadius: BorderRadius.circular(12),
                                  loadingColor: const Color(0xFFFF5200),
                                ),
                                const SizedBox(width: 12),

                                // Food Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1D2338),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '\$${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF5200),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Category + Tag Badges
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.category,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF4B5563),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (item.tag != null && item.tag!.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3EB),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.tag!,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFFF5200),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      if (item.note != null && item.note!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          item.note!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF8E99AF),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Action Buttons (Edit / Delete)
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6B7280)),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(6),
                                      onPressed: () => _openEditMenuModal(context, item),
                                    ),
                                    const SizedBox(height: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(6),
                                      onPressed: () => _confirmDelete(context, item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFFF5200),
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.add),
            label: Text(
              context.tr('add_new_menu_item'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openCreateMenuModal(context),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, RestaurantMenuItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.tr('delete_menu_item')),
        content: Text('${dialogCtx.tr('delete_menu_confirm')}\n\n"${item.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(dialogCtx.tr('cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              RestaurantMenuController.instance.deleteMenuItem(item.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('menu_item_deleted')),
                  backgroundColor: const Color(0xFF1D2338),
                ),
              );
            },
            child: Text(dialogCtx.tr('delete')),
          ),
        ],
      ),
    );
  }

  void _openCreateMenuModal(BuildContext context) {
    _showItemFormModal(context: context);
  }

  void _openEditMenuModal(BuildContext context, RestaurantMenuItem item) {
    _showItemFormModal(context: context, existingItem: item);
  }

  void _showItemFormModal({
    required BuildContext context,
    RestaurantMenuItem? existingItem,
  }) {
    final isEditing = existingItem != null;
    final nameCtrl = TextEditingController(text: existingItem?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existingItem != null ? existingItem.price.toStringAsFixed(2) : '',
    );
    final tagCtrl = TextEditingController(text: existingItem?.tag ?? '');
    final noteCtrl = TextEditingController(text: existingItem?.note ?? '');
    final imageCtrl = TextEditingController(text: existingItem?.imageUrl ?? '');
    String selectedCategory = existingItem?.category ?? 'Cuntooyinka';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing
                              ? modalCtx.tr('edit_menu_item')
                              : modalCtx.tr('add_new_menu_item'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Food Name
                    Text(
                      modalCtx.tr('item_name'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: modalCtx.tr('item_name_hint'),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Price & Category Row
                    Row(
                      children: [
                        // Price
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modalCtx.tr('item_price'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: modalCtx.tr('item_price_hint'),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Category Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modalCtx.tr('item_category'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: 'Cuntooyinka', child: Text('Cuntooyinka')),
                                      DropdownMenuItem(value: 'Cabitaan', child: Text('Cabitaan')),
                                      DropdownMenuItem(value: 'Quraac', child: Text('Quraac')),
                                      DropdownMenuItem(value: 'Kharash', child: Text('Kharash')),
                                      DropdownMenuItem(value: 'Macmacaan', child: Text('Macmacaan')),
                                    ],
                                    onChanged: (newVal) {
                                      if (newVal != null) {
                                        setModalState(() => selectedCategory = newVal);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tag and Note
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modalCtx.tr('item_tag'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: tagCtrl,
                                decoration: InputDecoration(
                                  hintText: modalCtx.tr('item_tag_hint'),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modalCtx.tr('item_note'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: noteCtrl,
                                decoration: InputDecoration(
                                  hintText: modalCtx.tr('item_note_hint'),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Image URL Input & Presets
                    Text(
                      modalCtx.tr('item_image_url'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: imageCtrl,
                      decoration: InputDecoration(
                        hintText: modalCtx.tr('item_image_url_hint'),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      modalCtx.tr('select_preset_image'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetImages.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final p = _presetImages[i];
                          final isPicked = imageCtrl.text == p['url'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                imageCtrl.text = p['url']!;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPicked ? const Color(0xFFFFF3EB) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isPicked ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
                                  width: isPicked ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AppCachedImage(
                                    imageUrl: p['url']!,
                                    width: 34,
                                    height: 34,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    p['title']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isPicked ? FontWeight.bold : FontWeight.normal,
                                      color: isPicked ? const Color(0xFFFF5200) : const Color(0xFF1D2338),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Save / Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5200),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fadlan geli magaca cuntada!')),
                            );
                            return;
                          }

                          final price = double.tryParse(priceCtrl.text) ?? 5.0;
                          final img = imageCtrl.text.trim().isNotEmpty
                              ? imageCtrl.text.trim()
                              : _presetImages.first['url']!;

                          if (isEditing) {
                            final updated = RestaurantMenuItem(
                              id: existingItem.id,
                              name: name,
                              price: price,
                              category: selectedCategory,
                              imageUrl: img,
                              tag: tagCtrl.text.trim().isNotEmpty ? tagCtrl.text.trim() : null,
                              note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                            );
                            RestaurantMenuController.instance.updateMenuItem(updated);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('menu_item_updated')),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          } else {
                            RestaurantMenuController.instance.addMenuItem(
                              name: name,
                              price: price,
                              category: selectedCategory,
                              imageUrl: img,
                              tag: tagCtrl.text,
                              note: noteCtrl.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('menu_item_created')),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }

                          Navigator.pop(modalCtx);
                        },
                        child: Text(
                          isEditing ? modalCtx.tr('save') : modalCtx.tr('add_new_menu_item'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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
