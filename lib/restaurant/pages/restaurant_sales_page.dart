import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../general_features/models/gashi_models.dart';
import '../../general_features/repository/gashi_repository.dart';

class RestaurantSalesPage extends StatefulWidget {
  const RestaurantSalesPage({super.key});

  @override
  State<RestaurantSalesPage> createState() => _RestaurantSalesPageState();
}

class _RestaurantSalesPageState extends State<RestaurantSalesPage> {
  String _selectedPeriod = 'Maanta';
  String _selectedType = 'Dhammaan';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    GashiRepository.instance.addListener(_onRepoChanged);
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GashiRepository.instance.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getOrderList() {
    final sales = GashiRepository.instance.getSales(3);
    return sales.map((sale) {
      final orderIdStr = sale.id.toString();
      final shortId = orderIdStr.length > 4
          ? orderIdStr.substring(orderIdStr.length - 4)
          : orderIdStr;
      final type =
          sale.orderType.isNotEmpty && sale.orderType != 'standard'
              ? sale.orderType
              : 'Miis';
      final isDineIn = type == 'Miis';
      final isDelivery = type == 'Delivery';

      String typeLabel = 'Takeaway';
      IconData icon = Icons.shopping_bag_outlined;
      if (isDineIn) {
        typeLabel = 'Dine-in';
        icon = Icons.table_restaurant;
      } else if (isDelivery) {
        typeLabel = 'Geyn';
        icon = Icons.two_wheeler;
      }

      String title = sale.customAttributes['title'] ??
          (isDineIn
              ? (sale.customAttributes['table'] != null
                  ? 'Miiska ${sale.customAttributes['table']}'
                  : 'Miis')
              : (isDelivery ? 'Delivery' : 'Safaari'));

      Color paymentColor = const Color(0xFF00A859); // Zaad
      final pmLower = sale.paymentMethod.toLowerCase();
      if (pmLower.contains('dahab')) {
        paymentColor = const Color(0xFFF58220);
      } else if (pmLower.contains('kaash') || pmLower.contains('cash')) {
        paymentColor = const Color(0xFF2563EB);
      } else if (sale.paymentStatus != 'paid') {
        paymentColor = const Color(0xFFDC2626);
      }

      final itemsSummary = sale.items.isNotEmpty
          ? sale.items.map((i) => '${i.quantity}x ${i.productName}').join(', ')
          : 'Dalab Cunto';

      final isPaid = sale.paymentStatus == 'paid';
      return {
        'id': '#ORD-$shortId',
        'time': DateFormat('hh:mm a').format(sale.createdAt),
        'title': title,
        'type': type,
        'typeLabel': typeLabel,
        'payment': sale.paymentMethod,
        'paymentColor': paymentColor,
        'items': itemsSummary,
        'customer': sale.customerName,
        'location': sale.deliveryLocation ?? sale.customAttributes['delivery_location'],
        'price': sale.totalAmount,
        'status': isPaid
            ? 'Dhammaystiran'
            : (sale.paymentStatus == 'credit' ? 'Dayn' : 'Qayb la bixiyay'),
        'statusBg': isPaid ? const Color(0xFFE6F7F0) : const Color(0xFFFFF5F5),
        'statusText': isPaid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        'icon': icon,
        'sale': sale,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = _getOrderList();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));

    final filteredOrders = allOrders.where((order) {
      final sale = order['sale'] as Sale;
      final createdAt = sale.createdAt;

      // Period filter
      bool matchesPeriod = true;
      if (_selectedPeriod == 'Maanta') {
        matchesPeriod = createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;
      } else if (_selectedPeriod == 'Toddobaadkan') {
        matchesPeriod = createdAt.isAfter(weekAgo);
      } else if (_selectedPeriod == 'Bishan') {
        matchesPeriod = createdAt.year == now.year && createdAt.month == now.month;
      }

      if (!matchesPeriod) return false;

      final matchesSearch = order['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['items'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (order['location'] != null && order['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesType = _selectedType == 'Dhammaan' || order['type'] == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    final totalRevenue = filteredOrders.fold<double>(0.0, (sum, o) => sum + (o['price'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('sales_title'),
              style: const TextStyle(
                color: Color(0xFF1D2338),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              context.tr('sales_subtitle'),
              style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Period selector pill (Maanta / Toddobaadkan / Bishan)
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF1D2338)),
                style: const TextStyle(
                  color: Color(0xFF1D2338),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                items: const [
                  DropdownMenuItem(value: 'Maanta', child: Text('Maanta (Today)')),
                  DropdownMenuItem(value: 'Toddobaadkan', child: Text('Toddobaadkan (This Week)')),
                  DropdownMenuItem(value: 'Bishan', child: Text('Bishan (This Month)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Metric Cards Grid (Same styling as Dashboard)
            _buildMetricsGrid(totalRevenue, filteredOrders.length),
            const SizedBox(height: 16),

            // Payment Methods summary bar
            _buildPaymentMethodsBreakdown(filteredOrders),
            const SizedBox(height: 16),

            // Search Bar
            Container(
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
                      decoration: const InputDecoration(
                        hintText: 'Raadi dalab, macmiil ama cunto...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
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
            const SizedBox(height: 14),

            // Filter Chips by Order Type
            Row(
              children: [
                _buildFilterChip('Dhammaan', 'Dhammaan'),
                const SizedBox(width: 8),
                _buildFilterChip('Miis', 'Miis'),
                const SizedBox(width: 8),
                _buildFilterChip('Safaari', 'Safaari'),
                const SizedBox(width: 8),
                _buildFilterChip('Delivery', 'Delivery'),
              ],
            ),
            const SizedBox(height: 16),

            // Orders list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('sales_order_history'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                Text(
                  '${filteredOrders.length} dalab',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E99AF)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Orders List (Matching Restaurant Recent Orders styling)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return GestureDetector(
                  onTap: () => _showReceiptModal(context, order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      children: [
                        // ID & Time
                        SizedBox(
                          width: 78,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['id'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1D2338),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order['time'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF3EB),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            order['icon'] as IconData,
                            color: const Color(0xFFFF5200),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title & items
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1D2338),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (order['paymentColor'] as Color).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order['payment'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: order['paymentColor'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order['items'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          '\$${(order['price'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order['statusBg'],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: order['statusText'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5200) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5200) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(double totalRev, int totalOrders) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.attach_money,
                iconBg: const Color(0xFFE6F7F0),
                iconColor: const Color(0xFF10B981),
                label: 'Wadarta Iibka',
                value: '\$${totalRev.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.receipt_long_outlined,
                iconBg: const Color(0xFFFFF3EB),
                iconColor: const Color(0xFFFF5200),
                label: 'Tirada Dalabaadka',
                value: '$totalOrders',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.trending_up,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Celcelis Dalab',
                value: totalOrders > 0
                    ? '\$${(totalRev / totalOrders).toStringAsFixed(2)}'
                    : '\$0.00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Zaad / eDahab',
                value: '84%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsBreakdown(List<Map<String, dynamic>> orders) {
    double zaad = 0;
    double edahab = 0;
    double cash = 0;
    double debt = 0;
    double total = 0;

    for (final o in orders) {
      final p = (o['price'] as double? ?? 0.0);
      total += p;
      final pm = (o['payment'] as String? ?? '').toLowerCase();
      final status = (o['status'] as String? ?? '');
      if (status == 'Dayn') {
        debt += p;
      } else if (pm.contains('dahab')) {
        edahab += p;
      } else if (pm.contains('kaash') || pm.contains('cash')) {
        cash += p;
      } else {
        zaad += p;
      }
    }

    final validTotal = total > 0 ? total : 1.0;
    final zaadPct = (zaad / validTotal * 100).round();
    final edahabPct = (edahab / validTotal * 100).round();
    final cashPct = (cash / validTotal * 100).round();
    final debtPct = (debt / validTotal * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hababka Lacag-Bixinta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2338),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (zaad > 0)
                    Expanded(flex: zaadPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFF00A859))), // Zaad
                  if (edahab > 0)
                    Expanded(flex: edahabPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFFF58220))), // e-Dahab
                  if (cash > 0)
                    Expanded(flex: cashPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFF2563EB))), // Kaash
                  if (debt > 0)
                    Expanded(flex: debtPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFFEF4444))), // Dayn
                  if (total <= 0)
                    const Expanded(child: ColoredBox(color: Color(0xFFE5E7EB))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegend(const Color(0xFF00A859), 'Zaad ($zaadPct%)'),
              _buildLegend(const Color(0xFFF58220), 'e-Dahab ($edahabPct%)'),
              _buildLegend(const Color(0xFF2563EB), 'Kaash ($cashPct%)'),
              if (debt > 0) _buildLegend(const Color(0xFFEF4444), 'Dayn ($debtPct%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showReceiptModal(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['id']} - Faahfaahinta',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _receiptRow('Macmiilka:', order['customer']),
            if (order['location'] != null && order['location'].toString().isNotEmpty)
              _receiptRow('Goobta Geynta:', order['location'].toString()),
            _receiptRow('Waqtiga:', order['time']),
            _receiptRow('Nooca Dalabka:', '${order['title']} (${order['typeLabel']})'),
            _receiptRow('Habka Lacagta:', order['payment']),
            _receiptRow('Cuntooyinka:', order['items']),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wadarta Guud:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${(order['price'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5200),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Daabac Rasiidka (Print Receipt)'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rasiidka waxaa loo diray daabacaha!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)),
            ),
          ),
        ],
      ),
    );
  }
}
