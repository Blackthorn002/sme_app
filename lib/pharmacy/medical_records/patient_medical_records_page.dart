import 'package:flutter/material.dart';

// ============================================================================
// PHARMACY SPECIFIC FEATURE: PATIENT MEDICAL RECORDS (Diiwaanka Caafimaadka)
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
  });
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
      chronicConditions: ['Wadno-xanuun (Cardiovascular)'],
      allergies: [],
      prescriptions: [
        PrescriptionEntry(
          medicineName: 'Atorvastatin',
          dosage: '20mg',
          frequency: '1x Maalintii habeenkii',
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

  @override
  Widget build(BuildContext context) {
    final filtered = _patients.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.patientName.toLowerCase().contains(q) ||
          p.phone.contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Medical Records',
              style: TextStyle(
                  color: Color(0xFF1D2338),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Prescriptions, allergies & chronic medical history',
              style: TextStyle(fontSize: 11, color: Color(0xFF8E99AF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Medical Record',
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                        hintText: 'Search patient name, phone, or ID...',
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

          // Patient List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final patient = filtered[idx];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openPatientDetailsModal(context, patient),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFFEE2E2),
                              child: Text(
                                patient.patientName[0],
                                style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '${patient.id} • ${patient.gender}, ${patient.age} yrs • Blood: ${patient.bloodType}',
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
                                '${patient.prescriptions.length} Active Rx',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ),

                        // Allergies warning if any
                        if (patient.allergies.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFDC2626), size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Allergies: ${patient.allergies.join(", ")}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDC2626)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }

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
                          const Text('Age',
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
                          const Text('Gender',
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
                          const Text('Blood Group',
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
                const Text('Chronic Conditions / Cudurrada Guurguura:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
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

                // Active Prescriptions (Rx)
                const Text('Active Prescriptions (Qoraallada Daawada):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                if (patient.prescriptions.isEmpty)
                  const Text('No current prescriptions.',
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: patient.prescriptions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                                color: Color(0xFFEF4444), size: 20),
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
                                  Text('Frequency: ${rx.frequency}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF4B5563))),
                                  Text(
                                      'Prescribed by ${rx.doctorName} • ${rx.prescribedDate}',
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddPatientModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();

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
                  const Text('New Patient Medical File',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              const Text('Patient Full Name:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Cali Maxamed',
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

              const Text('Age:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 42',
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
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    setState(() {
                      _patients.insert(
                        0,
                        PatientMedicalRecord(
                          id: 'PT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                          patientName: name,
                          phone: phoneCtrl.text.trim().isNotEmpty
                              ? phoneCtrl.text.trim()
                              : '+252 63 0000000',
                          age: int.tryParse(ageCtrl.text) ?? 30,
                          gender: 'Unspecified',
                          bloodType: 'O+',
                          chronicConditions: const [],
                          allergies: const [],
                          prescriptions: const [],
                        ),
                      );
                    });

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Medical record for $name created!'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  },
                  child: const Text('Create Record',
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
}
