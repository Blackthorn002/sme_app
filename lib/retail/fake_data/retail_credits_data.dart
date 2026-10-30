import 'package:flutter/material.dart';

// ============================================================================
// RETAIL CREDITS / DAYN FAKE DATA & MODELS
// ============================================================================

class RetailDebtTransaction {
  final String id;
  final String date;
  final double amount;
  final String method;
  final String note;

  const RetailDebtTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.note,
  });
}

class RetailDebtor {
  final String id;
  final String invoiceId;
  final String name;
  final String phone;
  final String dateRecorded;
  final String dueDate;
  final double totalDebt;
  final double paid;
  final double remaining;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String notes;
  final List<String> items;
  final List<RetailDebtTransaction> paymentHistory;

  const RetailDebtor({
    required this.id,
    required this.invoiceId,
    required this.name,
    required this.phone,
    required this.dateRecorded,
    required this.dueDate,
    required this.totalDebt,
    required this.paid,
    required this.remaining,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.notes,
    required this.items,
    required this.paymentHistory,
  });

  RetailDebtor copyWith({
    String? id,
    String? invoiceId,
    String? name,
    String? phone,
    String? dateRecorded,
    String? dueDate,
    double? totalDebt,
    double? paid,
    double? remaining,
    String? status,
    Color? statusColor,
    Color? statusBg,
    String? notes,
    List<String>? items,
    List<RetailDebtTransaction>? paymentHistory,
  }) {
    return RetailDebtor(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dateRecorded: dateRecorded ?? this.dateRecorded,
      dueDate: dueDate ?? this.dueDate,
      totalDebt: totalDebt ?? this.totalDebt,
      paid: paid ?? this.paid,
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      statusBg: statusBg ?? this.statusBg,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

final List<RetailDebtor> sampleRetailDebtors = [
  const RetailDebtor(
    id: 'rd_1',
    invoiceId: '#INV-8821',
    name: 'Axmed Maxamed Nuur',
    phone: '+252 63 4411223',
    dateRecorded: '24 Oct 2026',
    dueDate: '02 Nov 2026',
    totalDebt: 65.0,
    paid: 20.0,
    remaining: 45.0,
    status: 'Qayb bixiyay',
    statusColor: Color(0xFFF59E0B),
    statusBg: Color(0xFFFEF3C7),
    notes: 'Dhar ciid iyo kabo rag',
    items: ['2x Shaadh Rag (L)', '1x Surwaal Jeans', '1x Suun Harag ah'],
    paymentHistory: [
      RetailDebtTransaction(
        id: 'tx_1',
        date: '25 Oct 2026',
        amount: 20.0,
        method: 'Zaad',
        note: 'Qayb horumaris ah',
      ),
    ],
  ),
  const RetailDebtor(
    id: 'rd_2',
    invoiceId: '#INV-8815',
    name: 'Safiya Cabdi Xasan',
    phone: '+252 63 7788990',
    dateRecorded: '22 Oct 2026',
    dueDate: '05 Nov 2026',
    totalDebt: 120.0,
    paid: 0.0,
    remaining: 120.0,
    status: 'Aan bixin',
    statusColor: Color(0xFFEF4444),
    statusBg: Color(0xFFFDE8E8),
    notes: 'Diracyo iyo uunsi aroos',
    items: ['1x Dirac Shiifon qaali ah', '1x Garbasaar', '1x Cadar Carbeed'],
    paymentHistory: [],
  ),
  const RetailDebtor(
    id: 'rd_3',
    invoiceId: '#INV-8790',
    name: 'Khadar Cismaan Cali',
    phone: '+252 65 9911224',
    dateRecorded: '18 Oct 2026',
    dueDate: '28 Oct 2026',
    totalDebt: 50.0,
    paid: 50.0,
    remaining: 0.0,
    status: 'Dhammaystiray',
    statusColor: Color(0xFF10B981),
    statusBg: Color(0xFFE6F7F0),
    notes: 'Lacagtiisii wuu dhammaystiray',
    items: ['1x Jaakad Jiilaal', '2x T-Shirt Cudbi ah'],
    paymentHistory: [
      RetailDebtTransaction(
        id: 'tx_2',
        date: '28 Oct 2026',
        amount: 50.0,
        method: 'EVC Plus',
        note: 'Bixiyay xisaabtii oo buuxda',
      ),
    ],
  ),
  const RetailDebtor(
    id: 'rd_4',
    invoiceId: '#INV-8772',
    name: 'Hodan Yuusuf Cilmi',
    phone: '+252 63 3322114',
    dateRecorded: '26 Oct 2026',
    dueDate: '10 Nov 2026',
    totalDebt: 85.0,
    paid: 35.0,
    remaining: 50.0,
    status: 'Qayb bixiyay',
    statusColor: Color(0xFFF59E0B),
    statusBg: Color(0xFFFEF3C7),
    notes: 'Alaab guri & gogol',
    items: ['3x Go\' & Barkimo', '1x Daah Qolka Fadhiga'],
    paymentHistory: [
      RetailDebtTransaction(
        id: 'tx_3',
        date: '26 Oct 2026',
        amount: 35.0,
        method: 'Edahab',
        note: 'Horumaris bilaw ah',
      ),
    ],
  ),
  const RetailDebtor(
    id: 'rd_5',
    invoiceId: '#INV-8740',
    name: 'Mustafe Cabdillaahi',
    phone: '+252 63 1234567',
    dateRecorded: '27 Oct 2026',
    dueDate: '04 Nov 2026',
    totalDebt: 38.0,
    paid: 0.0,
    remaining: 38.0,
    status: 'Aan bixin',
    statusColor: Color(0xFFEF4444),
    statusBg: Color(0xFFFDE8E8),
    notes: 'Qalabka dugsiga carruurta',
    items: ['1x Boorso Iskuul', '4x Buugaagta Xisaabta', '1x Qalimaan Baakidh'],
    paymentHistory: [],
  ),
];

