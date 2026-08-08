import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:organizador_app/core/security/secure_storage_service.dart';
import 'package:organizador_app/core/settings/settings_model.dart';
import 'package:organizador_app/core/settings/settings_provider.dart';
import 'package:organizador_app/core/settings/settings_repository.dart';

import '../security/secure_storage_service_test.dart';

void main() {
  group('SettingsRepository & SettingsProvider Unit Tests', () {
    late SharedPreferences prefs;
    late SecureStorageService secureStorage;
    late SettingsRepository repository;
    late SettingsProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      secureStorage = SecureStorageService(storage: FakeFlutterSecureStorage());
      repository = SettingsRepository(prefs: prefs, secureStorage: secureStorage);
      provider = SettingsProvider(repository);
    });

    test('Initial settings return safe defaults', () {
      final settings = provider.settings;

      expect(settings.themeMode, equals(AppThemeMode.system));
      expect(settings.language, equals(AppLanguage.es));
      expect(settings.currency, equals(AppCurrency.ars));
      expect(settings.dateFormat, equals(AppDateFormat.ddmmyyyy));
      expect(settings.firstDayOfWeek, equals(FirstDayOfWeek.monday));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.dailySpendingAlertsEnabled, isTrue);
      expect(settings.taskRemindersEnabled, isTrue);
      expect(settings.lastBackupDate, isNull);
    });

    test('Updating ThemeMode persists value and notifies listeners', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.updateThemeMode(AppThemeMode.dark);

      expect(provider.themeMode, equals(AppThemeMode.dark));
      expect(notifyCount, equals(1));

      // Verify persistence across repository reload
      final reloadedRepository = SettingsRepository(prefs: prefs, secureStorage: secureStorage);
      final reloadedSettings = reloadedRepository.loadSettings();
      expect(reloadedSettings.themeMode, equals(AppThemeMode.dark));
    });

    test('Updating Language persists value', () async {
      await provider.updateLanguage(AppLanguage.en);

      expect(provider.language, equals(AppLanguage.en));

      final reloadedSettings = repository.loadSettings();
      expect(reloadedSettings.language, equals(AppLanguage.en));
    });

    test('Updating Currency and DateFormat persists correctly', () async {
      await provider.updateCurrency(AppCurrency.usd);
      await provider.updateDateFormat(AppDateFormat.yyyymmdd);

      expect(provider.currency, equals(AppCurrency.usd));
      expect(provider.dateFormat, equals(AppDateFormat.yyyymmdd));

      final reloadedSettings = repository.loadSettings();
      expect(reloadedSettings.currency, equals(AppCurrency.usd));
      expect(reloadedSettings.dateFormat, equals(AppDateFormat.yyyymmdd));
    });

    test('Toggling Notification preferences updates state and persists', () async {
      await provider.toggleNotifications(false);

      expect(provider.notificationsEnabled, isFalse);
      expect(provider.dailySpendingAlertsEnabled, isFalse);
      expect(provider.taskRemindersEnabled, isFalse);

      final reloadedSettings = repository.loadSettings();
      expect(reloadedSettings.notificationsEnabled, isFalse);
    });

    test('Resetting to defaults clears preferences', () async {
      await provider.updateThemeMode(AppThemeMode.light);
      await provider.updateCurrency(AppCurrency.eur);

      expect(provider.themeMode, equals(AppThemeMode.light));

      await provider.resetToDefaults();

      expect(provider.themeMode, equals(AppThemeMode.system));
      expect(provider.currency, equals(AppCurrency.ars));
    });
  });
}
