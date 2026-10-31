import 'package:flutter/material.dart';

// ============================================================================
// PHARMACY POS MEDICINE CATALOG & POSTGRESQL SCHEMA MAPPING
// ============================================================================
//
// 1. DATA PURPOSE & EXPLANATION (Faahfaahinta Daawooyinka POS-ka Farmashiyaha):
//    - Defines the pharmaceutical products, prescription drugs, and OTC medicines
//      available in the Pharmacy Point of Sale.
//    - Includes specialized Chronic Care medicines (Amlodipine, Metformin,
//      Ventolin Inhaler, Atorvastatin) which are directly linked to the
//      "Refill Daawada (POS)" button in Patient Medical Records.
//
// 2. BACKEND POSTGRESQL SCHEMA EQUIVALENT:
//    - PharmacyMenuItem maps to the `products` table:
//        id SERIAL PRIMARY KEY,
//        business_id INT REFERENCES businesses(id),  -- business_id = 1 (Pharmacy)
//        name VARCHAR(255) NOT NULL,
//        selling_price NUMERIC(10, 2) NOT NULL,
//        cost_price NUMERIC(10, 2) DEFAULT 0.00,
//        stock_quantity INT DEFAULT 0,
//        category VARCHAR(100),
//        custom_attributes JSONB:
//          {
//            "dosage": "500mg",
//            "expiry_date": "2027-10-15",
//            "requires_prescription": true,
//            "chronic_disease": "Dhiigkar / Hypertension"
//          }
//    - PharmacyCartItem maps to `sale_items` at checkout.
//
// 3. HOW TO MODIFY THIS DATA (Sida Daawo Cusub Loogu Daro):
//    - To add a new medicine: Append a `PharmacyMenuItem` to `samplePharmacyProducts`.
//    - To link a medicine to patient refills: Ensure the product name or ID matches
//      the patient's regular prescription in `patient_medical_records_page.dart`.
// ============================================================================

class PharmacyMenuItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String? tag;
  final String? note;
  final int stockQuantity;

  const PharmacyMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.tag,
    this.note,
    this.stockQuantity = 50,
  });
}

class PharmacyCartItem {
  final PharmacyMenuItem item;
  int quantity;
  String? note;
  String? tag;

  PharmacyCartItem({
    required this.item,
    this.quantity = 1,
    this.note,
    this.tag,
  });

  double get totalPrice => item.price * quantity;
}

class PharmacyCategoryIconItem {
  final String title;
  final IconData icon;

  const PharmacyCategoryIconItem({
    required this.title,
    required this.icon,
  });
}

class PharmacyOrderType {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;

  const PharmacyOrderType({
    required this.id,
    required this.label,
    this.sublabel = '',
    required this.icon,
  });
}

class PharmacyPaymentMethod {
  final String id;
  final String label;
  final String subtext;
  final Color color;
  final String? symbol;
  final IconData? icon;

  const PharmacyPaymentMethod({
    required this.id,
    required this.label,
    required this.subtext,
    required this.color,
    this.symbol,
    this.icon,
  });
}

class PharmacySessionInfo {
  final String orderNumber;
  final String cashierName;
  final String orderTime;
  final double taxRatePercentage;
  final double exchangeRate;
  final String primaryCurrency;
  final String secondaryCurrency;

  const PharmacySessionInfo({
    this.orderNumber = '#PH-2049',
    this.cashierName = 'Dr. Faadumo',
    this.orderTime = '09:41',
    this.taxRatePercentage = 2.0,
    this.exchangeRate = 8500.0,
    this.primaryCurrency = 'USD',
    this.secondaryCurrency = 'SLSH',
  });
}

class PharmacyCustomerInfo {
  final String name;
  final String phone;
  final double paidAmount;
  final String paymentProvider;
  final String paymentStatus;
  final String customerStatus;

  const PharmacyCustomerInfo({
    this.name = 'Cali Jaamac',
    this.phone = '+252 63 4455667',
    this.paidAmount = 15.00,
    this.paymentProvider = 'Zaad\$',
    this.paymentStatus = 'Dhammaystiran',
    this.customerStatus = 'Bixiyay',
  });
}

class PharmacyTextLabels {
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

  const PharmacyTextLabels({
    this.appName = 'Gashi',
    this.subtitle = 'Farmaajo POS',
    this.searchHint = 'Raadi daawo...',
    this.categoryTitle = 'Daawooyinka',
    this.allCategory = 'Dhammaan',
    this.orderDetailsTitle = 'Faahfaahinta Iibka',
    this.orderTypeLabel = 'NOOCA:',
    this.selectedItemsLabel = 'DAAWOOYINKA LA DOORTAY',
    this.addFoodLabel = '+ Ku dar daawo',
    this.paymentMethodLabel = 'HABKA LACAG BIXINTA',
    this.subtotalLabel = 'Wadarta Guud (Subtotal)',
    this.taxLabel = 'Canshuur',
    this.totalLabel = 'Guud ahaan (Total)',
    this.confirmButtonLabel = 'Xaqiiji Iibka',
    this.emptySearchMessage = 'Daawo laguma helin',
    this.cartBarTitle = 'Kartida Iibka',
    this.viewOrderButton = 'Eeg Iibka',
    this.customerInfoTitle = 'Xogta Bukaanka',
    this.itemsPreparedTitle = 'Alaabta la bixinayo',
    this.exchangeRateLabel = 'Heerka',
  });
}

