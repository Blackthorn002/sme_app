import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gashi_models.dart';
import '../repository/gashi_repository.dart';
import '../widgets/offline_sync_banner.dart';
import '../services/currency_service.dart';

// ============================================================================
// GENERAL CREDITS / DEBT PAGE (Unified Across All Business Types)
// Backed by PostgreSQL Schema:
// - customers (total_debt, paid_debt, current_credit_balance, due_date, reminder_mode, reminder_days, status, notes)
// - customer_transactions (repayments & credit sales ledger)
// - sales & sale_items (items purchased on credit)
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
      animation: Listenable.merge([GashiRepository.instance, CurrencyService.instance]),
      builder: (context, _) {
        final repo = GashiRepository.instance;
        final customers = repo.getCustomers(widget.businessId);

        final filtered = customers.where((c) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = c.name.toLowerCase().contains(query) ||
              c.phone.contains(query) ||
              c.notes.toLowerCase().contains(query);

          final hasDebt = c.currentCreditBalance > 0.001;
          if (_selectedFilter == 'Deyn leh') {
            return matchesSearch && hasDebt;
          } else if (_selectedFilter == 'Waqtigu Dhaafay') {
            return matchesSearch && c.isOverdue;
          } else if (_selectedFilter == 'Ku Dhow Waqtiga') {
            return matchesSearch && c.isDueSoon;
          } else if (_selectedFilter == 'Dhammaystiray') {
            return matchesSearch && !hasDebt;
          }
          return matchesSearch;
        }).toList();

        final totalOutstanding = customers.fold<double>(
            0.0, (sum, c) => sum + c.currentCreditBalance);
        final activeDebtors =
            customers.where((c) => c.currentCreditBalance > 0.001).length;
        final overdueDebtors = customers.where((c) => c.isOverdue).length;
        final dueSoonDebtors = customers.where((c) => c.isDueSoon).length;
        final totalCollected =
            customers.fold<double>(0.0, (sum, c) => sum + c.paidDebt);

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
                _buildMetricsGrid(
                  totalOutstanding: totalOutstanding,
                  activeCount: activeDebtors,
                  overdueCount: overdueDebtors,
                  collectedAmount: totalCollected,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 14),

                // Mobile Debt Reminder & Time Limit Notification Banner
                if (overdueDebtors > 0 || dueSoonDebtors > 0) ...[
                  _buildMobileNotificationAlertBanner(
                    context,
                    overdueCount: overdueDebtors,
                    dueSoonCount: dueSoonDebtors,
                    themeColor: themeColor,
                  ),
                  const SizedBox(height: 14),
                ],

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
                            hintText: 'Raadi macmiil, taleefan ama damiin...',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('Dhammaan', 'Dhammaan', themeColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('Deyn leh', 'Deyn leh', themeColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('Waqtigu Dhaafay', 'Waqtigu Dhaafay',
                          const Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Ku Dhow Waqtiga', 'Ku Dhow Waqtiga',
                          const Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Dhammaystiray', 'Dhammaystiray', themeColor),
                    ],
                  ),
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
                      child: Text('Wax macaamiil ah lama helin',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final customer = filtered[idx];
                      final isCleared = customer.isCleared;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openCustomerDetailsModal(
                            context, customer, themeColor),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: customer.isOverdue
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFF1F3F6),
                            ),
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
                              // Customer Header Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        widget.businessType.softBgColor,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                customer.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Color(0xFF1D2338)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right,
                                                size: 18,
                                                color: Color(0xFF9CA3AF)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          customer.phone,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Wadarta: \$${customer.totalDebt.toStringAsFixed(2)} • Bixiyay: \$${customer.paidDebt.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF8E99AF)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                              : (customer.isOverdue
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFFEF4444)),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: customer.statusBg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          customer.statusLabel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: customer.statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Reminder & Due Date Pill
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (customer.isOverdue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDE8E8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFECACA)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded,
                                              size: 13,
                                              color: Color(0xFFDC2626)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Waqtigu Dhaafay (${customer.daysUntilDue.abs()} cisho)',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFDC2626)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (customer.isDueSoon)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.alarm,
                                              size: 13,
                                              color: Color(0xFFD97706)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ku dhow waqtiga (${customer.daysUntilDue} cisho)',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFD97706)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (customer.notificationCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.mark_chat_read_outlined,
                                              size: 13,
                                              color: Color(0xFF2563EB)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${customer.notificationCount}x xusuusin',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: customer.reminderMode == 'daily'
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          customer.reminderMode == 'daily'
                                              ? Icons.repeat
                                              : Icons.notifications_none,
                                          size: 13,
                                          color: customer.reminderMode == 'daily'
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFF4B5563),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          customer.reminderMode == 'daily'
                                              ? 'Maalin kasta (Maalinta 1-aad)'
                                              : (customer.dueDate != null
                                                  ? 'Xusuusin: ${customer.formattedDueDate}'
                                                  : 'Xusuusin: ${customer.reminderDays} maalmood'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                customer.reminderMode == 'daily'
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFF4B5563),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (customer.notes.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: Text(
                                        customer.notes,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
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
                                                    'Wicitaan: ${customer.phone}')),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          side: const BorderSide(
                                              color: Color(0xFFD97706)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.send_to_mobile,
                                            size: 14, color: Color(0xFFD97706)),
                                        label: const Text('Xusuusin',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFD97706))),
                                        onPressed: isCleared
                                            ? null
                                            : () => _openSendMobileNotificationModal(
                                                context, customer, themeColor),
                                      ),
                                      const SizedBox(width: 6),
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

  Widget _buildMobileNotificationAlertBanner(
    BuildContext context, {
    required int overdueCount,
    required int dueSoonCount,
    required Color themeColor,
  }) {
    final hasOverdue = overdueCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasOverdue ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasOverdue ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
        ),
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
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: hasOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasOverdue ? Icons.notifications_active : Icons.alarm_on,
              color: hasOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasOverdue ? 'Waqtigii Deynta Waa Dhaafay!' : 'Xusuusin: Deymo Waqtigoodu Dhaw Yahay',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: hasOverdue ? const Color(0xFF991B1B) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${overdueCount > 0 ? "$overdueCount macmiil waqtigu dhaafay" : ""}${overdueCount > 0 && dueSoonCount > 0 ? " • " : ""}${dueSoonCount > 0 ? "$dueSoonCount macmiil 3 maalmood ku eg" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasOverdue ? const Color(0xFFB91C1C) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.send_to_mobile, size: 14),
            label: const Text('Dir Fariin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => _openMobileNotificationCenterModal(context, themeColor),
          ),
        ],
      ),
    );
  }

  void _openMobileNotificationCenterModal(BuildContext context, Color themeColor) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (mCtx) {
        return StatefulBuilder(
          builder: (mCtx, setMCtxState) {
            final repo = GashiRepository.instance;
            final customers = repo.getCustomers(widget.businessId);
            final targetCustomers = customers
                .where((c) => c.currentCreditBalance > 0.001 && (c.isOverdue || c.isDueSoon))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.mark_chat_unread_outlined, color: Color(0xFFD97706), size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xarunta Xusuusinta Mobile-ka',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                              ),
                              Text(
                                'U dir fariimo xusuusin ah macaamiisha deyntu ku dhowdahay',
                                style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(mCtx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Bulk Action Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${targetCustomers.length} Macmiil ayaa u baahan xusuusin',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                        ),
                        if (targetCustomers.isNotEmpty)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.done_all, size: 14),
                            label: const Text('Dir Dhammaan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              for (final cust in targetCustomers) {
                                repo.recordCustomerReminderSent(cust.id, channel: 'SMS/WA');
                              }
                              setMCtxState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Dhammaan ${targetCustomers.length} macmiil ayaa loo diray xusuusinta!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: targetCustomers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified, size: 48, color: Color(0xFF10B981)),
                                SizedBox(height: 10),
                                Text(
                                  'Ma jiro macmiil waqtigiisu dhaafay ama ku dhow!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: targetCustomers.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, idx) {
                              final cust = targetCustomers[idx];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: cust.isOverdue ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: cust.isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                                      child: Text(
                                        cust.name.isNotEmpty ? cust.name[0] : 'M',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cust.isOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cust.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${cust.phone} • ${cust.isOverdue ? "Dhaafay ${cust.daysUntilDue.abs()} cisho" : "Ku eg ${cust.daysUntilDue} cisho"}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: cust.isOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (cust.notificationCount > 0)
                                            Text(
                                              'La xasuusiyay: ${cust.notificationCount}x',
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB)),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyService.instance.format(cust.currentCreditBalance),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444)),
                                        ),
                                        const SizedBox(height: 4),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD97706),
                                            foregroundColor: Colors.white,
                                            visualDensity: VisualDensity.compact,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.send_to_mobile, size: 12),
                                          label: const Text('Dir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            _openSendMobileNotificationModal(context, cust, themeColor);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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

  void _openSendMobileNotificationModal(BuildContext context, Customer customer, Color themeColor) {
    final repo = GashiRepository.instance;
    final business = repo.getBusinessById(widget.businessId);
    final initialMessage = customer.generateSomaliReminderMessage(
      storeName: business?.name ?? 'Gashi Platform',
      exchangeRate: CurrencyService.instance.dailyExchangeRate,
    );
    final messageCtrl = TextEditingController(text: initialMessage);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.phone_iphone, color: Color(0xFFD97706), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fariinta Xusuusinta Mobile-ka',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                            ),
                            Text(
                              'Mobile Debt Reminder Notification',
                              style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sCtx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Customer info pill
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: Text(
                          customer.name.isNotEmpty ? customer.name[0] : 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(customer.phone, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyService.instance.format(customer.currentCreditBalance),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFEF4444)),
                          ),
                          Text(
                            customer.isOverdue ? 'Waqtigu dhaafay' : 'Ku eg: ${customer.formattedDueDate}',
                            style: TextStyle(fontSize: 10, color: customer.isOverdue ? const Color(0xFFDC2626) : const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Qoraalka Fariinta (SMS / WhatsApp):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor)),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.sms, size: 16),
                        label: const Text('Dir SMS', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          repo.recordCustomerReminderSent(customer.id, channel: 'SMS');
                          Navigator.pop(sCtx);
                          _showSimulatedNotificationToast(
                            context,
                            title: 'SMS Xusuusin ah Waa la Diray 📩',
                            body: 'Fariinta waxaa loo diray ${customer.name} (${customer.phone})',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          repo.recordCustomerReminderSent(customer.id, channel: 'WhatsApp');
                          Navigator.pop(sCtx);
                          _showSimulatedNotificationToast(
                            context,
                            title: 'WhatsApp Xusuusin ah Waa la Diray 💬',
                            body: 'Fariinta WhatsApp waxa loo diray ${customer.name} (${customer.phone})',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.phone, size: 16, color: Color(0xFF4B5563)),
                        label: const Text('Wac Toos', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Wicitaan toos ah: ${customer.phone}')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFFD97706)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.snooze, size: 16, color: Color(0xFFD97706)),
                        label: const Text('Snooze (+3 cisho)', style: TextStyle(color: Color(0xFFD97706), fontSize: 12)),
                        onPressed: () {
                          final currentDue = customer.dueDate ?? DateTime.now();
                          final newDue = currentDue.add(const Duration(days: 3));
                          repo.updateCustomerDueDate(customer.id, newDue);
                          Navigator.pop(sCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Waqtiga daynta ${customer.name} waxa lagu kordhiyay 3 maalmood (${DateFormat("dd MMM").format(newDue)})'),
                              backgroundColor: const Color(0xFFD97706),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSimulatedNotificationToast(BuildContext context, {required String title, required String body}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1D2338),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                  Text(body, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildMetricsGrid({
    required double totalOutstanding,
    required int activeCount,
    required int overdueCount,
    required double collectedAmount,
    required Color themeColor,
  }) {
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
                icon: Icons.warning_amber_rounded,
                iconBg: overdueCount > 0
                    ? const Color(0xFFFDE8E8)
                    : const Color(0xFFF3F4F6),
                iconColor: overdueCount > 0
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF6B7280),
                label: 'Overdue Debts',
                value: '$overdueCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.task_alt,
                iconBg: const Color(0xFFE6F7F0),
                iconColor: const Color(0xFF10B981),
                label: 'Collected Total',
                value: '\$${collectedAmount.toStringAsFixed(2)}',
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
                        fontSize: 16,
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
  // CUSTOMER DETAILS MODAL (SHOWING MORE DETAILED INFO)
  // Shows:
  // 1. Header with Customer details & call buttons
  // 2. Reminder & Due Date Status (with quick edit reminder)
  // 3. Payment Progress Bar & 3-metric breakdown (Total, Paid, Remaining)
  // 4. Alaabta La Qaatay (Items purchased on credit)
  // 5. Damiin & Faahfaahin (Guarantor and Notes)
  // 6. PostgreSQL Ledger / Transaction History
  // 7. Sticky bottom action bar
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
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final repo = GashiRepository.instance;
            // Fetch updated customer from repository
            final currentCust = repo
                    .getCustomers(widget.businessId)
                    .firstWhere((c) => c.id == customer.id, orElse: () => customer);

            final txs = repo.getCustomerTransactions(currentCust.id);
            final creditSales = repo.getCustomerCreditSales(currentCust.id);
            final creditItems = repo.getCustomerCreditItems(currentCust.id);

            final progress = currentCust.totalDebt > 0
                ? (currentCust.paidDebt / currentCust.totalDebt).clamp(0.0, 1.0)
                : (currentCust.isCleared ? 1.0 : 0.0);

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Top Drag Handle & Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: widget.businessType.softBgColor,
                              child: Text(
                                currentCust.name.isNotEmpty
                                    ? currentCust.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentCust.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D2338)),
                                ),
                                Text(
                                  '${currentCust.phone} • Account #${currentCust.id}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF8E99AF)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --------------------------------------------------
                          // 1. REMINDER & DUE DATE STATUS CARD
                          // --------------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: currentCust.isOverdue
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: currentCust.isOverdue
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          currentCust.isOverdue
                                              ? Icons.warning_amber_rounded
                                              : (currentCust.reminderMode == 'daily'
                                                  ? Icons.repeat
                                                  : Icons.notifications_active_outlined),
                                          size: 18,
                                          color: currentCust.isOverdue
                                              ? const Color(0xFFDC2626)
                                              : (currentCust.reminderMode == 'daily'
                                                  ? const Color(0xFF2563EB)
                                                  : const Color(0xFFD97706)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          currentCust.isOverdue
                                              ? 'Xusuusinta Daynta (Waqtigu Dhaafay)'
                                              : 'Qorshaha Xusuusinta Daynta',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: currentCust.isOverdue
                                                ? const Color(0xFF991B1B)
                                                : const Color(0xFF1D2338),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      ),
                                      icon: const Icon(Icons.edit_outlined, size: 14),
                                      label: const Text('Beddel',
                                          style: TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        _openEditReminderModal(
                                            context, currentCust, themeColor, () {
                                          setModalState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Jadwalka: ${currentCust.reminderDescription}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF374151)),
                                          ),
                                          if (currentCust.formattedDueDate.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Waqtiga Bixinta: ${currentCust.formattedDueDate}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: currentCust.isOverdue
                                                    ? const Color(0xFFDC2626)
                                                    : const Color(0xFF6B7280),
                                                fontWeight: currentCust.isOverdue
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: currentCust.isCleared
                                            ? const Color(0xFFE6F7F0)
                                            : (currentCust.isOverdue
                                                ? const Color(0xFFFDE8E8)
                                                : const Color(0xFFFEF3C7)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentCust.isCleared
                                            ? 'Dhammaystiran'
                                            : (currentCust.isOverdue
                                                ? 'Dhaafay ${currentCust.daysUntilDue.abs()} cisho'
                                                : '${currentCust.daysUntilDue} cisho hadhay'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: currentCust.isCleared
                                              ? const Color(0xFF10B981)
                                              : (currentCust.isOverdue
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFFD97706)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --------------------------------------------------
                          // 2. FINANCIAL PROGRESS BREAKDOWN CARD
                          // --------------------------------------------------
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Xaaladda Lacag-bixinta (Progress)',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1D2338)),
                                    ),
                                    Text(
                                      '${(progress * 100).toInt()}% La Bixiyay',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981)),
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
                                      currentCust.isCleared
                                          ? const Color(0xFF10B981)
                                          : themeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Wadarta Guud',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text(
                                            '\$${currentCust.totalDebt.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1D2338))),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text('La Bixiyay',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text(
                                            '\$${currentCust.paidDebt.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF10B981))),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text('Ku Hadhay',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF))),
                                        const SizedBox(height: 2),
                                        Text(
                                          '\$${currentCust.currentCreditBalance.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: currentCust.isCleared
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // 3. ALAABTA LA QAATAY (PURCHASED ITEMS ON CREDIT)
                          // --------------------------------------------------
                          const Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 16, color: Color(0xFF1D2338)),
                              SizedBox(width: 6),
                              Text(
                                'Alaabta La Qaatay (Purchased Items)',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2338)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (creditItems.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      size: 18, color: Color(0xFF8E99AF)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Deyntan waxaa lagu diiwaangeliyay rasiid hore: \$${currentCust.totalDebt.toStringAsFixed(2)} (${currentCust.notes.isNotEmpty ? currentCust.notes : "Alaab guud"})',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4B5563)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                children: [
                                  if (creditSales.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF9FAFC),
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(14)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${creditSales.length} Iib oo dayn ah',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4B5563)),
                                          ),
                                          Text(
                                            '${creditItems.length} alaab wadar ahaan',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF8E99AF)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: creditItems.length,
                                    separatorBuilder: (context, idx) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, idx) {
                                      final item = creditItems[idx];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF3F4F6),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                      Icons.check_circle_outline,
                                                      size: 16,
                                                      color: Color(0xFF10B981)),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.productName,
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF1D2338)),
                                                    ),
                                                    Text(
                                                      '${item.quantity}x @ \$${item.unitPrice.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Color(0xFF8E99AF)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '\$${item.total.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D2338)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),

                          // --------------------------------------------------
                          // 4. DAMIIN & FAAHFAAHIN (GUARANTOR & NOTES)
                          // --------------------------------------------------
                          if (currentCust.notes.isNotEmpty) ...[
                            const Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 16, color: Color(0xFF1D2338)),
                                SizedBox(width: 6),
                                Text(
                                  'Damiin & Xusuusin (Notes)',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D2338)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Text(
                                currentCust.notes,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF374151)),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // --------------------------------------------------
                          // 5. TAARIIKHDA BIXINTA (POSTGRESQL TRANSACTION LEDGER)
                          // --------------------------------------------------
                          const Row(
                            children: [
                              Icon(Icons.history,
                                  size: 16, color: Color(0xFF1D2338)),
                              SizedBox(width: 6),
                              Text(
                                'Taariikhda Bixinta & Iibka (Ledger)',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2338)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (txs.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Center(
                                child: Text('Wax dhaqdhaqaaq ah weli lama diiwaangelin.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: txs.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (c, i) {
                                final tx = txs[i];
                                final isRepayment = tx.type == 'repayment';

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isRepayment
                                                  ? const Color(0xFFE6F7F0)
                                                  : const Color(0xFFFDE8E8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isRepayment
                                                  ? Icons.arrow_downward
                                                  : Icons.arrow_upward,
                                              size: 14,
                                              color: isRepayment
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFEF4444),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${isRepayment ? "Lacag bixin (Repayment)" : "Deyn Qaadasho (Credit)"} • ${tx.paymentMethod}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Color(0xFF1D2338)),
                                              ),
                                              Text(
                                                '${DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt)} • ${tx.notes}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF8E99AF)),
                                              ),
                                            ],
                                          ),
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
                          const SizedBox(height: 16),
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
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.phone,
                                size: 18, color: Color(0xFF4B5563)),
                            label: const Text('Wac Macmiilka',
                                style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Wicitaan: ${currentCust.phone}')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: currentCust.isCleared
                                  ? const Color(0xFF9CA3AF)
                                  : themeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.attach_money, size: 18),
                            label: const Text('Qaado Lacag',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: currentCust.isCleared
                                ? null
                                : () {
                                    Navigator.pop(ctx);
                                    _openCollectPaymentModal(
                                        context, currentCust, themeColor);
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
  // EDIT REMINDER SCHEDULE MODAL
  // ============================================================================
  void _openEditReminderModal(BuildContext context, Customer customer,
      Color themeColor, VoidCallback onUpdated) {
    String selectedMode = customer.reminderMode;
    int selectedDays = customer.reminderDays > 0 ? customer.reminderDays : 7;
    final customDaysCtrl =
        TextEditingController(text: selectedDays.toString());
    DateTime selectedDate = customer.dueDate ??
        (selectedMode == 'daily'
            ? DateTime.now().add(const Duration(days: 1))
            : DateTime.now().add(Duration(days: selectedDays)));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (bCtx, setBState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(bCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Beddel Qorshaha Xusuusinta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(bCtx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  const Text('Dooro Nooca Xusuusinta:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setBState(() {
                              selectedMode = 'after_days';
                              selectedDate = DateTime.now()
                                  .add(Duration(days: selectedDays));
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedMode == 'after_days'
                                  ? themeColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedMode == 'after_days'
                                    ? themeColor
                                    : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.date_range,
                                    size: 20,
                                    color: selectedMode == 'after_days'
                                        ? Colors.white
                                        : const Color(0xFF4B5563)),
                                const SizedBox(height: 4),
                                Text(
                                  'Maalmo Kadib',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: selectedMode == 'after_days'
                                        ? Colors.white
                                        : const Color(0xFF1D2338),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setBState(() {
                              selectedMode = 'daily';
                              selectedDays = 1;
                              selectedDate =
                                  DateTime.now().add(const Duration(days: 1));
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedMode == 'daily'
                                  ? themeColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedMode == 'daily'
                                    ? themeColor
                                    : const Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.repeat,
                                    size: 20,
                                    color: selectedMode == 'daily'
                                        ? Colors.white
                                        : const Color(0xFF4B5563)),
                                const SizedBox(height: 4),
                                Text(
                                  'Maalin Kasta (Laga bilaabo 1-aad)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: selectedMode == 'daily'
                                        ? Colors.white
                                        : const Color(0xFF1D2338),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (selectedMode == 'after_days') ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [1, 3, 7, 14, 30].map((d) {
                        final isSel = selectedDays == d;
                        return ChoiceChip(
                          label: Text('$d Maalmood'),
                          selected: isSel,
                          selectedColor: themeColor,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF374151),
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setBState(() {
                                selectedDays = d;
                                customDaysCtrl.text = d.toString();
                                selectedDate =
                                    DateTime.now().add(Duration(days: d));
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
                              labelText: 'Geli Maalmo Kale',
                              suffixText: 'Maalmood',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null && parsed > 0) {
                                setBState(() {
                                  selectedDays = parsed;
                                  selectedDate =
                                      DateTime.now().add(Duration(days: parsed));
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Icon(Icons.calendar_month,
                                color: themeColor, size: 20),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: bCtx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              final diff =
                                  picked.difference(DateTime.now()).inDays + 1;
                              setBState(() {
                                selectedDate = picked;
                                selectedDays = diff > 0 ? diff : 1;
                                customDaysCtrl.text = selectedDays.toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      selectedMode == 'daily'
                          ? 'Xusuusin: Maalin kasta laga bilaabo berrito (${DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 1)))}) ilaa lacagta la bixiyo.'
                          : 'Waqtiga Bixinta: ${DateFormat('dd MMM yyyy').format(selectedDate)} ($selectedDays maalmood kadib)',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        GashiRepository.instance.updateCustomerReminder(
                          customerId: customer.id,
                          reminderMode: selectedMode,
                          reminderDays: selectedDays,
                          dueDate: selectedDate,
                        );
                        Navigator.pop(bCtx);
                        onUpdated();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Jadwalka xusuusinta si guul leh ayaa loo beddelay!'),
                            backgroundColor: themeColor,
                          ),
                        );
                      },
                      child: const Text('Keydi Xusuusinta',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
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
  // COLLECT REPAYMENT MODAL
  // ============================================================================
  void _openCollectPaymentModal(
      BuildContext context, Customer customer, Color themeColor) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
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
                      Expanded(
                        child: Text('Collect Repayment - ${customer.name}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
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
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining Debt:',
                            style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Text(
                          '\$${customer.currentCreditBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 12),

                  const Text('Notes / Xusuusin (Optional):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Qayb ka mid ah deynta',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 18),

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
                          notes: notesCtrl.text.trim(),
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
  // ADD NEW CUSTOMER MODAL (With Full Schema & Reminder Schedule)
  // ============================================================================
  void _openAddCustomerModal(BuildContext context, Color themeColor) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final initialDebtCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    String reminderMode = 'after_days';
    int reminderDays = 7;
    final customDaysCtrl = TextEditingController(text: '7');
    DateTime calculatedDueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setAddState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
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
                    const SizedBox(height: 10),

                    const Text('Guarantor / Notes (Damiin ama Faahfaahin):',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Damiin: Axmed Cali ama alaab gaar ah',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ----------------------------------------------------
                    // Reminder Options
                    // ----------------------------------------------------
                    const Divider(),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        const Text('Qorshaha Xusuusinta Daynta:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setAddState(() {
                                reminderMode = 'after_days';
                                calculatedDueDate = DateTime.now()
                                    .add(Duration(days: reminderDays));
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: reminderMode == 'after_days'
                                    ? themeColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: reminderMode == 'after_days'
                                      ? themeColor
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.date_range,
                                      size: 18,
                                      color: reminderMode == 'after_days'
                                          ? Colors.white
                                          : const Color(0xFF4B5563)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Maalmo Kadib',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: reminderMode == 'after_days'
                                          ? Colors.white
                                          : const Color(0xFF1D2338),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setAddState(() {
                                reminderMode = 'daily';
                                reminderDays = 1;
                                calculatedDueDate = DateTime.now()
                                    .add(const Duration(days: 1));
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: reminderMode == 'daily'
                                    ? themeColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: reminderMode == 'daily'
                                      ? themeColor
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.repeat,
                                      size: 18,
                                      color: reminderMode == 'daily'
                                          ? Colors.white
                                          : const Color(0xFF4B5563)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Maalin Kasta (1-aad)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: reminderMode == 'daily'
                                          ? Colors.white
                                          : const Color(0xFF1D2338),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (reminderMode == 'after_days') ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [1, 3, 7, 14, 30].map((d) {
                          final isSel = reminderDays == d;
                          return ChoiceChip(
                            label: Text('$d Maalmood'),
                            selected: isSel,
                            selectedColor: themeColor,
                            labelStyle: TextStyle(
                              color:
                                  isSel ? Colors.white : const Color(0xFF374151),
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 11,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setAddState(() {
                                  reminderDays = d;
                                  customDaysCtrl.text = d.toString();
                                  calculatedDueDate =
                                      DateTime.now().add(Duration(days: d));
                                });
                              }
                            },
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customDaysCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Maalmo Kale',
                                suffixText: 'Maalmood',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFC),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed > 0) {
                                  setAddState(() {
                                    reminderDays = parsed;
                                    calculatedDueDate = DateTime.now()
                                        .add(Duration(days: parsed));
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Icon(Icons.calendar_month,
                                  color: themeColor, size: 20),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: calculatedDueDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                final diff =
                                    picked.difference(DateTime.now()).inDays + 1;
                                setAddState(() {
                                  calculatedDueDate = picked;
                                  reminderDays = diff > 0 ? diff : 1;
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reminderMode == 'daily'
                            ? 'Xusuusin maalinle ah laga bilaabo berrito.'
                            : 'Waqtiga bixinta: ${calculatedDueDate.day}/${calculatedDueDate.month}/${calculatedDueDate.year} ($reminderDays maalmood kadib)',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151)),
                      ),
                    ),
                    const SizedBox(height: 18),

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
                              totalDebt: debt,
                              paidDebt: 0.0,
                              currentCreditBalance: debt,
                              dueDate: calculatedDueDate,
                              reminderMode: reminderMode,
                              reminderDays: reminderDays,
                              status: debt > 0 ? 'unpaid' : 'cleared',
                              notes: notesCtrl.text.trim(),
                              createdAt: DateTime.now(),
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
              ),
            );
          },
        );
      },
    );
  }
}
