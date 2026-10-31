import 'package:flutter/material.dart';
import '../fake_data/pharmacy_pos_data.dart';
import '../pages/pharmacy_pos_page.dart';

// ============================================================================
// PHARMACY FEATURE: PATIENT MEDICAL RECORDS (Diiwaanka Caafimaadka Macaamiisha)
// Supports:
// - Detailed health records (Blood group, Allergies, Chronic diseases)
// - Regular prescription management for chronic conditions
// - ONE-TAP REFILL: Tapping 'Refill' pre-loads all patient medicines into POS cart
// ============================================================================

class PatientMedicalRecord {
  final String id;
  final String patientName;
  final String phone;
  final int age;
  final String gender;
  final String bloodType;
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<PrescriptionEntry> prescriptions;
  final String nextRefillDate;

  const PatientMedicalRecord({
    required this.id,
    required this.patientName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.chronicConditions,
    required this.allergies,
    required this.prescriptions,
    this.nextRefillDate = '30 Maalmood Gudahood',
  });

  bool get isChronicPatient => chronicConditions.isNotEmpty;

  // Generates pre-selected cart items for POS refill checkout
  List<PharmacyCartItem> generateRefillCartItems() {
    final List<PharmacyCartItem> items = [];

    for (final rx in prescriptions) {
      // Find matching item in pharmacy inventory catalog
      PharmacyMenuItem? matchedItem;
      try {
        matchedItem = samplePharmacyMenuItems.firstWhere(
          (m) =>
              m.name.toLowerCase().contains(rx.medicineName.toLowerCase()) ||
              rx.medicineName.toLowerCase().contains(m.name.toLowerCase()),
        );
      } catch (_) {
        matchedItem = PharmacyMenuItem(
          id: 'rx_${rx.medicineName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
          name: '${rx.medicineName} (${rx.dosage})',
          price: 5.00,
          category: 'Daawo Joogto ah',
          tag: rx.dosage,
          note: 'Qoraalka Dhakhtarka: ${rx.doctorName}',
          stockQuantity: 50,
          imageUrl: 'https://via.placeholder.com/150?text=${Uri.encodeComponent(rx.medicineName)}',
        );
      }

      items.add(
        PharmacyCartItem(
          item: matchedItem,
          quantity: 1,
          tag: rx.dosage,
          note: 'Qiyaasta: ${rx.frequency} • Dhakhtar: ${rx.doctorName}',
        ),
      );
    }

    return items;
  }
}

class PrescriptionEntry {
  final String medicineName;
  final String dosage;
  final String frequency;
  final String doctorName;
  final String prescribedDate;

  const PrescriptionEntry({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.doctorName,
    required this.prescribedDate,
  });
}

class PatientMedicalRecordsPage extends StatefulWidget {
  const PatientMedicalRecordsPage({super.key});

  @override
  State<PatientMedicalRecordsPage> createState() =>
      _PatientMedicalRecordsPageState();
}

