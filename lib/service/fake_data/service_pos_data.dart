import 'package:flutter/material.dart';

// ============================================================================
// SERVICE POS DATA MODELS & SAMPLE VARIABLES
// ============================================================================

class ServiceItem {
  final String id;
  final String name;
  final double price;
  final String duration;
  final String imageUrl;
  final String category;
  final String? technician;
  final String? tag;
  final String? note;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.category,
    this.technician,
    this.tag,
    this.note,
  });
}

class ServiceCartItem {
  final ServiceItem service;
  int quantity;
  String? customerName;
  String? customerPhone;
  String? referenceInfo; // e.g., Car Plate / Phone Model
  String? note;

  ServiceCartItem({
    required this.service,
    this.quantity = 1,
    this.customerName,
    this.customerPhone,
    this.referenceInfo,
    this.note,
  });

  double get totalPrice => service.price * quantity;
}

class ServiceCategoryIconItem {
  final String title;
  final IconData icon;

  const ServiceCategoryIconItem({
    required this.title,
    required this.icon,
  });
}

class ServiceOrderType {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;

  const ServiceOrderType({
    required this.id,
    required this.label,
    this.sublabel = '',
    required this.icon,
  });
}

class ServicePaymentMethod {
  final String id;
  final String label;
  final String subtext;
  final Color color;
  final String? symbol;
  final IconData? icon;

  const ServicePaymentMethod({
    required this.id,
    required this.label,
    required this.subtext,
    required this.color,
    this.symbol,
    this.icon,
  });
}

// Sample services data
const List<ServiceItem> sampleServiceItems = [
  ServiceItem(
    id: 's1',
    name: 'Dhaqista Baabuurka (Full Wash)',
    price: 15.0,
    duration: '45 daqiiqo',
    imageUrl: 'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&w=400&q=80',
    category: 'Baabuur',
    technician: 'Cabdi & Kooxda',
    tag: 'Caanka ah',
    note: 'Gudaha iyo dibadda baabuurka',
  ),
  ServiceItem(
    id: 's2',
    name: 'Beddelka Shaashad iPhone / Samsung',
    price: 35.0,
    duration: '1 saac',
    imageUrl: 'https://images.unsplash.com/photo-1597740985671-2a8a3b80532e?auto=format&fit=crop&w=400&q=80',
    category: 'Farsamo & IT',
    technician: 'Eng. Xamze',
    tag: 'Damaanad leh',
    note: 'Shaashad Original ah oo leh 3 bilood damaanad',
  ),
  ServiceItem(
    id: 's3',
    name: 'Beddelka Saliidda Gaadhiga (Oil Change)',
    price: 25.0,
    duration: '30 daqiiqo',
    imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=400&q=80',
    category: 'Baabuur',
    technician: 'Mustafe Farsamo',
    tag: 'Degdeg',
    note: 'Saliid Total / Shell tayo sare leh',
  ),
  ServiceItem(
    id: 's4',
    name: 'Dhar Tolasho (Khamiis / Suit)',
    price: 30.0,
    duration: '2 maalmood',
    imageUrl: 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?auto=format&fit=crop&w=400&q=80',
    category: 'Dhar & Qurxin',
    technician: 'Ustaad Maxamed',
    tag: 'Tayada Sare',
    note: 'Tolasho casri ah oo cabbir sax ah leh',
  ),
  ServiceItem(
    id: 's5',
    name: 'Tima-jaryo & Xiirasho (Haircut & Beard)',
    price: 6.0,
    duration: '25 daqiiqo',
    imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=400&q=80',
    category: 'Dhar & Qurxin',
    technician: 'Barber Cali',
    tag: 'Standard',
    note: 'Timo-jarid, makiinad iyo cream nadiifin',
  ),
  ServiceItem(
    id: 's6',
    name: 'Rakibaad & Hagaajin Wi-Fi / CCTV',
    price: 45.0,
    duration: '2 saacadood',
    imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=400&q=80',
    category: 'Farsamo & IT',
    technician: 'Eng. Guuleed',
    tag: 'Guriga/Xafiiska',
    note: 'Qalabka router-ka iyo xadhkaha internetka',
  ),
  ServiceItem(
    id: 's7',
    name: 'La-talin Xisaabeed & Cashuuro (Tax Audit)',
    price: 50.0,
    duration: '1 saac',
    imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80',
    category: 'La-talin',
    technician: 'Xisaabiye Cabdilaahi',
    tag: 'Xirfadlayaal',
    note: 'Diyaarinta xisaabaadka iyo xisaab-xidhka',
  ),
];

