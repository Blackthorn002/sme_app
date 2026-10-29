import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RestaurantCreditsPage extends StatefulWidget {
  const RestaurantCreditsPage({super.key});

  @override
  State<RestaurantCreditsPage> createState() => _RestaurantCreditsPageState();
}

class _RestaurantCreditsPageState extends State<RestaurantCreditsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Dhammaan';

  final List<Map<String, dynamic>> _debtors = [
    {
      'id': 'd1',
      'name': 'Jaamac Maxamed Cilmi',
      'phone': '+252 63 4411223',
      'totalDebt': 65.0,
      'paid': 20.0,
      'remaining': 45.0,
      'dueDate': '30 Oct 2026',
      'status': 'Qayb bixiyay',
      'statusColor': Color(0xFFF59E0B),
      'statusBg': Color(0xFFFEF3C7),
      'notes': 'Miiska 4 - Cunto shaqaale',
    },
    {
      'id': 'd2',
      'name': 'Faarax Cabdi Warsame',
      'phone': '+252 63 7788990',
      'totalDebt': 110.0,
      'paid': 0.0,
      'remaining': 110.0,
      'dueDate': '02 Nov 2026',
      'status': 'Aan bixin',
      'statusColor': Color(0xFFEF4444),
      'statusBg': Color(0xFFFDE8E8),
      'notes': 'Dalab Safaari iyo Cunto marti',
    },
    {
      'id': 'd3',
      'name': 'Maryan Xasan Cali',
      'phone': '+252 65 9911224',
      'totalDebt': 35.0,
      'paid': 35.0,
      'remaining': 0.0,
      'dueDate': '28 Oct 2026',
      'status': 'Dhammaystiray',
      'statusColor': Color(0xFF10B981),
      'statusBg': Color(0xFFE6F7F0),
      'notes': 'Lacagteedii way dhammaystirtay',
    },
    {
      'id': 'd4',
      'name': 'Maxamed Yuusuf Guuleed',
      'phone': '+252 63 3322114',
      'totalDebt': 85.0,
      'paid': 15.0,
      'remaining': 70.0,
      'dueDate': '05 Nov 2026',
      'status': 'Qayb bixiyay',
      'statusColor': Color(0xFFF59E0B),
      'statusBg': Color(0xFFFEF3C7),
      'notes': 'Bariis iyo Kaluun',
    },
    {
      'id': 'd5',
      'name': 'Khadar Ismaaciil Nuur',
      'phone': '+252 63 1234567',
      'totalDebt': 55.0,
      'paid': 0.0,
      'remaining': 55.0,
      'dueDate': '01 Nov 2026',
      'status': 'Aan bixin',
      'statusColor': Color(0xFFEF4444),
      'statusBg': Color(0xFFFDE8E8),
      'notes': 'Miiska 2',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _debtors.where((d) {
      final matchesSearch = d['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d['phone'].toString().contains(_searchQuery);
      final matchesStatus = _selectedFilter == 'Dhammaan' || d['status'] == _selectedFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final totalOutstanding = _debtors.fold<double>(0.0, (sum, d) => sum + (d['remaining'] as double));
    final activeDebtorsCount = _debtors.where((d) => (d['remaining'] as double) > 0).length;

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
            tooltip: 'Diiwaangeli Deyn Cusub',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5200),
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
            // 2x2 Metric Grid (Matching Theme)
            _buildMetricsGrid(totalOutstanding, activeDebtorsCount),
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
                  'Liiska Deymaha',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final debtor = filtered[index];
                final remaining = debtor['remaining'] as double;
                final isCleared = remaining <= 0;

                return Container(
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
                          // Avatar with initial
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFFFF3EB),
                            child: Text(
                              (debtor['name'] as String).substring(0, 1),
                              style: const TextStyle(
                                color: Color(0xFFFF5200),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name, Phone, and Notes
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debtor['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1D2338),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  debtor['phone'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                if (debtor['notes'] != null && debtor['notes'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    debtor['notes'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8E99AF),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Remaining Balance & Status
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${remaining.toStringAsFixed(2)}',
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
                                  color: debtor['statusBg'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  debtor['status'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: debtor['statusColor'],
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

                      // Action buttons: "Qaado Lacag" and "Wac"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Waqtiga: ${debtor['dueDate']}',
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
                                    SnackBar(content: Text('Wicitaan: ${debtor['phone']}')),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCleared ? const Color(0xFF9CA3AF) : const Color(0xFFFF5200),
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
                label: 'Wadarta Deynta',
                value: '\$${totalOutstanding.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_outline,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Macaamiisha Deynta leh',
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
                value: '\$80.00',
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

  void _openCollectPaymentModal(BuildContext context, Map<String, dynamic> debtor) {
    final amountCtrl = TextEditingController();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qaado Lacag - ${debtor['name']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('Deynta ku hadhay: \$${(debtor['remaining'] as double).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            const Text('Cadadka la bixinayo (\$):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'e.g. ${(debtor['remaining'] as double).toStringAsFixed(2)}',
                filled: true,
                fillColor: const Color(0xFFF9FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5200),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final pay = double.tryParse(amountCtrl.text) ?? 0.0;
                  if (pay <= 0) return;
                  setState(() {
                    debtor['paid'] = (debtor['paid'] as double) + pay;
                    final rem = (debtor['remaining'] as double) - pay;
                    debtor['remaining'] = rem < 0 ? 0.0 : rem;
                    if (debtor['remaining'] <= 0) {
                      debtor['status'] = 'Dhammaystiray';
                      debtor['statusColor'] = const Color(0xFF10B981);
                      debtor['statusBg'] = const Color(0xFFE6F7F0);
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
  }

  void _openAddCreditModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
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
                  hintText: 'Tusaale: Dalab qado Miiska 2',
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
                    backgroundColor: const Color(0xFFFF5200),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (name.isEmpty || amount <= 0) return;

                    setState(() {
                      _debtors.insert(0, {
                        'id': 'd_${DateTime.now().millisecondsSinceEpoch}',
                        'name': name,
                        'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+252 63 0000000',
                        'totalDebt': amount,
                        'paid': 0.0,
                        'remaining': amount,
                        'dueDate': 'Qorshaysan',
                        'status': 'Aan bixin',
                        'statusColor': const Color(0xFFEF4444),
                        'statusBg': const Color(0xFFFDE8E8),
                        'notes': noteCtrl.text.trim(),
                      });
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
