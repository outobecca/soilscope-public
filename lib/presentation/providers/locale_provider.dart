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
    // Prefer the device language when the app ships translations for it.
    _loadPersistedLocale();
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final isSupported = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );
    return isSupported ? Locale(systemLocale.languageCode) : const Locale('en');
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
