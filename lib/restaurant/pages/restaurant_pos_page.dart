import 'package:flutter/material.dart';
import '../fake_data/restaurant_pos_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/restaurant_menu_controller.dart';
import 'restaurant_menu_page.dart';

// ============================================================================
// RESTAURANT POS PAGE WIDGET
// ============================================================================

class RestaurantPosPage extends StatefulWidget {
  final List<RestaurantMenuItem> menuItems;
  final List<PosOrderType> orderTypes;
  final List<PosPaymentMethod> paymentMethods;
  final List<CategoryIconItem> categoryIconItems;
  final PosSessionInfo sessionInfo;
  final PosCustomerInfo customerInfo;
  final PosTextLabels labels;
  final List<RestaurantCartItem>? initialCart;
  final ValueChanged<List<RestaurantCartItem>>? onOrderConfirmed;

  const RestaurantPosPage({
    super.key,
    this.menuItems = sampleRestaurantMenuItems,
    this.orderTypes = samplePosOrderTypes,
    this.paymentMethods = samplePosPaymentMethods,
    this.categoryIconItems = sampleCategoryIcons,
    this.sessionInfo = const PosSessionInfo(),
    this.customerInfo = const PosCustomerInfo(),
    this.labels = const PosTextLabels(),
    this.initialCart,
    this.onOrderConfirmed,
  });

  @override
  State<RestaurantPosPage> createState() => _RestaurantPosPageState();
}