class _PatientMedicalRecordsPageState extends State<PatientMedicalRecordsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCondition = 'Dhammaan';

  final List<PatientMedicalRecord> _patients = [
    const PatientMedicalRecord(
      id: 'PT-1001',
      patientName: 'Cali Jaamac Cilmi',
      phone: '+252 63 4455667',
      age: 48,
      gender: 'Male',
      bloodType: 'O+',
      chronicConditions: ['Dhiigkar (Hypertension)', 'Sonkorow (Type 2)'],
      allergies: ['Penicillin'],
      nextRefillDate: 'Maanta / Waqtigu waa gaadhay',
      prescriptions: [
        PrescriptionEntry(
          medicineName: 'Amlodipine',
          dosage: '5mg',
          frequency: '1x Maalintii subaxdii',
          doctorName: 'Dr. Axmed Nuur',
          prescribedDate: '24 Oct 2026',
        ),
        PrescriptionEntry(
          medicineName: 'Metformin',
          dosage: '500mg',
          frequency: '2x Maalintii cuntada kadib',
          doctorName: 'Dr. Axmed Nuur',
          prescribedDate: '15 Oct 2026',
        ),
      ],
    ),
    const PatientMedicalRecord(
      id: 'PT-1002',
      patientName: 'Faadumo Xasan Warsame',
      phone: '+252 63 7788990',
      age: 34,
      gender: 'Female',
      bloodType: 'A+',
      chronicConditions: ['Neef (Asthma)'],
      allergies: ['Aspirin', 'Sulfa drugs'],
      nextRefillDate: '5 Maalmood kadib',
      prescriptions: [
        PrescriptionEntry(
          medicineName: 'Ventolin Inhaler',
          dosage: '100mcg',
          frequency: 'Markii neeftu qabato',
          doctorName: 'Dr. Sahra Cali',
          prescribedDate: '28 Oct 2026',
        ),
      ],
    ),
    const PatientMedicalRecord(
      id: 'PT-1003',
      patientName: 'Maxamed Cabdi Guuleed',
      phone: '+252 65 1122334',
      age: 62,
      gender: 'Male',
      bloodType: 'B+',
      chronicConditions: ['Wadno-xanuun (Cardiovascular)', 'Dhiigkar (Hypertension)'],
      allergies: [],
      nextRefillDate: '2 Maalmood kadib',
      prescriptions: [
        PrescriptionEntry(
          medicineName: 'Atorvastatin',
          dosage: '20mg',
          frequency: '1x Maalintii habeenkii',
          doctorName: 'Dr. Cabdillaahi',
          prescribedDate: '20 Oct 2026',
        ),
        PrescriptionEntry(
          medicineName: 'Amlodipine',
          dosage: '5mg',
          frequency: '1x Maalintii',
          doctorName: 'Dr. Cabdillaahi',
          prescribedDate: '20 Oct 2026',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Action: Refill medicines directly in POS with items pre-selected
  void _refillMedicinesInPos(BuildContext context, PatientMedicalRecord patient) {
    final refillCart = patient.generateRefillCartItems();
    final customerInfo = PharmacyCustomerInfo(
      name: patient.patientName,
      phone: patient.phone,
      paymentStatus: 'Aan la bixin',
      customerStatus: 'Daawo Joogto ah (Chronic Patient)',
    );

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PharmacyPosPage(
          initialCart: refillCart,
          customerInfo: customerInfo,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daawada ${patient.patientName} waa la buuxiyay!',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    '${refillCart.length} daawo ayaa lagu shubay gaadhiga POS-ka.',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _patients.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = p.patientName.toLowerCase().contains(q) ||
          p.phone.contains(q) ||
          p.id.toLowerCase().contains(q);

      bool matchesCondition = true;
      if (_selectedCondition != 'Dhammaan') {
        matchesCondition = p.chronicConditions.any(
            (c) => c.toLowerCase().contains(_selectedCondition.toLowerCase()));
      }

      return matchesSearch && matchesCondition;
    }).toList();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diiwaanka Caafimaadka (Medical Records)',
              style: TextStyle(
                  color: Color(0xFF1D2338),
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            Text(
              '${_patients.length} bukaan oo leh daawooyin joogto ah (Chronic Rx)',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ku dar Bukaan Cusub',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1,
                  color: Colors.white, size: 20),
            ),
            onPressed: () => _openAddPatientModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
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
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Raadi bukaan, telefoon ama ID...',
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

          // Chronic Condition Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildFilterChip('Dhammaan', 'Dhammaan'),
                const SizedBox(width: 8),
                _buildFilterChip('Dhiigkar', 'Dhiigkar'),
                const SizedBox(width: 8),
                _buildFilterChip('Sonkorow', 'Sonkorow'),
                const SizedBox(width: 8),
                _buildFilterChip('Neef (Asthma)', 'Neef'),
                const SizedBox(width: 8),
                _buildFilterChip('Wadnaha', 'Wadno'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Patient List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Bukaan laguma helin xogtan.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final patient = filtered[idx];

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
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFFEE2E2),
                                  child: Text(
                                    patient.patientName.isNotEmpty
                                        ? patient.patientName[0]
                                        : 'B',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444),
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
                                        patient.patientName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1D2338)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${patient.id} • ${patient.phone} • Dhiigga: ${patient.bloodType}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF5F5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFFECACA)),
                                  ),
                                  child: Text(
                                    '${patient.prescriptions.length} Daawo Joogto ah',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Chronic Conditions Tags
                            if (patient.chronicConditions.isNotEmpty) ...[
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: patient.chronicConditions.map((c) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.favorite,
                                            size: 11, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 4),
                                        Text(
                                          c,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB91C1C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Next Refill Info
                            Row(
                              children: [
                                const Icon(Icons.alarm_on,
                                    size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  'Waqtiga Daawada: ${patient.nextRefillDate}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F3F6)),
                            const SizedBox(height: 10),

                            // Action Buttons: Refill (takes to POS with items pre-selected) & View Details
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: const Icon(Icons.visibility_outlined,
                                      size: 16, color: Color(0xFF4B5563)),
                                  label: const Text('Faahfaahin Buuxda',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4B5563))),
                                  onPressed: () => _openPatientDetailsModal(
                                      context, patient),
                                ),

                                // Refill Button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.replay_circle_filled,
                                      size: 16),
                                  label: const Text(
                                    'Refill Daawada (POS)',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () =>
                                      _refillMedicinesInPos(context, patient),
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
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCondition == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF4444) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  // Patient Details Modal with Full Refill Action
  void _openPatientDetailsModal(
      BuildContext context, PatientMedicalRecord patient) {
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
          child: SingleChildScrollView(
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
                        Text(patient.patientName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${patient.id} • ${patient.phone}',
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

                // Health Overview Card
                Container(
                  padding: const EdgeInsets.all(12),
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
                          const Text('Da\'da (Age)',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF8E99AF))),
                          const SizedBox(height: 2),
                          Text('${patient.age}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Jinsiga',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF8E99AF))),
                          const SizedBox(height: 2),
                          Text(patient.gender,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Kooxda Dhiigga',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF8E99AF))),
                          const SizedBox(height: 2),
                          Text(patient.bloodType,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFEF4444))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Chronic Conditions
                const Text('Cudurrada Guurguura (Chronic Conditions):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: patient.chronicConditions.map((c) {
                    return Chip(
                      backgroundColor: const Color(0xFFFEE2E2),
                      side: BorderSide.none,
                      label: Text(c,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Allergies
                if (patient.allergies.isNotEmpty) ...[
                  const Text('Xasaasiyadda (Allergies):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: patient.allergies.map((a) {
                      return Chip(
                        backgroundColor: const Color(0xFFFEF3C7),
                        side: BorderSide.none,
                        label: Text(a,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Active Prescriptions (Rx)
                const Text('Daawooyinka Joogtada ah (Prescriptions):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patient.prescriptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (c, i) {
                    final rx = patient.prescriptions[i];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.medication,
                              color: Color(0xFFEF4444), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${rx.medicineName} (${rx.dosage})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text('Sida loo qaato: ${rx.frequency}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4B5563))),
                                Text(
                                    'Dhakhtar: ${rx.doctorName} • Taariikh: ${rx.prescribedDate}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8E99AF))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Full Refill Action Button inside Modal
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.replay_circle_filled, size: 20),
                    label: const Text(
                      'Refill Daawada - U Dir POS-ka (Pre-select Cart)',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _refillMedicinesInPos(context, patient);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddPatientModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+252 63 ');
    final ageCtrl = TextEditingController();
    final conditionCtrl = TextEditingController();
    final medNameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '500mg');
    final freqCtrl = TextEditingController(text: '2x Maalintii');
    final docCtrl = TextEditingController(text: 'Dr. Axmed');

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diiwaangeli Bukaan Cusub',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Magaca Bukaanka:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Axmed Cali',
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
                          const Text('Telefoonka:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Da\'da:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '45',
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

                const Text('Cudurka Guurguura (Chronic Condition):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: conditionCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tusaale: Sonkorow, Dhiigkar, Neef',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Daawada Joogtada ah (Prescription):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                TextField(
                  controller: medNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Magaca daawada (e.g. Metformin / Amlodipine)',
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
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final newPatient = PatientMedicalRecord(
                        id: 'PT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                        patientName: name,
                        phone: phoneCtrl.text.trim(),
                        age: int.tryParse(ageCtrl.text) ?? 40,
                        gender: 'Male',
                        bloodType: 'O+',
                        chronicConditions: conditionCtrl.text.trim().isNotEmpty
                            ? [conditionCtrl.text.trim()]
                            : ['Dhiigkar'],
                        allergies: [],
                        prescriptions: [
                          PrescriptionEntry(
                            medicineName: medNameCtrl.text.trim().isNotEmpty
                                ? medNameCtrl.text.trim()
                                : 'Panadol Advance',
                            dosage: dosageCtrl.text.trim(),
                            frequency: freqCtrl.text.trim(),
                            doctorName: docCtrl.text.trim(),
                            prescribedDate: 'Maanta',
                          ),
                        ],
                      );

                      setState(() {
                        _patients.insert(0, newPatient);
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bukaanka $name si guul leh ayaa loo diiwaangeliyay!'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    },
                    child: const Text('Keydi Xogta Bukaanka',
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
}
