import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'Seguir sistema';
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
    }
  }
}

enum AppLanguage {
  es,
  en;

  String get label {
    switch (this) {
      case AppLanguage.es:
        return 'Español';
      case AppLanguage.en:
        return 'English';
    }
  }
}

enum AppCurrency {
  ars,
  usd,
  eur;

  String get symbol {
    switch (this) {
      case AppCurrency.ars:
      case AppCurrency.usd:
        return '\$';
      case AppCurrency.eur:
        return '€';
    }
  }

  String get code {
    switch (this) {
      case AppCurrency.ars:
        return 'ARS';
      case AppCurrency.usd:
        return 'USD';
      case AppCurrency.eur:
        return 'EUR';
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.ars:
        return 'Peso Argentino (ARS)';
      case AppCurrency.usd:
        return 'Dólar Estadounidense (USD)';
      case AppCurrency.eur:
        return 'Euro (EUR)';
    }
  }
}

enum AppDateFormat {
  ddmmyyyy,
  mmddyyyy,
  yyyymmdd;

  String get label {
    switch (this) {
      case AppDateFormat.ddmmyyyy:
        return 'DD/MM/YYYY (31/12/2026)';
      case AppDateFormat.mmddyyyy:
        return 'MM/DD/YYYY (12/31/2026)';
      case AppDateFormat.yyyymmdd:
        return 'YYYY-MM-DD (2026-12-31)';
    }
  }
}

enum FirstDayOfWeek {
  monday,
  sunday;

  String get label {
    switch (this) {
      case FirstDayOfWeek.monday:
        return 'Lunes';
      case FirstDayOfWeek.sunday:
        return 'Domingo';
    }
  }
}

/// Immutable data model containing all user configuration preferences.
class AppSettings {
  final AppThemeMode themeMode;
  final AppLanguage language;
  final AppCurrency currency;
  final AppDateFormat dateFormat;
  final FirstDayOfWeek firstDayOfWeek;
  final bool notificationsEnabled;
  final bool dailySpendingAlertsEnabled;
  final bool taskRemindersEnabled;
  final bool backupRemindersEnabled;
  final String? lastBackupDate;
  final bool includeIntegrationsInBackup;
  final bool hasCompletedOnboarding;
  final double exchangeRateUsd;
  final double exchangeRateEur;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.es,
    this.currency = AppCurrency.ars,
    this.dateFormat = AppDateFormat.ddmmyyyy,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
    this.notificationsEnabled = true,
    this.dailySpendingAlertsEnabled = true,
    this.taskRemindersEnabled = true,
    this.backupRemindersEnabled = true,
    this.lastBackupDate,
    this.includeIntegrationsInBackup = false,
    this.hasCompletedOnboarding = false,
    this.exchangeRateUsd = 1200.0,
    this.exchangeRateEur = 1300.0,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    AppCurrency? currency,
    AppDateFormat? dateFormat,
    FirstDayOfWeek? firstDayOfWeek,
    bool? notificationsEnabled,
    bool? dailySpendingAlertsEnabled,
    bool? taskRemindersEnabled,
    bool? backupRemindersEnabled,
    String? lastBackupDate,
    bool? includeIntegrationsInBackup,
    bool? hasCompletedOnboarding,
    double? exchangeRateUsd,
    double? exchangeRateEur,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailySpendingAlertsEnabled: dailySpendingAlertsEnabled ?? this.dailySpendingAlertsEnabled,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      backupRemindersEnabled: backupRemindersEnabled ?? this.backupRemindersEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      includeIntegrationsInBackup: includeIntegrationsInBackup ?? this.includeIntegrationsInBackup,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      exchangeRateUsd: exchangeRateUsd ?? this.exchangeRateUsd,
      exchangeRateEur: exchangeRateEur ?? this.exchangeRateEur,
    );
  }

}
