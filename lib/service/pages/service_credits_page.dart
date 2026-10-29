import 'package:flutter/material.dart';
import '../fake_data/service_credits_data.dart';

class ServiceCreditsPage extends StatefulWidget {
  const ServiceCreditsPage({super.key});

  @override
  State<ServiceCreditsPage> createState() => _ServiceCreditsPageState();
}

class _ServiceCreditsPageState extends State<ServiceCreditsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Dhammaan';

  late List<ServiceDebtor> _debtors;

  @override
  void initState() {
    super.initState();
    _debtors = List<ServiceDebtor>.from(sampleServiceDebtors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _debtors.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.phone.contains(_searchQuery) ||
          d.service.toLowerCase().contains(_searchQuery.toLowerCase());
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
          children: const [
            Text(
              'Deymaha Adeegyada (Service Credits)',
              style: TextStyle(color: Color(0xFF1D2338), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Macaamiisha lacagta adeegga lagu leeyahay',
              style: TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Diiwaangeli Deyn Cusub',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
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
            // 2x2 Metric Cards
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
                      decoration: const InputDecoration(
                        hintText: 'Raadi magac, taleefan ama adeeg...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            Row(
              children: [
                _buildFilterChip('Dhammaan', 'Dhammaan'),
                const SizedBox(width: 8),
                _buildFilterChip('Aan bixin', 'Aan bixin'),
                const SizedBox(width: 8),
                _buildFilterChip('Qayb bixiyay', 'Qayb bixiyay'),
                const SizedBox(width: 8),
                _buildFilterChip('Dhammaystiray', 'Dhammaystiray'),
              ],
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liiska Macaamiisha Deynta leh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                ),
                Text('${filtered.length} qof', style: const TextStyle(fontSize: 13, color: Color(0xFF8E99AF))),
              ],
            ),
            const SizedBox(height: 12),

            // Debtors List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final debtor = filtered[index];
                final isCleared = debtor.remaining <= 0;

                return GestureDetector(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFEEF2FF),
                              child: Text(
                                debtor.name.isNotEmpty ? debtor.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          debtor.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    debtor.service,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${debtor.phone} • ${debtor.notes}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                    backgroundColor: isCleared ? const Color(0xFF9CA3AF) : const Color(0xFF4F46E5),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
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

  Widget _buildMetricsGrid(double totalRemaining, int activeCount) {
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
                value: '\$${totalRemaining.toStringAsFixed(2)}',
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
                value: '\$60.00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.pie_chart_outline,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: 'Celcelis Deyn',
                value: activeCount > 0 ? '\$${(totalRemaining / activeCount).toStringAsFixed(2)}' : '\$0.00',
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Comprehensive Dayn Detail BottomSheet
  void _openDaynDetailsModal(BuildContext context, ServiceDebtor debtor) {
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
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(3)),
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
                              'Faahfaahinta Daynta (Debt Details)',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                            ),
                            Text(
                              'Tikidhka: ${debtor.ticketId} • La diiwaangeliyay: ${debtor.dateRecorded}',
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
                                  backgroundColor: const Color(0xFFEEF2FF),
                                  child: Text(
                                    debtor.name.isNotEmpty ? debtor.name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debtor.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2338)),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        debtor.phone,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFEEF2FF)),
                                  icon: const Icon(Icons.phone, color: Color(0xFF4F46E5), size: 20),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Wicitaan: ${debtor.phone}')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Debt Progress Summary Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCleared ? const Color(0xFFECFDF5) : const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: isCleared ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isCleared ? 'Deyntu Way Dhammaatay' : 'Deynta Ku Hadhi Doonta',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isCleared ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: debtor.statusBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        debtor.status,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: debtor.statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${debtor.remaining.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: isCleared ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.black12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isCleared ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Wadarta Deynta: \$${debtor.totalDebt.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'La bixiyay: \$${debtor.paid.toStringAsFixed(2)} (${(progress * 100).toStringAsFixed(0)}%)',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Service Details Info
                          const Text(
                            'Faahfaahinta Shaqada & Qalabka',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailRow('Adeegga:', debtor.service),
                                _detailRow('Farsamo-yaqaanka:', debtor.technician),
                                _detailRow('Waqtiga Bixinta (Due):', debtor.dueDate),
                                _detailRow('Xusuusin:', debtor.notes),
                                if (debtor.items.isNotEmpty) ...[
                                  const Divider(height: 16),
                                  const Text('Qaybaha/Adeegyada Deynta lagu qaatay:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  ...debtor.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF4F46E5)),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Payment History
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Taariikhda Lacag-bixinta (Payment History)',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                              ),
                              Text('${debtor.paymentHistory.length} jeer', style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (debtor.paymentHistory.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Weli wax lacag ah lagama bixin deyntan.',
                                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              ),
                            )
                          else
                            ...debtor.paymentHistory.map(
                              (tx) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE6F7F0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '+\$${tx.amount.toStringAsFixed(2)} • ${tx.method}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${tx.date} • ${tx.note}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Collect button
                          if (!isCleared)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.attach_money),
                                label: const Text('Qaado Lacag Hadda (Collect Payment)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _openCollectPaymentModal(context, debtor);
                                },
                              ),
                            ),
                        ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1D2338)))),
        ],
      ),
    );
  }

  void _openCollectPaymentModal(BuildContext context, ServiceDebtor debtor) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qaado Lacag - ${debtor.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Deynta Ku Hadhi Doonta: \$${debtor.remaining.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final pay = double.tryParse(amountCtrl.text) ?? 0.0;
                  if (pay <= 0) return;

                  final index = _debtors.indexWhere((d) => d.id == debtor.id);
                  if (index != -1) {
                    final newPaid = debtor.paid + pay;
                    final newRemaining = (debtor.totalDebt - newPaid).clamp(0.0, debtor.totalDebt);
                    final isNowCleared = newRemaining <= 0;

                    final updatedHistory = List<ServiceDebtTransaction>.from(debtor.paymentHistory)
                      ..add(
                        ServiceDebtTransaction(
                          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                          date: 'Maanta • 29 Oct 2026',
                          amount: pay,
                          method: 'Zaad',
                          note: 'Lacag qabasho xafiiska',
                        ),
                      );

                    setState(() {
                      _debtors[index] = debtor.copyWith(
                        paid: newPaid,
                        remaining: newRemaining,
                        status: isNowCleared ? 'Dhammaystiray' : 'Qayb bixiyay',
                        statusColor: isNowCleared ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        statusBg: isNowCleared ? const Color(0xFFE6F7F0) : const Color(0xFFFEF3C7),
                        paymentHistory: updatedHistory,
                      );
                    });
                  }

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lacag-bixinta adeegga si guul leh ayaa loo diiwaangeliyay!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Xaqiiji Lacagta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddCreditModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final serviceCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diiwaangeli Deyn Adeeg oo Cusub', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
              const Text('Adeegga Loo Qabtay:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: serviceCtrl,
                decoration: InputDecoration(
                  hintText: 'Tusaale: Dhaqis Gaadhi, Farsamo Shaashad',
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (name.isEmpty || amount <= 0) return;

                    setState(() {
                      _debtors.insert(
                        0,
                        ServiceDebtor(
                          id: 'sd_${DateTime.now().millisecondsSinceEpoch}',
                          ticketId: '#SRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          name: name,
                          phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+252 63 0000000',
                          service: serviceCtrl.text.trim().isNotEmpty ? serviceCtrl.text.trim() : 'Adeeg Guud',
                          dateRecorded: '29 Oct 2026',
                          dueDate: 'Qorshaysan',
                          totalDebt: amount,
                          paid: 0.0,
                          remaining: amount,
                          status: 'Aan bixin',
                          statusColor: const Color(0xFFEF4444),
                          statusBg: const Color(0xFFFDE8E8),
                          notes: 'Deyn adeeg cusub',
                          technician: 'Farsamo Guud',
                          items: [serviceCtrl.text.trim().isNotEmpty ? serviceCtrl.text.trim() : 'Adeeg Guud'],
                          paymentHistory: [],
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deynta adeegga si guul leh ayaa loo keydiyay!'), backgroundColor: Color(0xFF10B981)),
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
