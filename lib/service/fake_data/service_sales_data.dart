import 'package:flutter/material.dart';

// ============================================================================
// SERVICE SALES TICKETS & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Rasiidhada & Iibka Adeegyada):
//    - Represents completed repair job transactions and service sales receipts.
//    - Includes itemized billing: Labor charge (Khidmadda Shaqada) plus any
//      spare parts used (Qalabka la galiyay).
//    - Tracks payment channel (Zaad, e-Dahab, Kaash) and completion status.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - ServiceSalesTicket maps to `sales` joined with `service_jobs`:
//        sales.id, sales.created_at, sales.total_amount, sales.payment_method, sales.payment_status,
//        service_jobs.technician_name, service_jobs.job_notes, service_jobs.parts_cost
//
// 3. HOW TO MODIFY THIS DATA (Sida Rasiidh Cusub Loogu Daro):
//    - To add mock completed repair receipts: Append a `ServiceSalesTicket` to `sampleServiceSalesTickets`.
// ============================================================================

class ServiceSalesTicket {
  final String id;
  final String receiptNumber;
  final String time;
  final String date;
  final bool isToday;
  final String title;
  final String customer;
  final String phone;
  final String technician;
  final String type; // Goobta, Guriga, Degdeg
  final String payment; // Zaad, e-Dahab, Kaash, Dayn
  final Color paymentColor;
  final double price;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;
  final String details;
  final List<String> itemsBreakdown;

  const ServiceSalesTicket({
    required this.id,
    required this.receiptNumber,
    required this.time,
    required this.date,
    required this.isToday,
    required this.title,
    required this.customer,
    required this.phone,
    required this.technician,
    required this.type,
    required this.payment,
    required this.paymentColor,
    required this.price,
    required this.status,
    required this.statusBg,
    required this.statusText,
    required this.icon,
    required this.details,
    required this.itemsBreakdown,
  });
}

class ServiceTodaySalesSummary {
  final double totalRevenueToday;
  final int totalJobsToday;
  final double zaadTotal;
  final double edahabTotal;
  final double cashTotal;
  final double daynTotal;
  final String topServiceToday;
  final String topTechnicianToday;

  const ServiceTodaySalesSummary({
    required this.totalRevenueToday,
    required this.totalJobsToday,
    required this.zaadTotal,
    required this.edahabTotal,
    required this.cashTotal,
    required this.daynTotal,
    required this.topServiceToday,
    required this.topTechnicianToday,
  });
}

const sampleTodaySalesSummary = ServiceTodaySalesSummary(
  totalRevenueToday: 580.0,
  totalJobsToday: 19,
  zaadTotal: 340.0,
  edahabTotal: 125.0,
  cashTotal: 70.0,
  daynTotal: 45.0,
  topServiceToday: 'Hagaajinta Qalabka & Shaashadaha',
  topTechnicianToday: 'Eng. Xamze Cali (7 shaqo)',
);