const List<PharmacyMenuItem> samplePharmacyMenuItems = [
  PharmacyMenuItem(
    id: '1',
    name: 'Panadol Advance',
    price: 2.5,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    category: 'Xanuun Baabiiye',
    tag: '500mg',
    stockQuantity: 120,
  ),
  PharmacyMenuItem(
    id: '2',
    name: 'Amoxicillin',
    price: 4.0,
    imageUrl: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&w=400&q=80',
    category: 'Antibiotic',
    tag: '250mg',
    stockQuantity: 80,
  ),
  PharmacyMenuItem(
    id: '3',
    name: 'Vitamin C',
    price: 3.0,
    imageUrl: 'https://images.unsplash.com/photo-1550572017-edb3df163ab5?auto=format&fit=crop&w=400&q=80',
    category: 'Vitamin',
    stockQuantity: 200,
  ),
  PharmacyMenuItem(
    id: '4',
    name: 'Ibuprofen',
    price: 3.5,
    imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?auto=format&fit=crop&w=400&q=80',
    category: 'Xanuun Baabiiye',
    stockQuantity: 150,
  ),
  PharmacyMenuItem(
    id: '5',
    name: 'Omeprazole',
    price: 5.0,
    imageUrl: 'https://images.unsplash.com/photo-1628771065518-0d82f1938462?auto=format&fit=crop&w=400&q=80',
    category: 'Caloosha',
    stockQuantity: 60,
  ),
  PharmacyMenuItem(
    id: '6',
    name: 'Cough Syrup',
    price: 6.5,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    category: 'Sharoobo',
    note: 'Qufaca qallalan',
    stockQuantity: 40,
  ),
  PharmacyMenuItem(
    id: '7',
    name: 'Amlodipine',
    price: 4.0,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    category: 'Dhiigkar',
    tag: '5mg',
    note: 'Daawada Dhiigkarka (Chronic BP)',
    stockQuantity: 95,
  ),
  PharmacyMenuItem(
    id: '8',
    name: 'Metformin',
    price: 5.0,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    category: 'Sonkorow',
    tag: '500mg',
    note: 'Daawada Sonkorowga (Type 2 Diabetes)',
    stockQuantity: 110,
  ),
  PharmacyMenuItem(
    id: '9',
    name: 'Ventolin Inhaler',
    price: 8.5,
    imageUrl: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&w=400&q=80',
    category: 'Neef',
    tag: '100mcg',
    note: 'Inhaler-ka Neefta (Asthma Relief)',
    stockQuantity: 50,
  ),
  PharmacyMenuItem(
    id: '10',
    name: 'Atorvastatin',
    price: 7.0,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    category: 'Wadnaha',
    tag: '20mg',
    note: 'Dhimista Baruurta & Wadnaha',
    stockQuantity: 75,
  ),
];

const List<PharmacyOrderType> samplePharmacyOrderTypes = [
  PharmacyOrderType(id: 'Toos', label: 'Toos', sublabel: 'Walk-in', icon: Icons.person),
  PharmacyOrderType(id: 'Dhakhtar', label: 'Dhakhtar', sublabel: 'Prescription', icon: Icons.description_outlined),
];

const List<PharmacyPaymentMethod> samplePharmacyPaymentMethods = [
  PharmacyPaymentMethod(
    id: 'Zaad',
    label: 'Zaad',
    subtext: 'Telesom',
    color: Color(0xFF00A859),
    symbol: 'Z',
  ),
  PharmacyPaymentMethod(
    id: 'e-Dahab',
    label: 'e-Dahab',
    subtext: 'Somtel',
    color: Color(0xFFF58220),
    symbol: 'eD',
  ),
  PharmacyPaymentMethod(
    id: 'EVC Plus',
    label: 'EVC Plus',
    subtext: 'Hormuud',
    color: Color(0xFF0D9488),
    symbol: 'EVC',
  ),
  PharmacyPaymentMethod(
    id: 'Kaash',
    label: 'Kaash',
    subtext: 'Cash',
    color: Color(0xFF2563EB),
    icon: Icons.payments_outlined,
  ),
];

const List<PharmacyCategoryIconItem> samplePharmacyCategoryIcons = [
  PharmacyCategoryIconItem(title: 'Dhammaan', icon: Icons.grid_view_rounded),
  PharmacyCategoryIconItem(title: 'Xanuun Baabiiye', icon: Icons.healing),
  PharmacyCategoryIconItem(title: 'Antibiotic', icon: Icons.medication),
  PharmacyCategoryIconItem(title: 'Vitamin', icon: Icons.health_and_safety),
  PharmacyCategoryIconItem(title: 'Sharoobo', icon: Icons.water_drop),
];
