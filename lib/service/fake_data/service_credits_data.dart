import 'package:flutter/material.dart';

// ============================================================================
// SERVICE CREDITS / DAYN FAKE DATA & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Deymaha Adeegyada & Dayactirka):
//    - Defines customer credit accounts specific to service and repair workshops
//      (e.g., auto mechanics, electronics repair, AC maintenance, tailoring).
//    - In service SME businesses, customers often pay an upfront advance deposit
//      (horumarin) and owe the remaining balance upon device or vehicle handover.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - ServiceDebtor maps to `customers` joined with `service_jobs`:
//        customers.id, customers.name, customers.phone, customers.current_debt,
//        service_jobs.id (ticketId), service_jobs.service_id, service_jobs.technician_name,
//        service_jobs.total_estimated_price, service_jobs.paid_amount, service_jobs.due_date
//    - ServiceDebtTransaction maps to `customer_transactions`:
//        id, customer_id, business_id = 4, amount, payment_method, transaction_type = 'payment'
//
// 3. HOW TO MODIFY THIS DATA (Sida Wax Looga Beddelo):
//    - To add an unpaid job customer: Add a `ServiceDebtor` to `sampleServiceDebtors`.
//    - In production, debts are registered directly when a `ServiceJob` is delivered
//      with an unpaid balance (`GashiRepository.payServiceJobBalance()`).
// ============================================================================

class ServiceDebtTransaction {
  final String id;
  final String date;
  final double amount;
  final String method;
  final String note;

  const ServiceDebtTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.note,
  });
}

class ServiceDebtor {
  final String id;
  final String ticketId;
  final String name;
  final String phone;
  final String service;
  final String dateRecorded;
  final String dueDate;
  final double totalDebt;
  final double paid;
  final double remaining;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String notes;
  final String technician;
  final List<String> items;
  final List<ServiceDebtTransaction> paymentHistory;

  const ServiceDebtor({
    required this.id,
    required this.ticketId,
    required this.name,
    required this.phone,
    required this.service,
    required this.dateRecorded,
    required this.dueDate,
    required this.totalDebt,
    required this.paid,
    required this.remaining,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.notes,
    required this.technician,
    required this.items,
    required this.paymentHistory,
  });

