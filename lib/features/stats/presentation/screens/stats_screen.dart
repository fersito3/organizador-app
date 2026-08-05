import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/enums.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';
import '../../../calendar/presentation/controllers/calendar_notifier.dart';
import '../../../tasks/presentation/controllers/tasks_notifier.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _esSemanal = true; // true = Esta Semana, false = Este Mes
  late DateTime _focusedDate;

  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
  }

  DateTime _getStartOfWeek(DateTime date) {
    final offset = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
  }

  Color _obtenerColorTipoTarea(TipoTarea tipo) {
    switch (tipo) {
      case TipoTarea.parcial:
        return const Color(0xFFEF4444);
      case TipoTarea.entrega:
        return const Color(0xFFF97316);
      case TipoTarea.TP:
        return const Color(0xFF3B82F6);
      case TipoTarea.estudio:
        return const Color(0xFFEC4899);
      case TipoTarea.deudas:
        return const Color(0xFFF59E0B);
      case TipoTarea.otro:
        return const Color(0xFF06B6D4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesNotifier = Provider.of<ExpensesNotifier>(context);
    final calendarNotifier = Provider.of<CalendarNotifier>(context);
    final tasksNotifier = Provider.of<TasksNotifier>(context);

    final startOfWeek = _getStartOfWeek(_focusedDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    // =========================================================================
    // 1. CÁLCULOS FINANCIEROS (Semanal / Mensual)
    // =========================================================================
    final txsInPeriod = expensesNotifier.transacciones.where((t) {
      if (_esSemanal) {
        return !t.fecha.isBefore(startOfWeek) && !t.fecha.isAfter(endOfWeek);
      } else {
        return t.fecha.year == _focusedDate.year && t.fecha.month == _focusedDate.month;
      }
    }).toList();

    double totalGastos = 0.0;
    double totalIngresos = 0.0;
    final Map<String, double> gastosPorCategoria = {};

    for (final tx in txsInPeriod) {
      final esIngreso = tx.tipo == TipoTransaccion.ingreso;
      String catNombre = 'Categoría ${tx.categoriaId}';
      try {
        final cat = expensesNotifier.categorias.firstWhere((c) => c.id == tx.categoriaId);
        catNombre = cat.nombre;
      } catch (_) {}

      if (esIngreso) {
        totalIngresos += tx.monto;
      } else {
        totalGastos += tx.monto;
        gastosPorCategoria[catNombre] = (gastosPorCategoria[catNombre] ?? 0.0) + tx.monto;
      }
    }

    final balanceNeto = totalIngresos - totalGastos;

    // =========================================================================
    // 2. CÁLCULOS ACADÉMICOS Y PRODUCTIVIDAD
    // =========================================================================
    // a. Horas de cursada en la semana
    double totalHorasCursada = 0.0;
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = startOfWeek.add(Duration(days: dayOffset));
      final eventosDelDia = calendarNotifier.eventos.where((e) {
        final inicio = e.fechaInicio;
        final inicioOnly = DateTime(inicio.year, inicio.month, inicio.day);
        final dayOnly = DateTime(date.year, date.month, date.day);
        if (dayOnly.isBefore(inicioOnly)) return false;
        if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
          return dayOnly.weekday == inicioOnly.weekday;
        }
        final finOnly = DateTime(e.fechaFin.year, e.fechaFin.month, e.fechaFin.day);
        return !dayOnly.isAfter(finOnly);
      }).toList();

      for (final e in eventosDelDia) {
        double startH = e.fechaInicio.hour + (e.fechaInicio.minute / 60.0);
        double endH = e.fechaFin.hour + (e.fechaFin.minute / 60.0);
        if (endH > startH) {
          totalHorasCursada += (endH - startH);
        } else {
          totalHorasCursada += 1.0;
        }
      }
    }

    // b. Tareas del período
    final tareasInPeriod = tasksNotifier.tareas.where((t) {
      if (_esSemanal) {
        return !t.fecha.isBefore(startOfWeek) && !t.fecha.isAfter(endOfWeek);
      } else {
        return t.fecha.year == _focusedDate.year && t.fecha.month == _focusedDate.month;
      }
    }).toList();

    final tareasCompletadas = tareasInPeriod.where((t) => t.completada).length;
    final totalTareas = tareasInPeriod.length;
    final tasaCumplimiento = totalTareas > 0 ? (tareasCompletadas / totalTareas) : 1.0;

    final proximosParciales = tasksNotifier.tareas
        .where((t) => !t.completada && (t.tipo == TipoTarea.parcial || t.tipo == TipoTarea.entrega))
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const AppLogo(size: 32, showText: true),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SELECTOR DE PERÍODO (Semanal / Mensual) Y NAVEGADOR
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esSemanal = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _esSemanal ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _esSemanal
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Resumen Semanal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _esSemanal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esSemanal = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_esSemanal ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_esSemanal
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Resumen Mensual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: !_esSemanal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rango de fechas del período
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                    onPressed: () {
                      setState(() {
                        _focusedDate = _esSemanal
                            ? _focusedDate.subtract(const Duration(days: 7))
                            : DateTime(_focusedDate.year, _focusedDate.month - 1);
                      });
                    },
                  ),
                  Text(
                    _esSemanal
                        ? '${startOfWeek.day} ${_meses[startOfWeek.month - 1].substring(0, 3)} - ${endOfWeek.day} ${_meses[endOfWeek.month - 1].substring(0, 3)} ${endOfWeek.year}'
                        : '${_meses[_focusedDate.month - 1]} ${_focusedDate.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 28),
                    onPressed: () {
                      setState(() {
                        _focusedDate = _esSemanal
                            ? _focusedDate.add(const Duration(days: 7))
                            : DateTime(_focusedDate.year, _focusedDate.month + 1);
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. TARJETA RESUMEN EJECUTIVO INTELIGENTE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Resumen Inteligente',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Esta semana acumulás \$${totalGastos.toStringAsFixed(2)} en gastos y $totalHorasCursada hs de cursada agendadas.',
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      totalTareas > 0
                          ? 'Completaste $tareasCompletadas de $totalTareas actividades (${(tasaCumplimiento * 100).toStringAsFixed(0)}% de efectividad).'
                          : '¡No hay entregas pendientes agendadas esta semana!',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. SECCIÓN FINANZAS Y BALANCE
              const Text(
                '💰 Balance Financiero',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Ingresos',
                      amount: '+\$${totalIngresos.toStringAsFixed(2)}',
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Gastos',
                      amount: '-\$${totalGastos.toStringAsFixed(2)}',
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: balanceNeto >= 0
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : const Color(0xFFEF4444).withOpacity(0.15),
                          child: Icon(
                            balanceNeto >= 0 ? Icons.account_balance_wallet : Icons.warning_rounded,
                            color: balanceNeto >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Balance Neto del Período', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(
                              '\$${balanceNeto.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: balanceNeto >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DESGLOSE POR CATEGORÍA
              if (gastosPorCategoria.isNotEmpty) ...[
                const Text(
                  'Gastos por Categoría',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                ...gastosPorCategoria.entries.map((entry) {
                  final catName = entry.key;
                  final catMonto = entry.value;
                  final porcentaje = totalGastos > 0 ? (catMonto / totalGastos) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            Text('\$${catMonto.toStringAsFixed(2)} (${(porcentaje * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: porcentaje,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 24),

              // 4. SECCIÓN ACADÉMICA Y PRODUCTIVIDAD
              const Text(
                '🎓 Rendimiento Académico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFF3E8FF),
                            child: Icon(Icons.schedule_rounded, color: Color(0xFF8B5CF6)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${totalHorasCursada.toStringAsFixed(1)} hs',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          const Text('Cursadas Agendadas', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFFEF3C7),
                            child: Icon(Icons.task_alt_rounded, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$tareasCompletadas de $totalTareas',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          const Text('Tareas Cumplidas', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PRÓXIMOS EXÁMENES
              if (proximosParciales.isNotEmpty) ...[
                const Text(
                  'Próximas Evaluaciones Agendadas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                ...proximosParciales.map((t) {
                  final color = _obtenerColorTipoTarea(t.tipo);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: color, width: 4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text(
                              'Vence el ${t.fecha.day}/${t.fecha.month} a las ${t.fecha.hour.toString().padLeft(2, '0')}:${t.fecha.minute.toString().padLeft(2, '0')} hs',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t.tipo == TipoTarea.parcial ? 'Parcial' : 'Entrega',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
