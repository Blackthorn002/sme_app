# SME App - Concise File & Folder Guide

An overview of every directory and file in the application, what each contains, and its responsibility.

---

## 📁 Root Configuration & Platform Folders

| File / Folder | Purpose & Contents |
| :--- | :--- |
| **`pubspec.yaml`** | App specifications, dependencies (`intl`, `cached_network_image`, `image_picker`, etc.), assets declaration, and SDK version. |
| **`analysis_options.yaml`** | Dart static analyzer and linter rules. |
| **`assets/`** | Application branding images and logos (`gashi_logo*.png/jpeg`). |
| **`test/`** | Automated testing directory (e.g. `widget_test.dart` for smoke and UI testing). |
| **`android/`** | Native Android project files, Gradle build scripts, manifest, and hardware permissions (Camera, Storage, Internet). |
| **`ios/`** | Native iOS Xcode project, `Info.plist`, Runner, and iOS privacy permissions. |
| **`web/`**, **`windows/`**, **`macos/`**, **`linux/`** | Native runner wrappers for web and desktop platforms. |

---

## 📁 `lib/` — Application Source Code

### 1. Core Entry & Common Modules
- **`lib/main.dart`**: Application entry point (`main()`). Initializes themes, sets up localizations, manages global providers, and loads the initial screen.
- **`lib/common/widgets/app_cached_image.dart`**: Reusable network image widget with automatic caching, placeholder skeleton, and error fallback.

### 2. Localization (`lib/l10n/`)
- **`app_language.dart`**: State provider (`ChangeNotifier`) controlling dynamic language switching (English ⇄ Somali).
- **`app_localizations.dart`**: Central translation lookup service reading localized string keys.
- **`languages/en.dart`**: English dictionary containing all UI strings.
- **`languages/so.dart`**: Somali dictionary containing all UI strings.

---

### 3. Shared Features (`lib/general_features/`)
Unified modules used across different business types (Retail, Pharmacy, etc.):

- **`models/gashi_models.dart`**: Core data models (`Product`, `Category`, `Order`, `CartItem`, `CustomerDebt`, `BusinessType`, `PaymentMethod`, etc.).
- **`repository/gashi_repository.dart`**: Central data access layer managing products, sales records, customer debts, and transactions.
- **`pages/general_pos_page.dart`**: High-performance Point of Sale screen with camera barcode/photo search, fast quantity adjustments, dual cash/debt checkout modes, and the bargaining modal.
- **`pages/general_inventory_page.dart`**: Inventory management for adding, editing, searching products, and tracking stock alerts.
- **`pages/general_credits_page.dart`**: Customer credit & debt management ledger (Deymaha) for tracking unpaid balances and logging debt repayments.
- **`pages/general_settings_page.dart`**: Business settings, profile information, currency exchange rates (USD/SLSH), and thermal receipt printer setup.
- **`widgets/offline_sync_banner.dart`**: Visual alert banner indicating offline status and pending local-to-cloud synchronization.
- **`widgets/pos_camera_capture_sheet.dart`**: Bottom sheet camera interface to snap product photos for fast matching or inventory reference.

---

### 4. Sector-Specific Business Modules

#### 🏥 Pharmacy (`lib/pharmacy/`)
- **`pharmacy_view.dart`**: Bottom navigation scaffold for pharmacy workflows (POS, Inventory, Medical Records, Patients, Settings).
- **`medical_records/patient_medical_records_page.dart`**: Patient medication history and clinical records.
- **`pages/pharmacy_inventory_page.dart`**: Medicine inventory with batch numbers and expiration tracking.
- **`pages/pharmacy_patients_page.dart`**: Patient contact directory and prescription logs.
- **`pages/pharmacy_pos_page.dart`**: Dedicated pharmacy checkout page.
- **`pages/pharmacy_settings_page.dart`**: Pharmacy-specific preferences.
- **`fake_data/`**: Mock datasets for medicines (`pharmacy_pos_data.dart`) and dashboard metrics (`pharmacy_dashboard_data.dart`).

#### 🍽️ Restaurant (`lib/restaurant/`)
- **`restaurant_view.dart`**: Bottom navigation scaffold for restaurant workflows (POS, Orders, Menu, Sales, Debts, Settings).
- **`pages/restaurant_pos_page.dart`**: Restaurant POS supporting Dine-in (`Miis`), Takeaway (`Safaari`), and Delivery orders. Operates in POS-only mode without stock quantity tracking or bargaining. Only requires Customer Name and Location for Delivery orders (no customer name required for paid-now dine-in/takeaway). Directly writes completed orders to `GashiRepository` sales.
- **`pages/restaurant_menu_page.dart`**: Food & drink menu catalog manager with category filters.
- **`pages/restaurant_sales_page.dart`**: Daily dining sales logs and ticket receipts, reactively bound to `GashiRepository` sales.
- **`pages/restaurant_credits_page.dart`**: Customer tabs and debt tracking.
- **`pages/restaurant_settings_page.dart`**: Table layout and kitchen printer configurations.
- **`services/restaurant_menu_controller.dart`**: State controller managing active menu items and tables.
- **`fake_data/`**: Mock data for food items (`restaurant_pos_data.dart`) and dining metrics (`restaurant_dashboard_data.dart`).

---

### 5. 🗄️ Database & Schema Architecture Notes
- **Deployment Status**: The PostgreSQL / Supabase remote database is **NOT yet deployed**. The application currently runs entirely with client-side models (`gashi_models.dart`) and local simulated repositories (`GashiRepository`, controllers, and `fake_data/*.dart`). This enables comprehensive prototyping and UI verification before cloud schema provisioning.
- **Restaurant POS-Only Schema**: In the PostgreSQL schema definition (`gashi_repository.dart`), the `products` table defines `track_inventory BOOLEAN NOT NULL DEFAULT TRUE` and `stock_quantity INT DEFAULT NULL`. Restaurants operate as POS-only without inventory stock tracking (`track_inventory = false`). Sales entries include `order_type` (`Miis`, `Safaari`, `Delivery`) and optional `delivery_location`. `sale_items` uses a nullable `product_id` so made-to-order dishes can be logged seamlessly without strict inventory product constraints.

#### 🛍️ Retail (`lib/retail/`)
- **`retail_view.dart`**: Bottom navigation scaffold for general retail shops.
- **`pages/retail_pos_page.dart`**: Dedicated retail POS checkout screen.
- **`pages/retail_inventory_page.dart`**: General retail stock manager, barcode scanning, and restocking.
- **`pages/retail_credits_page.dart`**: Customer store credit ledger.
- **`pages/retail_settings_page.dart`**: Store preferences and receipt headers.
- **`fake_data/`**: Mock datasets for retail items, debts, and dashboard analytics.

#### ✂️ Service (`lib/service/`)
- **`service_view.dart`**: Bottom navigation scaffold for service-based businesses (barbers, repairs, salons, clinics).
- **`pages/service_pos_page.dart`**: Service checkout and billing page.
- **`pages/service_services_page.dart`**: Service catalog manager (pricing, labor rates, service duration).
- **`pages/service_sales_page.dart`**: Completed appointment records and sales summaries.
- **`pages/service_credits_page.dart`**: Client credit balances and invoice tracking.
- **`pages/service_settings_page.dart`**: Booking and service preferences.
- **`services/service_controller.dart`**: State controller managing service offerings and appointments.
- **`fake_data/`**: Mock service packages, client debts, and sales analytics.

