import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../../general_features/repository/gashi_repository.dart';
import '../../general_features/services/currency_service.dart';
import '../fake_data/service_pos_data.dart';
import '../services/service_controller.dart';
import 'service_pos_page.dart';

// ============================================================================
// SERVICE SERVICES CATALOG & MANAGEMENT PAGE
// Schema Aligned & Customizable Attributes:
// - Database Schema: `services` (id, business_id, name, price, custom_attributes)
// - Treated as direct products sold via POS (with Dayn & Bargaining support)
// - No intermediate job status lifecycles (pending/in_progress/completed)
// ============================================================================

class ServiceServicesPage extends StatefulWidget {
  const ServiceServicesPage({super.key});

  @override
  State<ServiceServicesPage> createState() => _ServiceServicesPageState();
}

class _ServiceServicesPageState extends State<ServiceServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Dhammaan';

  @override
  void dispose() {
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

        final filtered = allServices.where((s) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = s.name.toLowerCase().contains(query) ||
              (s.technician?.toLowerCase().contains(query) ?? false) ||
              (s.category.toLowerCase().contains(query)) ||
              s.resolvedCustomAttributes.values.any(
                  (v) => v.toString().toLowerCase().contains(query));
          final matchesCat =
              _selectedCategory == 'Dhammaan' || s.category == _selectedCategory;
          return matchesSearch && matchesCat;
        }).toList();

        final avgPrice = allServices.isNotEmpty
            ? allServices.fold<double>(0.0, (sum, s) => sum + s.price) /
                allServices.length
            : 0.0;

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
                  'Adeegyada (Services)',
                  style: TextStyle(
                    color: Color(0xFF1D2338),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Diiwaanka Adeegyada & Sifooyinka Gaarka ah (Schema Aligned)',
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
          ),
          body: Column(
            children: [
              // 1. KPI SUMMARY BANNER
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
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
                    _buildKpiItem(
                      icon: Icons.design_services_outlined,
                      label: 'Wadarta Adeegyada',
                      value: '${allServices.length}',
                      color: const Color(0xFF4F46E5),
                    ),
                    Container(height: 30, width: 1, color: const Color(0xFFE5E7EB)),
                    _buildKpiItem(
                      icon: Icons.category_outlined,
                      label: 'Qaybaha',
                      value: '${(categories.length - 1).clamp(0, 999)}',
                      color: const Color(0xFF0EA5E9),
                    ),
                    Container(height: 30, width: 1, color: const Color(0xFFE5E7EB)),
                    _buildKpiItem(
                      icon: Icons.payments_outlined,
                      label: 'Qiimaha Celcelis',
                      value: CurrencyService.instance.formatUsd(avgPrice),
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),

              // 2. SEARCH BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Raadi adeeg, farsamo-yaqaan ama sifo gaar ah...',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
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
              ),

              // 3. CATEGORY FILTER CHIPS
              SizedBox(
                height: 42,
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
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
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

              // 4. SERVICES LIST
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
                              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                          return _buildServiceCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // KPI Widget
  Widget _buildKpiItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF8E99AF)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2338),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Service Card
  Widget _buildServiceCard(BuildContext context, ServiceItem item) {
    final customAttrs = item.resolvedCustomAttributes;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCachedImage(
                imageUrl: item.imageUrl,
                width: 68,
                height: 68,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2338),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price Dual USD & SLSH
                    Text(
                      CurrencyService.instance.formatDual(item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Customized Attributes Chips (Duration, Technician, Notes)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.duration.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule, size: 10, color: Color(0xFF4F46E5)),
                                const SizedBox(width: 3),
                                Text(
                                  item.duration,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.technician != null && item.technician!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_outline, size: 10, color: Color(0xFF6B7280)),
                                const SizedBox(width: 3),
                                Text(
                                  item.technician!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF4B5563),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (customAttrs.containsKey('warranty'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_outlined, size: 10, color: Color(0xFF059669)),
                                const SizedBox(width: 3),
                                Text(
                                  '${customAttrs['warranty']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F3F6)),
          const SizedBox(height: 8),

          // Actions Row: Info, Edit, Sell in POS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    icon: const Icon(Icons.info_outline, size: 14),
                    label: const Text('Faahfaahin', style: TextStyle(fontSize: 12)),
                    onPressed: () => _openServiceDetailsModal(context, item),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF6B7280)),
                    label: const Text(
                      'Wax ka beddel',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    onPressed: () => _openEditServiceModal(context, item),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.point_of_sale, size: 14),
                label: const Text(
                  'Iibi POS-ka',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ServicePosPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SERVICE DETAILS MODAL (With Schema Info & Customized Attributes)
  // ============================================================================
  void _openServiceDetailsModal(BuildContext context, ServiceItem item) {
    final customAttrs = item.resolvedCustomAttributes;

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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2338),
                      ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCachedImage(
                    imageUrl: item.imageUrl,
                    width: 75,
                    height: 75,
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
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qaybta: ${item.category}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        Text(
                          'Shaxda Kaydka: services (id: ${item.id}, business_id: 4)',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CUSTOMIZED ATTRIBUTES CONTAINER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune, size: 14, color: Color(0xFF4F46E5)),
                        SizedBox(width: 6),
                        Text(
                          'Sifooyinka Gaarka ah (Customized Attributes)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2338),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...customAttrs.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D2338),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Sell directly in POS button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text(
                    'Iibi Adeeggan POS-ka (Sell at POS)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (context) => const ServicePosPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // ADD SERVICE MODAL (Schema Inputs + Customized Attributes)
  // ============================================================================
  void _openAddServiceModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'Baabuur');
    final durationCtrl = TextEditingController(text: '30 daqiiqo');
    final technicianCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final warrantyCtrl = TextEditingController();

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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ku dar Adeeg Cusub (Add Service)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(aCtx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // SECTION 1: SCHEMA INPUTS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEF2F6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storage, size: 14, color: Color(0xFF4F46E5)),
                          SizedBox(width: 6),
                          Text(
                            'Xogta Asaasiga ah ee Shaxda (Database Schema)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      const Text('Magaca Adeegga (Service Name) *:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Tusaale: Beddelka Shaashad ama Dhaqid Baabuur',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Qiimaha (\$ USD) *:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: priceCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                                const Text('Qaybta (Category) *:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: categoryCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Baabuur, Farsamo, iwm.',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // SECTION 2: CUSTOMIZED ATTRIBUTES (JSONB)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, size: 14, color: Color(0xFF4338CA)),
                          SizedBox(width: 6),
                          Text(
                            'Sifooyinka Gaarka ah (Customized Attributes - JSONB)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF4338CA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Waqtiga (Duration):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: durationCtrl,
                                  decoration: InputDecoration(
                                    hintText: '30 daqiiqo',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                                const Text('Farsamo-yaqaan (Staff):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: technicianCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Tusaale: Cali Farsamo',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Damaanad (Warranty / Spec):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: warrantyCtrl,
                                  decoration: InputDecoration(
                                    hintText: '3 bilood damaanad',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                                const Text('Faahfaahin (Note):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: noteCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Tixraac ama faahfaahin',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text) ?? 0.0;
                      if (name.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fadlan geli magaca adeegga iyo qiimaha saxda ah!')),
                        );
                        return;
                      }

                      final customAttributes = <String, dynamic>{
                        if (durationCtrl.text.trim().isNotEmpty) 'duration': durationCtrl.text.trim(),
                        if (technicianCtrl.text.trim().isNotEmpty) 'technician': technicianCtrl.text.trim(),
                        if (warrantyCtrl.text.trim().isNotEmpty) 'warranty': warrantyCtrl.text.trim(),
                        if (noteCtrl.text.trim().isNotEmpty) 'note': noteCtrl.text.trim(),
                      };

                      ServiceController.instance.addService(
                        name: name,
                        price: price,
                        duration: durationCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        technician: technicianCtrl.text.trim().isNotEmpty ? technicianCtrl.text.trim() : null,
                        note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                        customAttributes: customAttributes,
                      );

                      Navigator.pop(aCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Adeegga $name si guul leh ayaa loo keydiyay!'),
                          backgroundColor: const Color(0xFF4F46E5),
                        ),
                      );
                    },
                    child: const Text(
                      'Keydi Adeegga (Save Service)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // EDIT SERVICE MODAL
  // ============================================================================
  void _openEditServiceModal(BuildContext context, ServiceItem item) {
    final customAttrs = item.resolvedCustomAttributes;
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(2));
    final categoryCtrl = TextEditingController(text: item.category);
    final durationCtrl = TextEditingController(text: item.duration);
    final technicianCtrl = TextEditingController(text: item.technician ?? '');
    final warrantyCtrl = TextEditingController(text: customAttrs['warranty']?.toString() ?? '');
    final noteCtrl = TextEditingController(text: item.note ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (eCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(eCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wax ka beddel Adeegga (Edit Service)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(eCtx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Magaca Adeegga:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Qiimaha (\$ USD):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          const Text('Qaybta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: categoryCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Waqtiga (Custom Attribute):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: durationCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          const Text('Farsamo-yaqaan (Custom Attribute):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: technicianCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Damaanad (Warranty):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: warrantyCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          const Text('Faahfaahin (Note):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: noteCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          foregroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          ServiceController.instance.deleteService(item.id);
                          Navigator.pop(eCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Adeegga ${item.name} waa la tirtiray!'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        },
                        child: const Text('Tirtir (Delete)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text) ?? item.price;
                          if (name.isEmpty) return;

                          final updatedAttrs = Map<String, dynamic>.from(customAttrs);
                          if (durationCtrl.text.trim().isNotEmpty) {
                            updatedAttrs['duration'] = durationCtrl.text.trim();
                          }
                          if (technicianCtrl.text.trim().isNotEmpty) {
                            updatedAttrs['technician'] = technicianCtrl.text.trim();
                          }
                          if (warrantyCtrl.text.trim().isNotEmpty) {
                            updatedAttrs['warranty'] = warrantyCtrl.text.trim();
                          }
                          if (noteCtrl.text.trim().isNotEmpty) {
                            updatedAttrs['note'] = noteCtrl.text.trim();
                          }

                          final updated = ServiceItem(
                            id: item.id,
                            name: name,
                            price: price,
                            duration: durationCtrl.text.trim(),
                            category: categoryCtrl.text.trim(),
                            imageUrl: item.imageUrl,
                            technician: technicianCtrl.text.trim().isNotEmpty ? technicianCtrl.text.trim() : null,
                            note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                            tag: item.tag,
                            customAttributes: updatedAttrs,
                          );

                          ServiceController.instance.updateService(updated);
                          Navigator.pop(eCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Adeegga si guul leh ayaa loo cusbooneysiiyay!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        child: const Text('Cusbooneysii (Update)', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
