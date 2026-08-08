import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/notifications/notification_types.dart';
import '../../../../core/settings/settings_model.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final cardColor = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    final notificationService = context.read<NotificationService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('settings_title'),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;

          return SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              children: [
                // 1. SECCIÓN GENERAL
                _buildSectionTitle(context, context.tr('general')),
                _buildCardContainer(context, [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: Color(0xFF0EA5E9)),
                    title: Text(context.tr('language'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(settings.language.label, style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: DropdownButton<AppLanguage>(
                      value: settings.language,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) settingsProvider.updateLanguage(val);
                      },
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang.label, style: TextStyle(fontSize: 13, color: textPrimary)),
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(height: 1, color: AppColors.borderColor(context)),
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded, color: Color(0xFF10B981)),
                    title: Text(context.tr('currency'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(settings.currency.label, style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: DropdownButton<AppCurrency>(
                      value: settings.currency,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) settingsProvider.updateCurrency(val);
                      },
                      items: AppCurrency.values.map((curr) {
                        return DropdownMenuItem(
                          value: curr,
                          child: Text(curr.code, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                        );
                      }).toList(),
                    ),
                  ),
                  if (settings.currency == AppCurrency.usd) ...[
                    Divider(height: 1, color: AppColors.borderColor(context)),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded, color: Color(0xFF0EA5E9)),
                      title: Text(context.tr('exchange_rate_usd'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                      subtitle: Text('\$${settings.exchangeRateUsd.toStringAsFixed(2)} ARS = 1 USD', style: TextStyle(fontSize: 12, color: textSecondary)),
                      trailing: Icon(Icons.edit_rounded, size: 18, color: textSecondary),
                      onTap: () => _mostrarDialogoCotizacion(context, 'USD', settings.exchangeRateUsd, (val) => settingsProvider.updateExchangeRateUsd(val)),
                    ),
                  ],
                  if (settings.currency == AppCurrency.eur) ...[
                    Divider(height: 1, color: AppColors.borderColor(context)),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded, color: Color(0xFF8B5CF6)),
                      title: Text(context.tr('exchange_rate_eur'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                      subtitle: Text('\$${settings.exchangeRateEur.toStringAsFixed(2)} ARS = 1 EUR', style: TextStyle(fontSize: 12, color: textSecondary)),
                      trailing: Icon(Icons.edit_rounded, size: 18, color: textSecondary),
                      onTap: () => _mostrarDialogoCotizacion(context, 'EUR', settings.exchangeRateEur, (val) => settingsProvider.updateExchangeRateEur(val)),
                    ),
                  ],

                  Divider(height: 1, color: AppColors.borderColor(context)),
                  ListTile(
                    leading: const Icon(Icons.date_range_rounded, color: Color(0xFF6366F1)),
                    title: Text(context.tr('date_format'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(settings.dateFormat.label, style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: DropdownButton<AppDateFormat>(
                      value: settings.dateFormat,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) settingsProvider.updateDateFormat(val);
                      },
                      items: AppDateFormat.values.map((fmt) {
                        return DropdownMenuItem(
                          value: fmt,
                          child: Text(fmt.name.toUpperCase(), style: TextStyle(fontSize: 12, color: textPrimary)),
                        );
                      }).toList(),
                    ),
                  ),
                  Divider(height: 1, color: AppColors.borderColor(context)),
                  ListTile(
                    leading: const Icon(Icons.today_rounded, color: Color(0xFFF59E0B)),
                    title: Text(context.tr('first_day_of_week'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(settings.firstDayOfWeek.label, style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: DropdownButton<FirstDayOfWeek>(
                      value: settings.firstDayOfWeek,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) settingsProvider.updateFirstDayOfWeek(val);
                      },
                      items: FirstDayOfWeek.values.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day.label, style: TextStyle(fontSize: 13, color: textPrimary)),
                        );
                      }).toList(),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // 2. SECCIÓN APARIENCIA
                _buildSectionTitle(context, context.tr('appearance')),
                _buildCardContainer(context, [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: Color(0xFF8B5CF6)),
                    title: Text(context.tr('visual_theme'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(settings.themeMode.label, style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: DropdownButton<AppThemeMode>(
                      value: settings.themeMode,
                      dropdownColor: cardColor,
                      underline: const SizedBox(),
                      onChanged: (val) {
                        if (val != null) settingsProvider.updateThemeMode(val);
                      },
                      items: AppThemeMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.label, style: TextStyle(fontSize: 13, color: textPrimary)),
                        );
                      }).toList(),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // 3. SECCIÓN NOTIFICACIONES
                _buildSectionTitle(context, context.tr('notifications')),
                _buildCardContainer(context, [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF0EA5E9)),
                    title: Text(context.tr('enable_notifications'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(context.tr('enable_notifications_sub'), style: TextStyle(fontSize: 12, color: textSecondary)),
                    value: settings.notificationsEnabled,
                    onChanged: (val) async {
                      final success = await settingsProvider.toggleNotifications(val, notificationService: notificationService);
                      if (!success && val && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Permiso de notificaciones denegado en el sistema.')),
                        );
                      }
                    },
                  ),
                  if (settings.notificationsEnabled) ...[
                    Divider(height: 1, color: AppColors.borderColor(context)),
                    SwitchListTile(
                      secondary: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF10B981)),
                      title: Text(context.tr('daily_spending_alert'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                      subtitle: Text(context.tr('daily_spending_alert_sub'), style: TextStyle(fontSize: 11, color: textSecondary)),
                      value: settings.dailySpendingAlertsEnabled,
                      onChanged: (val) => settingsProvider.toggleDailySpendingAlerts(val),
                    ),
                    Divider(height: 1, color: AppColors.borderColor(context)),
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm_on_rounded, color: Color(0xFFF59E0B)),
                      title: Text(context.tr('task_reminders'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                      subtitle: Text(context.tr('task_reminders_sub'), style: TextStyle(fontSize: 11, color: textSecondary)),
                      value: settings.taskRemindersEnabled,
                      onChanged: (val) => settingsProvider.toggleTaskReminders(val),
                    ),
                    Divider(height: 1, color: AppColors.borderColor(context)),
                    ListTile(
                      leading: const Icon(Icons.notification_add_rounded, color: Color(0xFF8B5CF6)),
                      title: Text(context.tr('test_notification'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                      subtitle: Text(context.tr('test_notification_sub'), style: TextStyle(fontSize: 12, color: textSecondary)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          await notificationService.showNotification(
                            id: 9999,
                            title: '🔔 Probar Notificación',
                            body: '¡Excelente! Las notificaciones y recordatorios locales funcionan correctamente en tu dispositivo.',
                            category: NotificationCategory.personal,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('test_notification_sent')),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Probar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 24),

                // 4. SECCIÓN BACKUP Y DATOS
                _buildSectionTitle(context, context.tr('backups_data')),
                _buildCardContainer(context, [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: Color(0xFF10B981)),
                    title: Text(context.tr('manage_backups'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(
                      settings.lastBackupDate != null
                          ? 'Último backup: ${settings.lastBackupDate}'
                          : 'Crea copias de seguridad portátiles cifradas',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.routeBackup),
                  ),
                  Divider(height: 1, color: AppColors.borderColor(context)),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF0EA5E9)),
                    title: Text('Ver Tutorial de Bienvenida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text('Revisá la guía inicial y la explicación de privacidad.', style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.routeOnboarding),
                  ),
                ]),
                const SizedBox(height: 24),

                // 5. SECCIÓN INTEGRACIONES
                _buildSectionTitle(context, context.tr('integrations')),
                _buildCardContainer(context, [
                  ListTile(
                    leading: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF009EE3)),
                    title: Text('Mercado Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                    subtitle: Text(
                      'Conectá tu cuenta de Mercado Pago para importar movimientos automáticamente.',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSubSurface : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Próximamente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // 6. SECCIÓN PRIVACIDAD & SEGURIDAD INFO
                _buildCardContainer(context, [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_rounded, color: textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('privacy'),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('privacy_desc'),
                          style: TextStyle(fontSize: 11, color: textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textSecondary = AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildCardContainer(BuildContext context, List<Widget> children) {
    final cardColor = AppColors.cardBackground(context);
    final borderColor = AppColors.borderColor(context);
    final isDark = AppColors.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: borderColor, width: 1) : null,
        boxShadow: isDark
            ? []
            : const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  void _mostrarDialogoCotizacion(
    BuildContext context,
    String moneda,
    double valorActual,
    Function(double) onGuardar,
  ) {
    final controller = TextEditingController(text: valorActual.toStringAsFixed(2));
    final isDark = AppColors.isDarkMode(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground(context),
          title: Text(
            'Cotización de $moneda',
            style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresa el valor de 1 $moneda en Pesos Argentinos (ARS):',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                  suffixText: 'ARS',
                  filled: true,
                  fillColor: AppColors.subSurface(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDark ? BorderSide(color: AppColors.borderColor(context)) : BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final nuevoValor = double.tryParse(controller.text.replaceAll(',', '.'));
                if (nuevoValor != null && nuevoValor > 0) {
                  onGuardar(nuevoValor);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

