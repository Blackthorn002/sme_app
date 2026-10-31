import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../../general_features/models/gashi_models.dart';
import '../../general_features/repository/gashi_repository.dart';
import '../fake_data/service_pos_data.dart';
import '../services/service_controller.dart';
import 'service_services_page.dart';

// ============================================================================
// SERVICE POS PAGE WIDGET (MIRRORING RESTAURANT POS GENERAL PATTERNS)
// ============================================================================

class ServicePosPage extends StatefulWidget {
  final List<ServiceOrderType> orderTypes;
  final List<ServicePaymentMethod> paymentMethods;
  final List<ServiceCategoryIconItem> categoryIconItems;
  final ServicePosSessionInfo sessionInfo;
  final ServicePosCustomerInfo customerInfo;
  final ServicePosTextLabels labels;
  final List<ServiceCartItem>? initialCart;
  final ValueChanged<List<ServiceCartItem>>? onOrderConfirmed;

  const ServicePosPage({
    super.key,
    this.orderTypes = sampleServiceOrderTypes,
    this.paymentMethods = sampleServicePaymentMethods,
    this.categoryIconItems = sampleServiceCategoryIcons,
    this.sessionInfo = sampleServicePosSessionInfo,
    this.customerInfo = sampleServicePosCustomerInfo,
    this.labels = sampleServicePosTextLabels,
    this.initialCart,
    this.onOrderConfirmed,
  });

  @override
  State<ServicePosPage> createState() => _ServicePosPageState();
}

