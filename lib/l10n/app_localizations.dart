import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'languages/en.dart';
import 'languages/so.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const LocalizationsDelegate<MaterialLocalizations> materialDelegate = FallbackMaterialLocalizationsDelegate();
  static const LocalizationsDelegate<CupertinoLocalizations> cupertinoDelegate = FallbackCupertinoLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('so'), // Somali
    Locale('en'), // English
  ];

  late final Map<String, String> _localizedStrings = 
      locale.languageCode == 'en' ? enTranslations : soTranslations;

  String translate(String key) {
    return _localizedStrings[key] ?? enTranslations[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['so', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) => DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) => DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

extension AppLocalizationExtension on BuildContext {
  String tr(String key) {
    final loc = AppLocalizations.of(this);
    if (loc != null) {
      return loc.translate(key);
    }
    return soTranslations[key] ?? enTranslations[key] ?? key;
  }
}
