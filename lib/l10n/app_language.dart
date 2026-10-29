import 'package:flutter/material.dart';

class AppLanguage extends ChangeNotifier {
  static final AppLanguage instance = AppLanguage._internal();

  AppLanguage._internal();

  Locale _currentLocale = const Locale('so'); // Default to Somali

  Locale get currentLocale => _currentLocale;
  bool get isSomali => _currentLocale.languageCode == 'so';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  void changeLanguage(Locale newLocale) {
    if (_currentLocale == newLocale) return;
    _currentLocale = newLocale;
    notifyListeners();
  }

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'so') {
      changeLanguage(const Locale('en'));
    } else {
      changeLanguage(const Locale('so'));
    }
  }

  void setSomali() => changeLanguage(const Locale('so'));
  void setEnglish() => changeLanguage(const Locale('en'));
}

