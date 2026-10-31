import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// ============================================================================
// DYNAMIC MONEY EXCHANGE SERVICE (Gashi Multi-Currency Engine)
// ============================================================================
// Supports:
// - Dynamic daily exchange rate between USD and Somaliland Shilling (SLSh) / SOS
// - Connectable to daily market rates or database records
// - Seamless price conversion & formatting across POS, Sales, Credits, and Dashboards
// ============================================================================

class CurrencyService extends ChangeNotifier {
  static final CurrencyService instance = CurrencyService._internal();

  CurrencyService._internal();

  // Active currency selected by user ('USD' or 'SLSh')
  String _activeCurrency = 'USD';
  String get activeCurrency => _activeCurrency;

  // Daily exchange rate (e.g., 1 USD = 8,500 SLSh)
  // Connectable to backend database: e.g. `daily_exchange_rates` table
  double _dailyExchangeRate = 8500.0;
  double get dailyExchangeRate => _dailyExchangeRate;

  // Source / market reference
  String _rateSource = 'Dahabshiil / Suuqyada Hargeysa';
  String get rateSource => _rateSource;

  // Last update timestamp
  DateTime _lastUpdated = DateTime.now();
  DateTime get lastUpdated => _lastUpdated;

  // Supported currencies list
  List<String> get supportedCurrencies => const ['USD', 'SLSh'];

  // Switch active currency
  void setActiveCurrency(String currencyCode) {
    final code = currencyCode.toUpperCase();
    if (_activeCurrency != code && (code == 'USD' || code == 'SLSH')) {
      _activeCurrency = code == 'SLSH' ? 'SLSh' : 'USD';
      notifyListeners();
    }
  }

  // Toggle between USD and SLSh
  void toggleCurrency() {
    _activeCurrency = _activeCurrency == 'USD' ? 'SLSh' : 'USD';
    notifyListeners();
  }

  // Update daily exchange rate (e.g. from UI input, SQLite, or backend API)
  void setDailyExchangeRate(double newRate, {String? source}) {
    if (newRate > 0) {
      _dailyExchangeRate = newRate;
      if (source != null && source.trim().isNotEmpty) {
        _rateSource = source.trim();
      }
      _lastUpdated = DateTime.now();
      notifyListeners();
    }
  }

  void updateExchangeRate(double newRate, {String? source}) {
    setDailyExchangeRate(newRate, source: source);
  }

  // Convert USD value to active currency value
  double convert(double usdAmount) {
    if (_activeCurrency == 'SLSh') {
      return usdAmount * _dailyExchangeRate;
    }
    return usdAmount;
  }

  // Convert specific amount between currencies
  double convertBetween(double amount, {required String from, required String to}) {
    if (from == to) return amount;
    if (from == 'USD' && to == 'SLSh') {
      return amount * _dailyExchangeRate;
    } else if (from == 'SLSh' && to == 'USD') {
      return _dailyExchangeRate > 0 ? amount / _dailyExchangeRate : amount;
    }
    return amount;
  }

  // Format amount according to active currency
  String format(double usdAmount, {bool includeCode = true}) {
    final numberFormat = NumberFormat('#,##0.##');
    if (_activeCurrency == 'SLSh') {
      final slshValue = usdAmount * _dailyExchangeRate;
      final formatted = NumberFormat('#,##0').format(slshValue.round());
      return includeCode ? '$formatted SLSh' : formatted;
    } else {
      final formatted = numberFormat.format(usdAmount);
      return includeCode ? '\$$formatted' : formatted;
    }
  }

  // Format SLSh value directly from USD amount
  String formatSlsh(double usdAmount, {bool includeCode = true}) {
    final slshVal = (usdAmount * _dailyExchangeRate).round();
    final formatted = NumberFormat('#,##0').format(slshVal);
    return includeCode ? '$formatted SLSh' : formatted;
  }

  // Format USD value directly
  String formatUsd(double usdAmount) {
    return '\$${usdAmount.toStringAsFixed(2)}';
  }

  // Dual currency representation (e.g. "$15.00 • 127,500 SLSh")
  String formatDual(double usdAmount) {
    final usdStr = '\$${usdAmount.toStringAsFixed(2)}';
    final slshVal = (usdAmount * _dailyExchangeRate).round();
    final slshStr = '${NumberFormat('#,##0').format(slshVal)} SLSh';
    return '$usdStr • $slshStr';
  }

  // Formatted date string of last rate update
  String get formattedLastUpdated {
    return DateFormat('dd MMM yyyy, hh:mm a').format(_lastUpdated);
  }
}