const List<ServiceCategoryIconItem> sampleServiceCategoryIcons = [
  ServiceCategoryIconItem(title: 'Dhammaan', icon: Icons.grid_view_rounded),
  ServiceCategoryIconItem(title: 'Baabuur', icon: Icons.directions_car_outlined),
  ServiceCategoryIconItem(title: 'Farsamo & IT', icon: Icons.build_circle_outlined),
  ServiceCategoryIconItem(title: 'Dhar & Qurxin', icon: Icons.content_cut_outlined),
  ServiceCategoryIconItem(title: 'La-talin', icon: Icons.business_center_outlined),
];

const List<ServiceOrderType> sampleServiceOrderTypes = [
  ServiceOrderType(id: 'Goobta', label: 'Goobta', sublabel: 'In-Shop', icon: Icons.store_outlined),
  ServiceOrderType(id: 'Guriga', label: 'Guriga/Bannaanka', sublabel: 'On-Site', icon: Icons.home_repair_service_outlined),
  ServiceOrderType(id: 'Degdeg', label: 'Degdeg', sublabel: 'Express', icon: Icons.electric_bolt_outlined),
];

const List<ServicePaymentMethod> sampleServicePaymentMethods = [
  ServicePaymentMethod(
    id: 'Zaad',
    label: 'Zaad',
    subtext: 'Telesom',
    color: Color(0xFF00A859),
    symbol: 'Z',
  ),
  ServicePaymentMethod(
    id: 'e-Dahab',
    label: 'e-Dahab',
    subtext: 'Somtel',
    color: Color(0xFFF58220),
    symbol: 'eD',
  ),
  ServicePaymentMethod(
    id: 'Kaash',
    label: 'Kaash',
    subtext: 'USD / SLSH',
    color: Color(0xFF2563EB),
    icon: Icons.account_balance_wallet_outlined,
  ),
];

class ServicePosSessionInfo {
  final String orderNumber;
  final String cashierName;
  final String orderTime;
  final double taxRatePercentage;
  final double exchangeRate;
  final String primaryCurrency;
  final String secondaryCurrency;

  const ServicePosSessionInfo({
    this.orderNumber = '#SRV-3015',
    this.cashierName = 'Axmed Cali',
    this.orderTime = '12:45 PM',
    this.taxRatePercentage = 5.0,
    this.exchangeRate = 8500.0,
    this.primaryCurrency = 'USD',
    this.secondaryCurrency = 'SLSH',
  });
}

class ServicePosCustomerInfo {
  final String name;
  final String phone;
  final String referenceInfo;
  final String customerStatus;

  const ServicePosCustomerInfo({
    this.name = 'Macmiil Caadi ah (Walk-in)',
    this.phone = '+252 63 0000000',
    this.referenceInfo = '',
    this.customerStatus = 'Standard',
  });
}

class ServicePosTextLabels {
  final String appName;
  final String subtitle;
  final String searchHint;
  final String categoryTitle;
  final String allCategory;
  final String orderDetailsTitle;
  final String orderTypeLabel;
  final String selectedItemsLabel;
  final String addServiceLabel;
  final String customerInfoLabel;
  final String paymentMethodLabel;
  final String subtotalLabel;
  final String taxLabel;
  final String totalLabel;
  final String confirmButtonLabel;
  final String clearCartLabel;
  final String emptySearchMessage;
  final String cartBarTitle;
  final String viewOrderButton;
  final String customerInfoTitle;
  final String itemsPreparedTitle;
  final String exchangeRateLabel;

  const ServicePosTextLabels({
    this.appName = 'Gashi',
    this.subtitle = 'Services POS',
    this.searchHint = 'Raadi adeeg...',
    this.categoryTitle = 'Adeegyada',
    this.allCategory = 'Dhammaan',
    this.orderDetailsTitle = 'Faahfaahinta Dalabka',
    this.orderTypeLabel = 'NOOCA BIXINTA:',
    this.selectedItemsLabel = 'ADEEGYADA LA DOORTAY',
    this.addServiceLabel = '+ Ku dar adeeg',
    this.customerInfoLabel = 'Macluumaadka Macmiilka (Customer Info)',
    this.paymentMethodLabel = 'HABKA LACAG BIXINTA',
    this.subtotalLabel = 'Wadarta Guud (Subtotal)',
    this.taxLabel = 'Canshuur',
    this.totalLabel = 'Guud ahaan (Total)',
    this.confirmButtonLabel = 'Xaqiiji Dalabka',
    this.clearCartLabel = 'Nadiifi Dalabka',
    this.emptySearchMessage = 'Ma jiro adeeg la helay',
    this.cartBarTitle = 'Wadarta Dalabka',
    this.viewOrderButton = 'Eeg Dalabka',
    this.customerInfoTitle = 'Xogta Macaamiilka',
    this.itemsPreparedTitle = 'Adeegyada Diyaarinta',
    this.exchangeRateLabel = 'Sarifka Maanta',
  });
}

const sampleServicePosSessionInfo = ServicePosSessionInfo();
const sampleServicePosCustomerInfo = ServicePosCustomerInfo();
const sampleServicePosTextLabels = ServicePosTextLabels();