class _RestaurantPosPageState extends State<RestaurantPosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedCategory;
  late String _selectedOrderType;
  late String _selectedPaymentMethod;
  late List<RestaurantCartItem> _cart;

  void _onMenuChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    RestaurantMenuController.instance.addListener(_onMenuChanged);
    _selectedCategory = widget.categoryIconItems.isNotEmpty 
        ? widget.categoryIconItems.first.title 
        : widget.labels.allCategory;
    _selectedOrderType = widget.orderTypes.isNotEmpty 
        ? widget.orderTypes.first.id 
        : 'Miis';
    _selectedPaymentMethod = widget.paymentMethods.isNotEmpty 
        ? widget.paymentMethods.first.id 
        : 'Zaad';

    if (widget.initialCart != null) {
      _cart = List.from(widget.initialCart!);
    } else {
      // Default sample cart matching the initial state
      _cart = [
        RestaurantCartItem(
          item: widget.menuItems.isNotEmpty ? widget.menuItems[0] : sampleRestaurantMenuItems[0],
          quantity: 1,
          tag: widget.menuItems.isNotEmpty ? widget.menuItems[0].tag : 'Hilib Geel',
          note: widget.menuItems.isNotEmpty ? widget.menuItems[0].note : 'Bariis dheeraad ah',
        ),
        RestaurantCartItem(
          item: widget.menuItems.length > 5 ? widget.menuItems[5] : sampleRestaurantMenuItems[5],
          quantity: 3,
          note: widget.menuItems.length > 5 ? widget.menuItems[5].note : 'Sambusa Qudaar',
        ),
      ];
    }
  }

  @override
  void dispose() {
    RestaurantMenuController.instance.removeListener(_onMenuChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(RestaurantMenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.item.id == item.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(RestaurantCartItem(
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

  // Dynamic calculations derived from sessionInfo and cart
  double get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => _cartSubtotal * (widget.sessionInfo.taxRatePercentage / 100.0);
  double get _cartTotal => _cartSubtotal + _taxAmount;
  int get _cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  String _formatSecondaryCurrency(double usd) {
    final int converted = (usd * widget.sessionInfo.exchangeRate).round();
    return '${converted.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${widget.sessionInfo.secondaryCurrency}';
  }

  List<RestaurantMenuItem> get _filteredItems {
    final allCatLabel = widget.labels.allCategory;
    // Word-based non-exact search: split search query into individual words
    final queryWords = _searchQuery
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final activeItems = RestaurantMenuController.instance.menuItems;
    return activeItems.where((item) {
      final itemSearchText =
          '${item.name} ${item.category} ${item.tag ?? ''} ${item.note ?? ''}'.toLowerCase();
      
      final matchesSearch = queryWords.isEmpty ||
          queryWords.every((word) => itemSearchText.contains(word));

      final matchesCategory = _selectedCategory == allCatLabel || 
                              _selectedCategory == 'Dhammaan' ||
                              (_selectedCategory == 'Cunto' && item.category == 'Cuntooyinka') ||
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

  // --------------------------------------------------------------------------
  // TOP HEADER WIDGET
  // --------------------------------------------------------------------------
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/gashi_logo_orange.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/gashi_logo.jpeg',
                  color: const Color(0xFFFF5200),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
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
              tooltip: 'Maamul Menu-ga',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const RestaurantMenuPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.restaurant_menu,
                color: Color(0xFFFF5200),
                size: 24,
              ),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Color(0xFF1D2338),
                size: 24,
              ),
              visualDensity: VisualDensity.compact,
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF1D2338),
                    size: 26,
                  ),
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

  // --------------------------------------------------------------------------
  // SEARCH BAR WIDGET
  // --------------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1D2338),
              ),
              decoration: InputDecoration(
                hintText: widget.labels.searchHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
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
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Icon(
                Icons.cancel,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            )
          else
            const Icon(
              Icons.qr_code_scanner,
              color: Color(0xFF6B7280),
              size: 22,
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ICON CATEGORY CARDS ROW WIDGET
  // --------------------------------------------------------------------------
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
            onTap: () {
              setState(() {
                _selectedCategory = cat.title;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF5200) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF5200) : const Color(0xFFF1F3F6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFF5200).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat.icon,
                    size: 22,
                    color: isSelected ? Colors.white : const Color(0xFFFF5200),
                  ),
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

  // --------------------------------------------------------------------------
  // SECTION HEADER WIDGET ("Cuntooyinka 12" & "Dhammaan >")
  // --------------------------------------------------------------------------
  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.labels.categoryTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2338),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5200),
                ),
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E99AF),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF8E99AF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // FOOD GRID (3 COLUMNS)
  // --------------------------------------------------------------------------
  Widget _buildFoodGrid(List<RestaurantMenuItem> items) {
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
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
        final item = items[index];
        return _buildFoodCard(item);
      },
    );
  }

  // --------------------------------------------------------------------------
  // FOOD CARD ITEM (Supports immediate selection & deselection)
  // --------------------------------------------------------------------------
  Widget _buildFoodCard(RestaurantMenuItem item) {
    final cartIndex = _cart.indexWhere((c) => c.item.id == item.id);
    final cartQuantity = cartIndex >= 0 ? _cart[cartIndex].quantity : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cartQuantity > 0 ? const Color(0xFFFF5200) : const Color(0xFFF1F3F6),
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
                    placeholder: (context, url) {
                      return Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF5200),
                            ),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFF3EB), Color(0xFFFFE4D6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 32,
                            color: Color(0xFFFF5200),
                          ),
                        ),
                      );
                    },
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
                        color: const Color(0xFFFF5200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$cartQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                      height: 1.15,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5200),
                        ),
                      ),
                      if (cartQuantity > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EB),
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
                                  child: Icon(
                                    cartQuantity == 1 ? Icons.delete_outline : Icons.remove,
                                    color: cartQuantity == 1 ? Colors.white : const Color(0xFFFF5200),
                                    size: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '$cartQuantity',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF5200),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _addToCart(item),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5200),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 14,
                                  ),
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
                              color: const Color(0xFFFF5200),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5200).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
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
    );
  }

  // --------------------------------------------------------------------------
  // BOTTOM STICKY CART BAR
  // --------------------------------------------------------------------------
  Widget _buildCartBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_cartCount items',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5200),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.labels.cartBarTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _showCartBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5200),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.labels.viewOrderButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
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

  // --------------------------------------------------------------------------
  // DYNAMIC ORDER DETAILS BOTTOM SHEET MODAL (CHECKOUT SUMMARY)
  // --------------------------------------------------------------------------
  void _showCartBottomSheet() {
    bool isDaynPayment = false;
    final isDineInInitial = _selectedOrderType == 'Miis';
    final debtorNameCtrl = TextEditingController(text: !isDineInInitial ? widget.customerInfo.name : '');
    final debtorPhoneCtrl = TextEditingController(text: !isDineInInitial ? widget.customerInfo.phone : '');
    final paidNowCtrl = TextEditingController(text: '0.00');
    final dueDateCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDineIn = _selectedOrderType == 'Miis';
            final activeOrderType = widget.orderTypes.firstWhere(
              (t) => t.id == _selectedOrderType,
              orElse: () => widget.orderTypes.first,
            );

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
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header differs depending on Dine-In vs Takeaway/Delivery
                  if (isDineIn) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.labels.orderDetailsTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D2338),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3EB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.sessionInfo.orderNumber,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF5200),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adeegaha: ${widget.sessionInfo.waiterName} • Waqtiga: ${widget.sessionInfo.orderTime}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DALABKA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5200),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tix: ${widget.sessionInfo.orderNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        if (widget.sessionInfo.prepTime.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3EB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFF5200).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 14,
                                  color: Color(0xFFFF5200),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.sessionInfo.prepTime,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF5200),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeOrderType.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Order Type Selector Cards
                          Text(
                            widget.labels.orderTypeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildOrderTypeSegmentedToggle(setSheetState),
                          const SizedBox(height: 14),

                          // If NOT Dine-In, show Customer Info Card ("Xogta Macaamiilka")
                          if (!isDineIn) ...[
                            _buildCustomerInfoCard(),
                            const SizedBox(height: 14),
                          ],

                          // Items Section: If Dine-In, show editable cart cards; if Safaari/Delivery, show prepared items card
                          if (isDineIn) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.labels.selectedItemsLabel} ($_cartCount)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    widget.labels.addFoodLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF5200),
                                    ),
                                  ),
                                ),
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
                          ] else ...[
                            _buildItemsPreparedCard(setSheetState, activeOrderType.label),
                            const SizedBox(height: 14),
                          ],

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
                                    selectedColor: const Color(0xFFFF5200),
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
                                          'Dalabkan waxa loo diiwaangelinayaa Dayn ahaan macmiilka kor ku xusan.',
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
                                                hintText: 'e.g. 3 maalmood',
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
                                      return Container(
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
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // Calculation Summary Card
                          _buildCalculationSummaryCard(isDineIn),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // Confirm Order Button
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
                          if (widget.onOrderConfirmed != null) {
                            widget.onOrderConfirmed!(_cart);
                          }
                          Navigator.pop(context);
                          setState(() {
                            _cart.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dalabka waxa loo diiwaangeliyay DEYN ahaan Macmiilka: $name (\$${remaining.toStringAsFixed(2)})!'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        } else {
                          final customerDisplayName = name.isNotEmpty ? name : 'Macmiil Caadi ah';
                          if (widget.onOrderConfirmed != null) {
                            widget.onOrderConfirmed!(_cart);
                          }
                          Navigator.pop(context);
                          setState(() {
                            _cart.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dalabka ($customerDisplayName) si buuxda ayaa loo bixiyay loona xaqiijiyay (\$${_cartTotal.toStringAsFixed(2)})!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDaynPayment ? const Color(0xFFEF4444) : const Color(0xFFFF5200),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(isDaynPayment ? Icons.assignment_late_outlined : Icons.print_outlined, size: 20),
                      label: Text(
                        isDaynPayment ? 'Diiwaangeli Daynta' : (isDineIn ? widget.labels.confirmButtonLabel : 'Xaqiiji Dalabka'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

  // --------------------------------------------------------------------------
  // ORDER TYPE SEGMENTED TOGGLE (Dynamic from widget.orderTypes)
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
                  Icon(Icons.person_outline, size: 18, color: Color(0xFFFF5200)),
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
                    color: const Color(0xFFFFF3EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Iibka Caadiga ah',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF5200)),
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

  // --------------------------------------------------------------------------
  Widget _buildOrderTypeSegmentedToggle(StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: widget.orderTypes.map((type) {
          final isSelected = _selectedOrderType == type.id;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setSheetState(() {
                  _selectedOrderType = type.id;
                });
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFFF5200), width: 1.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type.icon,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFFFF5200)
                                  : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFFFF5200)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        if (type.sublabel.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            type.sublabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFFF5200).withValues(alpha: 0.8)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: -4,
                        right: 2,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5200),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // EDITABLE CART ITEM CARD (FOR DINE-IN / MIIS)
  // --------------------------------------------------------------------------
  Widget _buildCartItemCard(RestaurantCartItem cartItem, StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cartItem.item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                    if (cartItem.tag != null && cartItem.tag!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cartItem.tag!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (cartItem.note != null && cartItem.note!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '* Qoraal: ${cartItem.note}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFFF5200),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${_formatSecondaryCurrency(cartItem.totalPrice)})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
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
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.remove, size: 16, color: Color(0xFF4B5563)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _updateCartQuantity(cartItem.item.id, 1);
                    setSheetState(() {});
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.add, size: 16, color: Color(0xFFFF5200)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // CUSTOMER INFO CARD ("Xogta Macaamiilka" - FOR SAFARI / DELIVERY)
  // --------------------------------------------------------------------------
  Widget _buildCustomerInfoCard() {
    final info = widget.customerInfo;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.labels.customerInfoTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ],
              ),
              if (info.customerStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    info.customerStatus,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Field 1: Customer Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F3F6)),
            ),
            child: Row(
              children: [
                const Text(
                  'Macaamiil: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Field 2: Tel + Provider badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F3F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      'Tel: ${info.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                  ],
                ),
                if (info.paymentProvider.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      info.paymentProvider,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Field 3: Lacagta la bixiyay + Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F3F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 14, color: Color(0xFFFF5200)),
                    const SizedBox(width: 4),
                    const Text(
                      'Lacagta la bixiyay: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '\$${info.paidAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                  ],
                ),
                if (info.paymentStatus.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      info.paymentStatus,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5200),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ITEMS PREPARED CARD ("Alaabta loo diyaarinayo Qaadasho" - FOR SAFARI / DELIVERY)
  // --------------------------------------------------------------------------
  Widget _buildItemsPreparedCard(StateSetter setSheetState, String orderTypeName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: Color(0xFFFF5200),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Alaabta loo diyaarinayo Qaadasho',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_cartCount xabbo',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5200),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items list from _cart
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cart.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cartItem = _cart[index];
              return Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cartItem.quantity}x',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cartItem.item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2338),
                        ),
                      ),
                      Text(
                        _formatSecondaryCurrency(cartItem.totalPrice),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PAYMENT METHOD SELECTOR (Dynamic from widget.paymentMethods)
  // --------------------------------------------------------------------------
  Widget _buildPaymentMethodSelector(StateSetter setSheetState) {
    return Row(
      children: widget.paymentMethods.map((m) {
        final isSelected = _selectedPaymentMethod == m.id;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setSheetState(() {
                _selectedPaymentMethod = m.id;
              });
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF7F2) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: m.color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: m.icon != null
                              ? Icon(m.icon, color: Colors.white, size: 18)
                              : Text(
                                  m.symbol ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.subtext,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --------------------------------------------------------------------------
  // DYNAMIC CALCULATION SUMMARY CARD
  // --------------------------------------------------------------------------
  Widget _buildCalculationSummaryCard(bool isDineIn) {
    final taxRate = widget.sessionInfo.taxRatePercentage;
    final taxLabel = isDineIn
        ? 'Canshuur (Tax ${taxRate.toInt()}%)'
        : (taxRate > 0
            ? '${widget.labels.taxLabel} (Tax ${taxRate.toStringAsFixed(taxRate.truncateToDouble() == taxRate ? 0 : 1)}%)'
            : '${widget.labels.taxLabel} (Tax 0%)');

    final subtotalLabel = isDineIn ? 'Wadarta Guud (Subtotal)' : widget.labels.subtotalLabel;
    final totalLabel = isDineIn ? 'Guud ahaan (Total)' : widget.labels.totalLabel;
    final exchangeRateInt = widget.sessionInfo.exchangeRate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtotalLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
              Row(
                children: [
                  Text(
                    '\$${_cartSubtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                  if (isDineIn) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${_formatSecondaryCurrency(_cartSubtotal)})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tax Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                taxLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
              Row(
                children: [
                  Text(
                    '\$${_taxAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                  if (isDineIn) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${_formatSecondaryCurrency(_taxAmount)})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFD1D5DB)),
          ),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isDineIn ? "Heerka" : "Sarifka"}: 1 USD = $exchangeRateInt ${widget.sessionInfo.secondaryCurrency}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5200),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5200),
                    ),
                  ),
                  Text(
                    _formatSecondaryCurrency(_cartTotal),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
