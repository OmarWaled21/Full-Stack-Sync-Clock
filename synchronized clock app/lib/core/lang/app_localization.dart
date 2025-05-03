import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppLocalization {
  static Map<String, String>? _localizedStrings;
  static Locale? currentLocale;

  // دالة لتحميل النصوص المترجمة من ملف JSON
  static Future<void> load(Locale locale) async {
    String jsonString = await rootBundle.loadString('lib/core/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    currentLocale = locale;
  }

  // دالة لترجمة النصوص
  static String translate(BuildContext context, String key) {
    return _localizedStrings?[key] ?? key;
  }

  // دالة لتغيير اللغة
  static void setLocale(Locale locale) {
    currentLocale = locale;
  }

  // دالة لبناء اللغات المدعومة
  static List<Locale> supportedLocales() {
    return [const Locale('en', 'US'), const Locale('ar', 'EG')];
  }

  // دالة لبناء الـ LocalizationsDelegate
  static LocalizationsDelegate<AppLocalization> delegate() {
    return const _AppLocalizationDelegate();
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    await AppLocalization.load(locale);
    return AppLocalization();
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