class _ServicePosPageState extends State<ServicePosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedCategory;
  late String _selectedOrderType;
  late String _selectedPaymentMethod;
  late List<ServiceCartItem> _cart;

  void _onServicesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ServiceController.instance.addListener(_onServicesChanged);
    _selectedCategory = widget.categoryIconItems.isNotEmpty
        ? widget.categoryIconItems.first.title
        : widget.labels.allCategory;
    _selectedOrderType = widget.orderTypes.isNotEmpty
        ? widget.orderTypes.first.id
        : 'Goobta';
    _selectedPaymentMethod = widget.paymentMethods.isNotEmpty
        ? widget.paymentMethods.first.id
        : 'Zaad';

    if (widget.initialCart != null) {
      _cart = List<ServiceCartItem>.from(widget.initialCart!);
    } else {
      // Default sample cart items
      final allServices = ServiceController.instance.services;
      _cart = [
        if (allServices.isNotEmpty)
          ServiceCartItem(
            service: allServices[0],
            quantity: 1,
            customerName: 'Cali Maxamed',
            customerPhone: '+252 63 4401122',
            referenceInfo: 'Toyota Prado #38921',
            note: 'Dhaqis buuxda iyo nadiifin gudaha ah',
          ),
      ];
    }
  }

  @override
  void dispose() {
    ServiceController.instance.removeListener(_onServicesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(ServiceItem service) {
    setState(() {
      final index = _cart.indexWhere((c) => c.service.id == service.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(ServiceCartItem(service: service, quantity: 1));
      }
    });
  }

  void _updateCartQuantity(String serviceId, int change) {
    setState(() {
      final index = _cart.indexWhere((c) => c.service.id == serviceId);
      if (index >= 0) {
        _cart[index].quantity += change;
        if (_cart[index].quantity <= 0) {
          _cart.removeAt(index);
        }
      }
    });
  }

  void _removeFromCart(String serviceId) {
    setState(() {
      _cart.removeWhere((c) => c.service.id == serviceId);
    });
  }

  double _overallDiscount = 0.0;

  double get _cartSubtotal => _cart.fold(0.0, (sum, c) => sum + c.totalPrice);
  double get _taxAmount =>
      ((_cartSubtotal - _overallDiscount).clamp(0.0, double.infinity)) *
      (widget.sessionInfo.taxRatePercentage / 100);
  double get _cartTotal =>
      ((_cartSubtotal - _overallDiscount).clamp(0.0, double.infinity)) + _taxAmount;
  int get _cartCount => _cart.fold(0, (sum, c) => sum + c.quantity);

  String _formatSecondaryCurrency(double usd) {
    final slsh = (usd * widget.sessionInfo.exchangeRate).round();
    return '${slsh.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${widget.sessionInfo.secondaryCurrency}';
  }

  List<ServiceItem> get _filteredServices {
    final allCatLabel = widget.labels.allCategory;
    final queryWords = _searchQuery
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final activeServices = ServiceController.instance.services;
    return activeServices.where((item) {
      final itemSearchText =
          '${item.name} ${item.category} ${item.technician ?? ''} ${item.tag ?? ''} ${item.note ?? ''}'.toLowerCase();

      final matchesSearch = queryWords.isEmpty ||
          queryWords.every((word) => itemSearchText.contains(word));

      final matchesCategory = _selectedCategory == allCatLabel ||
          _selectedCategory == 'Dhammaan' ||
          item.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredServices;

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
                    _buildServiceGrid(filtered),
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
  // TOP HEADER WIDGET (Matching Restaurant Top Header)
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
                'assets/gashi_logo_indigo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/gashi_logo_indigo.jpeg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.build_circle,
                    color: Color(0xFF4F46E5),
                    size: 28,
                  ),
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
              tooltip: 'Maamul Adeegyada',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ServiceServicesPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.miscellaneous_services_outlined,
                color: Color(0xFF4F46E5),
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
  // SEARCH BAR WIDGET (Matching Restaurant Search Bar)
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
  // ICON CATEGORY CARDS ROW (Matching Restaurant 72px Category Cards)
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
                color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F3F6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF4F46E5).withValues(alpha: 0.25)
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
                    color: isSelected ? Colors.white : const Color(0xFF4F46E5),
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
  // SECTION HEADER WIDGET ("Adeegyada 7" & "Dhammaan >")
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
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
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
  // SERVICE GRID (3 COLUMNS - EXACTLY LIKE RESTAURANT FOOD GRID)
  // --------------------------------------------------------------------------
  Widget _buildServiceGrid(List<ServiceItem> items) {
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
        return _buildServiceCard(item);
      },
    );
  }

  // --------------------------------------------------------------------------
  // SERVICE CARD ITEM (Matching Restaurant Food Card: 3-column, direct counter)
  // --------------------------------------------------------------------------
  Widget _buildServiceCard(ServiceItem item) {
    final cartIndex = _cart.indexWhere((c) => c.service.id == item.id);
    final cartQuantity = cartIndex >= 0 ? _cart[cartIndex].quantity : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cartQuantity > 0 ? const Color(0xFF4F46E5) : const Color(0xFFF1F3F6),
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
              GestureDetector(
                onTap: () => _showServiceDetailModal(item),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: AppCachedImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.build_circle_outlined,
                            size: 32,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
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
                        color: const Color(0xFF4F46E5),
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
                )
              else
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 9, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          item.duration,
                          style: const TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
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
                  GestureDetector(
                    onTap: () => _showServiceDetailModal(item),
                    child: Text(
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
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      if (cartQuantity > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
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
                                    color: cartQuantity == 1 ? Colors.white : const Color(0xFF4F46E5),
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
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _addToCart(item),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5),
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
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
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
  // SERVICE DETAIL QUICK PREVIEW MODAL
  // --------------------------------------------------------------------------
  void _showServiceDetailModal(ServiceItem service) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: AppCachedImage(
                    imageUrl: service.imageUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.build_circle_outlined,
                    loadingColor: const Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                    ),
                  ),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatSecondaryCurrency(service.price),
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.category,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (service.technician != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_pin, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Text(
                      'Farsamo-yaqaan: ${service.technician}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
              if (service.note != null) ...[
                const SizedBox(height: 8),
                Text(
                  service.note!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.3),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _addToCart(service);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Ku dar Dalabka (Add to Cart)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // BOTTOM STICKY CART BAR (Matching Restaurant Sticky Cart Bar)
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
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_cartCount items',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
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
                Row(
                  children: [
                    Text(
                      '\$${_cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${_formatSecondaryCurrency(_cartTotal)})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E99AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _showCartBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
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
  // ORDER DETAILS BOTTOM SHEET MODAL (CHECKOUT & DAYN SUMMARY)
  // --------------------------------------------------------------------------
  void _showCartBottomSheet() {
    bool isDaynPayment = false;
    bool isWalkInCustomer = true;
    String selectedPayment = _selectedPaymentMethod;

    final customerNameCtrl = TextEditingController(text: widget.customerInfo.name);
    final customerPhoneCtrl = TextEditingController(text: widget.customerInfo.phone);
    final customerRefCtrl = TextEditingController(text: widget.customerInfo.referenceInfo);
    final paidNowCtrl = TextEditingController(text: '0.00');
    Customer? selectedExistingDebtor;
    bool isNewDebtor = true;
    String reminderMode = 'days'; // 'days' or 'daily'
    int reminderDays = 7;
    DateTime calculatedDueDate = DateTime.now().add(const Duration(days: 7));
    final customDaysCtrl = TextEditingController(text: '7');

    showModalBottomSheet<void>(
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

                  // Header with Order # and Cashier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.labels.orderDetailsTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.sessionInfo.orderNumber,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Qasnaji: ${widget.sessionInfo.cashierName} • ${widget.sessionInfo.orderTime}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Color(0xFF4B5563)),
                        ),
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
                          // 1. Order Type Segmented Toggle (Matching Restaurant)
                          Text(
                            widget.labels.orderTypeLabel,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),
                          _buildOrderTypeSegmentedToggle(setSheetState),
                          const SizedBox(height: 14),

                          // 2. Customer Information Card (Collected for all sales: full payment or debt)
                          _buildCustomerInformationSection(
                            setSheetState: setSheetState,
                            isDaynPayment: isDaynPayment,
                            isWalkIn: isWalkInCustomer,
                            onToggleWalkIn: (val) {
                              setSheetState(() {
                                isWalkInCustomer = val;
                                if (val) {
                                  customerNameCtrl.text = 'Macmiil Caadi ah (Walk-in)';
                                  customerPhoneCtrl.text = '+252 63 0000000';
                                } else {
                                  customerNameCtrl.clear();
                                  customerPhoneCtrl.clear();
                                }
                              });
                            },
                            isNewDebtor: isNewDebtor,
                            onToggleNewDebtor: (val) {
                              setSheetState(() => isNewDebtor = val);
                            },
                            selectedExistingDebtor: selectedExistingDebtor,
                            onSelectDebtor: (deb) {
                              setSheetState(() => selectedExistingDebtor = deb);
                            },
                            nameCtrl: customerNameCtrl,
                            phoneCtrl: customerPhoneCtrl,
                            refCtrl: customerRefCtrl,
                          ),
                          const SizedBox(height: 14),

                          // 3. Selected Services List (Review & Quantity adjust)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.labels.selectedItemsLabel} ($_cartCount)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  widget.labels.addServiceLabel,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
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

                          // 4. Payment Mode & Dayn Switcher
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
                                    selectedColor: const Color(0xFF4F46E5),
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
                                      setSheetState(() {
                                        isDaynPayment = true;
                                        isWalkInCustomer = false; // Debt requires a real customer!
                                        if (customerNameCtrl.text.contains('Walk-in')) {
                                          customerNameCtrl.clear();
                                          customerPhoneCtrl.clear();
                                        }
                                      });
                                    },
                                    showCheckmark: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (!isDaynPayment) ...[
                            // Payment method selector
                            Row(
                              children: widget.paymentMethods.map((m) {
                                final isSelected = selectedPayment == m.id;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setSheetState(() => selectedPayment = m.id);
                                      setState(() => _selectedPaymentMethod = m.id);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? m.color.withValues(alpha: 0.12) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? m.color : const Color(0xFFE5E7EB),
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
                                            alignment: Alignment.center,
                                            child: m.icon != null
                                                ? Icon(m.icon, color: Colors.white, size: 16)
                                                : Text(
                                                    m.symbol ?? m.label.substring(0, 1),
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                  ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            m.label,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              fontSize: 12,
                                              color: const Color(0xFF1D2338),
                                            ),
                                          ),
                                          Text(
                                            m.subtext,
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            // Dayn breakdown card
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
                                    children: const [
                                      Icon(Icons.assignment_late_outlined, size: 18, color: Color(0xFFDC2626)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Diiwaangelinta Deynta Adeegga',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B)),
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
                                  const SizedBox(height: 14),

                                  // REMINDER SCHEDULE SECTION
                                  const Text(
                                    'Jadwalka Xusuusinta Deynta (Reminder Schedule)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ChoiceChip(
                                          label: const Text('Maalmo Kadib'),
                                          selected: reminderMode == 'days',
                                          selectedColor: const Color(0xFFEF4444),
                                          labelStyle: TextStyle(
                                            color: reminderMode == 'days' ? Colors.white : const Color(0xFF374151),
                                            fontWeight: reminderMode == 'days' ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                          onSelected: (val) {
                                            if (val) {
                                              setSheetState(() {
                                                reminderMode = 'days';
                                                calculatedDueDate = DateTime.now().add(Duration(days: reminderDays));
                                              });
                                            }
                                          },
                                          showCheckmark: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ChoiceChip(
                                          label: const Text('Maalin Kasta'),
                                          selected: reminderMode == 'daily',
                                          selectedColor: const Color(0xFFEF4444),
                                          labelStyle: TextStyle(
                                            color: reminderMode == 'daily' ? Colors.white : const Color(0xFF374151),
                                            fontWeight: reminderMode == 'daily' ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                          onSelected: (val) {
                                            if (val) {
                                              setSheetState(() {
                                                reminderMode = 'daily';
                                                calculatedDueDate = DateTime.now().add(const Duration(days: 1));
                                              });
                                            }
                                          },
                                          showCheckmark: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (reminderMode == 'days') ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: [1, 3, 7, 14, 30].map((d) {
                                        final isSel = reminderDays == d;
                                        return ChoiceChip(
                                          label: Text('$d Maalmood'),
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
                                              labelText: 'Tirada Maalmaha',
                                              labelStyle: const TextStyle(fontSize: 11),
                                              suffixText: 'maalmood',
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
                                              context: context,
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
                          ],
                          const SizedBox(height: 14),

                          // Calculation Summary Card
                          _buildCalculationSummaryCard(setSheetState),
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
                        final name = customerNameCtrl.text.trim();
                        final phone = customerPhoneCtrl.text.trim();
                        final ref = customerRefCtrl.text.trim();
                        final refNote = ref.isNotEmpty ? ' [$ref]' : '';
                        final phoneNote = phone.isNotEmpty ? ' ($phone)' : '';

                        final paidAmount = isDaynPayment
                            ? (double.tryParse(paidNowCtrl.text) ?? 0.0)
                            : _cartTotal;
                        final paymentStatus = isDaynPayment
                            ? (paidAmount > 0 ? 'partial' : 'credit')
                            : 'paid';

                        if (isDaynPayment) {
                          if (name.isEmpty || name.contains('Walk-in')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fadlan geli magaca dhabta ah ee macmiilka deynta loo qorayo!')),
                            );
                            return;
                          }
                        }

                        int? finalCustomerId;
                        if (isDaynPayment) {
                          if (isNewDebtor) {
                            final newCustomer = GashiRepository.instance.addCustomer(
                              Customer(
                                id: 0,
                                businessId: 4,
                                name: name,
                                phone: phone.isNotEmpty ? phone : '+252 63 0000000',
                                totalDebt: 0.0,
                                paidDebt: 0.0,
                                currentCreditBalance: 0.0,
                                dueDate: calculatedDueDate,
                                reminderMode: reminderMode,
                                reminderDays: reminderDays,
                                status: 'active',
                                notes: ref.isNotEmpty ? 'Tixraac: $ref' : 'Deyn Adeeg',
                                createdAt: DateTime.now(),
                              ),
                            );
                            finalCustomerId = newCustomer.id;
                          } else {
                            finalCustomerId = selectedExistingDebtor?.id;
                            if (finalCustomerId != null) {
                              GashiRepository.instance.updateCustomerReminder(
                                customerId: finalCustomerId,
                                reminderMode: reminderMode,
                                reminderDays: reminderDays,
                                dueDate: calculatedDueDate,
                              );
                            }
                          }
                        }

                        // Record sale into GashiRepository (offline-first, triggers GeneralSalesPage reactive updates)
                        GashiRepository.instance.recordSale(
                          businessId: 4, // Service
                          customerId: finalCustomerId,
                          customerName: isDaynPayment ? name : (name.isNotEmpty ? name : 'Macmiil Caadi ah'),
                          orderType: _selectedOrderType,
                          totalAmount: _cartTotal,
                          discount: _overallDiscount,
                          paidAmount: paidAmount,
                          paymentStatus: paymentStatus,
                          paymentMethod: isDaynPayment ? 'Credit' : selectedPayment,
                          customAttributes: {
                            'title': _selectedOrderType == 'Standard' ? 'Adeeg Dukaanka' : _selectedOrderType,
                            'cashier': widget.sessionInfo.cashierName,
                            'reference': ref,
                            'order_type': _selectedOrderType,
                            if (isDaynPayment) ...{
                              'due_date': calculatedDueDate,
                              'reminder_mode': reminderMode,
                              'reminder_days': reminderDays,
                            },
                          },
                          items: _cart.map((c) {
                            return SaleItem(
                              id: DateTime.now().millisecondsSinceEpoch + _cart.indexOf(c),
                              saleId: 0,
                              productId: null,
                              productName: c.service.name,
                              quantity: c.quantity,
                              unitPrice: c.service.price,
                              total: c.totalPrice,
                            );
                          }).toList(),
                        );

                        if (isDaynPayment) {
                          final remaining = (_cartTotal - paidAmount).clamp(0.0, _cartTotal);
                          if (widget.onOrderConfirmed != null) {
                            widget.onOrderConfirmed!(_cart);
                          }
                          Navigator.pop(context);
                          setState(() {
                            _cart.clear();
                            _overallDiscount = 0.0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Adeegga waxa loo diiwaangeliyay DEYN ahaan Macmiilka: $name$refNote (\$${remaining.toStringAsFixed(2)})!'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        } else {
                          // Full Payment
                          final customerDisplayName = name.isNotEmpty ? name : 'Macmiil Caadi ah';
                          if (widget.onOrderConfirmed != null) {
                            widget.onOrderConfirmed!(_cart);
                          }
                          Navigator.pop(context);
                          setState(() {
                            _cart.clear();
                            _overallDiscount = 0.0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Iibka adeegga ($customerDisplayName$phoneNote$refNote) si buuxda ayaa loo xaqiijiyay (\$${_cartTotal.toStringAsFixed(2)})!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDaynPayment ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(isDaynPayment ? Icons.assignment_late_outlined : Icons.print_outlined, size: 20),
                      label: Text(
                        isDaynPayment ? 'Diiwaangeli Daynta' : widget.labels.confirmButtonLabel,
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

  // --------------------------------------------------------------------------
  // ORDER TYPE SEGMENTED TOGGLE (Matching Restaurant)
  // --------------------------------------------------------------------------
  Widget _buildOrderTypeSegmentedToggle(StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
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
                      ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
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
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF4B5563),
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
                                  ? const Color(0xFF4F46E5).withValues(alpha: 0.8)
                                  : const Color(0xFF8E99AF),
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
                            color: Color(0xFF4F46E5),
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
  // CUSTOMER INFORMATION SECTION (Collected for all sales)
  // --------------------------------------------------------------------------
  Widget _buildCustomerInformationSection({
    required StateSetter setSheetState,
    required bool isDaynPayment,
    required bool isWalkIn,
    required ValueChanged<bool> onToggleWalkIn,
    required bool isNewDebtor,
    required ValueChanged<bool> onToggleNewDebtor,
    required Customer? selectedExistingDebtor,
    required ValueChanged<Customer?> onSelectDebtor,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController refCtrl,
  }) {
    final existingDebtors = GashiRepository.instance.getCustomers(4);

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
                  Icon(Icons.person_outline, size: 18, color: Color(0xFF4F46E5)),
                  SizedBox(width: 6),
                  Text(
                    'Macluumaadka Macmiilka (Customer Info)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
                  ),
                ],
              ),
              if (!isDaynPayment)
                Row(
                  children: [
                    const Text('Walk-in:', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    const SizedBox(width: 4),
                    Switch(
                      value: isWalkIn,
                      activeThumbColor: const Color(0xFF4F46E5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: onToggleWalkIn,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Cusub'),
                      selected: isNewDebtor,
                      selectedColor: const Color(0xFFEF4444),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNewDebtor ? Colors.white : const Color(0xFF4B5563),
                      ),
                      onSelected: (val) {
                        onToggleNewDebtor(true);
                        nameCtrl.clear();
                        phoneCtrl.clear();
                      },
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text('Jira'),
                      selected: !isNewDebtor,
                      selectedColor: const Color(0xFFEF4444),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: !isNewDebtor ? Colors.white : const Color(0xFF4B5563),
                      ),
                      onSelected: (val) {
                        onToggleNewDebtor(false);
                        if (existingDebtors.isNotEmpty) {
                          final deb = selectedExistingDebtor ?? existingDebtors.first;
                          onSelectDebtor(deb);
                          nameCtrl.text = deb.name;
                          phoneCtrl.text = deb.phone;
                        }
                      },
                      showCheckmark: false,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isDaynPayment && !isNewDebtor && existingDebtors.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  value: selectedExistingDebtor ?? existingDebtors.first,
                  isExpanded: true,
                  items: existingDebtors.map((c) {
                    return DropdownMenuItem<Customer>(
                      value: c,
                      child: Text(
                        '${c.name} (${c.phone}) - Deynta: \$${c.currentCreditBalance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                  onChanged: (c) {
                    if (c != null) {
                      onSelectDebtor(c);
                      nameCtrl.text = c.name;
                      phoneCtrl.text = c.phone;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tixraaca Qalabka / Gaadhiga (Vehicle Plate / Device Note)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: refCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Toyota Prado #38921 / iPhone 13 Pro',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // EDITABLE CART ITEM CARD (Matching Restaurant)
  // --------------------------------------------------------------------------
  Widget _buildCartItemCard(ServiceCartItem cartItem, StateSetter setSheetState) {
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
                      cartItem.service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1D2338),
                      ),
                    ),
                    if (cartItem.service.tag != null && cartItem.service.tag!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cartItem.service.tag!,
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
                if (cartItem.service.technician != null && cartItem.service.technician!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '* Farsamo-yaqaan: ${cartItem.service.technician}',
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
                        color: Color(0xFF4F46E5),
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
                    _updateCartQuantity(cartItem.service.id, -1);
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
                    _updateCartQuantity(cartItem.service.id, 1);
                    setSheetState(() {});
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.add, size: 16, color: Color(0xFF4F46E5)),
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
  // CALCULATION SUMMARY CARD (Matching Restaurant & Retail with Bargain)
  // --------------------------------------------------------------------------
  Widget _buildCalculationSummaryCard(StateSetter setSheetState) {
    const indigoTheme = Color(0xFF4F46E5);
    final discountPct = _cartSubtotal > 0
        ? (_overallDiscount / _cartSubtotal * 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.labels.subtotalLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
              Row(
                children: [
                  Text(
                    '\$${_cartSubtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: _overallDiscount > 0 ? TextDecoration.lineThrough : null,
                      color: _overallDiscount > 0 ? const Color(0xFF9CA3AF) : const Color(0xFF1D2338),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${_formatSecondaryCurrency(_cartSubtotal)})',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
          if (_overallDiscount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gorgortan / Dhimis (${discountPct.toStringAsFixed(1)}%):',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
                Text(
                  '-\$${_overallDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.labels.taxLabel} (${widget.sessionInfo.taxRatePercentage.toInt()}%)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              Row(
                children: [
                  Text(
                    '\$${_taxAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${_formatSecondaryCurrency(_taxAmount)})',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // BARGAIN / GORGORTAN TRIGGER BUTTON (Indigo theme)
          InkWell(
            onTap: () => _showOverallBargainDialog(
              context,
              _cartSubtotal,
              _overallDiscount,
              setSheetState,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _overallDiscount != 0.0
                    ? indigoTheme.withValues(alpha: 0.08)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _overallDiscount != 0.0
                      ? indigoTheme.withValues(alpha: 0.35)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _overallDiscount != 0.0
                              ? indigoTheme.withValues(alpha: 0.18)
                              : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_offer,
                          size: 15,
                          color: _overallDiscount != 0.0
                              ? indigoTheme
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gorgortan / Qiimo Dhimis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _overallDiscount != 0.0
                                  ? indigoTheme
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            _overallDiscount != 0.0
                                ? 'Laga dhimay: -\$${_overallDiscount.toStringAsFixed(2)} (${discountPct.toStringAsFixed(1)}% dhimis)'
                                : 'Guji si aad wadarta gorgortan uga dhinto',
                            style: TextStyle(
                              fontSize: 10,
                              color: _overallDiscount != 0.0
                                  ? indigoTheme
                                  : const Color(0xFF64748B),
                              fontWeight: _overallDiscount != 0.0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: indigoTheme,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _overallDiscount != 0.0 ? 'Wax ka beddel' : '+ Gorgortan',
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFD1D5DB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.labels.totalLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  Text(
                    _formatSecondaryCurrency(_cartTotal),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E99AF)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog to bargain / negotiate the overall total in Service POS (Indigo theme)
  void _showOverallBargainDialog(
    BuildContext context,
    double baseSubtotal,
    double currentDiscount,
    StateSetter setSheetState,
  ) {
    const themeColor = Color(0xFF4F46E5);
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

          final double discountPct = baseSubtotal > 0
              ? (effectiveDiscount / baseSubtotal * 100.0)
              : 0.0;
          final double costPct = baseSubtotal > 0
              ? (effectivePrice / baseSubtotal * 100.0)
              : 0.0;

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
            validationMessage = 'Fadlan geli lambar sax ah';
          } else if (isUnderMin) {
            validationMessage =
                '⚠️ Qiimuhu kama yaraan karo 50% (\$${minAllowedPrice.toStringAsFixed(2)}).';
          } else if (isOverMax) {
            validationMessage =
                '⚠️ Qiimuhu kama badnaan karo 150% (\$${maxAllowedPrice.toStringAsFixed(2)}).';
          }

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
                  // --- HEADER BANNER WITH INDIGO TINT ---
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
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: themeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
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
                              SizedBox(height: 2),
                              Text(
                                'Xadku waa 50% ilaa 150% ee qiimaha asalka ah',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6366F1),
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
                        // Live calculation summary card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
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
                                  ],
                                ),
                              ),
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
                                              : const Color(0xFF16A34A),
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
                                                : const Color(0xFF16A34A),
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
                                            : const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isValid
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isValid
                                          ? const Color(0xFFC7D2FE)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isValid ? 'Wadarta Bixinta' : 'Qiime Qaldan',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isValid
                                              ? themeColor
                                              : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                      Text(
                                        '\$${effectivePrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isValid
                                              ? themeColor
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

                        // Validation banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isValid
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isValid
                                  ? const Color(0xFFC7D2FE)
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
                                    ? themeColor
                                    : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isValid
                                      ? (effectiveDiscount >= 0
                                          ? 'Dhimista hadda: ${discountPct.toStringAsFixed(1)}% (${costPct.toStringAsFixed(1)}% ee qiimaha asalka)'
                                          : 'Dheeraadka hadda: +${(-discountPct).toStringAsFixed(1)}%')
                                      : validationMessage!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isValid
                                        ? themeColor
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Reductions chips
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.bolt,
                                    size: 14, color: themeColor),
                                SizedBox(width: 4),
                                Text(
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

                        // Inputs
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isUnderMin || isOverMax)
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.point_of_sale_rounded,
                                      size: 15, color: Color(0xFF4F46E5)),
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
                              const SizedBox(height: 6),
                              TextField(
                                controller: targetPriceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (val) {
                                  final numVal = double.tryParse(val.trim());
                                  if (numVal != null) {
                                    final calculatedDiscount =
                                        baseSubtotal - numVal;
                                    discountCtrl.text =
                                        calculatedDiscount.toStringAsFixed(2);
                                  }
                                  setDlgState(() {});
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.attach_money,
                                      size: 18, color: Color(0xFF4F46E5)),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Discount input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.local_offer_outlined,
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
                              const SizedBox(height: 6),
                              TextField(
                                controller: discountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (val) {
                                  final numVal = double.tryParse(val.trim());
                                  if (numVal != null) {
                                    final calculatedTarget =
                                        baseSubtotal - numVal;
                                    targetPriceCtrl.text =
                                        calculatedTarget.toStringAsFixed(2);
                                  }
                                  setDlgState(() {});
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.remove,
                                      size: 18, color: Color(0xFFD97706)),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _overallDiscount = 0.0;
                              });
                              setSheetState(() {});
                              Navigator.pop(dlgCtx);
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Dib u Celi',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
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
                            icon: const Icon(Icons.check_circle_rounded, size: 17),
                            label: const Text('Xaqiiji Gorgortanka',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
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
}
