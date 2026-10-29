import 'package:flutter/material.dart';
import '../../common/widgets/app_cached_image.dart';
import '../fake_data/service_pos_data.dart';
import '../services/service_controller.dart';
import 'service_pos_page.dart';

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
      animation: ServiceController.instance,
      builder: (context, _) {
        final allServices = ServiceController.instance.services;
        final categories = ServiceController.instance.availableCategories;

        final filtered = allServices.where((s) {
          final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (s.technician?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          final matchesCat = _selectedCategory == 'Dhammaan' || s.category == _selectedCategory;
          return matchesSearch && matchesCat;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1D2338)),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adeegyada (Services)',
                  style: TextStyle(color: Color(0xFF1D2338), fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${allServices.length} adeeg oo diiwaangashan',
                  style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 12),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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

              // Services List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.miscellaneous_services_outlined, size: 56, color: Colors.grey.shade400),
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
                          return GestureDetector(
                            onTap: () => _openServiceDetailsModal(context, item),
                            child: Container(
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppCachedImage(
                                    imageUrl: item.imageUrl,
                                    width: 76,
                                    height: 76,
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
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1D2338),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
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
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.category,
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEF2FF),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.schedule, size: 10, color: Color(0xFF4F46E5)),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    item.duration,
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
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
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: 'Faahfaahin & U Iibi',
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4F46E5)),
                                        ),
                                        onPressed: () => _openServiceDetailsModal(context, item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
  }

  // Comprehensive Service Details Modal (Read-only + Assign in POS)
  void _openServiceDetailsModal(BuildContext context, ServiceItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
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

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Faahfaahinta Adeegga (Service Details)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
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
                      // Service Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AppCachedImage(
                          imageUrl: item.imageUrl,
                          width: double.infinity,
                          height: 180,
                          borderRadius: BorderRadius.circular(16),
                          loadingColor: const Color(0xFF4F46E5),
                          fallbackIcon: Icons.build_circle_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D2338)),
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badges Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                            child: Text(item.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule, size: 14, color: Color(0xFF4F46E5)),
                                const SizedBox(width: 4),
                                Text(item.duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Diyaar ah / Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Admin lock note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.shield_outlined, color: Color(0xFF6B7280), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Adeeggan iyo qiimihiisa waxa laga xukumaa dhanka Admin-ka. Halkan koodhkiisa iyo macluumaadkiisa waxa loo isticmaalaa iibinta POS-ka.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details Table
                      const Text('Xogta Adeegga', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D2338))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            _detailRow('Farsamo-yaqaan:', item.technician ?? 'Shaqaale Farsamo oo Guud'),
                            _detailRow('Nooca Bixinta:', 'Goobta ama Guriga (On-Site/In-Shop)'),
                            _detailRow('Waqtiga lagu Qiyaasay:', item.duration),
                            _detailRow('Qalabka loo isticmaalo:', 'Qalabka Farsamada ee Shirkadda'),
                            _detailRow('Xaaladda:', 'La ogolyahay iibinta POS-ka'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Assign & Sell in POS Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.point_of_sale, size: 20),
                          label: const Text(
                            'U Iibi Adeeggan POS-ka (Assign in POS)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => const ServicePosPage(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Waxaad gashay POS-ka si aad u iibiso: ${item.name}!'),
                                backgroundColor: const Color(0xFF4F46E5),
                              ),
                            );
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1D2338)))),
        ],
      ),
    );
  }
}
