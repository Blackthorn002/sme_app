import 'package:flutter/material.dart';

// ============================================================================
// RETAIL DASHBOARD DATA & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Shaashadda Guud ee Dukaanka):
//    - Defines configuration and showcase data for the Retail Dashboard.
//    - Contains KPI cards (Revenue, Orders, In-Stock Products, Outstanding Debts),
//      promotional banners, fast navigation quick actions, and recent sales tickets.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - RetailHeaderData & BannerData -> `businesses` table:
//        name VARCHAR(255), business_type = 'retail', currency = 'USD'
//    - RetailMetricItem -> Computed from aggregation queries:
//        SELECT SUM(total_amount) FROM sales WHERE business_id = 2 AND created_at >= CURRENT_DATE;
//        SELECT COUNT(id) FROM products WHERE business_id = 2 AND is_active = TRUE;
//        SELECT SUM(current_debt) FROM customers WHERE business_id = 2;
//    - RetailOrderItem -> `sales` and `sale_items` tables:
//        sales.id, sales.created_at, sales.total_amount, sales.payment_method, sales.payment_status
//
// 3. HOW TO MODIFY THIS DATA (Sida Wax Looga Beddelo):
//    - To alter dashboard KPI figures: update `sampleRetailMetrics` values.
//    - To add recent transactions: append a new `RetailOrderItem` to `sampleRetailOrders`.
// ============================================================================

class RetailHeaderData {
  final String appName;
  final String subtitle;
  final List<String> currencies;

  const RetailHeaderData({
    required this.appName,
    required this.subtitle,
    required this.currencies,
  });
}

class RetailBannerData {
  final String title;
  final String subtitle;

  const RetailBannerData({
    required this.title,
    required this.subtitle,
  });
}

class RetailMetricItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const RetailMetricItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class RetailQuickAction {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const RetailQuickAction({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });
}

class RetailOrderItem {
  final String id;
  final String time;
  final String title;
  final String type;
  final double price;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;

  const RetailOrderItem({
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

// Global sample data variables (Replace these when integrating real backend/database data)
const sampleRetailHeader = RetailHeaderData(
  appName: 'Gashi',
  subtitle: 'Dukaameysi Dashboard',
  currencies: ['USD', 'SLSH'],
);

const sampleRetailBanner = RetailBannerData(
  title: 'Aroor San!',
  subtitle: 'Si fudud u maamul dukaankaaga adoo adeegsanaya Gashi.',
);

const sampleRetailMetrics = [
  RetailMetricItem(
    icon: Icons.attach_money,
    iconBg: Color(0xFFE6F7F0),
    iconColor: Color(0xFF10B981),
    label: 'Iibka maanta',
    value: '\$420',
  ),
  RetailMetricItem(
    icon: Icons.inventory_2_outlined,
    iconBg: Color(0xFFE6F7F0), // Changed to Green tint
    iconColor: Color(0xFF10B981), // Changed to Green
    label: 'Alaabta\nHadhay',
    value: '342',
  ),
  RetailMetricItem(
    icon: Icons.people_outline,
    iconBg: Color(0xFFFDE8E8),
    iconColor: Color(0xFFEF4444),
    label: 'Dayn',
    value: '\$85',
  ),
  RetailMetricItem(
    icon: Icons.trending_up,
    iconBg: Color(0xFFFEF3C7),
    iconColor: Color(0xFFF59E0B),
    label: 'Macaash',
    value: '\$120',
  ),
];

const sampleRetailQuickActions = [
  RetailQuickAction(
    icon: Icons.point_of_sale,
    label: 'Iibi\nAlaab',
    isPrimary: true,
  ),
  RetailQuickAction(
    icon: Icons.inventory_outlined,
    label: 'Eeg kaydka',
  ),
  RetailQuickAction(
    icon: Icons.people_outline,
    label: 'Macaamiisha',
  ),
  RetailQuickAction(
    icon: Icons.assignment_outlined,
    label: 'Diwaangeli\nKharash',
  ),
];

const sampleRetailOrders = [
  RetailOrderItem(
    id: '#RT-1028',
    time: '12:30 PM',
    title: 'Dhar & Kabo',
    type: 'Dukaan',
    price: 25.0,
    status: 'La Bixiyay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.shopping_cart_checkout,
  ),
  RetailOrderItem(
    id: '#RT-1027',
    time: '11:21 AM',
    title: 'Qalab',
    type: 'Dukaan',
    price: 18.0,
    status: 'Sugaya',
    statusBg: Color(0xFFEFF6FF),
    statusText: Color(0xFF3B82F6),
    icon: Icons.devices,
  ),
  RetailOrderItem(
    id: '#RT-1026',
    time: '10:15 AM',
    title: 'Badeecooyin',
    type: 'Jumlad',
    price: 32.0,
    status: 'Deyn',
    statusBg: Color(0xFFFDE8E8),
    statusText: Color(0xFFEF4444),
    icon: Icons.local_shipping_outlined,
  ),
  RetailOrderItem(
    id: '#RT-1025',
    time: '09:40 AM',
    title: 'Dhar',
    type: 'Dukaan',
    price: 14.0,
    status: 'La Bixiyay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.shopping_bag_outlined,
  ),
];