import 'package:flutter/material.dart';
import '../fake_data/service_sales_data.dart';

class ServiceSalesPage extends StatefulWidget {
  const ServiceSalesPage({super.key});

  @override
  State<ServiceSalesPage> createState() => _ServiceSalesPageState();
}

class _ServiceSalesPageState extends State<ServiceSalesPage> {
  String _selectedPeriod = 'Maanta';
  String _selectedType = 'Dhammaan';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter by period first
    List<ServiceSalesTicket> periodTickets;
    if (_selectedPeriod == 'Maanta') {
      periodTickets = sampleServiceSalesTickets.where((t) => t.isToday).toList();
    } else {
      periodTickets = sampleServiceSalesTickets;
    }

    // Filter by search and type
    final filtered = periodTickets.where((t) {
      final matchesSearch = t.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.customer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.technician.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'Dhammaan' || t.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    final totalRev = filtered.fold<double>(0.0, (sum, t) => sum + t.price);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Iibka Adeegyada (Service Sales)',
              style: TextStyle(color: Color(0xFF1D2338), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Dakhliga adeegyada iyo shaqooyinka la iibiyay',
              style: TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF4F46E5)),
                style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12),
                items: const [
                  DropdownMenuItem(value: 'Maanta', child: Text('Maanta (Today)')),
                  DropdownMenuItem(value: 'Toddobaadkan', child: Text('Toddobaadkan (Week)')),
                  DropdownMenuItem(value: 'Bishan', child: Text('Bishan (Month)')),
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
            // Today's Sales Showcase Card
            if (_selectedPeriod == 'Maanta') ...[
              _buildTodayShowcaseCard(),
              const SizedBox(height: 16),
            ],

            // 2x2 Metric Cards
            _buildMetricsGrid(totalRev, filtered.length),
            const SizedBox(height: 16),

            // Payment Methods summary bar
            _buildPaymentMethodsBreakdown(),
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
                        hintText: 'Raadi adeeg, macmiil ama farsamo-yaqaan...',
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
                _buildFilterChip('Goobta', 'Goobta'),
                const SizedBox(width: 8),
                _buildFilterChip('Guriga', 'Guriga'),
                const SizedBox(width: 8),
                _buildFilterChip('Degdeg', 'Degdeg'),
              ],
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedPeriod == 'Maanta'
                      ? 'Adeegyadii Maanta la Iibiyay (Sold Today)'
                      : 'Shaqooyinkii Adeegga ee Dhammaystirmay',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                ),
                Text('${filtered.length} shaqo', style: const TextStyle(fontSize: 13, color: Color(0xFF8E99AF))),
              ],
            ),
            const SizedBox(height: 12),

            // Tickets List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ticket = filtered[index];
                return GestureDetector(
                  onTap: () => _showJobModal(context, ticket),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(ticket.time, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(ticket.icon, color: const Color(0xFF4F46E5), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D2338)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ticket.technician} • ${ticket.customer}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${ticket.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D2338)),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ticket.paymentColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ticket.payment,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ticket.paymentColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Sub-breakdown items sold
                        if (ticket.itemsBreakdown.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.checklist, size: 14, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ticket.itemsBreakdown.join(' • '),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildTodayShowcaseCard() {
    const summary = sampleTodaySalesSummary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.today, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Iibka Maanta (Today\'s Sales)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.totalJobsToday} Shaqo la iibiyay',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${summary.totalRevenueToday.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTodaySummaryItem('Zaad', '\$${summary.zaadTotal.toStringAsFixed(0)}'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildTodaySummaryItem('e-Dahab', '\$${summary.edahabTotal.toStringAsFixed(0)}'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildTodaySummaryItem('Kaash', '\$${summary.cashTotal.toStringAsFixed(0)}'),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildTodaySummaryItem('Dayn', '\$${summary.daynTotal.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
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

  Widget _buildMetricsGrid(double totalRev, int totalJobs) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.attach_money,
                iconBg: const Color(0xFFE6F7F0),
                iconColor: const Color(0xFF10B981),
                label: 'Dakhliga Xilligan',
                value: '\$${totalRev.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.handyman_outlined,
                iconBg: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                label: 'Shaqooyinka',
                value: '$totalJobs',
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
                label: 'Celcelis Shaqo',
                value: totalJobs > 0 ? '\$${(totalRev / totalJobs).toStringAsFixed(2)}' : '\$0.00',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                label: 'Zaad / e-Dahab',
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

  Widget _buildPaymentMethodsBreakdown() {
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
            'Hababka Lacag-Bixinta Adeegyada',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(flex: 58, child: ColoredBox(color: Color(0xFF00A859))), // Zaad
                  Expanded(flex: 22, child: ColoredBox(color: Color(0xFFF58220))), // e-Dahab
                  Expanded(flex: 12, child: ColoredBox(color: Color(0xFF2563EB))), // Kaash
                  Expanded(flex: 8, child: ColoredBox(color: Color(0xFFEF4444))), // Dayn
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(const Color(0xFF00A859), 'Zaad (58%)'),
              _buildLegend(const Color(0xFFF58220), 'e-Dahab (22%)'),
              _buildLegend(const Color(0xFF2563EB), 'Kaash (12%)'),
              _buildLegend(const Color(0xFFEF4444), 'Dayn (8%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showJobModal(BuildContext context, ServiceSalesTicket ticket) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                    Text('${ticket.id} - Rasiidka Iibka', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
                    Text('Rasiid #: ${ticket.receiptNumber}', style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 6),
            _infoRow('Adeegga:', ticket.title),
            _infoRow('Macmiilka:', '${ticket.customer} (${ticket.phone})'),
            _infoRow('Farsamo-yaqaanka:', ticket.technician),
            _infoRow('Nooca Shaqada:', ticket.type),
            _infoRow('Waqtiga & Taariikhda:', '${ticket.date} • ${ticket.time}'),
            _infoRow('Habka Bixinta:', ticket.payment),
            _infoRow('Xaaladda:', ticket.status),
            _infoRow('Faahfaahinta:', ticket.details),
            if (ticket.itemsBreakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Qaybaha/Qalabka la iibiyay:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D2338))),
              const SizedBox(height: 4),
              ...ticket.itemsBreakdown.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)))),
                    ],
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wadarta Qiimaha:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '\$${ticket.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Daabac Rasiidka Shaqada (Print Receipt)'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rasiidka adeegga waxaa loo diray daabacaha!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D2338)))),
        ],
      ),
    );
  }
}
