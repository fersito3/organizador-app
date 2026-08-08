import 'package:flutter/material.dart';


class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'settings_title': 'Configuración',
      'general': 'General',
      'language': 'Idioma',
      'currency': 'Moneda Principal',
      'date_format': 'Formato de Fecha',
      'first_day_of_week': 'Primer Día de la Semana',
      'appearance': 'Apariencia',
      'visual_theme': 'Tema Visual',
      'notifications': 'Notificaciones & Recordatorios',
      'enable_notifications': 'Recibir Alertas y Recordatorios',
      'enable_notifications_sub': 'Habilita recordatorios locales y alertas de límite de gasto.',
      'daily_spending_alert': 'Alerta de Límite de Gasto Diario',
      'daily_spending_alert_sub': 'Aviso cuando alcanzás tu presupuesto recomendado.',
      'task_reminders': 'Recordatorio de Tareas y Parciales',
      'task_reminders_sub': 'Aviso sobre próximos vencimientos.',
      'test_notification': 'Probar Notificación',
      'test_notification_sub': 'Envía una notificación de prueba inmediata a tu dispositivo.',
      'test_notification_sent': 'Notificación de prueba enviada con éxito.',
      'backups_data': 'Backups & Propiedad de Datos',
      'manage_backups': 'Gestión de Backups Encriptados',
      'integrations': 'Integraciones Externas',
      'privacy': 'Privacidad por Diseño',
      'privacy_desc': 'Esta aplicación no recopila ni transmite analíticas, telemetría ni datos personales. Toda tu información vive exclusivamente en este dispositivo.',
      'home': 'Inicio',
      'expenses': 'Movimientos',
      'calendar': 'Calendario',
      'stats': 'Estadísticas',
      'personal': 'Personal',
      'financial_summary': 'Resumen Financiero',
      'financial_health': 'Insights y Salud Financiera',
      'tasks_and_evaluations': 'Tareas & Evaluaciones',
      'agenda_of_day': 'Agenda del Día',
      'weekly_schedule': 'Horario Semanal',
      'monthly_schedule': 'Vista Mensual',
      'known_contacts': 'Tarjetas de Contactos',
      'exchange_rate_usd': r'Cotización USD ($ ARS por 1 USD)',
      'exchange_rate_eur': r'Cotización EUR ($ ARS por 1 EUR)',
      'balance_general': 'Balance General',
      'this_month': 'Este Mes',
      'income': 'Ingresos',
      'expenses_total': 'Gastos',
      'quick_access': 'Acceso Rápido',
      'search_placeholder': 'Buscar...',
    },
    'en': {
      'settings_title': 'Settings',
      'general': 'General',
      'language': 'Language',
      'currency': 'Main Currency',
      'date_format': 'Date Format',
      'first_day_of_week': 'First Day of Week',
      'appearance': 'Appearance',
      'visual_theme': 'Visual Theme',
      'notifications': 'Notifications & Reminders',
      'enable_notifications': 'Receive Alerts & Reminders',
      'enable_notifications_sub': 'Enables local reminders and spending limit alerts.',
      'daily_spending_alert': 'Daily Spending Limit Alert',
      'daily_spending_alert_sub': 'Get notified when approaching your recommended budget.',
      'task_reminders': 'Task & Exam Reminders',
      'task_reminders_sub': 'Notice about upcoming deadlines.',
      'test_notification': 'Test Notification',
      'test_notification_sub': 'Sends an immediate test notification to your device.',
      'test_notification_sent': 'Test notification sent successfully.',
      'backups_data': 'Backups & Data Ownership',
      'manage_backups': 'Encrypted Backup Management',
      'integrations': 'External Integrations',
      'privacy': 'Privacy by Design',
      'privacy_desc': 'This application does not collect or transmit analytics, telemetry, or personal data. All your data lives exclusively on this device.',
      'home': 'Home',
      'expenses': 'Transactions',
      'calendar': 'Calendar',
      'stats': 'Statistics',
      'personal': 'Personal Space',
      'financial_summary': 'Financial Summary',
      'financial_health': 'Insights & Financial Health',
      'tasks_and_evaluations': 'Tasks & Exams',
      'agenda_of_day': 'Daily Agenda',
      'weekly_schedule': 'Weekly View',
      'monthly_schedule': 'Monthly View',
      'known_contacts': 'Contact Cards',
      'exchange_rate_usd': r'USD Exchange Rate ($ ARS per 1 USD)',
      'exchange_rate_eur': r'EUR Exchange Rate ($ ARS per 1 EUR)',

      'balance_general': 'General Balance',
      'this_month': 'This Month',
      'income': 'Income',
      'expenses_total': 'Expenses',
      'quick_access': 'Quick Access',
      'search_placeholder': 'Search...',
    },

  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['es']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
