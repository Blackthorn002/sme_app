import 'package:flutter/material.dart';
import '../fake_data/service_pos_data.dart';

class ServiceController extends ChangeNotifier {
  static final ServiceController instance = ServiceController._internal();

  ServiceController._internal() {
    _services = List<ServiceItem>.from(sampleServiceItems);
  }

  late List<ServiceItem> _services;

  List<ServiceItem> get services => List.unmodifiable(_services);

  List<String> get availableCategories {
    final categories = <String>{'Dhammaan'};
    for (final item in _services) {
      if (item.category.isNotEmpty) {
        categories.add(item.category);
      }
    }
    return categories.toList();
  }

  void addService({
    required String name,
    required double price,
    required String duration,
    required String category,
    required String imageUrl,
    String? technician,
    String? tag,
    String? note,
  }) {
    final newService = ServiceItem(
      id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      price: price,
      duration: duration.trim().isEmpty ? '30 daqiiqo' : duration.trim(),
      category: category.trim().isEmpty ? 'Farsamo & IT' : category.trim(),
      imageUrl: imageUrl.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=400&q=80'
          : imageUrl.trim(),
      technician: technician != null && technician.trim().isNotEmpty ? technician.trim() : null,
      tag: tag != null && tag.trim().isNotEmpty ? tag.trim() : null,
      note: note != null && note.trim().isNotEmpty ? note.trim() : null,
    );

    _services.insert(0, newService);
    notifyListeners();
  }

  void updateService(ServiceItem updatedItem) {
    final index = _services.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _services[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteService(String id) {
    _services.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void resetToDefaults() {
    _services = List<ServiceItem>.from(sampleServiceItems);
    notifyListeners();
  }
}

