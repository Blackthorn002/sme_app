import 'package:flutter/material.dart';
import '../fake_data/restaurant_pos_data.dart';

class RestaurantMenuController extends ChangeNotifier {
  static final RestaurantMenuController instance = RestaurantMenuController._internal();

  RestaurantMenuController._internal() {
    // Start with the initial sample items
    _menuItems = List<RestaurantMenuItem>.from(sampleRestaurantMenuItems);
  }

  late List<RestaurantMenuItem> _menuItems;

  List<RestaurantMenuItem> get menuItems => List.unmodifiable(_menuItems);

  List<String> get availableCategories {
    final categories = <String>{'Dhammaan'};
    for (final item in _menuItems) {
      if (item.category.isNotEmpty) {
        categories.add(item.category);
      }
    }
    return categories.toList();
  }

  void addMenuItem({
    required String name,
    required double price,
    required String category,
    required String imageUrl,
    String? tag,
    String? note,
  }) {
    final newItem = RestaurantMenuItem(
      id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      price: price,
      category: category.trim().isEmpty ? 'Cuntooyinka' : category.trim(),
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
    _menuItems = List<RestaurantMenuItem>.from(sampleRestaurantMenuItems);
    notifyListeners();
  }

  void clearAll() {
    _menuItems.clear();
    notifyListeners();
  }
}

