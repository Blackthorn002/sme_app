import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../services/currency_service.dart';

// ============================================================================
// GENERAL SALES PAGE (Offline-First Sales History & Filtering for Retail, Pharmacy & Services)
// ============================================================================

class GeneralSalesPage extends StatefulWidget {
  final int businessId;
  final BusinessType businessType;

  const GeneralSalesPage({
    super.key,
    required this.businessId,
    required this.businessType,
  });

  @override
  State<GeneralSalesPage> createState() => _GeneralSalesPageState();
}

class _GeneralSalesPageState extends State<GeneralSalesPage> {
  String _selectedPeriod = 'Maanta'; // 'Maanta', 'Toddobaadkan', 'Bishan'
  String _selectedStatus = 'Dhammaan'; // 'Dhammaan', 'La Bixiyay', 'Dayn'
  String _selectedPaymentMethod = 'Dhammaan'; // 'Dhammaan', 'Zaad', 'e-Dahab', 'Kaash', 'Dayn'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    GashiRepository.instance.addListener(_onRepoChanged);
    CurrencyService.instance.addListener(_onRepoChanged);
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GashiRepository.instance.removeListener(_onRepoChanged);
    CurrencyService.instance.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  Color get _themeColor => widget.businessType.primaryColor;

  List<Sale> _getFilteredSales() {
    final sales = GashiRepository.instance.getSales(widget.businessId);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));

    return sales.where((sale) {
      final date = sale.createdAt;

      // 1. Period filter
      bool matchesPeriod = true;
      if (_selectedPeriod == 'Maanta') {
        matchesPeriod = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      } else if (_selectedPeriod == 'Toddobaadkan') {
        matchesPeriod = date.isAfter(weekAgo);
      } else if (_selectedPeriod == 'Bishan') {
        matchesPeriod = date.year == now.year && date.month == now.month;
      }

      if (!matchesPeriod) return false;

      // 2. Status filter
      if (_selectedStatus == 'La Bixiyay' && sale.paymentStatus != 'paid') {
        return false;
      }
      if (_selectedStatus == 'Dayn' && sale.paymentStatus != 'credit') {
        return false;
      }

      // 3. Payment Method filter
      if (_selectedPaymentMethod != 'Dhammaan') {
        final pm = sale.paymentMethod.toLowerCase();
        if (_selectedPaymentMethod == 'Zaad' && !pm.contains('zaad')) return false;
        if (_selectedPaymentMethod == 'e-Dahab' && !pm.contains('dahab')) return false;
        if (_selectedPaymentMethod == 'Kaash' && (!pm.contains('kaash') && !pm.contains('cash'))) return false;
        if (_selectedPaymentMethod == 'Dayn' && sale.paymentStatus != 'credit') return false;
      }

      // 4. Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesId = sale.id.toString().contains(query);
        final matchesCustomer = sale.customerName.toLowerCase().contains(query);
        final matchesItems = sale.items.any(
            (item) => item.productName.toLowerCase().contains(query));
        final matchesPayment = sale.paymentMethod.toLowerCase().contains(query);
        if (!matchesId && !matchesCustomer && !matchesItems && !matchesPayment) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSales = _getFilteredSales();

    // Summary calculations
    double totalRevenue = 0.0;
    double paidTotal = 0.0;
    double debtTotal = 0.0;
    double zaadTotal = 0.0;
    double edahabTotal = 0.0;
    double cashTotal = 0.0;

    for (final sale in filteredSales) {
      totalRevenue += sale.totalAmount;
      if (sale.paymentStatus == 'credit') {
        debtTotal += sale.totalAmount;
      } else {
        paidTotal += sale.totalAmount;
      }

      final pm = sale.paymentMethod.toLowerCase();
      if (sale.paymentStatus == 'credit') {
        // counted in debt
      } else if (pm.contains('dahab')) {
        edahabTotal += sale.totalAmount;
      } else if (pm.contains('kaash') || pm.contains('cash')) {
        cashTotal += sale.totalAmount;
      } else {
        zaadTotal += sale.totalAmount;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1D2338)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diiwaanka Iibka (Sales)',
              style: const TextStyle(
                color: Color(0xFF1D2338),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              '${widget.businessType.name.toUpperCase()} - Taariikhda Iibka',
              style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Daily exchange rate badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.currency_exchange, size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  '1\$ = ${CurrencyService.instance.dailyExchangeRate.toStringAsFixed(0)} SLSh',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Period selector pill (Maanta / Toddobaadkan / Bishan)
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: Icon(Icons.keyboard_arrow_down, size: 18, color: _themeColor),
                style: TextStyle(
                  color: _themeColor,
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
            // KPI Summary Metrics Cards
            _buildMetricsGrid(
              totalRevenue: totalRevenue,
              ordersCount: filteredSales.length,
              paidTotal: paidTotal,
              debtTotal: debtTotal,
            ),
            const SizedBox(height: 16),

            // Payment Methods Breakdown Bar
            _buildPaymentMethodsBreakdown(
              zaad: zaadTotal,
              edahab: edahabTotal,
              cash: cashTotal,
              debt: debtTotal,
              total: totalRevenue,
            ),
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
                        hintText: 'Raadi dalab, macmiil ama alaab...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
            const SizedBox(height: 12),

            // Status & Payment Method Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatusChip('Dhammaan', 'Dhammaan'),
                  const SizedBox(width: 6),
                  _buildStatusChip('La Bixiyay', 'La Bixiyay'),
                  const SizedBox(width: 6),
                  _buildStatusChip('Dayn', 'Dayn'),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
                  const SizedBox(width: 10),
                  _buildPaymentChip('Dhammaan Hababka', 'Dhammaan'),
                  const SizedBox(width: 6),
                  _buildPaymentChip('Zaad', 'Zaad', const Color(0xFF00A859)),
                  const SizedBox(width: 6),
                  _buildPaymentChip('e-Dahab', 'e-Dahab', const Color(0xFFF58220)),
                  const SizedBox(width: 6),
                  _buildPaymentChip('Kaash', 'Kaash', const Color(0xFF2563EB)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Orders list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Taariikhda Dalabaadka',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                Text(
                  '${filteredSales.length} iib',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E99AF)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Orders List
            if (filteredSales.isEmpty)
              Container(
                padding: const EdgeInsets.all(36),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F3F6)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Wax iib ah lama helin muddadan ($_selectedPeriod)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Iibka cusub ee POS-ka halkan ayaa si toos ah uga muuqan doona.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredSales.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final sale = filteredSales[index];
                  return _buildSaleCard(sale);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _themeColor : const Color(0xFFE5E7EB),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _themeColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

  Widget _buildPaymentChip(String label, String value, [Color? color]) {
    final isSelected = _selectedPaymentMethod == value;
    final chipColor = color ?? _themeColor;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : const Color(0xFFE5E7EB),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid({
    required double totalRevenue,
    required int ordersCount,
    required double paidTotal,
    required double debtTotal,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.attach_money,
                iconBg: _themeColor.withValues(alpha: 0.12),
                iconColor: _themeColor,
                title: 'Dakhliga Guud',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                subtitle: CurrencyService.instance.formatSlsh(totalRevenue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.shopping_bag_outlined,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                title: 'Tirada Iibka',
                value: '$ordersCount',
                subtitle: ordersCount == 1 ? '1 Dalab' : '$ordersCount Dalab',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.check_circle_outline,
                iconBg: const Color(0xFFE6F7F0),
                iconColor: const Color(0xFF10B981),
                title: 'La Bixiyay (Paid)',
                value: '\$${paidTotal.toStringAsFixed(2)}',
                subtitle: CurrencyService.instance.formatSlsh(paidTotal),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.pending_actions_outlined,
                iconBg: const Color(0xFFFDE8E8),
                iconColor: const Color(0xFFEF4444),
                title: 'Dayn (Credit)',
                value: '\$${debtTotal.toStringAsFixed(2)}',
                subtitle: CurrencyService.instance.formatSlsh(debtTotal),
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
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2338),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsBreakdown({
    required double zaad,
    required double edahab,
    required double cash,
    required double debt,
    required double total,
  }) {
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
            'Hababka Lacag-Bixinta (Payment Methods)',
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
                    Expanded(flex: zaadPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFF00A859))),
                  if (edahab > 0)
                    Expanded(flex: edahabPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFFF58220))),
                  if (cash > 0)
                    Expanded(flex: cashPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFF2563EB))),
                  if (debt > 0)
                    Expanded(flex: debtPct.clamp(1, 100), child: const ColoredBox(color: Color(0xFFEF4444))),
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
      mainAxisSize: MainAxisSize.min,
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

  Widget _buildSaleCard(Sale sale) {
    final isPaid = sale.paymentStatus == 'paid';
    final isCredit = sale.paymentStatus == 'credit';

    Color paymentColor = const Color(0xFF00A859);
    final pmLower = sale.paymentMethod.toLowerCase();
    if (pmLower.contains('dahab')) {
      paymentColor = const Color(0xFFF58220);
    } else if (pmLower.contains('kaash') || pmLower.contains('cash')) {
      paymentColor = const Color(0xFF2563EB);
    } else if (isCredit) {
      paymentColor = const Color(0xFFEF4444);
    }

    final itemsSummary = sale.items.isNotEmpty
        ? sale.items.map((i) => '${i.quantity}x ${i.productName}').join(', ')
        : 'Iib Alaab';

    return GestureDetector(
      onTap: () => _showReceiptModal(sale),
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
                    '#ORD-${sale.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1D2338),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('hh:mm a').format(sale.createdAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),

            // Icon Container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.businessType.icon,
                color: _themeColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),

            // Title & items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1D2338),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemsSummary,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: paymentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sale.paymentMethod,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: paymentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM').format(sale.createdAt),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${sale.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1D2338),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFFE6F7F0)
                        : (isCredit ? const Color(0xFFFDE8E8) : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPaid ? 'La Bixiyay' : (isCredit ? 'Dayn' : 'Qayb'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPaid
                          ? const Color(0xFF10B981)
                          : (isCredit ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(Sale sale) {
    final isPaid = sale.paymentStatus == 'paid';
    final isCredit = sale.paymentStatus == 'credit';
    final isPartial = sale.paymentStatus == 'partial';

    // Retrieve customer if associated
    final customer = sale.customerId != null
        ? GashiRepository.instance.getCustomerById(sale.customerId!)
        : null;

    final orderIdDisplay =
        sale.customAttributes['order_id'] ?? '#ORD-${sale.id}';
    final orderType = sale.orderType;
    final deliveryLocation = sale.deliveryLocation;
    final reminderMode = sale.customAttributes['reminder_mode'] as String?;
    final reminderDays = sale.customAttributes['reminder_days'] as int?;
    final dueDateStr = sale.customAttributes['due_date'] as String?;
    final debtorNotes = sale.customAttributes['debtor_notes'] as String?;

    DateTime? dueDate =
        dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Header with Drag Handle & Close
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_outlined,
                              color: _themeColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Faahfaahinta Iibka $orderIdDisplay',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2338),
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy - hh:mm a')
                                  .format(sale.createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF8E99AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Details Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFE6F7F0)
                              : (isCredit
                                  ? const Color(0xFFFDE8E8)
                                  : const Color(0xFFFEF3C7)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPaid
                                ? const Color(0xFF10B981)
                                : (isCredit
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF59E0B)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPaid
                                      ? Icons.check_circle_outline
                                      : (isCredit
                                          ? Icons.pending_actions
                                          : Icons.pie_chart_outline),
                                  color: isPaid
                                      ? const Color(0xFF10B981)
                                      : (isCredit
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFF59E0B)),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isPaid
                                      ? 'Iibkan waa la bixiyay'
                                      : (isCredit
                                          ? 'Iib Dayn ah (Credit)'
                                          : 'Qayb baa la bixiyay'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isPaid
                                        ? const Color(0xFF047857)
                                        : (isCredit
                                            ? const Color(0xFF991B1B)
                                            : const Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sale.paymentMethod,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2338),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Customer and Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Macmiilka:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280))),
                                Text(
                                  sale.customerName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D2338)),
                                ),
                              ],
                            ),
                            if (customer != null &&
                                customer.phone.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Taleefanka:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  Text(customer.phone,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF374151))),
                                ],
                              ),
                            ],
                            if (orderType.isNotEmpty &&
                                orderType != 'standard') ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Nooca Dalabka:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      orderType,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (deliveryLocation != null &&
                                deliveryLocation.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Goobta Gaadhsiinta:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  Text(deliveryLocation,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF374151))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // If Credit (Dayn), show reminder & debtor details
                      if (isCredit || isPartial) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.notifications_active_outlined,
                                      size: 16, color: Color(0xFFEF4444)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Xogta Daynta & Xusuusinta',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF991B1B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Deynta Ku Hadhey:',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  Text(
                                    '\$${(sale.totalAmount - sale.paidAmount).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444)),
                                  ),
                                ],
                              ),
                              if (reminderMode != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Jadwalka Xusuusinta:',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      reminderMode == 'daily'
                                          ? 'Maalin kasta (Maalinta 1-aad)'
                                          : '$reminderDays maalmood kadib',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF991B1B)),
                                    ),
                                  ],
                                ),
                              ],
                              if (dueDate != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Waqtiga Bixinta (Due):',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(dueDate),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D2338)),
                                    ),
                                  ],
                                ),
                              ],
                              if (debtorNotes != null &&
                                  debtorNotes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Damiin / Xusuusin:',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280))),
                                    Text(debtorNotes,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF374151))),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Items Purchased Section
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 16, color: Color(0xFF1D2338)),
                          SizedBox(width: 6),
                          Text(
                            'Alaabta La Gatay (Purchased Items)',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2338)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F3F6)),
                        ),
                        child: Column(
                          children: [
                            ...sale.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
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
                                            item.productName,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: Color(0xFF1D2338)),
                                          ),
                                          Text(
                                            '${item.quantity}x @ \$${item.unitPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${item.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D2338)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  if (sale.discount > 0) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Gorgortan / Dhimis:',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFEF4444))),
                                        Text(
                                            '-\$${sale.discount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFEF4444))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Wadarta Guud:',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D2338))),
                                      Text(
                                        '\$${sale.totalAmount.toStringAsFixed(2)} (${CurrencyService.instance.formatSlsh(sale.totalAmount)})',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: _themeColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    if (customer != null && customer.phone.isNotEmpty) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.phone,
                            size: 16, color: Color(0xFF4B5563)),
                        label: const Text('Wac',
                            style: TextStyle(color: Color(0xFF4B5563))),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Wicitaan: ${customer.phone}')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _themeColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.print_outlined,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Daabac Rasiidka (Print)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Rasiidka $orderIdDisplay waa la daabacay!'),
                              backgroundColor: _themeColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
