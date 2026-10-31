import 'package:flutter/material.dart';
import '../fake_data/restaurant_pos_data.dart';

// ============================================================================
// RESTAURANT MENU CONTROLLER (Multi-Menu Management & Toggles)
// ============================================================================
// Manages:
// - Different restaurant menus (Morning, Afternoon, Dinner, Drinks)
// - Enable / disable toggling of specific menus
// - Individual dish availability and management
// ============================================================================

class RestaurantMenuController extends ChangeNotifier {
  static final RestaurantMenuController instance =
      RestaurantMenuController._internal();

  RestaurantMenuController._internal() {
    _menuSections = List<RestaurantMenuSection>.from(sampleRestaurantMenuSections);
    _menuItems = List<RestaurantMenuItem>.from(sampleRestaurantMenuItems);
  }

  late List<RestaurantMenuSection> _menuSections;
  late List<RestaurantMenuItem> _menuItems;

  List<RestaurantMenuSection> get menuSections =>
      List.unmodifiable(_menuSections);

  List<RestaurantMenuItem> get menuItems => List.unmodifiable(_menuItems);

  // Returns only items belonging to menus that are currently ENABLED
  List<RestaurantMenuItem> get activeMenuItems {
    final enabledSectionIds = _menuSections
        .where((s) => s.isEnabled)
        .map((s) => s.id)
        .toSet();

    return _menuItems
        .where((item) =>
            enabledSectionIds.contains(item.menuSectionId) && item.isAvailable)
        .toList();
  }

  // Check if a specific menu section is enabled
  bool isMenuSectionEnabled(String sectionId) {
    try {
      return _menuSections.firstWhere((s) => s.id == sectionId).isEnabled;
    } catch (_) {
      return true;
    }
  }

  // Toggle a menu section (e.g., enable/disable Morning menu, Afternoon menu, etc.)
  void toggleMenuSection(String sectionId, bool isEnabled) {
    final index = _menuSections.indexWhere((s) => s.id == sectionId);
    if (index != -1) {
      _menuSections[index] =
          _menuSections[index].copyWith(isEnabled: isEnabled);
      notifyListeners();
    }
  }

  // Get items belonging to a specific section
  List<RestaurantMenuItem> getItemsForSection(String sectionId) {
    return _menuItems.where((item) => item.menuSectionId == sectionId).toList();
  }

  // Categories list
  List<String> get availableCategories {
    final categories = <String>{'Dhammaan'};
    for (final item in _menuItems) {
      if (item.category.isNotEmpty) {
        categories.add(item.category);
      }
    }
    return categories.toList();
  }

  // Toggle availability of an individual item
  void toggleItemAvailability(String itemId, bool isAvailable) {
    final index = _menuItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _menuItems[index] =
          _menuItems[index].copyWith(isAvailable: isAvailable);
      notifyListeners();
    }
  }

  // Add new menu item to a specific menu section
  void addMenuItem({
    required String name,
    required double price,
    required String category,
    required String imageUrl,
    String menuSectionId = 'afternoon',
    String? tag,
    String? note,
  }) {
    final newItem = RestaurantMenuItem(
      id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      price: price,
      category: category.trim().isEmpty ? 'Cuntooyinka' : category.trim(),
      menuSectionId: menuSectionId,
      imageUrl: imageUrl.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80'
          : imageUrl.trim(),
      tag: tag != null && tag.trim().isNotEmpty ? tag.trim() : null,
      note: note != null && note.trim().isNotEmpty ? note.trim() : null,
    );

    _menuItems.insert(0, newItem);
    notifyListeners();
  }

  void updateMenuItem(RestaurantMenuItem updatedItem) {
    final index = _menuItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _menuItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteMenuItem(String id) {
    _menuItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void resetToDefaults() {
    _menuSections = List<RestaurantMenuSection>.from(sampleRestaurantMenuSections);
    _menuItems = List<RestaurantMenuItem>.from(sampleRestaurantMenuItems);
    notifyListeners();
  }

  void clearAll() {
    _menuItems.clear();
    notifyListeners();
  }
}
