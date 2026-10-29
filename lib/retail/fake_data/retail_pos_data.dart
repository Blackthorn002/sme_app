import 'package:flutter/material.dart';

// ============================================================================
// RETAIL POS DATA MODELS & SAMPLE VARIABLES
// ============================================================================

class RetailProductItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String? tag;
  final String? note;
  final int stockQuantity;

  const RetailProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.tag,
    this.note,
    this.stockQuantity = 10,
  });
}

class RetailCartItem {
  final RetailProductItem item;
  int quantity;
  String? note;
  String? tag;

  RetailCartItem({
    required this.item,
    this.quantity = 1,
    this.note,
    this.tag,
  });

  double get totalPrice => item.price * quantity;
}

class RetailCategoryIconItem {
  final String title;
  final IconData icon;

  const RetailCategoryIconItem({
    required this.title,
    required this.icon,
  });
}

class RetailPosOrderType {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;

  const RetailPosOrderType({
    required this.id,
    required this.label,
    this.sublabel = '',
    required this.icon,
  });
}

class RetailPosPaymentMethod {
  final String id;
  final String label;
  final String subtext;
  final Color color;
  final String? symbol;
  final IconData? icon;

  const RetailPosPaymentMethod({
    required this.id,
    required this.label,
    required this.subtext,
    required this.color,
    this.symbol,
    this.icon,
  });
}

class RetailPosSessionInfo {
  final String orderNumber;
  final String cashierName;
  final String orderTime;
  final double taxRatePercentage;
  final double exchangeRate;
  final String primaryCurrency;
  final String secondaryCurrency;

  const RetailPosSessionInfo({
    this.orderNumber = '#INV-5092',
    this.cashierName = 'Faadumo Cali',
    this.orderTime = '14:20',
    this.taxRatePercentage = 5.0,
    this.exchangeRate = 8500.0,
    this.primaryCurrency = 'USD',
    this.secondaryCurrency = 'SLSH',
  });
}

class RetailPosCustomerInfo {
  final String name;
  final String phone;
  final double paidAmount;
  final String paymentProvider;
  final String paymentStatus;
  final String customerStatus;

  const RetailPosCustomerInfo({
    this.name = 'Xasan Maxamed',
    this.phone = '+252 63 4455667',
    this.paidAmount = 25.00,
    this.paymentProvider = 'Zaad\$',
    this.paymentStatus = 'Dhammaystiran',
    this.customerStatus = 'Macmiil Joogto ah',
  });
}

class RetailPosTextLabels {
  final String appName;
  final String subtitle;
  final String searchHint;
  final String categoryTitle;
  final String allCategory;
  final String orderDetailsTitle;
  final String orderTypeLabel;
  final String selectedItemsLabel;
  final String addProductLabel;
  final String paymentMethodLabel;
  final String subtotalLabel;
  final String taxLabel;
  final String totalLabel;
  final String confirmButtonLabel;
  final String emptySearchMessage;
  final String cartBarTitle;
  final String viewOrderButton;
  final String customerInfoTitle;
  final String exchangeRateLabel;

  const RetailPosTextLabels({
    this.appName = 'Gashi',
    this.subtitle = 'Retail POS',
    this.searchHint = 'Raadi alaab...',
    this.categoryTitle = 'Alaabooyinka',
    this.allCategory = 'Dhammaan',
    this.orderDetailsTitle = 'Faahfaahinta Iibka',
    this.orderTypeLabel = 'NOOCA IIBKA:',
    this.selectedItemsLabel = 'ALAABTA LA DOORTAY',
    this.addProductLabel = '+ Ku dar alaab',
    this.paymentMethodLabel = 'HABKA LACAG BIXINTA',
    this.subtotalLabel = 'Wadarta Guud (Subtotal)',
    this.taxLabel = 'Canshuur',
    this.totalLabel = 'Guud ahaan (Total)',
    this.confirmButtonLabel = 'Iibi Hada',
    this.emptySearchMessage = 'Alaab laguma helin',
    this.cartBarTitle = 'Karta Iibka',
    this.viewOrderButton = 'Eeg Iibka',
    this.customerInfoTitle = 'Xogta Macmiilka',
    this.exchangeRateLabel = 'Heerka Sarifka',
  });
}

// Sample externalizable default variables
const List<RetailProductItem> sampleRetailMenuItems = [
  RetailProductItem(
    id: '1',
    name: 'Shaati Gacmo Dheere',
    price: 15.0,
    imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e32f85e2c?auto=format&fit=crop&w=400&q=80',
    category: 'Dhar',
    tag: 'Ragga',
    stockQuantity: 45,
  ),
  RetailProductItem(
    id: '2',
    name: 'Taleefan S21',
    price: 450.0,
    imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=400&q=80',
    category: 'Qalab',
    stockQuantity: 5,
  ),
  RetailProductItem(
    id: '3',
    name: 'Kabaha Isboortiga',
    price: 25.0,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=80',
    category: 'Kabo',
    stockQuantity: 20,
  ),
  RetailProductItem(
    id: '4',
    name: 'Saacad Gacan',
    price: 45.0,
    imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=400&q=80',
    category: 'Qalab',
    stockQuantity: 12,
  ),
  RetailProductItem(
    id: '5',
    name: 'Bariis Basmati 25kg',
    price: 32.0,
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e8ac?auto=format&fit=crop&w=400&q=80',
    category: 'Cunto',
    stockQuantity: 150,
  ),
  RetailProductItem(
    id: '6',
    name: 'Biyo Safiir 1.5L',
    price: 0.5,
    imageUrl: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=400&q=80',
    category: 'Cabitaan',
    stockQuantity: 200,
  ),
];

const List<RetailPosOrderType> sampleRetailOrderTypes = [
  RetailPosOrderType(id: 'Dukaan', label: 'Dukaan', sublabel: 'Walk-in', icon: Icons.storefront),
  RetailPosOrderType(id: 'Jumlad', label: 'Jumlad', sublabel: 'Wholesale', icon: Icons.local_shipping),
];

const List<RetailPosPaymentMethod> sampleRetailPaymentMethods = [
  RetailPosPaymentMethod(
    id: 'Zaad',
    label: 'Zaad',
    subtext: 'Telesom',
    color: Color(0xFF00A859),
    symbol: 'Z',
  ),
  RetailPosPaymentMethod(
    id: 'e-Dahab',
    label: 'e-Dahab',
    subtext: 'Somtel',
    color: Color(0xFFF58220),
    symbol: 'eD',
  ),
  RetailPosPaymentMethod(
    id: 'Kaash',
    label: 'Kaash',
    subtext: 'USD / SLSH',
    color: Color(0xFF2563EB),
    icon: Icons.account_balance_wallet_outlined,
  ),
];

const List<RetailCategoryIconItem> sampleRetailCategoryIcons = [
  RetailCategoryIconItem(title: 'Dhammaan', icon: Icons.grid_view_rounded),
  RetailCategoryIconItem(title: 'Dhar', icon: Icons.checkroom),
  RetailCategoryIconItem(title: 'Qalab', icon: Icons.devices),
  RetailCategoryIconItem(title: 'Kabo', icon: Icons.do_not_step),
  RetailCategoryIconItem(title: 'Cunto', icon: Icons.shopping_basket),
];