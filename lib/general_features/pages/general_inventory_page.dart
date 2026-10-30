import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../widgets/offline_sync_banner.dart';
import '../widgets/pos_camera_capture_sheet.dart';

// ============================================================================
// GENERAL INVENTORY PAGE (Conforming to PostgreSQL Schema & Dynamic Customization)
// ============================================================================

class GeneralInventoryPage extends StatefulWidget {
  final int businessId;
  final BusinessType businessType;

  const GeneralInventoryPage({
    super.key,
    required this.businessId,
    required this.businessType,
  });

  @override
  State<GeneralInventoryPage> createState() => _GeneralInventoryPageState();
}

class _GeneralInventoryPageState extends State<GeneralInventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Dhammaan';
  bool _filterLowStockOnly = false;
  final double _exchangeRate = 8500.0;
  PosCapturedPhoto? _capturedPhoto;

  static const List<String> _somaliUnits = [
    'xabbo',
    'baakidh',
    'kartoon',
    'dhalo',
    'falag',
    'kiilo',
    'litir',
    'xidhmo',
    'darasin',
    'joog',
    'saxan',
  ];

  String _formatAttributeDisplay(String key, dynamic value) {
    if (value is bool) {
      return value ? '$key: Haa' : '$key: Maya';
    }
    switch (key.toLowerCase()) {
      case 'expiry_date':
        return '📅 Dhicitaan: $value';
      case 'dosage':
        return '💊 $value';
      case 'batch_number':
        return '🏷️ Dufcad: $value';
      case 'requires_prescription':
        final bool isReq =
            value == true || value.toString().toLowerCase() == 'true';
        return isReq ? '🩺 Warqad Dhakhtar' : 'Bilaash Warqad';
      case 'barcode':
        return '🔍 SKU: $value';
      case 'brand':
        return '✨ $value';
      case 'size':
        return '📏 Cabbir: $value';
      case 'color':
        return '🎨 Midab: $value';
      default:
        return '$key: $value';
    }
  }

  Future<void> _pickDateForController(
      BuildContext ctx, TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initial = now;
    if (controller.text.trim().isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text.trim());
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      final y = picked.year.toString();
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$y-$m-$d';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.businessType.primaryColor;

    return AnimatedBuilder(
      animation: GashiRepository.instance,
      builder: (context, _) {
        final repo = GashiRepository.instance;
        final products = repo.getProducts(widget.businessId);
        final fieldDefs = repo.getFieldDefinitions(
            widget.businessType.name, 'inventory');
        final suppliers = repo.getSuppliers(widget.businessId);

        // Compute Distinct Categories
        final categories = <String>{'Dhammaan'};
        for (final p in products) {
          if (p.categoryName.isNotEmpty) {
            categories.add(p.categoryName);
          }
        }

        // Filter products based on search, category & low stock toggle
        final filtered = products.where((p) {
          // Category filter
          if (_selectedCategory != 'Dhammaan' &&
              p.categoryName.toLowerCase() != _selectedCategory.toLowerCase()) {
            return false;
          }

          // Low stock filter (<= 10)
          if (_filterLowStockOnly && p.stockQuantity > 10) {
            return false;
          }

          // Search query
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final inName = p.name.toLowerCase().contains(query);
            final inCategory = p.categoryName.toLowerCase().contains(query);
            final inUnit = p.unit.toLowerCase().contains(query);
            final inCustom = p.customAttributes.values.any(
                (v) => v.toString().toLowerCase().contains(query));
            if (!(inName || inCategory || inUnit || inCustom)) {
              return false;
            }
          }

          // Search by image photo match
          if (_capturedPhoto != null) {
            final pId = _capturedPhoto!.id.toLowerCase();
            if (!pId.startsWith('cam_') && !pId.startsWith('img_') && !pId.startsWith('sim_')) {
              final inName = p.name.toLowerCase().contains(pId);
              final inCategory = p.categoryName.toLowerCase().contains(pId);
              if (!(inName || inCategory)) return false;
            }
          }

          return true;
        }).toList();

        // Calculate KPI Metrics
        final totalStockUnits =
            products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
        final totalCostValuation = products.fold<double>(
            0.0, (sum, p) => sum + (p.stockQuantity * p.costPrice));
        final totalSalesValuation = products.fold<double>(
            0.0, (sum, p) => sum + (p.stockQuantity * p.sellingPrice));
        final lowStockCount =
            products.where((p) => p.stockQuantity <= 10).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alaabta & Kaydka (Inventory)',
                  style: TextStyle(
                      color: Color(0xFF1D2338),
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Text(
                  '${products.length} alaab • $totalStockUnits xabbo • ${fieldDefs.length} tiirarka gaarka ah',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: widget.businessType.softBgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.tune, color: themeColor, size: 16),
                label: Text(
                  'Tiirarka (${fieldDefs.length})',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _openColumnManagerModal(context, fieldDefs),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(
            children: [
              const OfflineSyncBanner(),

              // Search Bar & Filter Controls (with Image Search Camera)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: Color(0xFF9CA3AF), size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Raadi magac, qayb, cabbir, ama baarkoodh...',
                                      hintStyle: TextStyle(
                                          color: Color(0xFF9CA3AF), fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 12),
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
                        const SizedBox(width: 8),

                        // Camera Button for Image Search (like in POS)
                        GestureDetector(
                          onTap: () async {
                            final photo = await PosCameraCaptureSheet.show(
                                context, themeColor);
                            if (photo != null) {
                              setState(() {
                                _capturedPhoto = photo;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Sawirka waa la qaaday - Baadhitaanka kaydka...',
                                    ),
                                    backgroundColor: themeColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: _capturedPhoto != null
                                  ? themeColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _capturedPhoto != null
                                    ? themeColor
                                    : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 22,
                              color: _capturedPhoto != null
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Attached Photo Chip / Active Search Banner
                    if (_capturedPhoto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.photo_camera,
                                  size: 16, color: themeColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sawir ku xidhan: ${_capturedPhoto!.id}',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _capturedPhoto = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // KPI Summary Banner Cards
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    // Total Cost Valuation Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Qiimaha Soo Iibsiga',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFF6B7280)),
                            ),
                            Text(
                              '\$${totalCostValuation.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total Sales Valuation Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Qiimaha Iibka',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFF6B7280)),
                            ),
                            Text(
                              '\$${totalSalesValuation.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Low Stock Alert Button/Filter
                    InkWell(
                      onTap: () {
                        setState(() {
                          _filterLowStockOnly = !_filterLowStockOnly;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _filterLowStockOnly
                              ? const Color(0xFFFEE2E2)
                              : (lowStockCount > 0
                                  ? const Color(0xFFFFFBEB)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _filterLowStockOnly
                                ? const Color(0xFFEF4444)
                                : (lowStockCount > 0
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 13,
                                  color: lowStockCount > 0
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Gabaabsi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: lowStockCount > 0
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$lowStockCount',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: lowStockCount > 0
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final cat = categories.elementAt(idx);
                    final isSelected = _selectedCategory == cat;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : const Color(0xFF4B5563),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: themeColor,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? themeColor
                            : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              // Product List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            const Text(
                              'Alaab lama helin (No items found)',
                              style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Wax ku habboon "$_searchQuery" lama helin'
                                  : 'Guji "Ku dar Alaab" si aad alaab cusub ugu darto kaydka',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final product = filtered[idx];
                          final profit =
                              product.sellingPrice - product.costPrice;
                          final marginPct = product.costPrice > 0
                              ? (profit / product.costPrice * 100.0)
                              : 0.0;
                          final supplier = suppliers.firstWhere(
                            (s) => s.id == product.supplierId,
                            orElse: () => const Supplier(
                                id: -1, businessId: -1, name: ''),
                          );

                          return InkWell(
                            onTap: () => _openProductDetailDrawer(
                              context,
                              product,
                              fieldDefs,
                              suppliers,
                              themeColor,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFF1F3F6)),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image / Thumbnail
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: product.imageUrl.isNotEmpty
                                            ? (product.imageUrl.startsWith('http')
                                                ? CachedNetworkImage(
                                                    imageUrl: product.imageUrl,
                                                    width: 54,
                                                    height: 54,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      width: 54,
                                                      height: 54,
                                                      color: widget.businessType
                                                          .softBgColor,
                                                      child: Icon(
                                                          widget.businessType
                                                              .icon,
                                                          color: themeColor,
                                                          size: 26),
                                                    ),
                                                  )
                                                : (File(product.imageUrl)
                                                        .existsSync()
                                                    ? Image.file(
                                                        File(product.imageUrl),
                                                        width: 54,
                                                        height: 54,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: 54,
                                                        height: 54,
                                                        color: widget
                                                            .businessType
                                                            .softBgColor,
                                                        child: Icon(
                                                            widget.businessType
                                                                .icon,
                                                            color: themeColor,
                                                            size: 26),
                                                      )))
                                            : Container(
                                                width: 54,
                                                height: 54,
                                                color: widget
                                                    .businessType.softBgColor,
                                                child: Icon(
                                                    widget.businessType.icon,
                                                    color: themeColor,
                                                    size: 26),
                                              ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Main Column Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF1D2338),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFFF3F4F6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    product.categoryName,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Color(0xFF4B5563),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Halbeeg: ${product.unit}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        Color(0xFF8E99AF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (supplier.id != -1) ...[
                                              const SizedBox(height: 3),
                                              Text(
                                                'Keeniye: ${supplier.name}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Price & Stock Badges Column
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${product.sellingPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: themeColor,
                                            ),
                                          ),
                                          Text(
                                            '${(product.sellingPrice * _exchangeRate).toStringAsFixed(0)} SLSH',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                          // Stock Badge (Color coded)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                            decoration: BoxDecoration(
                                              color: product.stockQuantity == 0
                                                  ? const Color(0xFFFEE2E2)
                                                  : (product.stockQuantity <= 10
                                                      ? const Color(0xFFFFFBEB)
                                                      : const Color(
                                                          0xFFE6F7F0)),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: product.stockQuantity ==
                                                        0
                                                    ? const Color(0xFFFCA5A5)
                                                    : (product.stockQuantity <=
                                                            10
                                                        ? const Color(
                                                            0xFFFDE68A)
                                                        : const Color(
                                                            0xFFA7F3D0)),
                                              ),
                                            ),
                                            child: Text(
                                              product.stockQuantity == 0
                                                  ? 'Dhamaaday (0)'
                                                  : (product.stockQuantity <= 10
                                                      ? 'Yar: ${product.stockQuantity} ${product.unit}'
                                                      : '${product.stockQuantity} ${product.unit}'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: product.stockQuantity ==
                                                        0
                                                    ? const Color(0xFFDC2626)
                                                    : (product.stockQuantity <=
                                                            10
                                                        ? const Color(
                                                            0xFFD97706)
                                                        : const Color(
                                                            0xFF059669)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  const Divider(
                                      height: 1, color: Color(0xFFF1F3F6)),
                                  const SizedBox(height: 6),

                                  // Cost Price, Margin & Custom Attributes Row
                                  Row(
                                    children: [
                                      // Cost Price & Profit
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Soo Iib: \$${product.costPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF64748B),
                                                  fontWeight:
                                                      FontWeight.w500),
                                            ),
                                            if (profit > 0) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '(+${marginPct.toStringAsFixed(0)}%)',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Custom Attributes Preview
                                      Expanded(
                                        child: product
                                                .customAttributes.isNotEmpty
                                            ? SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: product
                                                      .customAttributes.entries
                                                      .map((entry) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 6),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFEF3C7),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFFDE68A),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        _formatAttributeDisplay(
                                                            entry.key,
                                                            entry.value),
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 9.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF92400E),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF1F5F9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Text(
                                                      '+ Ku dar Tiirar',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color:
                                                            Color(0xFF94A3B8),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),

                                      // Chevron indicator to open drawer
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: Color(0xFFCBD5E1),
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: themeColor,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Ku dar Alaab (Add Product)',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            onPressed: () => _openAddProductModal(
                context, fieldDefs, suppliers, themeColor),
          ),
        );
      },
    );
  }

  // ============================================================================
  // PRODUCT DETAIL & QUICK EDIT BOTTOM DRAWER (Like POS Checkout Modal)
  // ============================================================================
  void _openProductDetailDrawer(
    BuildContext context,
    Product initialProduct,
    List<BusinessFieldDefinition> fieldDefs,
    List<Supplier> suppliers,
    Color themeColor,
  ) {
    int stockAdjustmentQty = 0;
    String adjustmentType = 'stock_receipt';
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (drawerCtx) {
        return StatefulBuilder(
          builder: (drawerCtx, setDrawerState) {
            // Live product reference from repository
            final product =
                GashiRepository.instance.getProductById(initialProduct.id) ??
                    initialProduct;
            final profit = product.sellingPrice - product.costPrice;
            final marginPct = product.costPrice > 0
                ? (profit / product.costPrice * 100.0)
                : 0.0;
            final stockMovements = GashiRepository.instance
                .getStockMovements(product.id)
                .take(6)
                .toList();
            final supplier = suppliers.firstWhere(
              (s) => s.id == product.supplierId,
              orElse: () =>
                  const Supplier(id: -1, businessId: -1, name: 'Lama xusin'),
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(drawerCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(drawerCtx).size.height * 0.88,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Drag Indicator & Header Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: themeColor.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${product.id}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: themeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qaybta: ${product.categoryName} • Halbeeg: ${product.unit}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 22),
                            color: const Color(0xFF64748B),
                            splashRadius: 20,
                            onPressed: () => Navigator.pop(drawerCtx),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Drawer Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. PRODUCT SNAPSHOT & STOCK STATUS CARD
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: product.imageUrl.isNotEmpty
                                        ? (product.imageUrl.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: product.imageUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 64,
                                                  height: 64,
                                                  color: widget
                                                      .businessType.softBgColor,
                                                  child: Icon(
                                                      widget.businessType.icon,
                                                      color: themeColor,
                                                      size: 30),
                                                ),
                                              )
                                            : (File(product.imageUrl)
                                                    .existsSync()
                                                ? Image.file(
                                                    File(product.imageUrl),
                                                    width: 64,
                                                    height: 64,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 64,
                                                    height: 64,
                                                    color: widget.businessType
                                                        .softBgColor,
                                                    child: Icon(
                                                        widget
                                                            .businessType.icon,
                                                        color: themeColor,
                                                        size: 30),
                                                  )))
                                        : Container(
                                            width: 64,
                                            height: 64,
                                            color: widget
                                                .businessType.softBgColor,
                                            child: Icon(
                                                widget.businessType.icon,
                                                color: themeColor,
                                                size: 30),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hadda Kaydka ku jira (In Stock):',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          '${product.stockQuantity} ${product.unit}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: product.stockQuantity == 0
                                                ? const Color(0xFFDC2626)
                                                : (product.stockQuantity <= 10
                                                    ? const Color(0xFFD97706)
                                                    : const Color(0xFF059669)),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Qiimaha Wadarta Kaydka: \$${(product.stockQuantity * product.costPrice).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        if (supplier.id != -1) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Keeniye: ${supplier.name}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 2. FINANCIAL / MARGIN DETAILS
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Soo Iibsiga',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${product.costPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      width: 1,
                                      height: 28,
                                      color: const Color(0xFFCBD5E1)),
                                  Column(
                                    children: [
                                      const Text('Iibka Macmiilka',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${product.sellingPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: themeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      width: 1,
                                      height: 28,
                                      color: const Color(0xFFCBD5E1)),
                                  Column(
                                    children: [
                                      const Text('Faa\'iidada (Margin)',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF64748B))),
                                      const SizedBox(height: 2),
                                      Text(
                                        '+\$${profit.toStringAsFixed(2)} (${marginPct.toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 3. QUICK INLINE STOCK ADJUSTMENT TOOL
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.sync_alt_rounded,
                                              size: 16,
                                              color: Color(0xFFB45309)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Hagaajinta & Soo Dejinta Kaydka',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      DropdownButton<String>(
                                        value: adjustmentType,
                                        isDense: true,
                                        underline: const SizedBox.shrink(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF92400E)),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'stock_receipt',
                                            child: Text('+ Soo Dejin (Stock In)'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'adjustment',
                                            child: Text('⚙️ Hagaajin (Adjust)'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'return',
                                            child: Text('↩️ Celis (Return)'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setDrawerState(() =>
                                                adjustmentType = val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Quick add quantity chips
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [5, 10, 25, 50].map((qty) {
                                      return InkWell(
                                        onTap: () {
                                          setDrawerState(() {
                                            stockAdjustmentQty = qty;
                                          });
                                        },
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: stockAdjustmentQty == qty
                                                ? const Color(0xFFD97706)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: stockAdjustmentQty == qty
                                                  ? const Color(0xFFB45309)
                                                  : const Color(0xFFFDE68A),
                                            ),
                                          ),
                                          child: Text(
                                            '+$qty',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: stockAdjustmentQty == qty
                                                  ? Colors.white
                                                  : const Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),

                                  // Stepper for custom quantity
                                  Row(
                                    children: [
                                      // Decrement button
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFFB45309),
                                        ),
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: () {
                                          setDrawerState(() {
                                            stockAdjustmentQty--;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            stockAdjustmentQty > 0
                                                ? '+$stockAdjustmentQty ${product.unit}'
                                                : '$stockAdjustmentQty ${product.unit}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Increment button
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFFB45309),
                                        ),
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () {
                                          setDrawerState(() {
                                            stockAdjustmentQty++;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),

                                      // Apply Stock Button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD97706),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: stockAdjustmentQty == 0
                                            ? null
                                            : () {
                                                GashiRepository.instance
                                                    .adjustStock(
                                                  product.id,
                                                  stockAdjustmentQty,
                                                  type: adjustmentType,
                                                  notes: notesCtrl.text.trim(),
                                                );
                                                setDrawerState(() {
                                                  stockAdjustmentQty = 0;
                                                  notesCtrl.clear();
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Kaydka ${product.name} waa la cusbooneysiiyay!'),
                                                    backgroundColor:
                                                        const Color(0xFF10B981),
                                                  ),
                                                );
                                              },
                                        icon: const Icon(
                                            Icons.check_circle_outline,
                                            size: 16),
                                        label: const Text(
                                          'Dhaqangeli',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 4. DYNAMIC CUSTOM ATTRIBUTES (PostgreSQL JSONB)
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.tune_rounded,
                                        size: 16, color: Color(0xFF475569)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Tiirarka Gaarka ah (Custom Attributes):',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                  ),
                                  icon: Icon(Icons.add_circle_outline,
                                      size: 14, color: themeColor),
                                  label: Text(
                                    'Ku dar Tilmaan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: themeColor,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _openAddAttributeToProductDialog(
                                    drawerCtx,
                                    product,
                                    fieldDefs,
                                    setDrawerState,
                                    themeColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (product.customAttributes.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        size: 16, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Alaabtan wali ma laha tiirar gaar ah (No custom attributes yet).',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _openAddAttributeToProductDialog(
                                        drawerCtx,
                                        product,
                                        fieldDefs,
                                        setDrawerState,
                                        themeColor,
                                      ),
                                      child: const Text('Ku dar Hadda',
                                          style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      product.customAttributes.entries.length,
                                  separatorBuilder: (_, _) => const Divider(
                                      height: 1, color: Color(0xFFF1F3F6)),
                                  itemBuilder: (ctx, i) {
                                    final e = product.customAttributes.entries
                                        .elementAt(i);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.key,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _formatAttributeDisplay(
                                                      e.key, e.value),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Color(0xFFEF4444)),
                                            tooltip: 'Tirtir tilmaantan',
                                            splashRadius: 16,
                                            onPressed: () {
                                              final updatedAttrs =
                                                  Map<String, dynamic>.from(
                                                      product.customAttributes);
                                              updatedAttrs.remove(e.key);
                                              final updated = product.copyWith(
                                                  customAttributes:
                                                      updatedAttrs);
                                              GashiRepository.instance
                                                  .updateProduct(updated);
                                              setDrawerState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 14),

                            // 5. RECENT STOCK MOVEMENTS HISTORY
                            const Text(
                              'Dhaqdhaqaaqii ugu Dambeeyay (Stock Movement Log):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (stockMovements.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Dhaqdhaqaaq hore looma diiwaangelin.',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stockMovements.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (ctx, idx) {
                                  final m = stockMovements[idx];
                                  final isPositive = m.quantity > 0;
                                  final timeStr =
                                      '${m.createdAt.day}/${m.createdAt.month} ${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, '0')}';

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: m.type == 'sale'
                                                    ? const Color(0xFFFEE2E2)
                                                    : (m.type == 'stock_receipt'
                                                        ? const Color(0xFFE6F7F0)
                                                        : const Color(0xFFFEF3C7)),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                m.type.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: m.type == 'sale'
                                                      ? const Color(0xFFDC2626)
                                                      : (m.type == 'stock_receipt'
                                                          ? const Color(0xFF059669)
                                                          : const Color(0xFFB45309)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              m.notes.isNotEmpty
                                                  ? m.notes
                                                  : timeStr,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          isPositive
                                              ? '+${m.quantity}'
                                              : '${m.quantity}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isPositive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Actions Footer: Delete / Edit
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Archive / Delete button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _confirmDeleteProduct(
                                  context, product, drawerCtx);
                            },
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 16),
                            label: const Text(
                              'Tirtir (Delete)',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Edit Product button
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(drawerCtx);
                                _openEditProductModal(context, product,
                                    fieldDefs, suppliers, themeColor);
                              },
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text(
                                'Wax ka beddel (Edit Product)',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
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

  // Confirm product deletion / archive
  void _confirmDeleteProduct(
      BuildContext context, Product product, BuildContext drawerCtx) {
    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ma hubtaa inaad tirtirto alaabtan?'),
        content: Text(
          'Alaabta "${product.name}" waxaa laga tirtirayaa liiska kaydka.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Ka noqo (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              GashiRepository.instance.deleteProduct(product.id);
              Navigator.pop(dlgCtx);
              Navigator.pop(drawerCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} waa la tirtiray!'),
                  backgroundColor: const Color(0xFFDC2626),
                ),
              );
            },
            child: const Text('Haa, Tirtir (Delete)'),
          ),
        ],
      ),
    );
  }

  // Add a dynamic attribute directly to a product
  void _openAddAttributeToProductDialog(
    BuildContext parentCtx,
    Product product,
    List<BusinessFieldDefinition> fieldDefs,
    void Function(void Function()) setDrawerState,
    Color themeColor,
  ) {
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    bool saveToBusinessFields = false;

    final unusedDefs = fieldDefs
        .where((d) => !product.customAttributes.containsKey(d.fieldKey))
        .toList();
    String? selectedPresetKey;
    if (unusedDefs.isNotEmpty) {
      selectedPresetKey = unusedDefs.first.fieldKey;
      keyCtrl.text = selectedPresetKey;
    }

    showDialog<void>(
      context: parentCtx,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.add_box_outlined, color: themeColor, size: 20),
                const SizedBox(width: 8),
                const Text('Ku dar Tilmaan Gaar ah',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unusedDefs.isNotEmpty) ...[
                    const Text('Ka dooro Tiirarka Ganacsiga:',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPresetKey,
                      isDense: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      items: [
                        ...unusedDefs.map((d) => DropdownMenuItem(
                            value: d.fieldKey, child: Text(d.fieldLabel))),
                        const DropdownMenuItem(
                            value: '__custom__',
                            child: Text('✍️ Geli Tilmaan kale (Custom)')),
                      ],
                      onChanged: (val) {
                        setDlgState(() {
                          selectedPresetKey = val;
                          if (val != null && val != '__custom__') {
                            keyCtrl.text = val;
                          } else {
                            keyCtrl.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (unusedDefs.isEmpty ||
                      selectedPresetKey == '__custom__') ...[
                    const Text('Furaha Tilmaanta (Attribute Key) *:',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: keyCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. barcode, shelf_number, color...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Text('Qiimaha Tilmaanta (Value) *:',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: valCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. 2027-06-30, Madow, 500mg...',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        onPressed: () =>
                            _pickDateForController(dlgCtx, valCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: saveToBusinessFields,
                    title: const Text('Ku dar tiirarka guud ee ganacsiga',
                        style: TextStyle(fontSize: 11)),
                    onChanged: (val) => setDlgState(
                        () => saveToBusinessFields = val ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgCtx),
                child: const Text('Ka noqo'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final key =
                      keyCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
                  final val = valCtrl.text.trim();
                  if (key.isEmpty || val.isEmpty) return;

                  final updatedAttrs =
                      Map<String, dynamic>.from(product.customAttributes);
                  updatedAttrs[key] = val;
                  final updated =
                      product.copyWith(customAttributes: updatedAttrs);
                  GashiRepository.instance.updateProduct(updated);

                  if (saveToBusinessFields) {
                    GashiRepository.instance.addFieldDefinition(
                      businessType: widget.businessType.name,
                      targetEntity: 'inventory',
                      fieldKey: key,
                      fieldLabel: keyCtrl.text.trim(),
                      fieldType: 'text',
                    );
                  }

                  setDrawerState(() {});
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(parentCtx).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Tilmaanta "$key" waa lagu daray ${product.name}!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Ku dar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================================
  // CAMERA IMAGE PICKER HEADER (Shared by Add & Edit Modals)
  // ============================================================================
  Widget _buildImagePickerHeader({
    required BuildContext context,
    required String? imagePath,
    required Color themeColor,
    required ValueChanged<String?> onImageChanged,
  }) {
    final hasImage = imagePath != null && imagePath.trim().isNotEmpty;
    final path = imagePath?.trim() ?? '';
    final isHttp = path.startsWith('http://') || path.startsWith('https://');
    final isLocalFile = !isHttp && path.isNotEmpty && File(path).existsSync();

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final photo = await PosCameraCaptureSheet.show(context, themeColor);
              if (photo != null) {
                onImageChanged(photo.path ?? photo.id);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasImage ? themeColor : const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? (isHttp
                          ? CachedNetworkImage(
                              imageUrl: path,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: themeColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.broken_image,
                                color: themeColor,
                                size: 36,
                              ),
                            )
                          : (isLocalFile
                              ? Image.file(File(path), fit: BoxFit.cover)
                              : Container(
                                  color: themeColor.withValues(alpha: 0.1),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.image, color: themeColor, size: 32),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            path,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: themeColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 24,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sawirka Alaabta',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                ),
                if (hasImage)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => onImageChanged(null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasImage ? 'Guji sawirka si aad u bedesho' : 'Guji si aad sawir ugu darto',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // EDIT PRODUCT MODAL (Update all columns + dynamic attributes)
  // ============================================================================
  void _openEditProductModal(
    BuildContext context,
    Product product,
    List<BusinessFieldDefinition> fieldDefs,
    List<Supplier> suppliers,
    Color themeColor,
  ) {
    final nameCtrl = TextEditingController(text: product.name);
    final categoryCtrl = TextEditingController(text: product.categoryName);
    final costPriceCtrl =
        TextEditingController(text: product.costPrice.toStringAsFixed(2));
    final sellingPriceCtrl =
        TextEditingController(text: product.sellingPrice.toStringAsFixed(2));
    final stockCtrl =
        TextEditingController(text: product.stockQuantity.toString());
    String? selectedImagePath = product.imageUrl;
    String selectedUnit = product.unit;
    int? selectedSupplierId = product.supplierId;

    final Map<String, TextEditingController> customControllers = {};
    for (final def in fieldDefs) {
      final initialVal =
          product.customAttributes[def.fieldKey]?.toString() ?? '';
      customControllers[def.fieldKey] = TextEditingController(text: initialVal);
    }

    final List<MapEntry<TextEditingController, TextEditingController>>
        extraCustomRows = [];
    for (final entry in product.customAttributes.entries) {
      final bool isDefined = fieldDefs.any((d) => d.fieldKey == entry.key);
      if (!isDefined) {
        extraCustomRows.add(
          MapEntry(
            TextEditingController(text: entry.key),
            TextEditingController(text: entry.value.toString()),
          ),
        );
      }
    }

    final availableUnits = [..._somaliUnits];
    if (!availableUnits.contains(selectedUnit)) {
      availableUnits.insert(0, selectedUnit);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (editCtx) {
        return StatefulBuilder(
          builder: (editCtx, setEditState) {
            final parsedCost = double.tryParse(costPriceCtrl.text) ?? 0.0;
            final parsedSelling = double.tryParse(sellingPriceCtrl.text) ?? 0.0;
            final profitMargin = parsedSelling - parsedCost;
            final marginPct =
                parsedCost > 0 ? (profitMargin / parsedCost * 100.0) : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(editCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Wax ka beddel Alaabta (Edit Product)',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(editCtx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Product Image Camera Picker
                    _buildImagePickerHeader(
                      context: context,
                      imagePath: selectedImagePath,
                      themeColor: themeColor,
                      onImageChanged: (newPath) {
                        setEditState(() => selectedImagePath = newPath);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Name
                    const Text('Magaca Alaabta (Product Name) *:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cost Price & Selling Price with Live Margin Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qiimaha Soo Iibsiga (\$)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: costPriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setEditState(() {}),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qiimaha Iibka (\$)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: sellingPriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setEditState(() {}),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Live Profit Margin Pill
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: profitMargin >= 0
                            ? const Color(0xFFE6F7F0)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profitMargin >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: profitMargin >= 0
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Faa\'iidada halkii xabbo: \$${profitMargin.toStringAsFixed(2)} (${marginPct.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: profitMargin >= 0
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Stock Quantity & Unit
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tirada Kaydka (Stock)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Halbeeg (Unit):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedUnit,
                                isDense: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                items: availableUnits.map((u) {
                                  return DropdownMenuItem(
                                      value: u, child: Text(u));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setEditState(() => selectedUnit = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Category & Supplier
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qaybta (Category):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: categoryCtrl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Keeniye (Supplier):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int?>(
                                initialValue: selectedSupplierId,
                                isExpanded: true,
                                isDense: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text(
                                        'Ma jiro (None)',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )),
                                  ...suppliers.map((s) {
                                    return DropdownMenuItem(
                                        value: s.id,
                                        child: Text(
                                          '${s.name} (${s.phone})',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ));
                                  }),
                                ],
                                onChanged: (val) {
                                  setEditState(() => selectedSupplierId = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Dynamic Custom Attributes
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiirarka Gaarka ah (${widget.businessType.name.toUpperCase()} Custom Fields):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: themeColor),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('+ Tilmaan Kale',
                              style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setEditState(() {
                              extraCustomRows.add(
                                MapEntry(
                                  TextEditingController(),
                                  TextEditingController(),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...fieldDefs.map((def) {
                      final ctrl = customControllers[def.fieldKey]!;
                      final isDateField = def.fieldType == 'date';
                      final isBoolField = def.fieldType == 'boolean';

                      if (isBoolField) {
                        final currentVal =
                            ctrl.text.toLowerCase() == 'true' ||
                                ctrl.text == '1';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              def.fieldLabel,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            value: currentVal,
                            activeThumbColor: themeColor,
                            onChanged: (val) {
                              setEditState(() {
                                ctrl.text = val.toString();
                              });
                            },
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${def.fieldLabel}:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: ctrl,
                              keyboardType: def.fieldType == 'number'
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Geli ${def.fieldLabel}',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFC),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: isDateField
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18),
                                        onPressed: () =>
                                            _pickDateForController(
                                                editCtx, ctrl),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Ad-hoc Extra Custom Attributes Rows
                    if (extraCustomRows.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Tilmaamo Dheeraad ah (Additional Attributes):',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      ...extraCustomRows.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: entry.key,
                                  decoration: InputDecoration(
                                    hintText: 'Furaha (Key)',
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFC),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    hintText: 'Qiimaha (Value)',
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFC),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16),
                                      onPressed: () =>
                                          _pickDateForController(
                                              editCtx, entry.value),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFFEF4444),
                                    size: 18),
                                onPressed: () {
                                  setEditState(() {
                                    extraCustomRows.remove(entry);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 18),

                    // Save Updates Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text(
                          'Keydi Wax Ka Beddelka (Save Changes)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final cost =
                              double.tryParse(costPriceCtrl.text.trim()) ?? 0.0;
                          final selling =
                              double.tryParse(sellingPriceCtrl.text.trim()) ??
                                  0.0;
                          final stock =
                              int.tryParse(stockCtrl.text.trim()) ?? 0;
                          final category =
                              categoryCtrl.text.trim().isNotEmpty
                                  ? categoryCtrl.text.trim()
                                  : 'General';

                          if (name.isEmpty || selling <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fadlan geli magaca iyo qiimaha saxda ah!'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          // Collect dynamic attributes
                          final customAttrs = <String, dynamic>{};
                          customControllers.forEach((key, ctrl) {
                            if (ctrl.text.trim().isNotEmpty) {
                              if (ctrl.text.toLowerCase() == 'true') {
                                customAttrs[key] = true;
                              } else if (ctrl.text.toLowerCase() == 'false') {
                                customAttrs[key] = false;
                              } else {
                                customAttrs[key] = ctrl.text.trim();
                              }
                            }
                          });
                          for (final row in extraCustomRows) {
                            final k = row.key.text
                                .trim()
                                .toLowerCase()
                                .replaceAll(' ', '_');
                            final v = row.value.text.trim();
                            if (k.isNotEmpty && v.isNotEmpty) {
                              customAttrs[k] = v;
                            }
                          }

                          final updated = product.copyWith(
                            name: name,
                            categoryName: category,
                            costPrice: cost,
                            sellingPrice: selling,
                            stockQuantity: stock,
                            unit: selectedUnit,
                            supplierId: selectedSupplierId,
                            imageUrl: selectedImagePath ?? '',
                            customAttributes: customAttrs,
                          );

                          GashiRepository.instance.updateProduct(updated);
                          Navigator.pop(editCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Alaabta "${updated.name}" waa la cusbooneysiiyay!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
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

  // ============================================================================
  // ADD PRODUCT MODAL (Conforming to PostgreSQL columns + Dynamic Attributes)
  // ============================================================================
  void _openAddProductModal(
    BuildContext context,
    List<BusinessFieldDefinition> fieldDefs,
    List<Supplier> suppliers,
    Color themeColor,
  ) {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General');
    final costPriceCtrl = TextEditingController(text: '1.00');
    final sellingPriceCtrl = TextEditingController(text: '2.00');
    final stockCtrl = TextEditingController(text: '20');
    String? selectedImagePath;
    String selectedUnit = 'xabbo';
    int? selectedSupplierId;

    final Map<String, TextEditingController> customControllers = {};
    for (final def in fieldDefs) {
      customControllers[def.fieldKey] = TextEditingController();
    }

    final List<MapEntry<TextEditingController, TextEditingController>>
        extraCustomRows = [];

    final availableUnits = [..._somaliUnits];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (addCtx) {
        return StatefulBuilder(
          builder: (addCtx, setAddState) {
            final parsedCost = double.tryParse(costPriceCtrl.text) ?? 0.0;
            final parsedSelling =
                double.tryParse(sellingPriceCtrl.text) ?? 0.0;
            final profitMargin = parsedSelling - parsedCost;
            final marginPct =
                parsedCost > 0 ? (profitMargin / parsedCost * 100.0) : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(addCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ku dar Alaab Cusub (Add Product)',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(addCtx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Product Image Camera Picker
                    _buildImagePickerHeader(
                      context: context,
                      imagePath: selectedImagePath,
                      themeColor: themeColor,
                      onImageChanged: (newPath) {
                        setAddState(() => selectedImagePath = newPath);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Product Name
                    const Text('Magaca Alaabta (Product Name) *:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Tusaale: Panadol, Caanaha Safi, Shaadh...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cost Price & Selling Price with Live Margin Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qiimaha Soo Iibsiga (\$)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: costPriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setAddState(() {}),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: '1.50',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qiimaha Iibka (\$)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: sellingPriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setAddState(() {}),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: '2.50',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Live Profit Margin preview badge
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: profitMargin >= 0
                            ? const Color(0xFFE6F7F0)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profitMargin >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: profitMargin >= 0
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Faa\'iidada halkii xabbo: \$${profitMargin.toStringAsFixed(2)} (${marginPct.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: profitMargin >= 0
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Stock Quantity & Unit
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tirada Hore (Initial Stock)*:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '10',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Halbeegga (Unit):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedUnit,
                                isDense: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                items: availableUnits.map((u) {
                                  return DropdownMenuItem(
                                      value: u, child: Text(u));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setAddState(() => selectedUnit = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Category & Supplier
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Qaybta (Category):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: categoryCtrl,
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. Daawooyin, Cabitaanno, Dhar...',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Keeniye (Supplier):',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int?>(
                                initialValue: selectedSupplierId,
                                isExpanded: true,
                                isDense: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFC),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                      value: null,
                                      child: Text(
                                        'Ma jiro (None)',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      )),
                                  ...suppliers.map((s) {
                                    return DropdownMenuItem(
                                        value: s.id,
                                        child: Text(
                                          '${s.name} (${s.phone})',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ));
                                  }),
                                ],
                                onChanged: (val) {
                                  setAddState(() => selectedSupplierId = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Dynamically Rendered Custom Columns
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiirarka Gaarka ah (${widget.businessType.name.toUpperCase()} Custom Fields):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: themeColor),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('+ Tilmaan Kale',
                              style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setAddState(() {
                              extraCustomRows.add(
                                MapEntry(
                                  TextEditingController(),
                                  TextEditingController(),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...fieldDefs.map((def) {
                      final ctrl = customControllers[def.fieldKey]!;
                      final isDateField = def.fieldType == 'date';
                      final isBoolField = def.fieldType == 'boolean';

                      if (isBoolField) {
                        final currentVal =
                            ctrl.text.toLowerCase() == 'true' ||
                                ctrl.text == '1';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              def.fieldLabel,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            value: currentVal,
                            activeThumbColor: themeColor,
                            onChanged: (val) {
                              setAddState(() {
                                ctrl.text = val.toString();
                              });
                            },
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${def.fieldLabel}:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: ctrl,
                              keyboardType: def.fieldType == 'number'
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Geli ${def.fieldLabel}',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFC),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: isDateField
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18),
                                        onPressed: () =>
                                            _pickDateForController(
                                                addCtx, ctrl),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Ad-hoc Extra Custom Attributes Rows
                    if (extraCustomRows.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Tilmaamo Dheeraad ah (Additional Attributes):',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 6),
                      ...extraCustomRows.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: entry.key,
                                  decoration: InputDecoration(
                                    hintText: 'Furaha (Key)',
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFC),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: entry.value,
                                  decoration: InputDecoration(
                                    hintText: 'Qiimaha (Value)',
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFC),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16),
                                      onPressed: () =>
                                          _pickDateForController(
                                              addCtx, entry.value),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFFEF4444),
                                    size: 18),
                                onPressed: () {
                                  setAddState(() {
                                    extraCustomRows.remove(entry);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 18),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text(
                          'Keydi Alaabta (Save Product)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final cost =
                              double.tryParse(costPriceCtrl.text.trim()) ?? 0.0;
                          final selling =
                              double.tryParse(sellingPriceCtrl.text.trim()) ??
                                  0.0;
                          final stock =
                              int.tryParse(stockCtrl.text.trim()) ?? 0;
                          final category =
                              categoryCtrl.text.trim().isNotEmpty
                                  ? categoryCtrl.text.trim()
                                  : 'General';

                          if (name.isEmpty || selling <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fadlan geli magaca iyo qiimaha saxda ah!'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          // Collect dynamic attributes
                          final customAttrs = <String, dynamic>{};
                          customControllers.forEach((key, ctrl) {
                            if (ctrl.text.trim().isNotEmpty) {
                              if (ctrl.text.toLowerCase() == 'true') {
                                customAttrs[key] = true;
                              } else if (ctrl.text.toLowerCase() == 'false') {
                                customAttrs[key] = false;
                              } else {
                                customAttrs[key] = ctrl.text.trim();
                              }
                            }
                          });
                          for (final row in extraCustomRows) {
                            final k = row.key.text
                                .trim()
                                .toLowerCase()
                                .replaceAll(' ', '_');
                            final v = row.value.text.trim();
                            if (k.isNotEmpty && v.isNotEmpty) {
                              customAttrs[k] = v;
                            }
                          }

                          GashiRepository.instance.addProduct(
                            Product(
                              id: 0,
                              businessId: widget.businessId,
                              name: name,
                              categoryName: category,
                              costPrice: cost,
                              sellingPrice: selling,
                              stockQuantity: stock,
                              unit: selectedUnit,
                              supplierId: selectedSupplierId,
                              imageUrl: selectedImagePath ?? '',
                              customAttributes: customAttrs,
                            ),
                          );

                          Navigator.pop(addCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name waa lagu daray kaydka!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
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

  // ============================================================================
  // DYNAMIC COLUMN MANAGER (Add & Remove Columns / business_field_definitions)
  // ============================================================================
  void _openColumnManagerModal(
      BuildContext context, List<BusinessFieldDefinition> currentDefs) {
    final keyCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    String selectedType = 'text';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                        const Text('Maamul Tiirarka Gaarka ah (Custom Columns)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text('Tiirarka Hadda Firfircoon (Active Columns):',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (currentDefs.isEmpty)
                      const Text('Tiirar gaar ah wali laguma darin.',
                          style: TextStyle(color: Colors.grey, fontSize: 12))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentDefs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (c, i) {
                          final def = currentDefs[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(def.fieldLabel,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    Text(
                                        'Key: ${def.fieldKey} • Nooca: ${def.fieldType}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280))),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Color(0xFFEF4444), size: 18),
                                  onPressed: () {
                                    GashiRepository.instance
                                        .removeFieldDefinition(def.id);
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    const Text('Ku dar Tiir Cusub (Add New Custom Column):',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: labelCtrl,
                      decoration: InputDecoration(
                        hintText: 'Magaca Tiirka (e.g. Taariikhda Dhicitaanka)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: keyCtrl,
                      decoration: InputDecoration(
                        hintText: 'Furaha Xogta (e.g. expiry_date, barcode)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Nooca Xogta: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        DropdownButton<String>(
                          value: selectedType,
                          items: const [
                            DropdownMenuItem(value: 'text', child: Text('Qoraal (Text)')),
                            DropdownMenuItem(
                                value: 'number', child: Text('Lambar (Number)')),
                            DropdownMenuItem(value: 'date', child: Text('Taariikh (Date)')),
                            DropdownMenuItem(
                                value: 'boolean', child: Text('Haa/Maya (Yes/No)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedType = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.businessType.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ku dar Tiirka (Add Column)'),
                        onPressed: () {
                          final label = labelCtrl.text.trim();
                          final key = keyCtrl.text
                              .trim()
                              .toLowerCase()
                              .replaceAll(' ', '_');
                          if (label.isEmpty || key.isEmpty) return;

                          GashiRepository.instance.addFieldDefinition(
                            businessType: widget.businessType.name,
                            targetEntity: 'inventory',
                            fieldKey: key,
                            fieldLabel: label,
                            fieldType: selectedType,
                          );

                          labelCtrl.clear();
                          keyCtrl.clear();
                          setModalState(() {});
                        },
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
