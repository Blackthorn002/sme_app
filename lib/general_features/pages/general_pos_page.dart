import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../widgets/offline_sync_banner.dart';
import '../widgets/pos_camera_capture_sheet.dart';

// ============================================================================
// GENERAL POS PAGE (Unified & Adaptable Across All Business Types)
// Features:
// 1. Point-and-shoot camera search with real camera connection & fallback
// 2. Large +/- buttons & Top-Right 'X' deselect button per item card
// 3. Somali localization & 'Dhammee Iibka' (Checkout)
// 4. Checkout Modal:
//    - Separate 'Iib Toos ah' (Direct Payment) vs 'Deyn' (Debt) modes
//    - When Deyn is clicked, payment options disappear completely
//    - Non-overflowing payment method cards
//    - 'Safaari / Delivery / Miis' ONLY for Restaurants
//    - Prominent Bargaining / Negotiation (Gorgortan) button in Total Amount section
//    - Base Subtotal, Negotiated Discount, Tax (0% omitted), and Dual USD/SLSH Total
//    - '🖨 Xaqiiji' confirmation button
// ============================================================================

class GeneralPosPage extends StatefulWidget {
  final int businessId;
  final BusinessType businessType;

  const GeneralPosPage({
    super.key,
    required this.businessId,
    required this.businessType,
  });

  @override
  State<GeneralPosPage> createState() => _GeneralPosPageState();
}

