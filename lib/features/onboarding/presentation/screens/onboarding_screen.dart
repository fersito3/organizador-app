import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/settings/settings_model.dart';
import '../../../../core/settings/settings_provider.dart';
import '../widgets/page_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR (SKIP BUTTON)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bienvenido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Saltar',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            // PAGE VIEW
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildWelcomePage(),
                  _buildPrivacyPage(),
                  _buildPersonalizationPage(),
                  _buildBackupPage(),
                  _buildNotificationsPage(),
                ],
              ),
            ),

            // FOOTER (INDICATOR & BUTTONS)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  OnboardingPageIndicator(
                    count: _totalPages,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: 20),
                  OnboardingPrimaryButton(
                    label: _currentPage == _totalPages - 1 ? 'Comenzar a usar la App' : 'Continuar',
                    icon: _currentPage == _totalPages - 1 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 1: WELCOME
  Widget _buildWelcomePage() {
    return _buildPageLayout(
      icon: Icons.space_dashboard_rounded,
      accentColor: const Color(0xFF0EA5E9),
      title: 'Organizá tu día a día',
      subtitle: 'Finanzas, calendario, tareas y notas personales en una sola aplicación rápida y elegante.',
      body: Column(
        children: [
          _buildFeatureTile(Icons.bar_chart_rounded, const Color(0xFF0EA5E9), 'Finanzas Inteligentes', 'Controlá tus ingresos y egresos de forma clara.'),
          const SizedBox(height: 12),
          _buildFeatureTile(Icons.calendar_today_rounded, const Color(0xFFF59E0B), 'Calendario & Tareas', 'Organizá entregas, parciales y eventos académicos.'),
          const SizedBox(height: 12),
          _buildFeatureTile(Icons.lightbulb_outline_rounded, const Color(0xFF6366F1), 'Espacio Personal', 'Guardá notas, listas de compras y objetivos.'),
        ],
      ),
    );
  }

  // PAGE 2: PRIVACY
  Widget _buildPrivacyPage() {
    return _buildPageLayout(
      icon: Icons.shield_outlined,
      accentColor: const Color(0xFF10B981),
      title: 'Tu información es tuya',
      subtitle: 'Diseñado bajo la filosofía Local-First. Todos tus datos viven guardados únicamente en tu dispositivo.',
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildPrivacyBullet(Icons.no_accounts_rounded, 'Sin cuenta obligatoria', 'Usá la aplicación inmediatamente sin registrarte.'),
            const Divider(height: 24),
            _buildPrivacyBullet(Icons.cloud_off_rounded, 'Sin nube obligatoria', 'No dependemos de servidores externos ni cobros mensuales.'),
            const Divider(height: 24),
            _buildPrivacyBullet(Icons.analytics_outlined, 'Sin analíticas ni rastreo', 'Tus hábitos de uso y gastos permanecen en privado.'),
          ],
        ),
      ),
    );
  }

  // PAGE 3: PERSONALIZATION
  Widget _buildPersonalizationPage() {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return _buildPageLayout(
      icon: Icons.tune_rounded,
      accentColor: const Color(0xFF8B5CF6),
      title: 'Personalizá tu experiencia',
      subtitle: 'Elegí tus preferencias iniciales. Podrás cambiarlas en cualquier momento.',
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined, color: Color(0xFF8B5CF6)),
              title: const Text('Tema Visual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: DropdownButton<AppThemeMode>(
                value: settings.themeMode,
                underline: const SizedBox(),
                onChanged: (val) {
                  if (val != null) settingsProvider.updateThemeMode(val);
                },
                items: AppThemeMode.values.map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode.label, style: const TextStyle(fontSize: 13)));
                }).toList(),
              ),
            ),
            const Divider(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_money_rounded, color: Color(0xFF10B981)),
              title: const Text('Moneda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              trailing: DropdownButton<AppCurrency>(
                value: settings.currency,
                underline: const SizedBox(),
                onChanged: (val) {
                  if (val != null) settingsProvider.updateCurrency(val);
                },
                items: AppCurrency.values.map((curr) {
                  return DropdownMenuItem(value: curr, child: Text(curr.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE 4: BACKUP INTRO
  Widget _buildBackupPage() {
    return _buildPageLayout(
      icon: Icons.lock_outline_rounded,
      accentColor: const Color(0xFF0EA5E9),
      title: 'Protegé tus datos',
      subtitle: 'Creá backups cifrados con contraseña y guardalos en tu Google Drive, pendrive o almacenamiento local.',
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: Color(0xFF0EA5E9), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los backups están encriptados con AES-256. Solo vos podés desbloquear tu información.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.routeBackup),
            icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF0EA5E9)),
            label: const Text('Crear un Backup ahora', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: const BorderSide(color: Color(0xFF0EA5E9)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 5: NOTIFICATIONS
  Widget _buildNotificationsPage() {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return _buildPageLayout(
      icon: Icons.notifications_active_outlined,
      accentColor: const Color(0xFFF59E0B),
      title: 'Recordatorios útiles',
      subtitle: 'Activá notificaciones locales para no olvidar entregas de tareas ni sobrepasar tu presupuesto.',
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Habilitar Notificaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Alertas locales en tu dispositivo.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              value: settings.notificationsEnabled,
              onChanged: (val) => settingsProvider.toggleNotifications(val),
            ),
            if (settings.notificationsEnabled) ...[
              const Divider(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alerta de Gasto Diario', style: TextStyle(fontSize: 13)),
                value: settings.dailySpendingAlertsEnabled,
                onChanged: (val) => settingsProvider.toggleDailySpendingAlerts(val),
              ),
              const Divider(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recordatorio de Tareas', style: TextStyle(fontSize: 13)),
                value: settings.taskRemindersEnabled,
                onChanged: (val) => settingsProvider.toggleTaskReminders(val),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageLayout({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required Widget body,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: accentColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          body,
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBullet(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
              Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}
