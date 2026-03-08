import 'package:event_planner/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageCodeKey = 'app_language_code';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  late final SharedPreferences _prefs;

  @override
  Locale build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _loadSavedLocale(_prefs);
  }

  static Locale _loadSavedLocale(SharedPreferences prefs) {
    final code = prefs.getString(_languageCodeKey);
    if (code == 'ne') {
      return const Locale('ne');
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    state = Locale(locale.languageCode);
    await _prefs.setString(_languageCodeKey, locale.languageCode);
  }
}
