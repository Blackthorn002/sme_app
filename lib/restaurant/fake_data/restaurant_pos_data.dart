import 'package:flutter/material.dart';

// ============================================================================
// RESTAURANT POS DATA MODELS & SAMPLE VARIABLES
// ============================================================================

class RestaurantMenuItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String? tag;
  final String? note;

  const RestaurantMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.tag,
    this.note,
  });
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

// Sample externalizable default variables
const List<RestaurantMenuItem> sampleRestaurantMenuItems = [
  RestaurantMenuItem(
    id: '1',
    name: 'Bariis iyo Hilib',
    price: 8.0,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    tag: 'Hilib Geel',
    note: 'Bariis dheeraad ah',
  ),
  RestaurantMenuItem(
    id: '2',
    name: 'Bariis Chicken',
    price: 7.0,
    imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
  ),
  RestaurantMenuItem(
    id: '3',
    name: 'Baasto',
    price: 6.0,
    imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
  ),
  RestaurantMenuItem(
    id: '4',
    name: 'Suqaar',
    price: 8.0,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
  ),
  RestaurantMenuItem(
    id: '5',
    name: 'Maraq',
    price: 7.0,
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
  ),
  RestaurantMenuItem(
    id: '6',
    name: 'Sambusa',
    price: 1.0,
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
    category: 'Cuntooyinka',
    note: 'Sambusa Qudaar',
  ),
  RestaurantMenuItem(
    id: '7',
    name: 'Sharaab Avocado',
    price: 1.5,
    imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=400&q=80',
    category: 'Cabitaan',
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
  CategoryIconItem(title: 'Quraac', icon: Icons.history),
  CategoryIconItem(title: 'Cunto', icon: Icons.local_fire_department_outlined),
  CategoryIconItem(title: 'Kharash', icon: Icons.restaurant),
  CategoryIconItem(title: 'Cabitaan', icon: Icons.local_drink_outlined),
];