  ServiceDebtor copyWith({
    String? id,
    String? ticketId,
    String? name,
    String? phone,
    String? service,
    String? dateRecorded,
    String? dueDate,
    double? totalDebt,
    double? paid,
    double? remaining,
    String? status,
    Color? statusColor,
    Color? statusBg,
    String? notes,
    String? technician,
    List<String>? items,
    List<ServiceDebtTransaction>? paymentHistory,
  }) {
    return ServiceDebtor(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      service: service ?? this.service,
      dateRecorded: dateRecorded ?? this.dateRecorded,
      dueDate: dueDate ?? this.dueDate,
      totalDebt: totalDebt ?? this.totalDebt,
      paid: paid ?? this.paid,
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      statusBg: statusBg ?? this.statusBg,
      notes: notes ?? this.notes,
      technician: technician ?? this.technician,
      items: items ?? this.items,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

final List<ServiceDebtor> sampleServiceDebtors = [
  ServiceDebtor(
    id: 'sd1',
    ticketId: '#SRV-2994',
    name: 'Daahir Cilmi Barre',
    phone: '+252 63 4455667',
    service: 'Beddelka Shaashad & Battery Laptop HP',
    dateRecorded: '24 Oct 2026',
    dueDate: '01 Nov 2026',
    totalDebt: 75.0,
    paid: 25.0,
    remaining: 50.0,
    status: 'Qayb bixiyay',
    statusColor: const Color(0xFFF59E0B),
    statusBg: const Color(0xFFFEF3C7),
    notes: 'Waxaa u shaqeeyay Eng. Xamze',
    technician: 'Eng. Xamze Cali',
    items: [
      'Shaashad HP 15.6" HD (\$45.00)',
      'Batari HP Original 3-Cell (\$20.00)',
      'Shaqada Farsamada (\$10.00)',
    ],
    paymentHistory: [
      const ServiceDebtTransaction(
        id: 'tx-1',
        date: '24 Oct 2026 • 02:15 PM',
        amount: 25.0,
        method: 'Zaad',
        note: 'Bixin bilow ah markii shaqada la bilaabay',
      ),
    ],
  ),
  ServiceDebtor(
    id: 'sd2',
    ticketId: '#SRV-2980',
    name: 'Cabdirisaaq Xasan Nuur',
    phone: '+252 63 7711223',
    service: 'Dhaqid Baabuur & Saliid Beddel',
    dateRecorded: '27 Oct 2026',
    dueDate: '31 Oct 2026',
    totalDebt: 40.0,
    paid: 0.0,
    remaining: 40.0,
    status: 'Aan bixin',
    statusColor: const Color(0xFFEF4444),
    statusBg: const Color(0xFFFDE8E8),
    notes: 'Toyota Prado Taargo #29381',
    technician: 'Mustafe & Cabdi',
    items: [
      'Saliid Mobil 1 5W-40 (\$25.00)',
      'Filter Saliid (\$5.00)',
      'VIP Car Wash & Engine Clean (\$10.00)',
    ],
    paymentHistory: [],
  ),
  ServiceDebtor(
    id: 'sd3',
    ticketId: '#SRV-2952',
    name: 'Safiya Maxamed Ismaaciil',
    phone: '+252 65 3344556',
    service: 'Dhar Tolasho (Dirac iyo Goono)',
    dateRecorded: '20 Oct 2026',
    dueDate: '27 Oct 2026',
    totalDebt: 30.0,
    paid: 30.0,
    remaining: 0.0,
    status: 'Dhammaystiray',
    statusColor: const Color(0xFF10B981),
    statusBg: const Color(0xFFE6F7F0),
    notes: 'Lacagteedii way dhammaysay',
    technician: 'Ustaad Maxamed Nuur',
    items: [
      'Tolida Dirac Bacweyne (\$18.00)',
      'Goono Xariir ah (\$12.00)',
    ],
    paymentHistory: [
      const ServiceDebtTransaction(
        id: 'tx-2',
        date: '20 Oct 2026 • 11:00 AM',
        amount: 15.0,
        method: 'e-Dahab',
        note: 'Qayb horumaris ah',
      ),
      const ServiceDebtTransaction(
        id: 'tx-3',
        date: '27 Oct 2026 • 04:30 PM',
        amount: 15.0,
        method: 'Zaad',
        note: 'Bixin buuxda xiligii dhar qaadashada',
      ),
    ],
  ),
  ServiceDebtor(
    id: 'sd4',
    ticketId: '#SRV-3001',
    name: 'Mukhtaar Cali Guuleed',
    phone: '+252 63 9900112',
    service: 'Rakibaad Wi-Fi & Qalab CCTV',
    dateRecorded: '28 Oct 2026',
    dueDate: '04 Nov 2026',
    totalDebt: 90.0,
    paid: 35.0,
    remaining: 55.0,
    status: 'Qayb bixiyay',
    statusColor: const Color(0xFFF59E0B),
    statusBg: const Color(0xFFFEF3C7),
    notes: 'Xafiiska shirkadda Global Logistics',
    technician: 'Eng. Guuleed & Xamze',
    items: [
      'Router TP-Link Archer AX73 (\$50.00)',
      '2x HD Wi-Fi Cameras (\$30.00)',
      'Rakibaad & Network Setup (\$10.00)',
    ],
    paymentHistory: [
      const ServiceDebtTransaction(
        id: 'tx-4',
        date: '28 Oct 2026 • 10:45 AM',
        amount: 35.0,
        method: 'Zaad',
        note: 'Bixin qayb ah xafiiska dhexdiisa',
      ),
    ],
  ),
];

