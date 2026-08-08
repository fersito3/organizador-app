import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_routes.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/enums.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';
import '../../../calendar/presentation/controllers/calendar_notifier.dart';
import '../../../tasks/presentation/controllers/tasks_notifier.dart';


class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildFinancialCard(context),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Funcionalidades',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.25,
                      children: [
                        _buildMenuCard(
                          context: context,
                          title: 'Finanzas',
                          subtitle: 'Estadisticas y resumen',
                          icon: Icons.bar_chart_rounded,
                          startColor: const Color(0xFF0EA5E9),
                          endColor: const Color(0xFF2563EB),
                          route: AppRoutes.routeStats,
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Espacio Personal',
                          subtitle: 'Notas, Listas y Objetivos',
                          icon: Icons.lightbulb_outline_rounded,
                          startColor: const Color(0xFF6366F1), // Indigo
                          endColor: const Color(0xFF4338CA),
                          route: AppRoutes.routePersonalSpace,
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Calendario',
                          subtitle: 'Clases y Horarios',
                          icon: Icons.calendar_today_rounded,
                          startColor: const Color(0xFFF59E0B), // Anaranjado
                          endColor: const Color(0xFFD97706),
                          route: AppRoutes.routeCalendar,
                          arguments: 0,
                        ),
                        _buildMenuCard(
                          context: context,
                          title: 'Movimientos',
                          subtitle: 'Gastos e Ingresos',
                          icon: Icons.receipt_long_rounded,
                          startColor: const Color(0xFF10B981),
                          endColor: const Color(0xFF047857),
                          route: AppRoutes.routeExpenses,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildAgendaSection(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final formattedDate = '$dayName, ${now.day} de $monthName';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Hola, Fer! 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.shield_outlined, color: Color(0xFF64748B), size: 26),
                tooltip: 'Backups & Propiedad de Datos',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.routeBackup),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B), size: 26),
                tooltip: 'Configuración',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.routeSettings),
              ),
              const SizedBox(width: 4),
              const AppLogo(size: 44),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = settingsProvider.currency;
    final rateUsd = settingsProvider.exchangeRateUsd;
    final rateEur = settingsProvider.exchangeRateEur;

    return Consumer<ExpensesNotifier>(
      builder: (context, notifier, child) {
        final balance = notifier.balance;
        final ingresos = notifier.totalIngresos;
        final egresos = notifier.totalEgresos;
        final esNegativo = balance < 0;
        final oculto = notifier.ocultarSaldos;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('balance_general'),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, size: 14, color: Colors.greenAccent),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('this_month'),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => notifier.toggleOcultarSaldos(),
                        child: Icon(
                          oculto ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: const Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                oculto
                    ? '••••'
                    : AppFormatters.formatCurrency(
                        balance,
                        currency,
                        exchangeRateUsd: rateUsd,
                        exchangeRateEur: rateEur,
                        showSign: true,
                      ),
                style: TextStyle(
                  color: oculto
                      ? const Color(0xFF64748B)
                      : (esNegativo ? const Color(0xFFF87171) : Colors.white),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF34D399), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('income'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              oculto
                                  ? '••••'
                                  : AppFormatters.formatCurrency(
                                      ingresos,
                                      currency,
                                      exchangeRateUsd: rateUsd,
                                      exchangeRateEur: rateEur,
                                    ),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 35, width: 1, color: const Color(0xFF334155)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFFF87171), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('expenses_total'), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              oculto
                                  ? '••••'
                                  : AppFormatters.formatCurrency(
                                      egresos,
                                      currency,
                                      exchangeRateUsd: rateUsd,
                                      exchangeRateEur: rateEur,
                                    ),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required String route,
    Object? arguments,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaSection(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Consumer2<CalendarNotifier, TasksNotifier>(
      builder: (context, calNotifier, tasksNotifier, child) {
        // Eventos de hoy: exacta (mismo día) o recurrente semanal (mismo weekday)
        final eventosHoy = calNotifier.eventos.where((e) {
          final mismodia = e.fechaInicio.year == now.year &&
              e.fechaInicio.month == now.month &&
              e.fechaInicio.day == now.day;
          final recurrente = e.esRecurrente && e.fechaInicio.weekday == now.weekday;
          return mismodia || recurrente;
        }).toList()
          ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

        // Tareas de hoy pendientes
        final tareasHoy = tasksNotifier.tareas.where((t) {
          return !t.completada &&
              t.fecha.year == now.year &&
              t.fecha.month == now.month &&
              t.fecha.day == now.day;
        }).toList();

        final total = eventosHoy.length + tareasHoy.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agenda de Hoy${total > 0 ? ' ($total)' : ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.routeCalendar),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (total == 0)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: const [
                    Icon(Icons.event_available_rounded, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 12),
                    Text(
                      '¡Todo al día por hoy!',
                      style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No hay clases, eventos ni tareas para hoy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // EVENTOS
                  ...eventosHoy.map((e) {
                    final color = _parseColorHex(e.colorHex);
                    final horaStr =
                        '${e.fechaInicio.hour.toString().padLeft(2, '0')}:${e.fechaInicio.minute.toString().padLeft(2, '0')} - '
                        '${e.fechaFin.hour.toString().padLeft(2, '0')}:${e.fechaFin.minute.toString().padLeft(2, '0')}';
                    return _agendaItem(
                      context,
                      titulo: e.titulo,
                      subtitulo: e.descripcion,
                      chip: horaStr,
                      color: color,
                      icon: Icons.schedule_rounded,
                    );
                  }),
                  // TAREAS
                  ...tareasHoy.map((t) {
                    const tipoColors = {
                      TipoTarea.parcial: Color(0xFFEF4444),
                      TipoTarea.entrega: Color(0xFFF59E0B),
                      TipoTarea.TP: Color(0xFF0EA5E9),
                      TipoTarea.estudio: Color(0xFF10B981),
                      TipoTarea.deudas: Color(0xFF6366F1),
                      TipoTarea.otro: Color(0xFF64748B),
                    };
                    final color = tipoColors[t.tipo] ?? const Color(0xFF64748B);
                    final tipoLabel = t.tipo.name[0].toUpperCase() + t.tipo.name.substring(1);
                    return GestureDetector(
                      onTap: () => tasksNotifier.toggleCompletada(t),
                      child: _agendaItem(
                        context,
                        titulo: t.titulo,
                        subtitulo: t.descripcion,
                        chip: tipoLabel,
                        color: color,
                        icon: Icons.check_circle_outline_rounded,
                        trailing: Checkbox(
                          value: t.completada,
                          onChanged: (_) => tasksNotifier.toggleCompletada(t),
                          activeColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
          ],
        );
      },
    );
  }

  static Color _parseColorHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFF59E0B);
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      } else if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFF59E0B);
  }

  Widget _agendaItem(
    BuildContext context, {
    required String titulo,
    required String? subtitulo,
    required String chip,
    required Color color,
    required IconData icon,
    Widget? trailing,
  }) {
    final cardBg = Theme.of(context).cardColor;
    final primaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryTextColor)),
                if (subtitulo != null && subtitulo.isNotEmpty)
                  Text(subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (trailing != null)
            trailing
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(chip,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
        ],
      ),
    );
  }
}
