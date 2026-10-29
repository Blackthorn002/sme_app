import 'package:flutter/material.dart';
import '../fake_data/pharmacy_pos_data.dart';

class PharmacyPatientsPage extends StatelessWidget {
  const PharmacyPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PharmacyCustomerInfo> patients = [
      const PharmacyCustomerInfo(name: 'Cali Jaamac', phone: '+252 63 4455667'),
      const PharmacyCustomerInfo(name: 'Faadumo Xasan', phone: '+252 63 7788990'),
      const PharmacyCustomerInfo(name: 'Maxamed Cabdi', phone: '+252 65 1122334'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Diiwaanka Bukaanada',
          style: TextStyle(color: Color(0xFF1D2338), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFF1F3F6)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFEE2E2),
                child: Text(
                  patient.name[0],
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(patient.phone),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF4444),
        onPressed: () {},
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
