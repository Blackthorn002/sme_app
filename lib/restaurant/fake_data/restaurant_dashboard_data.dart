import 'package:flutter/material.dart';

// ============================================================================
// RESTAURANT DASHBOARD DATA & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Shaashadda Guud ee Makhaayadda):
//    - Defines summary metrics, quick actions, and recent live table orders for restaurants.
//    - Real-time restaurant monitoring: Today's food revenue, active occupied tables,
//      completed orders count, and catering / corporate customer debt tabs.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - RestaurantHeaderData -> `businesses` table (business_type = 'restaurant', business_id = 3)
//    - RestaurantMetricItem -> Aggregations from `sales` table:
//        SELECT SUM(total_amount) FROM sales WHERE business_id = 3 AND created_at >= CURRENT_DATE;
//        SELECT COUNT(id) FROM sales WHERE business_id = 3 AND order_type = 'Miis' AND payment_status != 'paid';
//    - RestaurantOrderItem -> `sales` table with `order_type` ('Miis' / Dine-in, 'Takeaway', 'Delivery')
//        custom_attributes->>'table' (e.g., "Miiska 4")
//
// 3. HOW TO MODIFY THIS DATA (Sida Wax Looga Beddelo):
//    - Update `sampleRestaurantMetrics` to modify top dashboard KPI cards.
//    - Update `sampleRestaurantOrders` to test different table numbers or statuses.
// ============================================================================

class RestaurantHeaderData {
  final String appName;
  final String subtitle;
  final List<String> currencies;

  const RestaurantHeaderData({
    required this.appName,
    required this.subtitle,
    required this.currencies,
  });
}

class RestaurantBannerData {
  final String title;
  final String subtitle;

  const RestaurantBannerData({
    required this.title,
    required this.subtitle,
  });
}

class RestaurantMetricItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const RestaurantMetricItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

class RestaurantQuickAction {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const RestaurantQuickAction({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });
}

class RestaurantOrderItem {
  final String id;
  final String time;
  final String title;
  final String type;
  final double price;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;

  const RestaurantOrderItem({
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
const sampleRestaurantHeader = RestaurantHeaderData(
  appName: 'Gashi',
  subtitle: 'Dashboard',
  currencies: ['USD', 'SLSH'],
);

const sampleRestaurantBanner = RestaurantBannerData(
  title: 'Aroor San!',
  subtitle: 'Si fududu u maamul restraunt kaga adoo adeegsanaya Gashi.',
);

const sampleRestaurantMetrics = [
  RestaurantMetricItem(
    icon: Icons.attach_money,
    iconBg: Color(0xFFE6F7F0),
    iconColor: Color(0xFF10B981),
    label: 'Iibka maanta',
    value: '\$420',
  ),
  RestaurantMetricItem(
    icon: Icons.shopping_basket_outlined,
    iconBg: Color(0xFFFFF3EB),
    iconColor: Color(0xFFFF6B00),
    label: 'Tirada\nDalabaadka',
    value: '32',
  ),
  RestaurantMetricItem(
    icon: Icons.people_outline,
    iconBg: Color(0xFFFDE8E8),
    iconColor: Color(0xFFEF4444),
    label: 'Dayn',
    value: '\$85',
  ),
  RestaurantMetricItem(
    icon: Icons.credit_card_outlined,
    iconBg: Color(0xFFFEF3C7),
    iconColor: Color(0xFFF59E0B),
    label: 'Dhigaal',
    value: '\$120',
  ),
];

const sampleRestaurantQuickActions = [
  RestaurantQuickAction(
    icon: Icons.add,
    label: 'Dalab\ncusub',
    isPrimary: true,
  ),
  RestaurantQuickAction(
    icon: Icons.description_outlined,
    label: 'Eeg iibka',
  ),
  RestaurantQuickAction(
    icon: Icons.people_outline,
    label: 'Macaamiisha',
  ),
  RestaurantQuickAction(
    icon: Icons.restaurant_menu,
    label: 'Maamul\nMenu-ga',
  ),
];

const sampleRestaurantOrders = [
  RestaurantOrderItem(
    id: '#R-1028',
    time: '12:30 PM',
    title: 'Miiska',
    type: 'Dine-in',
    price: 25.0,
    status: 'La dhiibay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.table_restaurant,
  ),
  RestaurantOrderItem(
    id: '#R-1027',
    time: '11:21 AM',
    title: 'Safaari',
    type: 'Takeaway',
    price: 18.0,
    status: 'Diyaarin',
    statusBg: Color(0xFFEFF6FF),
    statusText: Color(0xFF3B82F6),
    icon: Icons.shopping_bag_outlined,
  ),
  RestaurantOrderItem(
    id: '#R-1026',
    time: '10:15 AM',
    title: 'Deliver',
    type: 'Gaarsiin',
    price: 32.0,
    status: 'La wado',
    statusBg: Color(0xFFFFF3EB),
    statusText: Color(0xFFFF6B00),
    icon: Icons.two_wheeler,
  ),
  RestaurantOrderItem(
    id: '#R-1025',
    time: '09:40 AM',
    title: 'Miiska',
    type: 'Dine-in',
    price: 14.0,
    status: 'La Dhiibay',
    statusBg: Color(0xFFE6F7F0),
    statusText: Color(0xFF10B981),
    icon: Icons.table_restaurant,
  ),
];
