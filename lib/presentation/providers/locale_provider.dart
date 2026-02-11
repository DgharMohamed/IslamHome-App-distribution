import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Initial load side-effect
    _loadLocale();
    return const Locale('ar');
  }

  Future<void> _loadLocale() async {
    final box = await Hive.openBox('settings');
    final String? languageCode = box.get('language');
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final box = await Hive.openBox('settings');
    await box.put('language', locale.languageCode);
    state = locale;
  }
}
