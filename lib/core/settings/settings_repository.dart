import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/secure_storage_service.dart';
import 'settings_model.dart';

class SettingsRepository {
  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;

  SettingsRepository({
    required SharedPreferences prefs,
    required SecureStorageService secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage;

  // Preference Keys
  static const String keyThemeMode = 'pref_theme_mode';
  static const String keyLanguage = 'pref_language';
  static const String keyCurrency = 'pref_currency';
  static const String keyDateFormat = 'pref_date_format';
  static const String keyFirstDayOfWeek = 'pref_first_day_of_week';
  static const String keyNotificationsEnabled = 'pref_notifications_enabled';
  static const String keyDailySpendingAlerts = 'pref_daily_spending_alerts';
  static const String keyTaskReminders = 'pref_task_reminders';
  static const String keyBackupReminders = 'pref_backup_reminders';
  static const String keyLastBackupDate = 'pref_last_backup_date';
  static const String keyIncludeIntegrationsBackup = 'pref_include_integrations_backup';
  static const String keyHasCompletedOnboarding = 'pref_has_completed_onboarding';
  static const String keyExchangeRateUsd = 'pref_exchange_rate_usd';
  static const String keyExchangeRateEur = 'pref_exchange_rate_eur';

  /// Loads all settings from persistent storage with safe default fallbacks.
  AppSettings loadSettings() {
    try {
      final themeIndex = _prefs.getInt(keyThemeMode) ?? AppThemeMode.system.index;
      final langIndex = _prefs.getInt(keyLanguage) ?? AppLanguage.es.index;
      final currIndex = _prefs.getInt(keyCurrency) ?? AppCurrency.ars.index;
      final dateFormatIndex = _prefs.getInt(keyDateFormat) ?? AppDateFormat.ddmmyyyy.index;
      final firstDayIndex = _prefs.getInt(keyFirstDayOfWeek) ?? FirstDayOfWeek.monday.index;

      return AppSettings(
        themeMode: AppThemeMode.values[themeIndex.clamp(0, AppThemeMode.values.length - 1)],
        language: AppLanguage.values[langIndex.clamp(0, AppLanguage.values.length - 1)],
        currency: AppCurrency.values[currIndex.clamp(0, AppCurrency.values.length - 1)],
        dateFormat: AppDateFormat.values[dateFormatIndex.clamp(0, AppDateFormat.values.length - 1)],
        firstDayOfWeek: FirstDayOfWeek.values[firstDayIndex.clamp(0, FirstDayOfWeek.values.length - 1)],
        notificationsEnabled: _prefs.getBool(keyNotificationsEnabled) ?? true,
        dailySpendingAlertsEnabled: _prefs.getBool(keyDailySpendingAlerts) ?? true,
        taskRemindersEnabled: _prefs.getBool(keyTaskReminders) ?? true,
        backupRemindersEnabled: _prefs.getBool(keyBackupReminders) ?? true,
        lastBackupDate: _prefs.getString(keyLastBackupDate),
        includeIntegrationsInBackup: _prefs.getBool(keyIncludeIntegrationsBackup) ?? false,
        hasCompletedOnboarding: _prefs.getBool(keyHasCompletedOnboarding) ?? false,
        exchangeRateUsd: _prefs.getDouble(keyExchangeRateUsd) ?? 1200.0,
        exchangeRateEur: _prefs.getDouble(keyExchangeRateEur) ?? 1300.0,
      );
    } catch (e) {
      debugPrint('❌ [SettingsRepository] Error loading settings: $e. Returning default AppSettings.');
      return const AppSettings();
    }
  }

  Future<bool> saveExchangeRateUsd(double rate) async {
    return await _prefs.setDouble(keyExchangeRateUsd, rate);
  }

  Future<bool> saveExchangeRateEur(double rate) async {
    return await _prefs.setDouble(keyExchangeRateEur, rate);
  }


  Future<bool> saveHasCompletedOnboarding(bool completed) async {
    return await _prefs.setBool(keyHasCompletedOnboarding, completed);
  }

  Future<bool> saveThemeMode(AppThemeMode mode) async {
    return await _prefs.setInt(keyThemeMode, mode.index);
  }

  Future<bool> saveLanguage(AppLanguage lang) async {
    return await _prefs.setInt(keyLanguage, lang.index);
  }

  Future<bool> saveCurrency(AppCurrency currency) async {
    return await _prefs.setInt(keyCurrency, currency.index);
  }

  Future<bool> saveDateFormat(AppDateFormat format) async {
    return await _prefs.setInt(keyDateFormat, format.index);
  }

  Future<bool> saveFirstDayOfWeek(FirstDayOfWeek firstDay) async {
    return await _prefs.setInt(keyFirstDayOfWeek, firstDay.index);
  }

  Future<bool> saveNotificationPreferences({
    required bool notificationsEnabled,
    required bool dailySpendingAlertsEnabled,
    required bool taskRemindersEnabled,
  }) async {
    final a = await _prefs.setBool(keyNotificationsEnabled, notificationsEnabled);
    final b = await _prefs.setBool(keyDailySpendingAlerts, dailySpendingAlertsEnabled);
    final c = await _prefs.setBool(keyTaskReminders, taskRemindersEnabled);
    return a && b && c;
  }

  Future<bool> saveLastBackupDate(String dateIso) async {
    return await _prefs.setString(keyLastBackupDate, dateIso);
  }

  Future<bool> saveIncludeIntegrationsInBackup(bool value) async {
    return await _prefs.setBool(keyIncludeIntegrationsBackup, value);
  }

  /// Resets all preferences back to default values.
  Future<bool> resetSettings() async {
    return await _prefs.clear();
  }

  /// Clears user preferences and deletes secure storage values.
  Future<void> clearUserPreferences() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
