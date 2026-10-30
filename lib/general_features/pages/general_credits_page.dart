import 'package:flutter/material.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../widgets/offline_sync_banner.dart';

// ============================================================================
// GENERAL CREDITS / DEBT PAGE (Unified Across All Business Types)
// ============================================================================

class GeneralCreditsPage extends StatefulWidget {
  final int businessId;
  final BusinessType businessType;

  const GeneralCreditsPage({
    super.key,
    required this.businessId,
    required this.businessType,
  });

  @override
  State<GeneralCreditsPage> createState() => _GeneralCreditsPageState();
}

class _GeneralCreditsPageState extends State<GeneralCreditsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Dhammaan';

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
        final customers = repo.getCustomers(widget.businessId);

        final filtered = customers.where((c) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = c.name.toLowerCase().contains(query) ||
              c.phone.contains(query);

          final hasDebt = c.currentCreditBalance > 0;
          if (_selectedFilter == 'Deyn leh') {
            return matchesSearch && hasDebt;
          } else if (_selectedFilter == 'Dhammaystiray') {
            return matchesSearch && !hasDebt;
          }
          return matchesSearch;
        }).toList();

        final totalOutstanding = customers.fold<double>(
            0.0, (sum, c) => sum + c.currentCreditBalance);
        final activeDebtors =
            customers.where((c) => c.currentCreditBalance > 0).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credits & Customers',
                  style: TextStyle(
                      color: Color(0xFF1D2338),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  'Customer credit balances & payment records',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Add Credit Entry',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add_alt_1,
                      color: Colors.white, size: 20),
                ),
                onPressed: () => _openAddCustomerModal(context, themeColor),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineSyncBanner(),

                // 2x2 Metric Cards Grid
                _buildMetricsGrid(totalOutstanding, activeDebtors, themeColor),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                            hintText: 'Search customer name or phone...',
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
                const SizedBox(height: 12),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('Dhammaan', 'Dhammaan', themeColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('Deyn leh', 'Deyn leh', themeColor),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dhammaystiray', 'Dhammaystiray', themeColor),
                  ],
                ),
                const SizedBox(height: 16),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Customer Debt List',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2338)),
                    ),
                    Text(
                      '${filtered.length} customers',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF8E99AF)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Debtors List
                if (filtered.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F3F6)),
                    ),
                    child: const Center(
                      child: Text('No customers found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final customer = filtered[idx];
                      final isCleared = customer.currentCreditBalance <= 0;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            _openCustomerDetailsModal(context, customer, themeColor),
                        child: Container(
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
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: widget.businessType.softBgColor,
                                    child: Text(
                                      customer.name.isNotEmpty
                                          ? customer.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1D2338)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          customer.phone,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${customer.currentCreditBalance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: isCleared
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isCleared
                                              ? const Color(0xFFE6F7F0)
                                              : const Color(0xFFFDE8E8),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isCleared ? 'Dhammaystiray' : 'Deyn leh',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isCleared
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: Color(0xFFF1F3F6)),
                              const SizedBox(height: 8),

                              // Actions Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Account #${customer.id}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF9CA3AF)),
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          side: const BorderSide(
                                              color: Color(0xFFE5E7EB)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.phone_outlined,
                                            size: 14, color: Color(0xFF4B5563)),
                                        label: const Text('Wac',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF4B5563))),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Calling: ${customer.phone}')),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCleared
                                              ? const Color(0xFF9CA3AF)
                                              : themeColor,
                                          foregroundColor: Colors.white,
                                          visualDensity: VisualDensity.compact,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.attach_money,
                                            size: 14),
                                        label: const Text('Qaado Lacag',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: isCleared
                                            ? null
                                            : () => _openCollectPaymentModal(
                                                context, customer, themeColor),
                                      ),
                                    ],
                                  ),
                                ],
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
      },
    );
  }

  Widget _buildFilterChip(String label, String value, Color themeColor) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? themeColor : const Color(0xFFE5E7EB)),
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

  Widget _buildMetricsGrid(
      double totalOutstanding, int activeCount, Color themeColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.money_off,
                iconBg: const Color(0xFFFDE8E8),
                iconColor: const Color(0xFFEF4444),
                label: 'Total Debt',
                value: '\$${totalOutstanding.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_outline,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Active Debtors',
                value: '$activeCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.task_alt,
                iconBg: const Color(0xFFE6F7F0),
                iconColor: const Color(0xFF10B981),
                label: 'Collected Today',
                value: '\$85.00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.pie_chart_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Average Debt',
                value: activeCount > 0
                    ? '\$${(totalOutstanding / activeCount).toStringAsFixed(2)}'
                    : '\$0.00',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // COLLECT REPAYMENT MODAL
  // ============================================================================
  void _openCollectPaymentModal(
      BuildContext context, Customer customer, Color themeColor) {
    final amountCtrl = TextEditingController();
    String selectedMethod = 'Zaad';

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
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Collect Repayment - ${customer.name}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    'Remaining Debt: \$${customer.currentCreditBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  const Text('Payment Amount (\$):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText:
                          customer.currentCreditBalance.toStringAsFixed(2),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Payment Channel:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Zaad', 'e-Dahab', 'EVC Plus', 'Cash'].map((m) {
                      final isSel = selectedMethod == m;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedMethod = m),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? themeColor.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? themeColor : const Color(0xFFE5E7EB),
                                width: isSel ? 1.5 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? themeColor : const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final pay = double.tryParse(amountCtrl.text) ?? 0.0;
                        if (pay <= 0) return;

                        GashiRepository.instance.recordRepayment(
                          businessId: widget.businessId,
                          customerId: customer.id,
                          amount: pay,
                          paymentMethod: selectedMethod,
                        );

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Payment of \$${pay.toStringAsFixed(2)} recorded for ${customer.name} via $selectedMethod!'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text('Confirm Repayment',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
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

  // ============================================================================
  // ADD NEW CUSTOMER MODAL
  // ============================================================================
  void _openAddCustomerModal(BuildContext context, Color themeColor) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final initialDebtCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Register New Customer',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              const Text('Customer Name:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Phone Number:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+252 63...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),

              const Text('Initial Debt Balance (\$):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: initialDebtCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    final debt =
                        double.tryParse(initialDebtCtrl.text) ?? 0.0;

                    GashiRepository.instance.addCustomer(
                      Customer(
                        id: 0,
                        businessId: widget.businessId,
                        name: name,
                        phone: phoneCtrl.text.trim().isNotEmpty
                            ? phoneCtrl.text.trim()
                            : '+252 63 0000000',
                        currentCreditBalance: debt,
                      ),
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Customer $name registered!'),
                        backgroundColor: themeColor,
                      ),
                    );
                  },
                  child: const Text('Save Customer',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // CUSTOMER DETAILS & TRANSACTION HISTORY SHEET
  // ============================================================================
  void _openCustomerDetailsModal(
      BuildContext context, Customer customer, Color themeColor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final txs =
            GashiRepository.instance.getCustomerTransactions(customer.id);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(customer.phone,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF8E99AF))),
                    ],
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.businessType.softBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Debt Balance:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '\$${customer.currentCreditBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customer.currentCreditBalance > 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Transaction History (PostgreSQL Ledger):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),

              if (txs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('No transaction history recorded yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (c, i) {
                    final tx = txs[i];
                    final isRepayment = tx.type == 'repayment';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isRepayment ? "Repayment" : "Credit Sale"} • ${tx.paymentMethod}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(tx.notes,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF8E99AF))),
                            ],
                          ),
                          Text(
                            '${isRepayment ? "-" : "+"}\$${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isRepayment
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
        );
      },
    );
  }
}
