import 'package:flutter/material.dart';

// ============================================================================
// PHARMACY DASHBOARD DATA MODELS & SAMPLE VARIABLES
// ============================================================================

class PharmacyHeaderData {
  final String appName;
  final String subtitle;
  final List<String> currencies;

  const PharmacyHeaderData({
    required this.appName,
    required this.subtitle,
    required this.currencies,
  });
}

class PharmacyBannerData {
  final String title;
  final String subtitle;

  const PharmacyBannerData({
    required this.title,
    required this.subtitle,
  });
}

class PharmacyMetricItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const PharmacyMetricItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class PharmacyQuickAction {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const PharmacyQuickAction({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });
}

class PharmacyOrderItem {
  final String id;
  final String time;
  final String title;
  final String type;
  final double price;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;

  const PharmacyOrderItem({
    required this.id,
    required this.time,
    required this.title,
    required this.type,
    required this.price,
    required this.status,
    required this.statusBg,
    required this.statusText,
    required this.icon,
  });
}

const samplePharmacyHeader = PharmacyHeaderData(
  appName: 'Gashi Farmaajo',
  subtitle: 'Dashboard',
  currencies: ['USD', 'SLSH'],
);

const samplePharmacyBanner = PharmacyBannerData(
  title: 'Maalin Wanaagsan!',
  subtitle: 'Si fudud u maamul farmaajiyahaaga adoo adeegsanaya Gashi.',
);

const samplePharmacyMetrics = [
  PharmacyMetricItem(
    icon: Icons.attach_money,
    iconBg: Color(0xFFE6F7F0),
    iconColor: Color(0xFF10B981),
    label: 'Iibka maanta',
    value: '\$540',
  ),
  PharmacyMetricItem(
    icon: Icons.medication_outlined,
    iconBg: Color(0xFFFEE2E2),
    iconColor: Color(0xFFEF4444),
    label: 'Daawooyinka\nLa Iibiyay',
    value: '45',
  ),
  PharmacyMetricItem(
    icon: Icons.people_outline,
    iconBg: Color(0xFFFDE8E8),
    iconColor: Color(0xFFEF4444),
    label: 'Bukaanada',
    value: '12',
  ),
  PharmacyMetricItem(
    icon: Icons.warning_amber_rounded,
    iconBg: Color(0xFFFEF3C7),
    iconColor: Color(0xFFF59E0B),
    label: 'Daawooyinka\nDhacaya',
    value: '3',
  ),
];

const samplePharmacyQuickActions = [
  PharmacyQuickAction(
    icon: Icons.add,
    label: 'Iib Cusub',
    isPrimary: true,
  ),
  PharmacyQuickAction(
    icon: Icons.inventory_2_outlined,
    label: 'Kaydka',
  ),
  PharmacyQuickAction(
    icon: Icons.people_outline,
    label: 'Bukaanada',
  ),
  PharmacyQuickAction(
    icon: Icons.assignment_outlined,
    label: 'Warbixin',
  ),
];

const samplePharmacyOrders = [
  PharmacyOrderItem(
    id: '#PH-2028',
    time: '12:30 PM',
    title: 'Panadol & Vitamin C',
    type: 'Daawo',
    price: 15.0,
    status: 'La Bixiyay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.medication,
  ),
  PharmacyOrderItem(
    id: '#PH-2027',
    time: '11:21 AM',
    title: 'Amoxicillin',
    type: 'Antibiotic',
    price: 8.5,
    status: 'La Bixiyay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.medical_services_outlined,
  ),
  PharmacyOrderItem(
    id: '#PH-2026',
    time: '10:15 AM',
    title: 'Ibuprofen',
    type: 'Daawo',
    price: 5.0,
    status: 'Deyn',
    statusBg: Color(0xFFFEE2E2),
    statusText: Color(0xFFEF4444),
    icon: Icons.healing,
  ),
];
