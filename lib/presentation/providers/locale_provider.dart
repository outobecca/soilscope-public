import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/l10n/app_localizations.dart';

part 'locale_provider.g.dart';

@riverpod
class AppLocale extends _$AppLocale {
  static const _key = 'selected_locale';

  @override
  Locale build() {
    // Load persisted locale if available, default to system
    _loadPersistedLocale();
    return const Locale('en');
  }

  Future<void> _loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }
}

@riverpod
AppLocalizations appLocalizations(Ref ref) {
  final locale = ref.watch(appLocaleProvider);
  return lookupAppLocalizations(locale);
}
