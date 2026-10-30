import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../fake_data/retail_credits_data.dart';

// ============================================================================
// RETAIL CREDITS / DAYN PAGE (Emerald Green Theme)
// ============================================================================

class RetailCreditsPage extends StatefulWidget {
  const RetailCreditsPage({super.key});

  @override
  State<RetailCreditsPage> createState() => _RetailCreditsPageState();
}

class _RetailCreditsPageState extends State<RetailCreditsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Dhammaan';

  late List<RetailDebtor> _debtors;

  @override
  void initState() {
    super.initState();
    _debtors = List<RetailDebtor>.from(sampleRetailDebtors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _debtors.where((d) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = d.name.toLowerCase().contains(query) ||
          d.phone.contains(query) ||
          d.invoiceId.toLowerCase().contains(query) ||
          d.notes.toLowerCase().contains(query) ||
          d.items.any((item) => item.toLowerCase().contains(query));

      final matchesFilter = _selectedFilter == 'Dhammaan' || d.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    final totalOutstanding = _debtors.fold<double>(0.0, (sum, d) => sum + d.remaining);
    final activeDebtors = _debtors.where((d) => d.remaining > 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('credits_title'),
              style: const TextStyle(
                color: Color(0xFF1D2338),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              context.tr('credits_subtitle'),
              style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('credits_add_new'),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
            ),
            onPressed: () => _openAddCreditModal(context),
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
            // 2x2 Metric Cards (Emerald Green Theme)
            _buildMetricsGrid(totalOutstanding, activeDebtors),
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
                      decoration: InputDecoration(
                        hintText: context.tr('credits_search_hint'),
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
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(context.tr('credits_filter_all'), 'Dhammaan'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('credits_filter_unpaid'), 'Aan bixin'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('credits_filter_partial'), 'Qayb bixiyay'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context.tr('credits_filter_cleared'), 'Dhammaystiray'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liiska Deymaha Dukaanka',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338),
                  ),
                ),
                Text(
                  '${filtered.length} macmiil',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E99AF)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Debtors List
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final debtor = filtered[index];
                  final isCleared = debtor.remaining <= 0;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openDaynDetailsModal(context, debtor),
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with Initial
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFE6F7F0),
                                child: Text(
                                  debtor.name.isNotEmpty ? debtor.name.substring(0, 1) : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name, Invoice, Notes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            debtor.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1D2338),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${debtor.invoiceId} • ${debtor.phone}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (debtor.notes.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        debtor.notes,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF8E99AF),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Remaining Debt & Status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${debtor.remaining.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isCleared ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: debtor.statusBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      debtor.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: debtor.statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F3F6)),
                          const SizedBox(height: 10),

                          // Due date + Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Waqtiga: ${debtor.dueDate}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF4B5563)),
                                    label: const Text('Wac', style: TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Wicitaan: ${debtor.phone}')),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCleared ? const Color(0xFF9CA3AF) : const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.attach_money, size: 14),
                                    label: const Text('Qaado Lacag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    onPressed: isCleared ? null : () => _openCollectPaymentModal(context, debtor),
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
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F6)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'Lama helin macmiil deyn leh',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Isku day inaad beddesho shaandhada ama ereyga raadinta.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
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

  Widget _buildMetricsGrid(double totalOutstanding, int activeCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.money_off,
                iconBg: const Color(0xFFFDE8E8),
                iconColor: const Color(0xFFEF4444),
                label: 'Deynta Maqan',
                value: '\$${totalOutstanding.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_outline,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Macaamiisha leh',
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
                label: 'La Ururiyay Maanta',
                value: '\$70.00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.pie_chart_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Celcelis Deyn',
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

  // ============================================================================
  // DEBTOR DETAILS SHEET (Items list + Payment History + Direct Actions)
  // ============================================================================
  void _openDaynDetailsModal(BuildContext context, RetailDebtor debtor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isCleared = debtor.remaining <= 0;
            final progress = debtor.totalDebt > 0 ? (debtor.paid / debtor.totalDebt).clamp(0.0, 1.0) : 1.0;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Faahfaahinta Daynta Dukaanka',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                            ),
                            Text(
                              'Qaansheegta: ${debtor.invoiceId} • La diiwaangeliyay: ${debtor.dateRecorded}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF4B5563)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFE6F7F0),
                                  child: Text(
                                    debtor.name.isNotEmpty ? debtor.name[0] : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debtor.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1D2338),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        debtor.phone,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: debtor.statusBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    debtor.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: debtor.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Debt Progress Breakdown Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Xaaladda Lacag-bixinta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
                                    Text(
                                      '${(progress * 100).toInt()}% La Bixiyay',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFF1F3F6),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isCleared ? const Color(0xFF10B981) : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Wadarta Guud', style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text('\$${debtor.totalDebt.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('La Bixiyay', style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text('\$${debtor.paid.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Ku Hadhay', style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text('\$${debtor.remaining.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isCleared ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Items Purchased Section
                          const Text(
                            'Alaabta La Qaatay (Purchased Items)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: debtor.items.length,
                              separatorBuilder: (context, idx) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF10B981)),
                                  title: Text(
                                    debtor.items[idx],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D2338)),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Payment History
                          const Text(
                            'Taariikhda Bixinta (Payment History)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                          ),
                          const SizedBox(height: 8),
                          if (debtor.paymentHistory.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Wax lacag ah weli lama bixin.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: debtor.paymentHistory.length,
                              separatorBuilder: (context, idx) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final tx = debtor.paymentHistory[idx];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${tx.method} • ${tx.date}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                                          ),
                                          if (tx.note.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(tx.note, style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '+\$${tx.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar in Details Sheet
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.phone, size: 18, color: Color(0xFF4B5563)),
                            label: const Text('Wac Macmiilka', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Wicitaan: ${debtor.phone}')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: isCleared ? const Color(0xFF9CA3AF) : const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.attach_money, size: 18),
                            label: const Text('Qaado Lacag', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: isCleared
                                ? null
                                : () {
                                    Navigator.pop(ctx);
                                    _openCollectPaymentModal(context, debtor);
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
      },
    );
  }

  // ============================================================================
  // COLLECT PAYMENT MODAL
  // ============================================================================
  void _openCollectPaymentModal(BuildContext context, RetailDebtor debtor) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedMethod = 'Zaad';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
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
                      Expanded(
                        child: Text(
                          'Qaado Lacag - ${debtor.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Remaining summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deynta ku hadhay:', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                        Text('\$${debtor.remaining.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Cadadka la bixinayo (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'e.g. ${debtor.remaining.toStringAsFixed(2)}',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Habka Lacag-bixinta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Zaad', 'Sahal', 'EVC Plus', 'Edahab', 'Kaash'].map((m) {
                      final isSel = selectedMethod == m;
                      return ChoiceChip(
                        label: Text(m),
                        selected: isSel,
                        selectedColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF1D2338),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedMethod = m);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  const Text('Xusuusin (Ikhtiyaari):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Qayb ka mid ah deynta',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final pay = double.tryParse(amountCtrl.text) ?? 0.0;
                        if (pay <= 0) return;

                        setState(() {
                          final newPaid = debtor.paid + pay;
                          final newRemaining = (debtor.remaining - pay).clamp(0.0, double.infinity);
                          final isNowCleared = newRemaining <= 0;

                          final newHistory = List<RetailDebtTransaction>.from(debtor.paymentHistory)
                            ..add(
                              RetailDebtTransaction(
                                id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                                date: 'Maanta',
                                amount: pay,
                                method: selectedMethod,
                                note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : 'Lacag bixin',
                              ),
                            );

                          final updatedDebtor = debtor.copyWith(
                            paid: newPaid,
                            remaining: newRemaining,
                            status: isNowCleared ? 'Dhammaystiray' : 'Qayb bixiyay',
                            statusColor: isNowCleared ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            statusBg: isNowCleared ? const Color(0xFFE6F7F0) : const Color(0xFFFEF3C7),
                            paymentHistory: newHistory,
                          );

                          final index = _debtors.indexWhere((d) => d.id == debtor.id);
                          if (index >= 0) {
                            _debtors[index] = updatedDebtor;
                          }
                        });

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('credits_payment_received')),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text('Xaqiiji Bixinta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  // ============================================================================
  // ADD NEW CREDIT MODAL
  // ============================================================================
  void _openAddCreditModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final itemCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
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
                  const Text('Diiwaangeli Deyn Cusub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              const Text('Magaca Macmiilka:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Geli magaca macmiilka',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('Taleefanka:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+252 63 ...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('Alaabta La Qaatay (Items):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: itemCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. 2x Shaadh, 1x Kabo',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('Cadadka Deynta (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              const Text('Xusuusin / Qoraal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  hintText: 'Faahfaahin dheeri ah',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (name.isEmpty || amount <= 0) return;

                    final itemsText = itemCtrl.text.trim();
                    final itemsList = itemsText.isNotEmpty
                        ? itemsText.split(',').map((e) => e.trim()).toList()
                        : <String>['Alaab Dukaanka'];

                    final randomNum = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

                    setState(() {
                      _debtors.insert(
                        0,
                        RetailDebtor(
                          id: 'rd_${DateTime.now().millisecondsSinceEpoch}',
                          invoiceId: '#INV-$randomNum',
                          name: name,
                          phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+252 63 0000000',
                          dateRecorded: 'Maanta',
                          dueDate: 'Qorshaysan',
                          totalDebt: amount,
                          paid: 0.0,
                          remaining: amount,
                          status: 'Aan bixin',
                          statusColor: const Color(0xFFEF4444),
                          statusBg: const Color(0xFFFDE8E8),
                          notes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : 'Deyn dukaameysi cusub',
                          items: itemsList,
                          paymentHistory: const [],
                        ),
                      );
                    });

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deynta cusub si guul leh ayaa loo diiwaangeliyay!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  child: const Text('Keydi Deynta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

