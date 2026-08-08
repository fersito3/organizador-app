import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:organizador_app/core/security/secure_storage_service.dart';
import 'package:organizador_app/core/settings/settings_provider.dart';
import 'package:organizador_app/core/settings/settings_repository.dart';

import '../security/secure_storage_service_test.dart';

void main() {
  group('Onboarding First Launch Unit Tests', () {
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

    test('First installation defaults hasCompletedOnboarding to false', () {
      expect(provider.hasCompletedOnboarding, isFalse);
    });

    test('Completing onboarding sets flag to true and persists across reloads', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.completeOnboarding();

      expect(provider.hasCompletedOnboarding, isTrue);
      expect(notifyCount, equals(1));

      final reloadedRepository = SettingsRepository(prefs: prefs, secureStorage: secureStorage);
      final reloadedSettings = reloadedRepository.loadSettings();
      expect(reloadedSettings.hasCompletedOnboarding, isTrue);
    });

    test('Resetting onboarding sets flag back to false', () async {
      await provider.completeOnboarding();
      expect(provider.hasCompletedOnboarding, isTrue);

      await provider.resetOnboarding();
      expect(provider.hasCompletedOnboarding, isFalse);

      final reloadedSettings = repository.loadSettings();
      expect(reloadedSettings.hasCompletedOnboarding, isFalse);
    });
  });
}
