import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';

  LocalizationCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString(_localeKey);
    if (savedLangCode != null) {
      emit(Locale(savedLangCode));
    }
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    await _saveLocale(newLocale.languageCode);
    emit(newLocale);
  }

  Future<void> setLocale(Locale locale) async {
    await _saveLocale(locale.languageCode);
    emit(locale);
  }

  Future<void> _saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
}
