import 'package:flutter/material.dart';

// ============================================================================
// RESTAURANT MULTI-MENU CATALOG & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Menu-yada Makhaayadda):
//    - Defines the full restaurant food and drink catalog split across 4 distinct
//      shift menus:
//        * Morning Menu / Quraac ('morning') - 06:00 AM to 11:30 AM (Canjeero, beer, suqaar)
//        * Afternoon Menu / Qado ('afternoon') - 12:00 PM to 04:30 PM (Bariis, baasto, hilib geel)
//        * Dinner Menu / Casho ('dinner') - 05:30 PM to 11:00 PM (Muqmad, roti, maraq)
//        * Drinks & Cafe / Cabitaan ('drinks') - All-day fresh juices and Somali spiced tea
//    - Each menu can be enabled or disabled via `RestaurantMenuController` or `RestaurantMenuPage`.
//      When disabled, its dishes automatically vanish from `RestaurantPosPage`.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - RestaurantMenuSection -> `menu_sections` table:
//        id VARCHAR(50) PRIMARY KEY,
//        business_id INT REFERENCES businesses(id),
//        title VARCHAR(100) NOT NULL,
//        somali_title VARCHAR(100) NOT NULL,
//        time_range VARCHAR(50),
//        is_enabled BOOLEAN DEFAULT TRUE,
//        icon_name VARCHAR(50)
//    - RestaurantMenuItem -> `products` table:
//        id SERIAL PRIMARY KEY,
//        business_id INT REFERENCES businesses(id),  -- business_id = 3 (Restaurant)
//        name VARCHAR(255) NOT NULL,
//        selling_price NUMERIC(10, 2) NOT NULL,
//        category VARCHAR(100),
//        custom_attributes JSONB:
//          {
//            "menu_section_id": "morning", -- 'morning', 'afternoon', 'dinner', 'drinks'
//            "spicy_level": "medium",
//            "serving_time_minutes": 15
//          }
//
// 3. HOW TO MODIFY THIS DATA (Sida Cunto Cusub Loogu Daro):
//    - To add a new dish: Append a `RestaurantMenuItem` to `sampleRestaurantDishes`.
//      Always specify the correct `menuSectionId` ('morning', 'afternoon', 'dinner', 'drinks').
//    - To change pricing: Edit the `price` field (in USD, converted reactively to SLSh).
// ============================================================================

class RestaurantMenuSection {
  final String id; // 'morning', 'afternoon', 'dinner', 'drinks'
  final String title;
  final String somaliTitle;
  final String timeRange; // '06:00 AM - 11:30 AM'
  final IconData icon;
  final Color color;
  bool isEnabled;

  RestaurantMenuSection({
    required this.id,
    required this.title,
    required this.somaliTitle,
    required this.timeRange,
    required this.icon,
    required this.color,
    this.isEnabled = true,
  });

  RestaurantMenuSection copyWith({
    String? id,
    String? title,
    String? somaliTitle,
    String? timeRange,
    IconData? icon,
    Color? color,
    bool? isEnabled,
  }) {
    return RestaurantMenuSection(
      id: id ?? this.id,
      title: title ?? this.title,
      somaliTitle: somaliTitle ?? this.somaliTitle,
      timeRange: timeRange ?? this.timeRange,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class RestaurantMenuItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String? tag;
  final String? note;
  final String menuSectionId; // 'morning', 'afternoon', 'dinner', 'drinks'
  final bool isAvailable;

  const RestaurantMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.tag,
    this.note,
    this.menuSectionId = 'afternoon',
    this.isAvailable = true,
  });

  RestaurantMenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? category,
    String? tag,
    String? note,
    String? menuSectionId,
    bool? isAvailable,
  }) {
    return RestaurantMenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tag: tag ?? this.tag,
      note: note ?? this.note,
      menuSectionId: menuSectionId ?? this.menuSectionId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class RestaurantCartItem {
  final RestaurantMenuItem item;
  int quantity;
  String? note;
  String? tag;

  RestaurantCartItem({
    required this.item,
    this.quantity = 1,
    this.note,
    this.tag,
  });

  double get totalPrice => item.price * quantity;
}

class CategoryIconItem {
  final String title;
  final IconData icon;

  const CategoryIconItem({
    required this.title,
    required this.icon,
  });
}

class PosOrderType {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;

  const PosOrderType({
    required this.id,
    required this.label,
    this.sublabel = '',
    required this.icon,
  });
}

class PosPaymentMethod {
  final String id;
  final String label;
  final String subtext;
  final Color color;
  final String? symbol;
  final IconData? icon;

  const PosPaymentMethod({
    required this.id,
    required this.label,
    required this.subtext,
    required this.color,
    this.symbol,
    this.icon,
  });
}

class PosSessionInfo {
  final String orderNumber;
  final String waiterName;
  final String orderTime;
  final String prepTime;
  final double taxRatePercentage;
  final double exchangeRate;
  final String primaryCurrency;
  final String secondaryCurrency;

  const PosSessionInfo({
    this.orderNumber = '#ORD-2049',
    this.waiterName = 'Axmed Cali',
    this.orderTime = '09:41',
    this.prepTime = '10-15 daqiiqo',
    this.taxRatePercentage = 5.0,
    this.exchangeRate = 8500.0,
    this.primaryCurrency = 'USD',
    this.secondaryCurrency = 'SLSH',
  });
}

class PosCustomerInfo {
  final String name;
  final String phone;
  final double paidAmount;
  final String paymentProvider;
  final String paymentStatus;
  final String customerStatus;

  const PosCustomerInfo({
    this.name = 'Cabdiraxmaan Maxamed',
    this.phone = '+252 63 4455667',
    this.paidAmount = 10.70,
    this.paymentProvider = 'Zaad\$',
    this.paymentStatus = 'Dhammaystiran',
    this.customerStatus = 'Bixiyay',
  });
}

class PosTextLabels {
  final String appName;
  final String subtitle;
  final String searchHint;
  final String categoryTitle;
  final String allCategory;
  final String orderDetailsTitle;
  final String orderTypeLabel;
  final String selectedItemsLabel;
  final String addFoodLabel;
  final String paymentMethodLabel;
  final String subtotalLabel;
  final String taxLabel;
  final String totalLabel;
  final String confirmButtonLabel;
  final String emptySearchMessage;
  final String cartBarTitle;
  final String viewOrderButton;
  final String customerInfoTitle;
  final String itemsPreparedTitle;
  final String exchangeRateLabel;

  const PosTextLabels({
    this.appName = 'Gashi',
    this.subtitle = 'Restaurant POS',
    this.searchHint = 'Raadi cunto...',
    this.categoryTitle = 'Cuntooyinka',
    this.allCategory = 'Dhammaan',
    this.orderDetailsTitle = 'Faahfaahinta Dalabka',
    this.orderTypeLabel = 'NOOCA DA:',
    this.selectedItemsLabel = 'CUNTOOYINKA LA DOORTAY',
    this.addFoodLabel = '+ Ku dar cunto',
    this.paymentMethodLabel = 'HABKA LACAG BIXINTA',
    this.subtotalLabel = 'Wadarta Guud (Subtotal)',
    this.taxLabel = 'Canshuur',
    this.totalLabel = 'Guud ahaan (Total)',
    this.confirmButtonLabel = 'Xaqiiji',
    this.emptySearchMessage = 'Cunto laguma helin',
    this.cartBarTitle = 'Karta Dalabka',
    this.viewOrderButton = 'Eeg Dalabka',
    this.customerInfoTitle = 'Xogta Macaamiilka',
    this.itemsPreparedTitle = 'Alaabta loo diyaarinayo Qaadasho',
    this.exchangeRateLabel = 'Heerka',
  });
}

// Default Restaurant Menu Sections
final List<RestaurantMenuSection> sampleRestaurantMenuSections = [
  RestaurantMenuSection(
    id: 'morning',
    title: 'Menu-ga Quraacda (Morning)',
    somaliTitle: 'Quraac',
    timeRange: '06:00 AM - 11:30 AM',
    icon: Icons.wb_sunny_outlined,
    color: const Color(0xFFF59E0B),
    isEnabled: true,
  ),
  RestaurantMenuSection(
    id: 'afternoon',
    title: 'Menu-ga Qadada (Afternoon)',
    somaliTitle: 'Qado',
    timeRange: '12:00 PM - 04:30 PM',
    icon: Icons.restaurant,
    color: const Color(0xFFFF5200),
    isEnabled: true,
  ),
  RestaurantMenuSection(
    id: 'dinner',
    title: 'Menu-ga Cashada (Dinner)',
    somaliTitle: 'Casho',
    timeRange: '05:00 PM - 11:00 PM',
    icon: Icons.nights_stay_outlined,
    color: const Color(0xFF4F46E5),
    isEnabled: true,
  ),
  RestaurantMenuSection(
    id: 'drinks',
    title: 'Cabitaanno & Macmacaan (Drinks)',
    somaliTitle: 'Cabitaan',
    timeRange: 'Maalintii oo dhan (All Day)',
    icon: Icons.local_drink_outlined,
    color: const Color(0xFF10B981),
    isEnabled: true,
  ),
];

// Sample default menu items assigned to respective menu sections
const List<RestaurantMenuItem> sampleRestaurantMenuItems = [
  // 1. MORNING / QURAAC ITEMS
  RestaurantMenuItem(
    id: 'm_morn_1',
    name: 'Canjeero & Beer Shiilan',
    price: 4.50,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    category: 'Quraac',
    tag: 'Caanka ah',
    note: 'Canjeero 3 xabbo iyo beer cusub',
    menuSectionId: 'morning',
  ),
  RestaurantMenuItem(
    id: 'm_morn_2',
    name: 'Malawax & Malab / Subag',
    price: 3.00,
    imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=400&q=80',
    category: 'Quraac',
    note: 'Malawax macaan oo subag iyo malab leh',
    menuSectionId: 'morning',
  ),
  RestaurantMenuItem(
    id: 'm_morn_3',
    name: 'Omelette & Roodhi Somali',
    price: 2.50,
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=400&q=80',
    category: 'Quraac',
    note: 'Ukumo laba ah iyo rooti jilicsan',
    menuSectionId: 'morning',
  ),
  RestaurantMenuItem(
    id: 'm_morn_4',
    name: 'Shaah Somali Cadeys',
    price: 1.00,
    imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80',
    category: 'Quraac',
    tag: 'Shaah Kulul',
    note: 'Shaah hayl iyo qorfe leh',
    menuSectionId: 'morning',
  ),

  // 2. AFTERNOON / QADO ITEMS
  RestaurantMenuItem(
    id: '1',
    name: 'Bariis iyo Hilib Geel',
    price: 8.0,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    tag: 'Hilib Geel',
    note: 'Bariis dheeraad ah oo suugo leh',
    menuSectionId: 'afternoon',
  ),
  RestaurantMenuItem(
    id: '2',
    name: 'Bariis & Digaag Duban',
    price: 7.0,
    imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    note: 'Digaag curry iyo bariis basmati ah',
    menuSectionId: 'afternoon',
  ),
  RestaurantMenuItem(
    id: '3',
    name: 'Baasto Saldaata & Hilib',
    price: 6.5,
    imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    menuSectionId: 'afternoon',
  ),
  RestaurantMenuItem(
    id: '4',
    name: 'Suqaar & Chapati',
    price: 8.0,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    menuSectionId: 'afternoon',
  ),
  RestaurantMenuItem(
    id: '5',
    name: 'Maraq & Hilib Adhi',
    price: 7.0,
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    menuSectionId: 'afternoon',
  ),

  // 3. DINNER / CASHO ITEMS
  RestaurantMenuItem(
    id: 'm_din_1',
    name: 'Chapati & Suqaar Hilib',
    price: 5.50,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    category: 'Casho',
    tag: 'Casho Kulul',
    note: 'Chapati 2 xabbo iyo suqaar hilib ari',
    menuSectionId: 'dinner',
  ),
  RestaurantMenuItem(
    id: 'm_din_2',
    name: 'Kimis & Beer Shiilan',
    price: 4.50,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    category: 'Casho',
    note: 'Kimis qamadi ah iyo beer shiilan',
    menuSectionId: 'dinner',
  ),
  RestaurantMenuItem(
    id: 'm_din_3',
    name: 'Boorash & Caano Geel',
    price: 3.50,
    imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=400&q=80',
    category: 'Casho',
    note: 'Boorash sonkor iyo caano geel leh',
    menuSectionId: 'dinner',
  ),
  RestaurantMenuItem(
    id: '6',
    name: 'Sambusa Hilib & Basal (4 xabbo)',
    price: 2.0,
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
    category: 'Casho',
    note: 'Sanbuus hilib iyo basal leh',
    menuSectionId: 'dinner',
  ),

  // 4. DRINKS & DESSERTS
  RestaurantMenuItem(
    id: '7',
    name: 'Sharaab Mango & Qare',
    price: 2.0,
    imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=400&q=80',
    category: 'Cabitaan',
    tag: 'Cusub (Fresh)',
    menuSectionId: 'drinks',
  ),
  RestaurantMenuItem(
    id: '8',
    name: 'Caano Geel Fiican',
    price: 2.5,
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
    category: 'Cabitaan',
    tag: 'Caano Geel',
    note: 'Caano dhalad ah oo la karkariyay',
    menuSectionId: 'drinks',
  ),
  RestaurantMenuItem(
    id: '9',
    name: 'Sharaab Avocado & Caano',
    price: 2.5,
    imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=400&q=80',
    category: 'Cabitaan',
    menuSectionId: 'drinks',
  ),
];

const List<PosOrderType> samplePosOrderTypes = [
  PosOrderType(id: 'Miis', label: 'Miis', sublabel: 'Dine-In', icon: Icons.restaurant),
  PosOrderType(id: 'Safaari', label: 'Safaari', sublabel: 'Takeaway', icon: Icons.shopping_bag_outlined),
  PosOrderType(id: 'Delivery', label: 'Delivery', sublabel: 'Geyn', icon: Icons.two_wheeler),
];

const List<PosPaymentMethod> samplePosPaymentMethods = [
  PosPaymentMethod(
    id: 'Zaad',
    label: 'Zaad',
    subtext: 'Telesom',
    color: Color(0xFF00A859),
    symbol: 'Z',
  ),
  PosPaymentMethod(
    id: 'e-Dahab',
    label: 'e-Dahab',
    subtext: 'Somtel',
    color: Color(0xFFF58220),
    symbol: 'eD',
  ),
  PosPaymentMethod(
    id: 'Kaash',
    label: 'Kaash',
    subtext: 'USD / SLSH',
    color: Color(0xFF2563EB),
    icon: Icons.account_balance_wallet_outlined,
  ),
];

const List<CategoryIconItem> sampleCategoryIcons = [
  CategoryIconItem(title: 'Dhammaan', icon: Icons.grid_view_rounded),
  CategoryIconItem(title: 'Quraac', icon: Icons.wb_sunny_outlined),
  CategoryIconItem(title: 'Cuntooyinka', icon: Icons.restaurant),
  CategoryIconItem(title: 'Casho', icon: Icons.nights_stay_outlined),
  CategoryIconItem(title: 'Cabitaan', icon: Icons.local_drink_outlined),
];
