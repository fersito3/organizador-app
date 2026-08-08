import 'package:flutter/material.dart';
import '../notifications/notification_service.dart';
import 'settings_model.dart';
import 'settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  late AppSettings _settings;

  SettingsProvider(this._repository) {
    _settings = _repository.loadSettings();
  }

  AppSettings get settings => _settings;

  AppThemeMode get themeMode => _settings.themeMode;
  AppLanguage get language => _settings.language;
  AppCurrency get currency => _settings.currency;
  AppDateFormat get dateFormat => _settings.dateFormat;
  FirstDayOfWeek get firstDayOfWeek => _settings.firstDayOfWeek;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get dailySpendingAlertsEnabled => _settings.dailySpendingAlertsEnabled;
  bool get taskRemindersEnabled => _settings.taskRemindersEnabled;
  bool get backupRemindersEnabled => _settings.backupRemindersEnabled;
  String? get lastBackupDate => _settings.lastBackupDate;
  bool get includeIntegrationsInBackup => _settings.includeIntegrationsInBackup;
  bool get hasCompletedOnboarding => _settings.hasCompletedOnboarding;

  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(hasCompletedOnboarding: true);
    notifyListeners();
    await _repository.saveHasCompletedOnboarding(true);
  }

  Future<void> resetOnboarding() async {
    _settings = _settings.copyWith(hasCompletedOnboarding: false);
    notifyListeners();
    await _repository.saveHasCompletedOnboarding(false);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    if (_settings.themeMode == mode) return;
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _repository.saveThemeMode(mode);
  }

  Future<void> updateLanguage(AppLanguage lang) async {
    if (_settings.language == lang) return;
    _settings = _settings.copyWith(language: lang);
    notifyListeners();
    await _repository.saveLanguage(lang);
  }

  Future<void> updateCurrency(AppCurrency currency) async {
    if (_settings.currency == currency) return;
    _settings = _settings.copyWith(currency: currency);
    notifyListeners();
    await _repository.saveCurrency(currency);
  }

  Future<void> updateDateFormat(AppDateFormat format) async {
    if (_settings.dateFormat == format) return;
    _settings = _settings.copyWith(dateFormat: format);
    notifyListeners();
    await _repository.saveDateFormat(format);
  }

  double get exchangeRateUsd => _settings.exchangeRateUsd;
  double get exchangeRateEur => _settings.exchangeRateEur;

  Future<void> updateExchangeRateUsd(double rate) async {
    if (_settings.exchangeRateUsd == rate || rate <= 0) return;
    _settings = _settings.copyWith(exchangeRateUsd: rate);
    notifyListeners();
    await _repository.saveExchangeRateUsd(rate);
  }

  Future<void> updateExchangeRateEur(double rate) async {
    if (_settings.exchangeRateEur == rate || rate <= 0) return;
    _settings = _settings.copyWith(exchangeRateEur: rate);
    notifyListeners();
    await _repository.saveExchangeRateEur(rate);
  }

  Future<void> updateFirstDayOfWeek(FirstDayOfWeek firstDay) async {
    if (_settings.firstDayOfWeek == firstDay) return;
    _settings = _settings.copyWith(firstDayOfWeek: firstDay);
    notifyListeners();
    await _repository.saveFirstDayOfWeek(firstDay);
  }


  Future<bool> toggleNotifications(bool enabled, {NotificationService? notificationService}) async {
    if (enabled && notificationService != null) {
      final granted = await notificationService.requestPermissions();
      if (!granted) {
        // Si el usuario rechaza los permisos nativos, no activamos la preferencia
        return false;
      }
    }

    _settings = _settings.copyWith(
      notificationsEnabled: enabled,
      dailySpendingAlertsEnabled: enabled ? true : false,
      taskRemindersEnabled: enabled ? true : false,
    );
    notifyListeners();
    await _repository.saveNotificationPreferences(
      notificationsEnabled: _settings.notificationsEnabled,
      dailySpendingAlertsEnabled: _settings.dailySpendingAlertsEnabled,
      taskRemindersEnabled: _settings.taskRemindersEnabled,
    );
    return true;
  }

  Future<void> toggleDailySpendingAlerts(bool enabled) async {
    _settings = _settings.copyWith(dailySpendingAlertsEnabled: enabled);
    notifyListeners();
    await _repository.saveNotificationPreferences(
      notificationsEnabled: _settings.notificationsEnabled,
      dailySpendingAlertsEnabled: _settings.dailySpendingAlertsEnabled,
      taskRemindersEnabled: _settings.taskRemindersEnabled,
    );
  }

  Future<void> toggleTaskReminders(bool enabled) async {
    _settings = _settings.copyWith(taskRemindersEnabled: enabled);
    notifyListeners();
    await _repository.saveNotificationPreferences(
      notificationsEnabled: _settings.notificationsEnabled,
      dailySpendingAlertsEnabled: _settings.dailySpendingAlertsEnabled,
      taskRemindersEnabled: _settings.taskRemindersEnabled,
    );
  }

  Future<void> updateLastBackupDate(String dateIso) async {
    _settings = _settings.copyWith(lastBackupDate: dateIso);
    notifyListeners();
    await _repository.saveLastBackupDate(dateIso);
  }

  Future<void> toggleIncludeIntegrationsInBackup(bool value) async {
    _settings = _settings.copyWith(includeIntegrationsInBackup: value);
    notifyListeners();
    await _repository.saveIncludeIntegrationsInBackup(value);
  }

  Future<void> resetToDefaults() async {
    _settings = const AppSettings();
    notifyListeners();
    await _repository.resetSettings();
  }
}