const List<ServiceSalesTicket> sampleServiceSalesTickets = [
  ServiceSalesTicket(
    id: '#SRV-3012',
    receiptNumber: 'REC-SRV-8821',
    time: '12:40 PM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Hagaajin Shaashad iPhone 13',
    customer: 'Axmed Maxamuud',
    phone: '+252 63 4411223',
    technician: 'Eng. Xamze Cali',
    type: 'Goobta',
    payment: 'Zaad',
    paymentColor: Color(0xFF00A859),
    price: 35.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.phone_android_outlined,
    details: 'Shaashad beddel iyo tijaabo buuxda',
    itemsBreakdown: [
      'Shaashad OLED iPhone 13 Original (\$25.00)',
      'Kharashka Farsamada & Rakibaadda (\$10.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3011',
    receiptNumber: 'REC-SRV-8820',
    time: '11:15 AM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Dhaqis Dhammaystiran (Car Wash VIP)',
    customer: 'Maxamed Cali Warsame',
    phone: '+252 63 9988776',
    technician: 'Cabdi & Mustafe',
    type: 'Goobta',
    payment: 'e-Dahab',
    paymentColor: Color(0xFFF58220),
    price: 15.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.local_car_wash_outlined,
    details: 'Toyota Land Cruiser V8 #38921',
    itemsBreakdown: [
      'Dhaqis Bannaanka & Hooska Gaadhiga (\$8.00)',
      'Vacuuming & Nadiifinta Gudaha (\$7.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3010',
    receiptNumber: 'REC-SRV-8819',
    time: '10:30 AM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Dhar Tolasho (Khamiis Somali)',
    customer: 'Mustafe Xuseen',
    phone: '+252 63 2233445',
    technician: 'Ustaad Maxamed Nuur',
    type: 'Goobta',
    payment: 'Kaash',
    paymentColor: Color(0xFF2563EB),
    price: 25.0,
    status: 'Socda',
    statusBg: Color(0xFFFEF3C7),
    statusText: Color(0xFFF59E0B),
    icon: Icons.content_cut_outlined,
    details: 'Tolmo labanlaab ah iyo xariir qoorta',
    itemsBreakdown: [
      'Tolida Khamiis Cadaan (\$20.00)',
      'Naqshad Xariir ah Qoorta (\$5.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3009',
    receiptNumber: 'REC-SRV-8818',
    time: '09:20 AM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Rakibaad Wi-Fi & Router Guriga',
    customer: 'Nimco Cabdilaahi',
    phone: '+252 65 1122334',
    technician: 'Eng. Guuleed',
    type: 'Guriga',
    payment: 'Zaad',
    paymentColor: Color(0xFF00A859),
    price: 40.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.wifi_outlined,
    details: 'Guri dabaq ah, Jigjiga Yar',
    itemsBreakdown: [
      'Rakibaad Router Dual-Band (\$25.00)',
      'Fiilooyinka Cat6 & Connectors (\$15.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3008',
    receiptNumber: 'REC-SRV-8817',
    time: '08:45 AM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Beddelka Saliidda Gaadhiga & Filter',
    customer: 'Cismaan Jaamac',
    phone: '+252 63 5566778',
    technician: 'Mustafe Farsamo',
    type: 'Degdeg',
    payment: 'Zaad',
    paymentColor: Color(0xFF00A859),
    price: 28.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.directions_car_outlined,
    details: 'Saliid Shell Helix 5W-30 & Oil Filter',
    itemsBreakdown: [
      'Saliid 4L Shell Helix (\$20.00)',
      'Oil Filter Original (\$8.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3007',
    receiptNumber: 'REC-SRV-8816',
    time: '08:10 AM',
    date: 'Maanta, 29 Oct 2026',
    isToday: true,
    title: 'Hagaajin Laptop Dell (Format & OS)',
    customer: 'Khadar Maxamed Warsame',
    phone: '+252 63 8899001',
    technician: 'Eng. Xamze Cali',
    type: 'Goobta',
    payment: 'Dayn',
    paymentColor: Color(0xFFEF4444),
    price: 20.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.laptop_mac_outlined,
    details: 'Windows 11 Pro, Office 365, Antivirus',
    itemsBreakdown: [
      'Rakibaad OS & Drivers (\$15.00)',
      'Software Optimization (\$5.00)',
    ],
  ),
  // Older sales (Yesterday / This week)
  ServiceSalesTicket(
    id: '#SRV-3006',
    receiptNumber: 'REC-SRV-8815',
    time: '04:30 PM',
    date: 'Shalay, 28 Oct 2026',
    isToday: false,
    title: 'Rakibaad CCTV 4 Cameras',
    customer: 'Shirkadda SomStore',
    phone: '+252 63 3322110',
    technician: 'Eng. Guuleed & Xamze',
    type: 'Guriga',
    payment: 'Zaad',
    paymentColor: Color(0xFF00A859),
    price: 180.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.videocam_outlined,
    details: 'Dhismaha weyn ee SomStore',
    itemsBreakdown: [
      'CCTV HD Cameras x4 (\$120.00)',
      'DVR 8-Channel & Hard Drive 1TB (\$60.00)',
    ],
  ),
  ServiceSalesTicket(
    id: '#SRV-3005',
    receiptNumber: 'REC-SRV-8814',
    time: '02:15 PM',
    date: 'Shalay, 28 Oct 2026',
    isToday: false,
    title: 'Tolida 3 Khamiis & Macawiis',
    customer: 'Cabdiraxmaan Sh. Cumar',
    phone: '+252 63 1144778',
    technician: 'Ustaad Maxamed Nuur',
    type: 'Goobta',
    payment: 'e-Dahab',
    paymentColor: Color(0xFFF58220),
    price: 65.0,
    status: 'Dhammaystiran',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.content_cut_outlined,
    details: 'Dhar ciid iyo aroos',
    itemsBreakdown: [
      '3 Khamiis Somali VIP (\$50.00)',
      'Tolida 2 Macawiis (\$15.00)',
    ],
  ),
];

