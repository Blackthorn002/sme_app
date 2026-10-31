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
    String duration = '30 daqiiqo',
    required String category,
    String imageUrl = '',
    String? technician,
    String? tag,
    String? note,
    Map<String, dynamic>? customAttributes,
  }) {
    final attributes = Map<String, dynamic>.from(customAttributes ?? {});
    final cleanDuration = duration.trim().isEmpty ? '30 daqiiqo' : duration.trim();
    final cleanCategory = category.trim().isEmpty ? 'Farsamo & IT' : category.trim();
    final cleanImage = imageUrl.trim().isEmpty
        ? 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=400&q=80'
        : imageUrl.trim();

    if (!attributes.containsKey('duration') && cleanDuration.isNotEmpty) {
      attributes['duration'] = cleanDuration;
    }
    if (!attributes.containsKey('technician') && technician != null && technician.trim().isNotEmpty) {
      attributes['technician'] = technician.trim();
    }
    if (!attributes.containsKey('note') && note != null && note.trim().isNotEmpty) {
      attributes['note'] = note.trim();
    }
    if (!attributes.containsKey('tag') && tag != null && tag.trim().isNotEmpty) {
      attributes['tag'] = tag.trim();
    }

    final newService = ServiceItem(
      id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      price: price,
      duration: cleanDuration,
      category: cleanCategory,
      imageUrl: cleanImage,
      technician: technician != null && technician.trim().isNotEmpty ? technician.trim() : null,
      tag: tag != null && tag.trim().isNotEmpty ? tag.trim() : null,
      note: note != null && note.trim().isNotEmpty ? note.trim() : null,
      customAttributes: attributes,
    );

    _services.insert(0, newService);
    notifyListeners();
  }

  void updateService(ServiceItem updatedItem) {
    final index = _services.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      // Ensure custom attributes has duration and technician
      final resolvedAttrs = updatedItem.resolvedCustomAttributes;
      final enriched = ServiceItem(
        id: updatedItem.id,
        name: updatedItem.name,
        price: updatedItem.price,
        duration: updatedItem.duration,
        category: updatedItem.category,
        imageUrl: updatedItem.imageUrl,
        technician: updatedItem.technician,
        tag: updatedItem.tag,
        note: updatedItem.note,
        customAttributes: resolvedAttrs,
      );
      _services[index] = enriched;
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