class _GeneralPosPageState extends State<GeneralPosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Dhammaan';
  String _selectedPaymentMethod = GashiPaymentMethods.zaad;
  String _selectedOrderType = 'Miis';

  // Local cart: Product ID -> quantity
  final Map<int, int> _cart = {};

  // Overall sale discount from bargaining on the total
  double _overallDiscount = 0.0;

  // Standard Somaliland Shilling exchange rate
  final double _exchangeRate = 8500.0;

  // Attached Camera Photo for search/reference
  PosCapturedPhoto? _capturedPhoto;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(int productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _updateCartQuantity(int productId, int change) {
    setState(() {
      final current = _cart[productId] ?? 0;
      final updated = current + change;
      if (updated <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId] = updated;
      }
    });
  }

  void _deselectItem(int productId) {
    setState(() {
      _cart.remove(productId);
    });
  }

  int get _cartCount => _cart.values.fold(0, (sum, q) => sum + q);

  // Base total without any discounts
  double _getBaseCartTotal(List<Product> products) {
    double total = 0.0;
    _cart.forEach((id, qty) {
      final p = products.firstWhere(
        (item) => item.id == id,
        orElse: () => const Product(
            id: -1, businessId: -1, name: '', sellingPrice: 0.0),
      );
      total += p.sellingPrice * qty;
    });
    return total;
  }

  // Final subtotal after overall bargaining discount
  double _getFinalCartTotal(List<Product> products) {
    final subtotal = _getBaseCartTotal(products);
    return (subtotal - _overallDiscount).clamp(0.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.businessType.primaryColor;
    final allCategoriesLabel = context.tr('all');

    return AnimatedBuilder(
      animation: GashiRepository.instance,
      builder: (context, _) {
        final products = GashiRepository.instance.getProducts(widget.businessId);
        final business = GashiRepository.instance.getBusinessById(widget.businessId) ??
            GashiRepository.instance.getBusinessByType(widget.businessType);

        // Filter products by search and category
        final filtered = products.where((p) {
          final matchesSearch =
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCat = _selectedCategory == allCategoriesLabel ||
              _selectedCategory == 'Dhammaan' ||
              p.categoryName.toLowerCase() == _selectedCategory.toLowerCase();
          return matchesSearch && matchesCat;
        }).toList();

        // Extract unique categories
        final categories = <String>[
          allCategoriesLabel,
          ...products.map((p) => p.categoryName).toSet()
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          body: SafeArea(
            child: Column(
              children: [
                const OfflineSyncBanner(),

                // Search Bar + Camera Search Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F6),
                            borderRadius: BorderRadius.circular(16),
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
                                  decoration: InputDecoration(
                                    hintText: context.tr('pos_search_items'),
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
                      const SizedBox(width: 10),

                      // Camera Button (Connected to hardware with fallback)
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
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _capturedPhoto != null
                                ? Icons.camera
                                : Icons.camera_alt_outlined,
                            size: 22,
                            color: _capturedPhoto != null
                                ? Colors.white
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Attached Photo Chip / Active Search Banner
                if (_capturedPhoto != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                          Icon(Icons.camera_alt, color: themeColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${context.tr('pos_attached_photo')}: ${_capturedPhoto!.id}',
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

                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSel = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: themeColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF1D2338),
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Products Grid with Large +/- and Top-Right 'X' Deselect Button
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            context.tr('pos_no_products'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.74,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            final qtyInCart = _cart[product.id] ?? 0;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Main Item Card Container
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: qtyInCart > 0
                                          ? themeColor
                                          : const Color(0xFFF1F3F6),
                                      width: qtyInCart > 0 ? 1.5 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(15)),
                                        child: AspectRatio(
                                          aspectRatio: 1.35,
                                          child: product.imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: product.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context,
                                                          error, stackTrace) =>
                                                      Container(
                                                    color: widget.businessType
                                                        .softBgColor,
                                                    child: Icon(
                                                        widget.businessType
                                                            .icon,
                                                        color: themeColor,
                                                        size: 30),
                                                  ),
                                                )
                                              : Container(
                                                  color: widget.businessType
                                                      .softBgColor,
                                                  child: Icon(
                                                      widget.businessType.icon,
                                                      color: themeColor,
                                                      size: 30),
                                                ),
                                        ),
                                      ),

                                      // Details
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Color(0xFF1D2338),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${context.tr('pos_stock')}: ${product.stockQuantity} ${product.unit}',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF8E99AF)),
                                                  ),
                                                ],
                                              ),

                                              // Bottom Row: Price + Large +/- Controls
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '\$${product.sellingPrice.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: themeColor,
                                                      ),
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),

                                                  // Large Quantity Controls
                                                  if (qtyInCart > 0)
                                                    Row(
                                                      children: [
                                                        // Large Minus Button
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _updateCartQuantity(
                                                                  product.id,
                                                                  -1),
                                                          child: Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF1F3F6),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Icon(
                                                              Icons.remove,
                                                              size: 18,
                                                              color: Color(
                                                                  0xFF1D2338),
                                                            ),
                                                          ),
                                                        ),

                                                        // Quantity Number
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 6),
                                                          child: Text(
                                                            '$qtyInCart',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),

                                                        // Large Plus Button
                                                        GestureDetector(
                                                          onTap: () =>
                                                              _addToCart(
                                                                  product.id),
                                                          child: Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: themeColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Icon(
                                                              Icons.add,
                                                              size: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    // Large Initial Add Button
                                                    GestureDetector(
                                                      onTap: () => _addToCart(
                                                          product.id),
                                                      child: Container(
                                                        width: 34,
                                                        height: 34,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: themeColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: themeColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Top-Right 'X' Button to completely deselect the item
                                if (qtyInCart > 0)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => _deselectItem(product.id),
                                      child: Tooltip(
                                        message:
                                            context.tr('pos_deselect_item'),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.25),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),

                // Bottom Cart Bar
                if (_cart.isNotEmpty)
                  _buildBottomCartBar(products, business, themeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomCartBar(
      List<Product> products, Business? business, Color themeColor) {
    final subtotal = _getFinalCartTotal(products);
    final taxRate = business?.taxRate ?? 0.0;
    final hasTax = taxRate > 0.0;
    final taxAmount = hasTax ? (subtotal * (taxRate / 100.0)) : 0.0;
    final total = subtotal + taxAmount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_cartCount ${context.tr('pos_items_in_order')}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                ),
                Row(
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2338)),
                    ),
                    if (hasTax)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          '(+${taxRate.toStringAsFixed(0)}% ${context.tr('pos_tax')})',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF10B981)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                context.tr('pos_checkout'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () =>
                  _openCheckoutModal(context, products, business, themeColor),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CHECKOUT MODAL (With Prominent Bargaining Button & Separated Debt Mode)
  // ==========================================================================
  void _openCheckoutModal(BuildContext context, List<Product> products,
      Business? business, Color themeColor) {
    final orderId = 'ORD-${(1000 + DateTime.now().millisecond).toString()}';
    final nowTime =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    // Transaction Mode: Direct Payment vs Debt
    bool isDebtMode = false;

    // Debt State
    bool isNewDebtor = false;
    Customer? selectedExistingDebtor;
    final newDebtorNameCtrl = TextEditingController();
    final newDebtorPhoneCtrl = TextEditingController();
    final newDebtorNotesCtrl = TextEditingController();

    // Reminder Schedule State (After X Days vs Daily from 1st day onward)
    String reminderMode = 'after_days'; // 'after_days' | 'daily'
    int reminderDays = 7;
    final customDaysCtrl = TextEditingController(text: '7');
    DateTime calculatedDueDate = DateTime.now().add(const Duration(days: 7));

    // Default existing debtor if any
    final existingDebtors =
        GashiRepository.instance.getCustomers(widget.businessId);
    if (existingDebtors.isNotEmpty) {
      selectedExistingDebtor = existingDebtors.first;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final baseSubtotal = _getBaseCartTotal(products);
            final totalDiscount = _overallDiscount;
            final subtotal =
                (baseSubtotal - totalDiscount).clamp(0.0, double.infinity);
            final discountPct = baseSubtotal > 0
                ? (totalDiscount / baseSubtotal * 100.0)
                : 0.0;

            final taxRate = business?.taxRate ?? 0.0;
            final hasTax = taxRate > 0.0;
            final taxAmount = hasTax ? (subtotal * (taxRate / 100.0)) : 0.0;
            final total = subtotal + taxAmount;
            final totalSlsh = total * _exchangeRate;

            // Items currently in the cart
            final cartItems = _cart.entries
                .map((e) {
                  final p = products.firstWhere(
                    (prod) => prod.id == e.key,
                    orElse: () => const Product(
                        id: -1, businessId: -1, name: '', sellingPrice: 0.0),
                  );
                  return MapEntry(p, e.value);
                })
                .where((entry) => entry.key.id != -1 && entry.value > 0)
                .toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.92,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header: Faahfaahinta Dalabka #ORD-XXXX • Staff • Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  context.tr('order_details'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2338),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: themeColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$orderId',
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Adeegaha: Cashier • Waqtiga: $nowTime',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E99AF),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Order Type Selector (ONLY for Restaurants!)
                    if (widget.businessType == BusinessType.restaurant) ...[
                      Text(
                        context.tr('order_type'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E99AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildOrderTypeChip(
                            label: 'Miis',
                            icon: Icons.restaurant,
                            type: 'Miis',
                            themeColor: themeColor,
                            setSheetState: setSheetState,
                          ),
                          const SizedBox(width: 8),
                          _buildOrderTypeChip(
                            label: 'Safaari',
                            icon: Icons.shopping_bag_outlined,
                            type: 'Safaari',
                            themeColor: themeColor,
                            setSheetState: setSheetState,
                          ),
                          const SizedBox(width: 8),
                          _buildOrderTypeChip(
                            label: 'Delivery',
                            icon: Icons.delivery_dining_outlined,
                            type: 'Delivery',
                            themeColor: themeColor,
                            setSheetState: setSheetState,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Selected Items Header & Add Items Trigger
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${context.tr('selected_items_title')} ($_cartCount)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E99AF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Text(
                            context.tr('add_more_items'),
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List of selected items with Stepper (Individual item bargain removed)
                    ...cartItems.map((entry) {
                      final prod = entry.key;
                      final qty = entry.value;
                      final basePrice = prod.sellingPrice;
                      final itemTotal = basePrice * qty;
                      final itemTotalSlsh = itemTotal * _exchangeRate;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F3F6)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          prod.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF1D2338),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (prod.categoryName.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F3F6),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            prod.categoryName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Item Price
                                  Text(
                                    '\$${itemTotal.toStringAsFixed(2)} (${itemTotalSlsh.toStringAsFixed(0)} SLSH)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stepper: [ - ] qty [ + ]
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _updateCartQuantity(prod.id, -1);
                                      setSheetState(() {});
                                      if (_cart.isEmpty) Navigator.pop(ctx);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      child: Icon(Icons.remove,
                                          size: 15, color: Color(0xFF4B5563)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _addToCart(prod.id);
                                      setSheetState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      child: Icon(Icons.add,
                                          size: 15, color: themeColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // ========================================================
                    // TRANSACTION MODE SELECTOR: IIB TOOS AH vs DEYN
                    // ========================================================
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                isDebtMode = false;
                                if (_selectedPaymentMethod ==
                                    GashiPaymentMethods.debt) {
                                  _selectedPaymentMethod =
                                      GashiPaymentMethods.zaad;
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isDebtMode
                                    ? themeColor
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  context.tr('direct_sale'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: !isDebtMode
                                        ? Colors.white
                                        : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                isDebtMode = true;
                                _selectedPaymentMethod =
                                    GashiPaymentMethods.debt;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isDebtMode
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  context.tr('credit_sale_tab'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDebtMode
                                        ? Colors.white
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // PAYMENT OPTIONS (ONLY shown when Iib Toos ah is active!)
                    // When Deyn is clicked, this section completely disappears!
                    if (!isDebtMode) ...[
                      Text(
                        context.tr('pos_payment_channel').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E99AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Non-overflowing horizontal payment cards row
                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPaymentCard(
                              method: GashiPaymentMethods.zaad,
                              title: 'Zaad',
                              subtitle: 'Telesom',
                              badgeColor: const Color(0xFF10B981),
                              badgeText: 'Z',
                              themeColor: themeColor,
                              setSheetState: setSheetState,
                            ),
                            const SizedBox(width: 8),
                            _buildPaymentCard(
                              method: GashiPaymentMethods.edahab,
                              title: 'e-Dahab',
                              subtitle: 'Somtel',
                              badgeColor: const Color(0xFFF59E0B),
                              badgeText: 'eD',
                              themeColor: themeColor,
                              setSheetState: setSheetState,
                            ),
                            const SizedBox(width: 8),
                            _buildPaymentCard(
                              method: GashiPaymentMethods.cash,
                              title: 'Kaash',
                              subtitle: 'USD / SLSH',
                              badgeColor: const Color(0xFF3B82F6),
                              badgeIcon: Icons.payments_outlined,
                              themeColor: themeColor,
                              setSheetState: setSheetState,
                            ),
                            const SizedBox(width: 8),
                            _buildPaymentCard(
                              method: GashiPaymentMethods.kaashplus,
                              title: 'Kaashplus',
                              subtitle: 'Soltelco',
                              badgeColor: const Color(0xFF8B5CF6),
                              badgeText: 'K+',
                              themeColor: themeColor,
                              setSheetState: setSheetState,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // DEBTOR INFORMATION (ONLY shown when Deyn mode is active!)
                    if (isDebtMode) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Xogta Macmiilka Daynta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Deyn Diiwaangashan',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Segmented Toggle: Macmiil Hore vs Macmiil Cusub
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: Center(
                                      child: Text(
                                          context.tr('debtor_type_existing')),
                                    ),
                                    selected: !isNewDebtor,
                                    selectedColor: const Color(0xFFEF4444),
                                    labelStyle: TextStyle(
                                      color: !isNewDebtor
                                          ? Colors.white
                                          : const Color(0xFF1D2338),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      setSheetState(() => isNewDebtor = false);
                                    },
                                    showCheckmark: false,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Center(
                                      child:
                                          Text(context.tr('debtor_type_new')),
                                    ),
                                    selected: isNewDebtor,
                                    selectedColor: const Color(0xFFEF4444),
                                    labelStyle: TextStyle(
                                      color: isNewDebtor
                                          ? Colors.white
                                          : const Color(0xFF1D2338),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      setSheetState(() => isNewDebtor = true);
                                    },
                                    showCheckmark: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Existing Debtor Selector
                            if (!isNewDebtor) ...[
                              if (existingDebtors.isEmpty)
                                const Text(
                                  'Wax macmiil dayn hore leh ma jiraan. Fadlan dooro "Macmiil Cusub".',
                                  style: TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 12),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Customer>(
                                      isExpanded: true,
                                      value: selectedExistingDebtor,
                                      hint: Text(context
                                          .tr('debtor_select_prompt')),
                                      items: existingDebtors.map((c) {
                                        return DropdownMenuItem<Customer>(
                                          value: c,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${c.name} (${c.phone})',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                '\$${c.currentCreditBalance.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Color(0xFFEF4444),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setSheetState(() =>
                                              selectedExistingDebtor = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ] else ...[
                              // New Debtor Registration Form
                              TextField(
                                controller: newDebtorNameCtrl,
                                decoration: InputDecoration(
                                  hintText: context.tr('debtor_name_prompt'),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newDebtorPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: context.tr('debtor_phone_prompt'),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newDebtorNotesCtrl,
                                decoration: InputDecoration(
                                  hintText: context.tr('debtor_notes_prompt'),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],

                            // ----------------------------------------------------
                            // CREDIT REMINDER SCHEDULE (After X Days vs Daily from 1st day)
                            // ----------------------------------------------------
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFFECACA)),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                const Icon(Icons.notifications_active_outlined,
                                    color: Color(0xFFEF4444), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('reminder_schedule'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Dooro muddada ama jadwalka xusuusinta dayntan:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Reminder Mode Choice: After X Days vs Daily from Day 1
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        reminderMode = 'after_days';
                                        calculatedDueDate = DateTime.now().add(Duration(days: reminderDays));
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: reminderMode == 'after_days' ? const Color(0xFFEF4444) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: reminderMode == 'after_days' ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.date_range,
                                            size: 20,
                                            color: reminderMode == 'after_days' ? Colors.white : const Color(0xFF4B5563),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.tr('reminder_mode_after_days'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: reminderMode == 'after_days' ? Colors.white : const Color(0xFF1D2338),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setSheetState(() {
                                        reminderMode = 'daily';
                                        reminderDays = 1;
                                        calculatedDueDate = DateTime.now().add(const Duration(days: 1));
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: reminderMode == 'daily' ? const Color(0xFFEF4444) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: reminderMode == 'daily' ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.repeat,
                                            size: 20,
                                            color: reminderMode == 'daily' ? Colors.white : const Color(0xFF4B5563),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.tr('reminder_mode_daily'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: reminderMode == 'daily' ? Colors.white : const Color(0xFF1D2338),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // If "after_days": Show Preset Day Chips (1, 3, 7, 14, 30, or Custom)
                            if (reminderMode == 'after_days') ...[
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [1, 3, 7, 14, 30].map((d) {
                                  final isSel = reminderDays == d;
                                  return ChoiceChip(
                                    label: Text('$d ${context.tr('reminder_presets_days')}'),
                                    selected: isSel,
                                    selectedColor: const Color(0xFFEF4444),
                                    labelStyle: TextStyle(
                                      color: isSel ? Colors.white : const Color(0xFF374151),
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setSheetState(() {
                                          reminderDays = d;
                                          customDaysCtrl.text = d.toString();
                                          calculatedDueDate = DateTime.now().add(Duration(days: d));
                                        });
                                      }
                                    },
                                    showCheckmark: false,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: customDaysCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: context.tr('reminder_custom_days'),
                                        labelStyle: const TextStyle(fontSize: 11),
                                        suffixText: context.tr('reminder_presets_days'),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        final parsed = int.tryParse(val);
                                        if (parsed != null && parsed > 0) {
                                          setSheetState(() {
                                            reminderDays = parsed;
                                            calculatedDueDate = DateTime.now().add(Duration(days: parsed));
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'Dooro Taariikh (Pick Date)',
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: const Icon(Icons.calendar_month, color: Color(0xFFEF4444), size: 20),
                                    ),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate: calculatedDueDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (picked != null) {
                                        final daysDiff = picked.difference(DateTime.now()).inDays + 1;
                                        setSheetState(() {
                                          calculatedDueDate = picked;
                                          reminderDays = daysDiff > 0 ? daysDiff : 1;
                                          customDaysCtrl.text = reminderDays.toString();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],

                            // Feedback / Information Box about the selected reminder
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    reminderMode == 'daily' ? Icons.info_outline : Icons.event_available,
                                    size: 16,
                                    color: const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reminderMode == 'daily'
                                          ? 'Xusuusin maalin kasta laga bilaabo berrito (${DateTime.now().add(const Duration(days: 1)).day}/${DateTime.now().add(const Duration(days: 1)).month}/${DateTime.now().add(const Duration(days: 1)).year}) ilaa laga bixiyo.'
                                          : 'Waqtiga Bixinta: ${calculatedDueDate.day}/${calculatedDueDate.month}/${calculatedDueDate.year} ($reminderDays maalmood kadib)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ========================================================
                    // AMOUNT BREAKDOWN BOX (With Highly Visible Gorgortan Button)
                    // ========================================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                      ),
                      child: Column(
                        children: [
                          // Base Subtotal (if discount or bargain was given)
                          if (totalDiscount != 0.0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr('base_price')}:',
                                  style: const TextStyle(
                                      color: Color(0xFF8E99AF), fontSize: 12),
                                ),
                                Text(
                                  '\$${baseSubtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF8E99AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  totalDiscount > 0
                                      ? 'Gorgortan / Dhimis (${discountPct.toStringAsFixed(1)}%):'
                                      : 'Gorgortan / Dheeraad (+${(-discountPct).toStringAsFixed(1)}%):',
                                  style: TextStyle(
                                    color: totalDiscount > 0
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF0284C7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  totalDiscount > 0
                                      ? '-\$${totalDiscount.toStringAsFixed(2)} (-${(totalDiscount * _exchangeRate).toStringAsFixed(0)} SLSH)'
                                      : '+\$${(-totalDiscount).toStringAsFixed(2)} (+${(-totalDiscount * _exchangeRate).toStringAsFixed(0)} SLSH)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: totalDiscount > 0
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Net Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${context.tr('pos_subtotal')}:',
                                style: const TextStyle(
                                    color: Color(0xFF4B5563), fontSize: 13),
                              ),
                              Text(
                                '\$${subtotal.toStringAsFixed(2)} (${(subtotal * _exchangeRate).toStringAsFixed(0)} SLSH)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF1D2338),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Tax Line (Strictly omitted if 0%)
                          if (hasTax) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${context.tr('pos_tax')} (${taxRate.toStringAsFixed(0)}%):',
                                  style: const TextStyle(
                                      color: Color(0xFF10B981), fontSize: 13),
                                ),
                                Text(
                                  '+\$${taxAmount.toStringAsFixed(2)} (${(taxAmount * _exchangeRate).toStringAsFixed(0)} SLSH)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 18),

                          // Total in bold USD and SLSH
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('pos_total_amount'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1D2338),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Heerka: 1 USD = ${_exchangeRate.toStringAsFixed(0)} SLSH',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8E99AF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: isDebtMode
                                          ? const Color(0xFFEF4444)
                                          : themeColor,
                                    ),
                                  ),
                                  Text(
                                    '${totalSlsh.toStringAsFixed(0)} SLSH',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1D2338),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ==================================================
                          // HIGHLY VISIBLE GORGORTAN / BARGAIN BUTTON
                          // ==================================================
                          InkWell(
                            onTap: () => _showOverallBargainDialog(
                              ctx,
                              baseSubtotal,
                              totalDiscount,
                              setSheetState,
                              themeColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: totalDiscount != 0.0
                                    ? themeColor.withValues(alpha: 0.08)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: totalDiscount != 0.0
                                      ? themeColor.withValues(alpha: 0.35)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: totalDiscount != 0.0
                                              ? themeColor.withValues(alpha: 0.18)
                                              : const Color(0xFFE2E8F0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.local_offer,
                                          size: 16,
                                          color: totalDiscount != 0.0
                                              ? themeColor
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Gorgortan / Qiimo Dhimis',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: totalDiscount != 0.0
                                                  ? themeColor
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                          Text(
                                            totalDiscount != 0.0
                                                ? (totalDiscount > 0
                                                    ? 'Laga dhimay: -\$${totalDiscount.toStringAsFixed(2)} (${discountPct.toStringAsFixed(1)}% dhimis)'
                                                    : 'Lagu daray: +\$${(-totalDiscount).toStringAsFixed(2)} (+${(-discountPct).toStringAsFixed(1)}% dheeraad)')
                                                : 'Guji si aad wadarta guud gorgortan uga dhinto',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: totalDiscount != 0.0
                                                  ? themeColor
                                                  : const Color(0xFF64748B),
                                              fontWeight: totalDiscount != 0.0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: themeColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      totalDiscount != 0.0
                                          ? 'Wax ka beddel'
                                          : '+ Gorgortan',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Confirm Action Button with Printer Icon (🖨 Xaqiiji)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDebtMode
                              ? const Color(0xFFEF4444)
                              : themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.print, size: 20),
                        label: Text(
                          context.tr('confirm_print'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          int? finalCustomerId;
                          String finalCustomerName = 'Walk-in Customer';

                          if (isDebtMode) {
                            if (isNewDebtor) {
                              final enteredName =
                                  newDebtorNameCtrl.text.trim();
                              if (enteredName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Fadlan geli magaca macmiilka daynta qaatay'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final newCustomer =
                                  GashiRepository.instance.addCustomer(
                                Customer(
                                  id: 0,
                                  businessId: widget.businessId,
                                  name: enteredName,
                                  phone: newDebtorPhoneCtrl.text.trim(),
                                  totalDebt: 0.0,
                                  paidDebt: 0.0,
                                  currentCreditBalance: 0.0,
                                  dueDate: calculatedDueDate,
                                  reminderMode: reminderMode,
                                  reminderDays: reminderDays,
                                  status: 'unpaid',
                                  notes: newDebtorNotesCtrl.text.trim(),
                                  createdAt: DateTime.now(),
                                ),
                              );
                              finalCustomerId = newCustomer.id;
                              finalCustomerName = newCustomer.name;
                            } else {
                              if (selectedExistingDebtor != null) {
                                finalCustomerId = selectedExistingDebtor!.id;
                                finalCustomerName =
                                    selectedExistingDebtor!.name;
                                GashiRepository.instance.updateCustomerReminder(
                                  customerId: finalCustomerId,
                                  reminderMode: reminderMode,
                                  reminderDays: reminderDays,
                                  dueDate: calculatedDueDate,
                                );
                              }
                            }
                          }

                          // Prepare sale items
                          final saleItems = <SaleItem>[];
                          _cart.forEach((pId, qty) {
                            final p = products
                                .firstWhere((item) => item.id == pId);
                            final unitPrice = p.sellingPrice;
                            saleItems.add(
                              SaleItem(
                                id: DateTime.now().millisecondsSinceEpoch,
                                saleId: 0,
                                productId: pId,
                                productName: p.name,
                                quantity: qty,
                                unitPrice: unitPrice,
                                total: unitPrice * qty,
                              ),
                            );
                          });

                          // Save sale to offline-first repository
                          GashiRepository.instance.recordSale(
                            businessId: widget.businessId,
                            customerId: finalCustomerId,
                            customerName: finalCustomerName,
                            totalAmount: total,
                            discount: totalDiscount,
                            paidAmount: isDebtMode ? 0.0 : total,
                            paymentStatus: isDebtMode ? 'credit' : 'paid',
                            paymentMethod: isDebtMode
                                ? GashiPaymentMethods.debt
                                : _selectedPaymentMethod,
                            customAttributes: {
                              if (widget.businessType == BusinessType.restaurant)
                                'order_type': _selectedOrderType,
                              'order_id': orderId,
                              if (totalDiscount != 0.0)
                                'negotiated_discount': totalDiscount,
                              if (isDebtMode) ...{
                                'reminder_mode': reminderMode,
                                'reminder_days': reminderDays,
                                'due_date': calculatedDueDate.toIso8601String(),
                                'debtor_notes': isNewDebtor
                                    ? newDebtorNotesCtrl.text.trim()
                                    : (selectedExistingDebtor?.notes ?? ''),
                              },
                            },
                            items: saleItems,
                          );

                          setState(() {
                            _cart.clear();
                            _overallDiscount = 0.0;
                          });
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isDebtMode
                                    ? 'Daynta waa la diiwaangeliyay: $finalCustomerName (\$${total.toStringAsFixed(2)})'
                                    : 'Iibka waa la xaqiijiyay via $_selectedPaymentMethod (\$${total.toStringAsFixed(2)})',
                              ),
                              backgroundColor: isDebtMode
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
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

  // Dialog to bargain / negotiate the overall total of the order
  void _showOverallBargainDialog(
    BuildContext context,
    double baseSubtotal,
    double currentDiscount,
    StateSetter setSheetState,
    Color themeColor,
  ) {
    final currentNet = baseSubtotal - currentDiscount;
    final targetPriceCtrl =
        TextEditingController(text: currentNet.toStringAsFixed(2));
    final discountCtrl =
        TextEditingController(text: currentDiscount.toStringAsFixed(2));

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) {
          final parsedTargetPrice =
              double.tryParse(targetPriceCtrl.text.trim());
          final parsedDiscount = double.tryParse(discountCtrl.text.trim());

          final bool hasValidNumbers = parsedTargetPrice != null &&
              parsedDiscount != null &&
              targetPriceCtrl.text.trim().isNotEmpty &&
              discountCtrl.text.trim().isNotEmpty;

          final double effectivePrice = parsedTargetPrice ?? baseSubtotal;
          final double effectiveDiscount =
              parsedDiscount ?? (baseSubtotal - effectivePrice);

          // Discount percentage relative to baseSubtotal:
          final double discountPct = baseSubtotal > 0
              ? (effectiveDiscount / baseSubtotal * 100.0)
              : 0.0;

          // Percentage of original cost:
          final double costPct = baseSubtotal > 0
              ? (effectivePrice / baseSubtotal * 100.0)
              : 0.0;

          // Minimum and maximum allowed prices:
          // 50% min cost (max 50% discount) and 150% max cost
          final double minAllowedPrice = baseSubtotal * 0.50;
          final double maxAllowedPrice = baseSubtotal * 1.50;

          final bool isUnderMin = effectivePrice < (minAllowedPrice - 0.009);
          final bool isOverMax = effectivePrice > (maxAllowedPrice + 0.009);

          final bool isValid = hasValidNumbers &&
              !isUnderMin &&
              !isOverMax &&
              effectivePrice >= 0;

          String? validationMessage;
          if (!hasValidNumbers) {
            validationMessage = 'Fadlan geli lambar sax ah (Please enter a valid amount)';
          } else if (isUnderMin) {
            validationMessage =
                '⚠️ Qiimuhu kama yaraan karo 50% (\$${minAllowedPrice.toStringAsFixed(2)}). Dhimistu waa ${discountPct.toStringAsFixed(1)}% (ugu badnaan 50%).';
          } else if (isOverMax) {
            validationMessage =
                '⚠️ Qiimuhu kama badnaan karo 150% (\$${maxAllowedPrice.toStringAsFixed(2)}). Qiimaha waa ${costPct.toStringAsFixed(1)}% (ugu badnaan 150%).';
          }

          // Calculated percentage options for quick reduction chips:
          final quickPercentages = [5, 10, 15, 20, 25, 30, 50];

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER BANNER WITH MODULE MATCHING TINT ---
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.08),
                      border: Border(
                        bottom: BorderSide(
                            color: themeColor.withValues(alpha: 0.22), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: themeColor.withValues(alpha: 0.35)),
                          ),
                          child: Icon(
                            Icons.local_offer_rounded,
                            color: themeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gorgortanka Wadarta Guud',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Xadku waa 50% ilaa 150% ee qiimaha asalka ah',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: themeColor,
                          splashRadius: 18,
                          onPressed: () => Navigator.pop(dlgCtx),
                        ),
                      ],
                    ),
                  ),

                  // --- BODY CONTENT ---
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- LIVE CALCULATION SUMMARY CARD ---
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              // 1. Original Subtotal
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Wadarta Hore',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${baseSubtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                    Text(
                                      '${(baseSubtotal * _exchangeRate).toStringAsFixed(0)} SLSH',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. Minus / Discount Badge (Always shows what percentage is the discount)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: !isValid
                                      ? const Color(0xFFFEF2F2)
                                      : (effectiveDiscount > 0
                                          ? const Color(0xFFFEF2F2)
                                          : (effectiveDiscount < 0
                                              ? const Color(0xFFF0FDF4)
                                              : const Color(0xFFF1F5F9))),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !isValid
                                        ? const Color(0xFFFECACA)
                                        : (effectiveDiscount > 0
                                            ? const Color(0xFFFECACA)
                                            : (effectiveDiscount < 0
                                                ? const Color(0xFFBBF7D0)
                                                : const Color(0xFFE2E8F0))),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          effectiveDiscount >= 0
                                              ? Icons.remove_circle_outline
                                              : Icons.add_circle_outline,
                                          size: 12,
                                          color: effectiveDiscount > 0
                                              ? const Color(0xFFDC2626)
                                              : (effectiveDiscount < 0
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFF94A3B8)),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          effectiveDiscount >= 0
                                              ? '-\$${effectiveDiscount.toStringAsFixed(2)}'
                                              : '+\$${(-effectiveDiscount).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: effectiveDiscount > 0
                                                ? const Color(0xFFDC2626)
                                                : (effectiveDiscount < 0
                                                    ? const Color(0xFF16A34A)
                                                    : const Color(0xFF94A3B8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      effectiveDiscount >= 0
                                          ? '${discountPct.toStringAsFixed(1)}% dhimis'
                                          : '+${(-discountPct).toStringAsFixed(1)}% dheeraad',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: effectiveDiscount > 0
                                            ? const Color(0xFFDC2626)
                                            : (effectiveDiscount < 0
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFF94A3B8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 3. New Payable Total Badge
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isValid
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isValid
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isValid
                                            ? 'Wadarta Bixinta'
                                            : 'Qiime Qaldan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isValid
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                      Text(
                                        '\$${effectivePrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isValid
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      Text(
                                        '${(effectivePrice * _exchangeRate).toStringAsFixed(0)} SLSH',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isValid
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // --- LIVE PERCENTAGE & VALIDATION STATUS BANNER ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isValid
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isValid
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isValid
                                    ? Icons.info_outline_rounded
                                    : Icons.warning_amber_rounded,
                                size: 16,
                                color: isValid
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isValid
                                      ? (effectiveDiscount >= 0
                                          ? 'Dhimista hadda: ${discountPct.toStringAsFixed(1)}% (${costPct.toStringAsFixed(1)}% ee qiimaha asalka)'
                                          : 'Dheeraadka hadda: +${(-discountPct).toStringAsFixed(1)}% (${costPct.toStringAsFixed(1)}% ee qiimaha asalka)')
                                      : validationMessage!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isValid
                                        ? const Color(0xFF1E40AF)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // --- QUICK REDUCTION CHIPS (CALCULATED FROM PERCENTAGES) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bolt,
                                    size: 14, color: themeColor),
                                const SizedBox(width: 4),
                                const Text(
                                  'Dhimis Degdeg ah (Quick Reductions):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Boqolkiiba la xisaabiyay',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: quickPercentages.map((pct) {
                            final discVal = (baseSubtotal * pct / 100.0);
                            final isSelected = hasValidNumbers &&
                                (effectiveDiscount - discVal).abs() < 0.01;
                            return InkWell(
                              onTap: () {
                                final newNet = baseSubtotal - discVal;
                                targetPriceCtrl.text =
                                    newNet.toStringAsFixed(2);
                                discountCtrl.text = discVal.toStringAsFixed(2);
                                setDlgState(() {});
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? themeColor
                                      : themeColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? themeColor
                                        : themeColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '-\$${discVal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : themeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.25)
                                            : themeColor.withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '$pct%',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : themeColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // --- INPUT 1: NEW SOLD-AT TOTAL ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isUnderMin || isOverMax)
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFCBD5E1),
                              width: (isUnderMin || isOverMax) ? 1.5 : 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.point_of_sale_rounded,
                                          size: 15, color: Color(0xFF0284C7)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Wadarta Cusub (Sold-At Total)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '≈ ${(effectivePrice * _exchangeRate).toStringAsFixed(0)} SLSH',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: targetPriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: (isUnderMin || isOverMax)
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: (isUnderMin || isOverMax)
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF0284C7),
                                  ),
                                  helperText:
                                      '50% min (\$${minAllowedPrice.toStringAsFixed(2)}) - 150% max (\$${maxAllowedPrice.toStringAsFixed(2)})',
                                  helperStyle: TextStyle(
                                    fontSize: 10,
                                    color: (isUnderMin || isOverMax)
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF64748B),
                                    fontWeight: (isUnderMin || isOverMax)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  hintText:
                                      'Tusaale: ${(baseSubtotal * 0.9).toStringAsFixed(2)}',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: (isUnderMin || isOverMax)
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF0284C7),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  final parsed = double.tryParse(val.trim());
                                  if (parsed != null) {
                                    final calcDiscount = baseSubtotal - parsed;
                                    discountCtrl.text =
                                        calcDiscount.toStringAsFixed(2);
                                  } else if (val.trim().isEmpty) {
                                    discountCtrl.text = '';
                                  }
                                  setDlgState(() {});
                                },
                              ),
                            ],
                          ),
                        ),

                        // --- OR DIVIDER ---
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0))),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'AMA (OR)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0))),
                            ],
                          ),
                        ),

                        // --- INPUT 2: DISCOUNT AMOUNT ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isUnderMin || isOverMax)
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFCBD5E1),
                              width: (isUnderMin || isOverMax) ? 1.5 : 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.discount_outlined,
                                          size: 15, color: Color(0xFFD97706)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Lacagta Laga Dhimayo (Discount)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '≈ ${(effectiveDiscount * _exchangeRate).toStringAsFixed(0)} SLSH',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: discountCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: (isUnderMin || isOverMax)
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  prefixText: '-\$ ',
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: (isUnderMin || isOverMax)
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFFD97706),
                                  ),
                                  helperText:
                                      'Dhimis: ${discountPct.toStringAsFixed(1)}% (Ugu badnaan 50%)',
                                  helperStyle: TextStyle(
                                    fontSize: 10,
                                    color: isUnderMin
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF64748B),
                                    fontWeight: isUnderMin
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  hintText:
                                      'Tusaale: ${(baseSubtotal * 0.1).toStringAsFixed(2)}',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: (isUnderMin || isOverMax)
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFFD97706),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  final parsed = double.tryParse(val.trim());
                                  if (parsed != null) {
                                    final calcNet = baseSubtotal - parsed;
                                    targetPriceCtrl.text =
                                        calcNet.toStringAsFixed(2);
                                  } else if (val.trim().isEmpty) {
                                    targetPriceCtrl.text = '';
                                  }
                                  setDlgState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- ACTIONS FOOTER ---
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
                        // Reset button
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(
                                  color: Color(0xFFCBD5E1)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _overallDiscount = 0.0;
                              });
                              setSheetState(() {});
                              Navigator.pop(dlgCtx);
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text(
                              'Dib u Celi',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Confirm Bargain button (Disabled if outside 50% - 150%)
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isValid
                                  ? themeColor
                                  : const Color(0xFFCBD5E1),
                              foregroundColor: isValid
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              disabledBackgroundColor:
                                  const Color(0xFFE2E8F0),
                              disabledForegroundColor:
                                  const Color(0xFF94A3B8),
                              elevation: isValid ? 1 : 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isValid
                                ? () {
                                    setState(() {
                                      _overallDiscount = effectiveDiscount;
                                    });
                                    setSheetState(() {});
                                    Navigator.pop(dlgCtx);
                                  }
                                : null,
                            icon: Icon(
                              isValid
                                  ? Icons.check_circle_rounded
                                  : Icons.block_rounded,
                              size: 17,
                            ),
                            label: const Text(
                              'Xaqiiji Gorgortanka',
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
      ),
    );
  }

  // Helper widget to build order type chips (Miis, Safaari, Delivery)
  Widget _buildOrderTypeChip({
    required String label,
    required IconData icon,
    required String type,
    required Color themeColor,
    required StateSetter setSheetState,
  }) {
    final isSel = _selectedOrderType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setSheetState(() => _selectedOrderType = type);
          setState(() => _selectedOrderType = type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? themeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? themeColor : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSel ? themeColor : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? themeColor : const Color(0xFF1D2338),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build payment method cards with fixed height to prevent overflow
  Widget _buildPaymentCard({
    required String method,
    required String title,
    required String subtitle,
    required Color badgeColor,
    String? badgeText,
    IconData? badgeIcon,
    required Color themeColor,
    required StateSetter setSheetState,
  }) {
    final isSel = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setSheetState(() => _selectedPaymentMethod = method);
        setState(() => _selectedPaymentMethod = method);
      },
      child: Container(
        width: 102,
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? themeColor.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? themeColor : const Color(0xFFE5E7EB),
            width: 1.5, // Constant width prevents size shifts & overflows
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: badgeIcon != null
                    ? Icon(badgeIcon, color: Colors.white, size: 15)
                    : Text(
                        badgeText ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSel ? themeColor : const Color(0xFF1D2338),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8E99AF),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
