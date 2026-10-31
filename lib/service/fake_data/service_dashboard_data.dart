import 'package:flutter/material.dart';

// ============================================================================
// SERVICE DASHBOARD DATA & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Shaashadda Guud ee Adeegyada):
//    - Defines top overview KPIs and recent job tickets for workshop & service businesses.
//    - Key metrics tracked: Today's repair income, ongoing active repair jobs (Shaqooyinka socda),
//      completed jobs ready for customer pickup, and outstanding repair balances.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - ServiceHeaderData -> `businesses` table (business_type = 'service', business_id = 4)
//    - ServiceMetricItem -> Aggregations from `service_jobs` and `sales`:
//        SELECT SUM(paid_amount) FROM service_jobs WHERE business_id = 4 AND created_at >= CURRENT_DATE;
//        SELECT COUNT(id) FROM service_jobs WHERE business_id = 4 AND status IN ('pending', 'in_progress');
//        SELECT COUNT(id) FROM service_jobs WHERE business_id = 4 AND status = 'completed';
//    - ServiceOrderItem -> `service_jobs` joined with `services` and `customers`
//
// 3. HOW TO MODIFY THIS DATA (Sida Wax Looga Beddelo):
//    - Update `sampleServiceMetrics` to change top KPI cards.
//    - Update `sampleServiceOrders` to test recent repair job displays.
// ============================================================================

class ServiceHeaderData {
  final String appName;
  final String subtitle;
  final List<String> currencies;

  const ServiceHeaderData({
    required this.appName,
    required this.subtitle,
    required this.currencies,
  });
}

class ServiceBannerData {
  final String title;
  final String subtitle;

  const ServiceBannerData({
    required this.title,
    required this.subtitle,
  });
}

class ServiceMetricItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const ServiceMetricItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class ServiceQuickAction {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const ServiceQuickAction({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });
}

class ServiceOrderItem {
  final String id;
  final String time;
  final String title;
  final String technician;
  final double price;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;

  const ServiceOrderItem({
    required this.id,
    required this.time,
    required this.title,
    required this.technician,
    required this.price,
    required this.status,
    required this.statusBg,
    required this.statusText,
    required this.icon,
  });
}

// Global sample data variables (Mock Data)
const sampleServiceHeader = ServiceHeaderData(
  appName: 'Gashi',
  subtitle: 'Services Suite',
  currencies: ['USD', 'SLSH'],
);

const sampleServiceBanner = ServiceBannerData(
  title: 'Aroor San!',
  subtitle: 'Si hufan u maamul adeegyadaada, farsamada, iyo xisaabaadka macaamiisha.',
);

const sampleServiceMetrics = [
  ServiceMetricItem(
    icon: Icons.attach_money,
    iconBg: Color(0xFFEEF2FF),
    iconColor: Color(0xFF4F46E5),
    label: 'Iibka Maanta',
    value: '\$580',
  ),
  ServiceMetricItem(
    icon: Icons.assignment_turned_in_outlined,
    iconBg: Color(0xFFE6F7F0),
    iconColor: Color(0xFF10B981),
    label: 'Adeegyada\nLa qabtay',
    value: '19',
  ),
  ServiceMetricItem(
    icon: Icons.people_outline,
    iconBg: Color(0xFFFDE8E8),
    iconColor: Color(0xFFEF4444),
    label: 'Dayn Maqan',
    value: '\$145',
  ),
  ServiceMetricItem(
    icon: Icons.pending_actions_outlined,
    iconBg: Color(0xFFFEF3C7),
    iconColor: Color(0xFFF59E0B),
    label: 'Adeegyo Socda',
    value: '4',
  ),
];

const sampleServiceQuickActions = [
  ServiceQuickAction(
    icon: Icons.add,
    label: 'Iibi\nAdeeg',
    isPrimary: true,
  ),
  ServiceQuickAction(
    icon: Icons.miscellaneous_services_outlined,
    label: 'Eeg\nAdeegyada',
  ),
  ServiceQuickAction(
    icon: Icons.bar_chart_outlined,
    label: 'Eeg\nIibka',
  ),
  ServiceQuickAction(
    icon: Icons.people_outline,
    label: 'Deymaha\n& Macaamiil',
  ),
];

const sampleServiceOrders = [
  ServiceOrderItem(
    id: '#SRV-3012',
    time: '12:40 PM',
    title: 'Hagaajin Shaashad iPhone',
    technician: 'Farsamo: Xamze Cali',
    price: 35.0,
    status: 'La Dhammaystiray',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.phone_android_outlined,
  ),
  ServiceOrderItem(
    id: '#SRV-3011',
    time: '11:15 AM',
    title: 'Dhaqis Dhammaystiran (Car Wash)',
    technician: 'Shaqaale: Cabdi & Mustafe',
    price: 15.0,
    status: 'La Dhammaystiray',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.local_car_wash_outlined,
  ),
  ServiceOrderItem(
    id: '#SRV-3010',
    time: '10:30 AM',
    title: 'Dhar Tolasho (Khamiis Somali)',
    technician: 'Dawaarle: Maxamed Nuur',
    price: 25.0,
    status: 'Wuu Socdaa',
    statusBg: Color(0xFFFEF3C7),
    statusText: Color(0xFFF59E0B),
    icon: Icons.content_cut_outlined,
  ),
  ServiceOrderItem(
    id: '#SRV-3009',
    time: '09:20 AM',
    title: 'Rakibaad Wi-Fi & Router',
    technician: 'Farsamo: Eng. Guuleed',
    price: 40.0,
    status: 'La Dhammaystiray',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.wifi_outlined,
  ),
];

