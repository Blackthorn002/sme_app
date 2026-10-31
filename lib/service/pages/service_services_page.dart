import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../../general_features/models/gashi_models.dart';
import '../../general_features/repository/gashi_repository.dart';
import '../../general_features/services/currency_service.dart';
import '../fake_data/service_pos_data.dart';
import '../services/service_controller.dart';
import 'service_pos_page.dart';

// ============================================================================
// SERVICE SERVICES & JOBS MANAGEMENT PAGE (Somali-Localized & Schema Aligned)
// Backed by PostgreSQL:
// - `services` (id, business_id, name, price)
// - `service_jobs` (id, business_id, customer_id, service_id, assigned_staff_id,
//                   status, total_amount, deposit_paid, balance_due, created_at)
// ============================================================================

class ServiceServicesPage extends StatefulWidget {
  const ServiceServicesPage({super.key});

  @override
  State<ServiceServicesPage> createState() => _ServiceServicesPageState();
}

class _ServiceServicesPageState extends State<ServiceServicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Services Catalog Filters
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Dhammaan';

  // Jobs Filter
  String _selectedJobStatus = 'Dhammaan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ServiceController.instance,
        GashiRepository.instance,
        CurrencyService.instance,
      ]),
      builder: (context, _) {
        final allServices = ServiceController.instance.services;
        final categories = ServiceController.instance.availableCategories;
        final jobs = GashiRepository.instance.getServiceJobs(4);

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: Color(0xFF1D2338)),
                    onPressed: () => Navigator.maybePop(context),
                  )
                : null,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adeegyada & Shaqooyinka',
                  style: TextStyle(
                      color: Color(0xFF1D2338),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Text(
                  'Diiwaanka Adeegyada & Shaqooyinka Socda (PostgreSQL Schema)',
                  style: TextStyle(color: Color(0xFF8E99AF), fontSize: 11),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ku dar Adeeg Cusub',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                onPressed: () => _openAddServiceModal(context),
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.miscellaneous_services_outlined, size: 18),
                  text: 'Diiwaanka Adeegyada (${allServices.length})',
                ),
                Tab(
                  icon: const Icon(Icons.build_circle_outlined, size: 18),
                  text: 'Shaqooyinka Socda (${jobs.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: SERVICES CATALOG
              _buildServicesCatalogTab(allServices, categories),

              // TAB 2: SERVICE JOBS WORKFLOW
              _buildServiceJobsTab(jobs),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // TAB 1: SERVICES CATALOG (Diiwaanka Adeegyada)
  // ============================================================================
  Widget _buildServicesCatalogTab(
      List<ServiceItem> allServices, List<String> categories) {
    final filtered = allServices.where((s) {
      final matchesSearch = s.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (s.technician?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCat =
          _selectedCategory == 'Dhammaan' || s.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Container(
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
                      hintText: 'Raadi adeeg ama farsamo-yaqaan...',
                      hintStyle:
                          TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
                    child: const Icon(Icons.close,
                        size: 18, color: Color(0xFF9CA3AF)),
                  ),
              ],
            ),
          ),
        ),

        // Category filter pills
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: const Color(0xFF4F46E5),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                onSelected: (val) {
                  setState(() => _selectedCategory = cat);
                },
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Services List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.miscellaneous_services_outlined,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Ma jiro adeeg la helay oo ku habboon baadhitaanka.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
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
                              AppCachedImage(
                                imageUrl: item.imageUrl,
                                width: 72,
                                height: 72,
                                borderRadius: BorderRadius.circular(12),
                                loadingColor: const Color(0xFF4F46E5),
                                fallbackIcon: Icons.build_circle_outlined,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D2338),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          CurrencyService.instance.format(item.price),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF4B5563),
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.schedule,
                                                  size: 10,
                                                  color: Color(0xFF4F46E5)),
                                              const SizedBox(width: 3),
                                              Text(
                                                item.duration,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF4F46E5),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.technician != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Farsamo: ${item.technician!}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF8E99AF)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFF1F3F6)),
                          const SizedBox(height: 8),

                          // Quick Actions Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.info_outline, size: 14),
                                label: const Text('Faahfaahin',
                                    style: TextStyle(fontSize: 12)),
                                onPressed: () =>
                                    _openServiceDetailsModal(context, item),
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      side: const BorderSide(
                                          color: Color(0xFF4F46E5)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.post_add,
                                        size: 14, color: Color(0xFF4F46E5)),
                                    label: const Text('Qabo Shaqo',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF4F46E5),
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () =>
                                        _openBookServiceJobModal(context, item),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.shopping_cart_checkout,
                                        size: 14),
                                    label: const Text('Iibi POS-ka',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const ServicePosPage(),
                                        ),
                                      );
                                    },
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
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 2: SERVICE JOBS WORKFLOW (Shaqooyinka Socda - PostgreSQL service_jobs)
  // ============================================================================
  Widget _buildServiceJobsTab(List<ServiceJob> jobs) {
    final filteredJobs = jobs.where((j) {
      if (_selectedJobStatus == 'Dhammaan') return true;
      if (_selectedJobStatus == 'Sugaya') return j.status == 'pending';
      if (_selectedJobStatus == 'Ku jira Shaqada') return j.status == 'in_progress';
      if (_selectedJobStatus == 'Diyaar') return j.status == 'completed';
      if (_selectedJobStatus == 'La Bixiyay') return j.status == 'delivered';
      return true;
    }).toList();

    final totalJobs = jobs.length;
    final inProgressJobs = jobs.where((j) => j.status == 'in_progress').length;
    final completedJobs = jobs.where((j) => j.status == 'completed').length;
    final totalBalanceDue = jobs.fold<double>(0.0, (sum, j) => sum + j.balanceDue);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildJobMetricCard(
                  title: 'Wadarta Shaqooyinka',
                  value: '$totalJobs',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF4F46E5),
                  bg: const Color(0xFFEEF2FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildJobMetricCard(
                  title: 'Ku jira Shaqada',
                  value: '$inProgressJobs',
                  icon: Icons.build_circle_outlined,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildJobMetricCard(
                  title: 'Diyaar ah (Diyaar)',
                  value: '$completedJobs',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF10B981),
                  bg: const Color(0xFFE6F7F0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildJobMetricCard(
                  title: 'Haraaga Dhiman',
                  value: CurrencyService.instance.format(totalBalanceDue),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFEF4444),
                  bg: const Color(0xFFFDE8E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildJobStatusChip('Dhammaan', 'Dhammaan'),
                const SizedBox(width: 8),
                _buildJobStatusChip('Sugaya', 'Sugaya'),
                const SizedBox(width: 8),
                _buildJobStatusChip('Ku jira Shaqada', 'Ku jira Shaqada'),
                const SizedBox(width: 8),
                _buildJobStatusChip('Diyaar', 'Diyaar'),
                const SizedBox(width: 8),
                _buildJobStatusChip('La Bixiyay', 'La Bixiyay'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diiwaanka Shaqooyinka Farsamada',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2338)),
              ),
              Text(
                '${filteredJobs.length} shaqo',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E99AF)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filteredJobs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 10),
                  Text(
                    'Ma jirto shaqo ku jirta xaaladdan.',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredJobs.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final job = filteredJobs[idx];
                return _buildJobCard(context, job);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildJobStatusChip(String label, String value) {
    final isSelected = _selectedJobStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedJobStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
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

  Widget _buildJobMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, ServiceJob job) {
    final repo = GashiRepository.instance;

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
          // Header: ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#JOB-${job.id}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    job.formattedCreatedAt,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: job.statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.statusLabelSomali,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: job.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Service Title & Customer Info
          Text(
            job.serviceName,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2338)),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                '${job.customerName} (${job.customerPhone})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],
          ),
          if (job.referenceInfo != null && job.referenceInfo!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 4),
                Text(
                  job.referenceInfo!,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5)),
                ),
              ],
            ),
          ],
          if (job.assignedStaff != null) ...[
            const SizedBox(height: 4),
            Text(
              'Farsamo-yaqaanka ku shaqaynaya: ${job.assignedStaff!}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
            ),
          ],
          const SizedBox(height: 10),

          // Financial Breakdown
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Wadarta',
                        style: TextStyle(fontSize: 10, color: Color(0xFF8E99AF))),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyService.instance.format(job.totalAmount),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2338)),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE5E7EB)),
                Column(
                  children: [
                    const Text('Deposit La Bixiyay',
                        style: TextStyle(fontSize: 10, color: Color(0xFF8E99AF))),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyService.instance.format(job.depositPaid),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981)),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE5E7EB)),
                Column(
                  children: [
                    const Text('Haraaga Dhiman',
                        style: TextStyle(fontSize: 10, color: Color(0xFF8E99AF))),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyService.instance.format(job.balanceDue),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: job.isPaidInFull
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.phone_outlined,
                        size: 14, color: Color(0xFF4B5563)),
                    label: const Text('Wac',
                        style: TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Wicitaan: ${job.customerPhone}')),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: Color(0xFF10B981)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 14, color: Color(0xFF10B981)),
                    label: const Text('Ogeysii',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981))),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '📱 Fariin ayaa loo diray ${job.customerName}: Shaqadii waa diyaar!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  if (!job.isPaidInFull) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.attach_money, size: 14),
                      label: const Text('Qaado Haraaga',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _openPayJobBalanceModal(context, job),
                    ),
                    const SizedBox(width: 6),
                  ],
                  PopupMenuButton<String>(
                    tooltip: 'Beddel Xaaladda',
                    onSelected: (newStatus) {
                      repo.updateServiceJobStatus(job.id, newStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Xaaladda shaqada #${job.id} waa la beddelay!'),
                          backgroundColor: const Color(0xFF4F46E5),
                        ),
                      );
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'pending',
                        child: Text('Sugaya Bilow (Pending)'),
                      ),
                      const PopupMenuItem(
                        value: 'in_progress',
                        child: Text('Ku jira Shaqada (In Progress)'),
                      ),
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Diyaar ah (Completed)'),
                      ),
                      const PopupMenuItem(
                        value: 'delivered',
                        child: Text('La Wareejiyay (Delivered)'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync_alt, size: 14, color: Color(0xFF4F46E5)),
                          SizedBox(width: 4),
                          Text(
                            'Xaaladda',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5)),
                          ),
                        ],
                      ),
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

  // Quick Modal: Pay Job Balance
  void _openPayJobBalanceModal(BuildContext context, ServiceJob job) {
    final amountCtrl =
        TextEditingController(text: job.balanceDue.toStringAsFixed(2));
    String paymentMethod = 'Zaad';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setPayState) {
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
                      Text('Qaado Haraaga Shaqada #${job.id}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text('Adeegga: ${job.serviceName} • Macmiil: ${job.customerName}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const SizedBox(height: 12),

                  const Text('Lacagta la bixinayo (\$):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFC),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Qaabka Lacag-bixinta:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Zaad', 'e-Dahab', 'Kaash'].map((pm) {
                      final isSel = paymentMethod == pm;
                      return ChoiceChip(
                        label: Text(pm),
                        selected: isSel,
                        selectedColor: const Color(0xFF10B981),
                        labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.bold),
                        onSelected: (val) {
                          if (val) setPayState(() => paymentMethod = pm);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                        if (amt <= 0) return;
                        GashiRepository.instance.payServiceJobBalance(job.id, amt);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Waxa la qabtay \$${amt.toStringAsFixed(2)} oo haraa ah!'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text('Xaqiiji Lacagta',
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

  // Book / Create Service Job Modal
  void _openBookServiceJobModal(BuildContext context, ServiceItem service) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+252 63 ');
    final refCtrl = TextEditingController();
    final depositCtrl =
        TextEditingController(text: (service.price * 0.5).toStringAsFixed(2));
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(bCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Diiwaangeli Shaqo: ${service.name}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bCtx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Magaca Macmiilka:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Axmed Maxamed',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                const Text('Telefoonka Macmiilka:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                const Text('Xogta Qalabka / Taargo / Cabbir (Reference):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: refCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Taargo SL-A 1234 ama iPhone 13 Pro',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wadarta Qiimaha:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              CurrencyService.instance.format(service.price),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deposit La Bixiyay (\$):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: depositCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const Text('Faahfaahin & Xusuusin (Notes):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Waxyaabaha macmiilku ka cawday ama shuruudaha...',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
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
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final deposit = double.tryParse(depositCtrl.text) ?? 0.0;
                      final newJob = ServiceJob(
                        id: DateTime.now().millisecondsSinceEpoch % 10000,
                        businessId: 4,
                        customerId: DateTime.now().millisecondsSinceEpoch % 1000,
                        customerName: name,
                        customerPhone: phoneCtrl.text.trim(),
                        serviceId: int.tryParse(service.id.replaceAll(RegExp(r'\D'), '')) ?? 1,
                        serviceName: service.name,
                        assignedStaff: service.technician,
                        status: 'in_progress',
                        totalAmount: service.price,
                        depositPaid: deposit,
                        balanceDue: (service.price - deposit).clamp(0.0, double.infinity),
                        referenceInfo: refCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        createdAt: DateTime.now(),
                      );

                      GashiRepository.instance.addServiceJob(newJob);
                      Navigator.pop(bCtx);

                      // Switch to jobs tab
                      _tabController.animateTo(1);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Shaqada #${newJob.id} si guul leh ayaa loo furay!'),
                          backgroundColor: const Color(0xFF4F46E5),
                        ),
                      );
                    },
                    child: const Text('Diiwaangeli Shaqada (Save Job)',
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
  }

  // Modal: Add New Service
  void _openAddServiceModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '45 daqiiqo');
    final technicianCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Farsamo & IT');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (aCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(aCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ku dar Adeeg Cusub',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(aCtx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Magaca Adeegga:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Beddelka Shaashad ama Dhaqid',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Qiimaha (\$ USD):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Waqtiga (Duration):',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: durationCtrl,
                            decoration: InputDecoration(
                              hintText: '30 daqiiqo',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const Text('Qaybta Adeegga (Category):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                    hintText: 'Baabuur, Farsamo, Dhar, iwm.',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                const Text('Farsamo-yaqaanka (Staff):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: technicianCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Cali & Kooxda',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
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
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text) ?? 0.0;
                      if (name.isEmpty || price <= 0) return;

                      ServiceController.instance.addService(
                        name: name,
                        price: price,
                        duration: durationCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        imageUrl:
                            'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=400&q=80',
                        technician: technicianCtrl.text.trim().isNotEmpty
                            ? technicianCtrl.text.trim()
                            : null,
                      );

                      Navigator.pop(aCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Adeegga $name si guul leh ayaa loo daray!'),
                          backgroundColor: const Color(0xFF4F46E5),
                        ),
                      );
                    },
                    child: const Text('Keydi Adeegga (Save Service)',
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
  }

  // Details Modal
  void _openServiceDetailsModal(BuildContext context, ServiceItem item) {
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
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2338)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              Row(
                children: [
                  AppCachedImage(
                    imageUrl: item.imageUrl,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyService.instance.formatDual(item.price),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(height: 4),
                        Text('Qaybta: ${item.category}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                        Text('Waqtiga: ${item.duration}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                        if (item.technician != null)
                          Text('Farsamo-yaqaan: ${item.technician}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF8E99AF))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.post_add),
                  label: const Text('Qabo Shaqo Adeeggan Ah (Book Job)',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openBookServiceJobModal(context, item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
