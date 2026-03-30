import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ru')];

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const Map<String, Map<String, String>> _v = {
    'en': {
      'appTitle': 'AutoMaster',
      'cars': 'Cars',
      'addCar': 'Add car',
      'upcoming': 'Upcoming',
      'overdue': 'Overdue',
      'totalCost': 'Total cost',
    },
    'ru': {
      'appTitle': 'AutoMaster',
      'cars': 'Автомобили',
      'addCar': 'Добавить авто',
      'upcoming': 'Скоро ТО',
      'overdue': 'Просрочено',
      'totalCost': 'Общие расходы',
    }
  };

  String t(String key) => _v[locale.languageCode]?[key] ?? _v['en']![key] ?? key;
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
