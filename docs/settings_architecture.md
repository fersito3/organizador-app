# Documentation: Settings & Preferences Architecture

**Project:** `organizador_app`  
**Philosophy:** Offline-First, Local-First, Privacy-First  

---

## 1. Executive Overview

The Settings architecture centralises all user configurable options in a single access layer while strictly respecting the project's data storage boundaries:

- **Non-sensitive user preferences** are persisted locally via `SharedPreferences`.
- **Sensitive credentials and secrets** (tokens, API keys, encryption keys) are persisted in hardware-backed encrypted storage via `SecureStorageService`.
- **No analytics or telemetry** are gathered or transmitted.

---

## 2. Storage Separation Matrix

| Configuration Category | Storage Mechanism | Example Keys | Encryption |
|---|---|---|---|
| **Appearance** (Theme Mode) | `SharedPreferences` | `pref_theme_mode` | Unencrypted |
| **Localization** (Language) | `SharedPreferences` | `pref_language` | Unencrypted |
| **Regional** (Currency, Date Format, First Day of Week) | `SharedPreferences` | `pref_currency`, `pref_date_format`, `pref_first_day_of_week` | Unencrypted |
| **Notifications & Alerts** (Master toggle, Spending alert, Reminders) | `SharedPreferences` | `pref_notifications_enabled`, `pref_daily_spending_alerts`, `pref_task_reminders` | Unencrypted |
| **Backup Meta** (Last backup date, include secrets toggle) | `SharedPreferences` | `pref_last_backup_date`, `pref_include_integrations_backup` | Unencrypted |
| **OAuth & API Credentials** | `SecureStorageService` | `mp_access_token`, `mp_refresh_token` | Android EncryptedSharedPreferences (AES-256) / iOS Keychain |
| **App Security & Encryption** | `SecureStorageService` | `user_pin_secret`, `backup_encryption_key` | Android EncryptedSharedPreferences / iOS Keychain |

---

## 3. Architecture Layers

```
                               ┌────────────────────────────────┐
                               │       SettingsScreen UI        │
                               └───────────────┬────────────────┘
                                               │
                                               ▼
                               ┌────────────────────────────────┐
                               │        SettingsProvider        │
                               │   (ChangeNotifier / State)     │
                               └───────────────┬────────────────┘
                                               │
                                               ▼
                               ┌────────────────────────────────┐
                               │       SettingsRepository       │
                               └───────┬────────────────┬───────┘
                                       │                │
                        ┌──────────────┘                └──────────────┐
                        ▼                                              ▼
          ┌───────────────────────────┐                  ┌───────────────────────────┐
          │     SharedPreferences     │                  │   SecureStorageService    │
          │ (Theme, Language, Toggles)│                  │ (Tokens, Secrets, Keys)   │
          └───────────────────────────┘                  └───────────────────────────┘
```

---

## 4. How Future Modules Should Integrate Preferences

1. **Adding a New Preference:**
   - Define the typed enum/field in `lib/core/settings/settings_model.dart`.
   - Add default value fallback in `SettingsRepository.loadSettings()`.
   - Add save method in `SettingsRepository` and provider method in `SettingsProvider`.

2. **Accessing Preferences in Widgets:**
   ```dart
   // Read theme mode or currency in any screen
   final settings = context.watch<SettingsProvider>();
   final currencySymbol = settings.currency.symbol;
   ```

3. **Updating Preferences:**
   ```dart
   context.read<SettingsProvider>().updateThemeMode(AppThemeMode.dark);
   ```
