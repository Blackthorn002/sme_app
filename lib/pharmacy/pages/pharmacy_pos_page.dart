import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../fake_data/pharmacy_pos_data.dart';

class PharmacyPosPage extends StatefulWidget {
  final List<PharmacyMenuItem> menuItems;
  final List<PharmacyOrderType> orderTypes;
  final List<PharmacyPaymentMethod> paymentMethods;
  final List<PharmacyCategoryIconItem> categoryIconItems;
  final PharmacySessionInfo sessionInfo;
  final PharmacyCustomerInfo customerInfo;
  final PharmacyTextLabels labels;

  const PharmacyPosPage({
    super.key,
    this.menuItems = samplePharmacyMenuItems,
    this.orderTypes = samplePharmacyOrderTypes,
    this.paymentMethods = samplePharmacyPaymentMethods,
    this.categoryIconItems = samplePharmacyCategoryIcons,
    this.sessionInfo = const PharmacySessionInfo(),
    this.customerInfo = const PharmacyCustomerInfo(),
    this.labels = const PharmacyTextLabels(),
  });

  @override
  State<PharmacyPosPage> createState() => _PharmacyPosPageState();
}

class _PharmacyPosPageState extends State<PharmacyPosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late List<PharmacyCartItem> _cart;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryIconItems.isNotEmpty 
        ? widget.categoryIconItems.first.title 
        : widget.labels.allCategory;
    _selectedPaymentMethod = widget.paymentMethods.isNotEmpty 
        ? widget.paymentMethods.first.id 
        : 'Zaad';

    _cart = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(PharmacyMenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(PharmacyCartItem(
          item: item,
          tag: item.tag,
          note: item.note,
        ));
      }
    });
  }

  void _updateCartQuantity(String itemId, int change) {
    setState(() {
      final index = _cart.indexWhere((c) => c.item.id == itemId);
      if (index >= 0) {
        _cart[index].quantity += change;
        if (_cart[index].quantity <= 0) {
          _cart.removeAt(index);
        }
      }
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cart.removeWhere((c) => c.item.id == itemId);
    });
  }

  double get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => _cartSubtotal * (widget.sessionInfo.taxRatePercentage / 100.0);
  double get _cartTotal => _cartSubtotal + _taxAmount;
  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  List<PharmacyMenuItem> get _filteredItems {
    final queryWords = _searchQuery
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return widget.menuItems.where((item) {
      final itemSearchText = '${item.name} ${item.category} ${item.tag ?? ''}'.toLowerCase();
      final matchesSearch = queryWords.isEmpty || queryWords.every((word) => itemSearchText.contains(word));
      final matchesCategory = _selectedCategory == widget.labels.allCategory || 
                              _selectedCategory == 'Dhammaan' ||
                              item.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildIconCategoriesRow(),
                    const SizedBox(height: 16),
                    _buildSectionHeader(filtered.length),
                    const SizedBox(height: 14),
                    _buildFoodGrid(filtered),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_cart.isNotEmpty) _buildCartBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: const Icon(Icons.local_pharmacy, color: Color(0xFFEF4444), size: 30),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.labels.appName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                    height: 1.1,
                  ),
                ),
                Text(
                  widget.labels.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E99AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Color(0xFF1D2338), size: 24),
              visualDensity: VisualDensity.compact,
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_outlined, color: Color(0xFF1D2338), size: 26),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1D2338)),
              decoration: InputDecoration(
                hintText: widget.labels.searchHint,
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
              child: const Icon(Icons.cancel, color: Color(0xFF9CA3AF), size: 20),
            )
          else
            const Icon(Icons.qr_code_scanner, color: Color(0xFF6B7280), size: 22),
        ],
      ),
    );
  }

  Widget _buildIconCategoriesRow() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.categoryIconItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = widget.categoryIconItems[index];
          final isSelected = _selectedCategory == cat.title;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 86,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFF1F3F6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0xFFEF4444).withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, size: 22, color: isSelected ? Colors.white : const Color(0xFFEF4444)),
                  const SizedBox(height: 6),
                  Text(
                    cat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
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

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.labels.categoryTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = widget.labels.allCategory;
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: Row(
            children: [
              Text(
                widget.labels.allCategory,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E99AF)),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF8E99AF)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFoodGrid(List<PharmacyMenuItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text(
              widget.labels.emptySearchMessage,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return _buildFoodCard(items[index]);
      },
    );
  }

  Widget _buildFoodCard(PharmacyMenuItem item) {
    final cartIndex = _cart.indexWhere((c) => c.item.id == item.id);
    final cartQuantity = cartIndex >= 0 ? _cart[cartIndex].quantity : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cartQuantity > 0 ? const Color(0xFFEF4444) : const Color(0xFFF1F3F6),
          width: cartQuantity > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
                        ),
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                      ),
                      child: const Center(
                        child: Icon(Icons.medical_services, size: 32, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                ),
              ),
              if (cartQuantity > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removeFromCart(item.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$cartQuantity', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 2),
                          const Icon(Icons.close, size: 10, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2338), height: 1.15),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                      if (cartQuantity > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _updateCartQuantity(item.id, -1),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: cartQuantity == 1 ? const Color(0xFFEF4444) : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(cartQuantity == 1 ? Icons.delete_outline : Icons.remove, color: cartQuantity == 1 ? Colors.white : const Color(0xFFEF4444), size: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text('$cartQuantity', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                              ),
                              GestureDetector(
                                onTap: () => _addToCart(item),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => _addToCart(item),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
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
    );
  }

  Widget _buildCartBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -3)),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$_cartCount items', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.labels.cartBarTitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 2),
                Text('\$${_cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
              ],
            ),
            ElevatedButton(
              onPressed: _showCartBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                children: [
                  Text(widget.labels.viewOrderButton, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet() {
    bool isDaynPayment = false;
    final debtorNameCtrl = TextEditingController(text: widget.customerInfo.name);
    final debtorPhoneCtrl = TextEditingController(text: widget.customerInfo.phone);
    final paidNowCtrl = TextEditingController(text: '0.00');
    final dueDateCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.labels.orderDetailsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${widget.labels.selectedItemsLabel} ($_cartCount)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cart.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cartItem = _cart[index];
                              return _buildCartItemCard(cartItem, setSheetState);
                            },
                          ),
                          const SizedBox(height: 14),

                          // Customer Information Card (Collected for All Orders: Full Payment or Debt)
                          _buildCustomerInformationSection(
                            setSheetState: setSheetState,
                            isDaynPayment: isDaynPayment,
                            nameCtrl: debtorNameCtrl,
                            phoneCtrl: debtorPhoneCtrl,
                          ),
                          const SizedBox(height: 14),

                          // Payment Type & Dayn Switcher
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isDaynPayment ? 'NOOCA BIXINTA (DEYN)' : widget.labels.paymentMethodLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDaynPayment ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Lacag Buuxda'),
                                    selected: !isDaynPayment,
                                    selectedColor: const Color(0xFFEF4444),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: !isDaynPayment ? Colors.white : const Color(0xFF4B5563),
                                    ),
                                    onSelected: (val) {
                                      setSheetState(() => isDaynPayment = false);
                                    },
                                    showCheckmark: false,
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.assignment_late_outlined, size: 14, color: Colors.white),
                                    label: const Text('Dayn (Credit)'),
                                    selected: isDaynPayment,
                                    selectedColor: const Color(0xFFEF4444),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDaynPayment ? Colors.white : const Color(0xFF4B5563),
                                    ),
                                    onSelected: (val) {
                                      setSheetState(() => isDaynPayment = true);
                                    },
                                    showCheckmark: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (!isDaynPayment) ...[
                            _buildPaymentMethodSelector(setSheetState),
                          ] else ...[
                            // Dayn Details Card
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.assignment_late_outlined, color: Color(0xFFEF4444), size: 18),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Daawooyinkan waxa loo diiwaangelinayaa Dayn ahaan macmiilka kor ku xusan.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Qayb Hadda la Bixiyay (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            const SizedBox(height: 4),
                                            TextField(
                                              controller: paidNowCtrl,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              onChanged: (_) => setSheetState(() {}),
                                              decoration: InputDecoration(
                                                prefixText: '\$ ',
                                                hintText: '0.00',
                                                filled: true,
                                                fillColor: Colors.white,
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
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
                                            const Text('Waqtiga Bixinta / Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            const SizedBox(height: 4),
                                            TextField(
                                              controller: dueDateCtrl,
                                              decoration: InputDecoration(
                                                hintText: 'e.g. 7 maalmood',
                                                filled: true,
                                                fillColor: Colors.white,
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Builder(
                                    builder: (context) {
                                      final paid = double.tryParse(paidNowCtrl.text) ?? 0.0;
                                      final remainingDebt = (_cartTotal - paid).clamp(0.0, _cartTotal);
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: const Color(0xFFFCA5A5)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Deynta Ku Hadhi Doonta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B))),
                                                Text(
                                                  '\$${remainingDebt.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (paid > 0) ...[
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Habka Bixinta Qaybta Hadda (Payment Method):',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF991B1B)),
                                            ),
                                            const SizedBox(height: 8),
                                            _buildPaymentMethodSelector(setSheetState),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _buildCalculationSummaryCard(),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final name = debtorNameCtrl.text.trim();
                        if (isDaynPayment) {
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fadlan geli magaca macmiilka deynta loo qorayo!')),
                            );
                            return;
                          }
                          final paid = double.tryParse(paidNowCtrl.text) ?? 0.0;
                          final remaining = (_cartTotal - paid).clamp(0.0, _cartTotal);
                          Navigator.pop(context);
                          setState(() => _cart.clear());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(paid > 0
                                  ? 'Iibka waxa loo diiwaangeliyay DEYN ahaan Macmiilka: $name - Haraaga: \$${remaining.toStringAsFixed(2)} (Waxaa la bixiyay \$${paid.toStringAsFixed(2)} oo $_selectedPaymentMethod ah)!'
                                  : 'Iibka waxa loo diiwaangeliyay DEYN ahaan Macmiilka: $name (\$${remaining.toStringAsFixed(2)})!'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        } else {
                          final customerDisplayName = name.isNotEmpty ? name : 'Macmiil Caadi ah';
                          Navigator.pop(context);
                          setState(() => _cart.clear());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Iibka farmashiyaha ($customerDisplayName) ee \$${_cartTotal.toStringAsFixed(2)} si buuxda ayaa loogu bixiyay $_selectedPaymentMethod!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(isDaynPayment ? Icons.assignment_late_outlined : Icons.check_circle_outline, size: 20),
                      label: Text(
                        isDaynPayment
                            ? 'Diiwaangeli Daynta'
                            : '${widget.labels.confirmButtonLabel} ($_selectedPaymentMethod)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomerInformationSection({
    required StateSetter setSheetState,
    required bool isDaynPayment,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.person_outline, size: 18, color: Color(0xFFEF4444)),
                  SizedBox(width: 6),
                  Text(
                    'Macluumaadka Macmiilka (Customer Info)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
                  ),
                ],
              ),
              if (!isDaynPayment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Iibka Caadiga ah',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDaynPayment ? 'Magaca Macmiilka *' : 'Magaca Macmiilka',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDaynPayment ? const Color(0xFFDC2626) : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Geli magaca macmiilka',
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDaynPayment ? 'Taleefanka *' : 'Taleefanka',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDaynPayment ? const Color(0xFFDC2626) : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+252 63 ...',
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(PharmacyCartItem cartItem, StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D2338))),
                const SizedBox(height: 6),
                Text('\$${cartItem.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _updateCartQuantity(cartItem.item.id, -1);
                    setSheetState(() {});
                  },
                  child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.remove, size: 16, color: Color(0xFF4B5563))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338))),
                ),
                GestureDetector(
                  onTap: () {
                    _updateCartQuantity(cartItem.item.id, 1);
                    setSheetState(() {});
                  },
                  child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.add, size: 16, color: Color(0xFFEF4444))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(StateSetter setSheetState) {
    return Row(
      children: widget.paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method.id;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setSheetState(() => _selectedPaymentMethod = method.id);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: method.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: method.icon != null
                        ? Icon(method.icon, color: Colors.white, size: 16)
                        : Text(
                            method.symbol ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF1D2338),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtext,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8E99AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalculationSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.labels.subtotalLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              Text('\$${_cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.labels.taxLabel} (${widget.sessionInfo.taxRatePercentage}%)', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              Text('\$${_taxAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.labels.totalLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
              Text('\$${_cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            ],
          ),
        ],
      ),
    );
  }
}
