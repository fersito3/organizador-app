import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../../../core/enums.dart';
import '../../../expenses/domain/models/transaccion.dart';
import '../controllers/calendar_notifier.dart';
import '../../../tasks/presentation/controllers/tasks_notifier.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Estado para alternar entre vista semanal (horario) y mensual
  bool _vistaSemanal = true;

  // Fecha base para la vista semanal (primer día de la semana, Lunes)
  late DateTime _focusedWeekStart;

  static const List<String> _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = _getStartOfWeek(DateTime.now());
  }

  DateTime _getStartOfWeek(DateTime date) {
    final offset = date.weekday - 1; // 0 para Lunes, 6 para Domingo
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: offset));
  }

  List<DateTime> _generarDiasDelMes(DateTime month) {
    final primerDia = DateTime(month.year, month.month, 1);
    final offset = primerDia.weekday - 1;

    final list = <DateTime>[];
    for (int i = 0; i < offset; i++) {
      list.add(primerDia.subtract(Duration(days: offset - i)));
    }

    final ultimoDia = DateTime(month.year, month.month + 1, 0);
    for (int i = 1; i <= ultimoDia.day; i++) {
      list.add(DateTime(month.year, month.month, i));
    }

    final celdasRestantes = (7 - (list.length % 7)) % 7;
    for (int i = 1; i <= celdasRestantes; i++) {
      list.add(ultimoDia.add(Duration(days: i)));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final calendarNotifier = Provider.of<CalendarNotifier>(context);
    final tasksNotifier = Provider.of<TasksNotifier>(context);
    final expensesNotifier = Provider.of<ExpensesNotifier>(context);

    final selectedDate = calendarNotifier.selectedDate;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Horarios & Cursadas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIEW SWITCHER TOGGLE (Semanal vs Mensual)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // Slate 100
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _vistaSemanal = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: _vistaSemanal ? const Color(0xFF8B5CF6) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.view_week_rounded,
                                      size: 16,
                                      color: _vistaSemanal ? Colors.white : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Horario Semanal',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _vistaSemanal ? Colors.white : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _vistaSemanal = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: !_vistaSemanal ? const Color(0xFF8B5CF6) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 16,
                                      color: !_vistaSemanal ? Colors.white : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Vista Mensual',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: !_vistaSemanal ? Colors.white : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // 2. CONTENIDO SEGÚN LA VISTA SELECCIONADA
            Expanded(
              child: _vistaSemanal
                  ? _buildVistaSemanal(context, calendarNotifier, tasksNotifier, expensesNotifier)
                  : _buildVistaMensual(context, calendarNotifier, tasksNotifier, expensesNotifier),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 28),
          onPressed: () => _mostrarAddEventBottomSheet(
            context,
            selectedDate: selectedDate,
            notifier: calendarNotifier,
            expNotifier: expensesNotifier,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 📅 VISTA SEMANAL (HORARIO DE CLASES POR FRANZAS HORARIAS)
  // ===========================================================================
  Widget _buildVistaSemanal(
    BuildContext context,
    CalendarNotifier calendarNotifier,
    TasksNotifier tasksNotifier,
    ExpensesNotifier expensesNotifier,
  ) {
    final diasDeLaSemana = List.generate(7, (i) => _focusedWeekStart.add(Duration(days: i)));
    final finSemana = diasDeLaSemana.last;
    final hoy = DateTime.now();

    // Rango de horas a mostrar (07:00 a 22:00 hs -> 16 slots)
    final horas = List.generate(16, (index) => index + 7);
    const double slotHeight = 64.0;
    final double totalHeight = horas.length * slotHeight;

    return Column(
      children: [
        // Navegador de semanas
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: () {
                  setState(() {
                    _focusedWeekStart = _focusedWeekStart.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                '${_focusedWeekStart.day} ${_meses[_focusedWeekStart.month - 1].substring(0, 3)} - ${finSemana.day} ${_meses[finSemana.month - 1].substring(0, 3)} ${finSemana.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 28),
                    onPressed: () {
                      setState(() {
                        _focusedWeekStart = _focusedWeekStart.add(const Duration(days: 7));
                      });
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _focusedWeekStart = _getStartOfWeek(DateTime.now());
                      });
                    },
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text('Hoy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cabecera de días de la semana (Lun 3, Mar 4, ...)
        Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.only(left: 50, right: 8, top: 8, bottom: 8),
          child: Row(
            children: diasDeLaSemana.map((date) {
              final esHoy = date.year == hoy.year && date.month == hoy.month && date.day == hoy.day;
              
              final tareasCount = tasksNotifier.tareas.where((t) =>
                  t.fecha.year == date.year &&
                  t.fecha.month == date.month &&
                  t.fecha.day == date.day).length;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      _diasSemana[date.weekday - 1],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: esHoy ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: esHoy ? const Color(0xFF8B5CF6) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: esHoy ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (tareasCount > 0) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$tareasCount Tareas',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Grilla del Horario semanal con scroll vertical y rectángulos continuos
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de Horas
                SizedBox(
                  width: 50,
                  child: Column(
                    children: horas.map((h) {
                      return SizedBox(
                        height: slotHeight,
                        child: Center(
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Columnas de Días (7 días)
                Expanded(
                  child: Row(
                    children: diasDeLaSemana.map((dayDate) {
                      // 1. Obtener todos los eventos que aplican a este día
                      final eventosDelDia = calendarNotifier.eventos.where((e) {
                        final inicio = e.fechaInicio;
                        final inicioOnly = DateTime(inicio.year, inicio.month, inicio.day);
                        final dayOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);

                        if (dayOnly.isBefore(inicioOnly)) return false;

                        if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
                          return dayOnly.weekday == inicioOnly.weekday;
                        }
                        final finOnly = DateTime(e.fechaFin.year, e.fechaFin.month, e.fechaFin.day);
                        return !dayOnly.isAfter(finOnly);
                      }).toList();

                      // 2. Obtener todas las tareas de este día
                      final tareasDelDia = tasksNotifier.tareas.where((t) {
                        return t.fecha.year == dayDate.year &&
                            t.fecha.month == dayDate.month &&
                            t.fecha.day == dayDate.day;
                      }).toList();

                      return Expanded(
                        child: Container(
                          height: totalHeight,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Capa 1: Celdas de fondo por hora
                              Column(
                                children: horas.map((h) {
                                  return GestureDetector(
                                    onTap: () {
                                      _mostrarAddEventBottomSheet(
                                        context,
                                        selectedDate: dayDate,
                                        initialHour: h,
                                        notifier: calendarNotifier,
                                        expNotifier: expensesNotifier,
                                      );
                                    },
                                    child: Container(
                                      height: slotHeight,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              // Capa 2: Rectángulos continuos de Eventos (Spanning multi-hour blocks)
                              ...eventosDelDia.map((e) {
                                double startHourFloat = e.fechaInicio.hour + (e.fechaInicio.minute / 60.0);
                                double endHourFloat = e.fechaFin.hour + (e.fechaFin.minute / 60.0);
                                
                                if (endHourFloat <= startHourFloat) {
                                  endHourFloat = startHourFloat + 1.0; // Duración mínima 1 hora
                                }

                                // Ajustar al rango de horas visible (07:00 a 23:00)
                                double clampedStart = startHourFloat.clamp(7.0, 23.0);
                                double clampedEnd = endHourFloat.clamp(7.0, 23.0);

                                if (clampedEnd <= clampedStart) return const SizedBox.shrink();

                                double topOffset = (clampedStart - 7.0) * slotHeight;
                                double blockHeight = (clampedEnd - clampedStart) * slotHeight;

                                final horaInicioStr = '${e.fechaInicio.hour.toString().padLeft(2, '0')}:${e.fechaInicio.minute.toString().padLeft(2, '0')}';
                                final horaFinStr = '${e.fechaFin.hour.toString().padLeft(2, '0')}:${e.fechaFin.minute.toString().padLeft(2, '0')}';

                                return Positioned(
                                  top: topOffset + 1.0,
                                  left: 1.0,
                                  right: 1.0,
                                  height: blockHeight - 2.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _mostrarOpcionesEvento(context, e, calendarNotifier, expensesNotifier);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6).withOpacity(0.35),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.titulo,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '$horaInicioStr - $horaFinStr',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (e.descripcion != null && e.descripcion!.isNotEmpty && blockHeight >= 70) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              e.descripcion!,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 8,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Capa 3: Tareas / Parciales / Deudas visibles en el horario
                              ...tareasDelDia.map((t) {
                                int taskHour = (t.fecha.hour >= 7 && t.fecha.hour <= 22) ? t.fecha.hour : 8;
                                double topOffset = (taskHour - 7.0) * slotHeight + 2.0;

                                return Positioned(
                                  top: topOffset,
                                  left: 2.0,
                                  right: 2.0,
                                  height: 26.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _mostrarOpcionesTarea(context, t, tasksNotifier);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: t.completada ? Colors.green.shade600 : const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.white, width: 1),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            t.completada ? Icons.check_circle : Icons.assignment_rounded,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              t.titulo,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                decoration: t.completada ? TextDecoration.lineThrough : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Modal para ver opciones de tarea desde el horario
  void _mostrarOpcionesTarea(BuildContext context, Tarea t, TasksNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${t.fecha.day}/${t.fecha.month}/${t.fecha.year} a las ${t.fecha.hour.toString().padLeft(2, '0')}:${t.fecha.minute.toString().padLeft(2, '0')} hs',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              if (t.descripcion != null && t.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  t.descripcion!,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        notifier.toggleCompletada(t);
                        Navigator.pop(context);
                      },
                      icon: Icon(t.completada ? Icons.undo_rounded : Icons.check_circle_rounded),
                      label: Text(t.completada ? 'Marcar Pendiente' : 'Marcar Completada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.completada ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

  // Filtrar eventos que ocurren en una fecha y comienzan en una hora dada
  List<Evento> _obtenerEventosParaSlot(DateTime dayDate, int hour, List<Evento> todosEventos) {
    return todosEventos.where((e) {
      final inicio = e.fechaInicio;
      final inicioOnly = DateTime(inicio.year, inicio.month, inicio.day);
      final dayOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);

      if (dayOnly.isBefore(inicioOnly)) return false;

      bool coincideDia = false;
      if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
        coincideDia = (dayOnly.weekday == inicioOnly.weekday);
      } else {
        final finOnly = DateTime(e.fechaFin.year, e.fechaFin.month, e.fechaFin.day);
        coincideDia = !dayOnly.isAfter(finOnly);
      }

      if (!coincideDia) return false;

      // El evento comienza en este slot de hora
      return e.fechaInicio.hour == hour;
    }).toList();
  }

  // Modal para ver detalles / eliminar evento desde la vista de horario
  void _mostrarOpcionesEvento(
    BuildContext context,
    Evento e,
    CalendarNotifier notifier,
    ExpensesNotifier expNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${e.fechaInicio.hour.toString().padLeft(2, '0')}:${e.fechaInicio.minute.toString().padLeft(2, '0')} - ${e.fechaFin.hour.toString().padLeft(2, '0')}:${e.fechaFin.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              if (e.descripcion != null && e.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  e.descripcion!,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await notifier.eliminarEvento(e.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Evento eliminado.'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

  // ===========================================================================
  // 🗓️ VISTA MENSUAL
  // ===========================================================================
  Widget _buildVistaMensual(
    BuildContext context,
    CalendarNotifier calendarNotifier,
    TasksNotifier tasksNotifier,
    ExpensesNotifier expensesNotifier,
  ) {
    final focusedMonth = calendarNotifier.focusedMonth;
    final selectedDate = calendarNotifier.selectedDate;
    final diasGrid = _generarDiasDelMes(focusedMonth);

    final tareasDelDia = tasksNotifier.tareas.where((t) {
      final tDate = t.fecha;
      return tDate.year == selectedDate.year &&
          tDate.month == selectedDate.month &&
          tDate.day == selectedDate.day;
    }).toList();

    final eventosDelDia = calendarNotifier.eventosDelDia;

    return Column(
      children: [
        // MONTH SELECTOR HEADER
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: () {
                  calendarNotifier.changeMonth(
                    DateTime(focusedMonth.year, focusedMonth.month - 1),
                  );
                },
              ),
              Text(
                '${_meses[focusedMonth.month - 1]} ${focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: () {
                  calendarNotifier.changeMonth(
                    DateTime(focusedMonth.year, focusedMonth.month + 1),
                  );
                },
              ),
            ],
          ),
        ),

        // CALENDAR GRID CONTAINER
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _diasSemana.map((d) {
                  return SizedBox(
                    width: 40,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: diasGrid.length,
                itemBuilder: (context, index) {
                  final date = diasGrid[index];
                  final esMismoMes = date.month == focusedMonth.month;
                  final esSeleccionado = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  final hoy = DateTime.now();
                  final esHoy = date.year == hoy.year && date.month == hoy.month && date.day == hoy.day;

                  final tieneEventos = calendarNotifier.eventos.any((e) {
                    final inicio = DateTime(e.fechaInicio.year, e.fechaInicio.month, e.fechaInicio.day);
                    final actual = DateTime(date.year, date.month, date.day);
                    
                    if (actual.isBefore(inicio)) return false;
                    
                    if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
                      return actual.weekday == inicio.weekday;
                    }
                    
                    final fin = DateTime(e.fechaFin.year, e.fechaFin.month, e.fechaFin.day);
                    return !actual.isAfter(fin);
                  });

                  final tieneTareas = tasksNotifier.tareas.any((t) =>
                      t.fecha.year == date.year &&
                      t.fecha.month == date.month &&
                      t.fecha.day == date.day);

                  return GestureDetector(
                    onTap: () {
                      calendarNotifier.selectDate(date);
                      if (date.month != focusedMonth.month) {
                        calendarNotifier.changeMonth(DateTime(date.year, date.month));
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: esSeleccionado ? const Color(0xFF8B5CF6) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: esHoy && !esSeleccionado
                            ? Border.all(color: const Color(0xFF8B5CF6), width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: esSeleccionado || esHoy ? FontWeight.bold : FontWeight.w500,
                              color: esSeleccionado
                                  ? Colors.white
                                  : esMismoMes
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFCBD5E1),
                            ),
                          ),
                          if (tieneEventos || tieneTareas) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (tieneEventos)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: esSeleccionado ? Colors.white : const Color(0xFF8B5CF6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (tieneEventos && tieneTareas) const SizedBox(width: 2),
                                if (tieneTareas)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: esSeleccionado ? Colors.white : const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // SELECTED DAY LIST
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Agenda del ${selectedDate.day} de ${_meses[selectedDate.month - 1]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),

              if (eventosDelDia.isEmpty && tareasDelDia.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.event_available_rounded, size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'Día Libre',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'No hay cursadas, eventos ni tareas agendados para esta fecha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                )
              else ...[
                ...eventosDelDia.map((e) => _buildEventoCard(context, e, calendarNotifier, expensesNotifier)),
                ...tareasDelDia.map((t) => _buildTareaCard(context, t, tasksNotifier)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventoCard(
    BuildContext context,
    Evento e,
    CalendarNotifier notifier,
    ExpensesNotifier expNotifier,
  ) {
    Transaccion? tx;
    if (e.transaccionId != null) {
      try {
        tx = expNotifier.transacciones.firstWhere((t) => t.id == e.transaccionId);
      } catch (_) {}
    }

    final horaStr = '${e.fechaInicio.hour.toString().padLeft(2, '0')}:${e.fechaInicio.minute.toString().padLeft(2, '0')} - '
        '${e.fechaFin.hour.toString().padLeft(2, '0')}:${e.fechaFin.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF8B5CF6), width: 5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          e.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(horaStr, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
            if (e.descripcion != null && e.descripcion!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                e.descripcion!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (tx != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_money_rounded, size: 12, color: Color(0xFF475569)),
                    const SizedBox(width: 2),
                    Text(
                      'Vinculado a: ${tx.descripcion} (\$${tx.monto.toStringAsFixed(2)})',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Evento'),
                content: const Text('¿Deseas eliminar este evento del calendario?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await notifier.eliminarEvento(e.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTareaCard(BuildContext context, Tarea t, TasksNotifier notifier) {
    String badgeText = '';
    Color badgeColor = Colors.grey;
    switch (t.tipo) {
      case TipoTarea.parcial:
        badgeText = 'Parcial';
        badgeColor = Colors.red;
        break;
      case TipoTarea.entrega:
        badgeText = 'Entrega';
        badgeColor = Colors.orange;
        break;
      case TipoTarea.TP:
        badgeText = 'TP';
        badgeColor = Colors.blue;
        break;
      case TipoTarea.estudio:
        badgeText = 'Estudio';
        badgeColor = Colors.purple;
        break;
      case TipoTarea.deudas:
        final monto = notifier.obtenerMontoDeuda(t);
        badgeText = 'Deuda: \$${monto.toStringAsFixed(0)}';
        badgeColor = const Color(0xFFF59E0B);
        break;
      case TipoTarea.otro:
        badgeText = 'Otro';
        badgeColor = Colors.blueGrey;
        break;
    }

    String displayDesc = t.descripcion ?? '';
    if (t.tipo == TipoTarea.deudas) {
      final amigo = notifier.obtenerAmigoDeuda(t);
      final detalles = notifier.obtenerDescripcionLimpiaDeuda(t);
      displayDesc = 'Le debes a $amigo' + (detalles.isNotEmpty ? ' - $detalles' : '');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: t.completada ? Colors.green : const Color(0xFFF59E0B), width: 5),
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: t.completada,
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => notifier.toggleCompletada(t),
        ),
        title: Text(
          t.titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            decoration: t.completada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayDesc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                displayDesc,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAddEventBottomSheet(
    BuildContext context, {
    required DateTime selectedDate,
    int? initialHour,
    required CalendarNotifier notifier,
    required ExpensesNotifier expNotifier,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddEventModal(
          selectedDate: selectedDate,
          initialHour: initialHour,
          notifier: notifier,
          expNotifier: expNotifier,
        );
      },
    );
  }
}

class _AddEventModal extends StatefulWidget {
  final DateTime selectedDate;
  final int? initialHour;
  final CalendarNotifier notifier;
  final ExpensesNotifier expNotifier;

  const _AddEventModal({
    required this.selectedDate,
    this.initialHour,
    required this.notifier,
    required this.expNotifier,
  });

  @override
  State<_AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<_AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;

  bool _esRecurrente = false;
  int? _selectedTransaccionId;

  @override
  void initState() {
    super.initState();
    final startH = widget.initialHour ?? 9;
    _horaInicio = TimeOfDay(hour: startH, minute: 0);
    _horaFin = TimeOfDay(hour: (startH + 1) % 24, minute: 0);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora(BuildContext context, bool esInicio) async {
    final horaInicial = esInicio ? _horaInicio : _horaFin;
    final picked = await showTimePicker(
      context: context,
      initialTime: horaInicial,
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = picked;
          int finHour = (_horaInicio.hour + 1) % 24;
          _horaFin = TimeOfDay(hour: finHour, minute: _horaInicio.minute);
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Agregar Evento / Cursada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título (Materia / Cursada)',
                      prefixIcon: Icon(Icons.title_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Aula / Ubicación (Opcional)',
                      prefixIcon: Icon(Icons.location_on_rounded),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _seleccionarHora(context, true),
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text('Inicio: ${_horaInicio.format(context)}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _seleccionarHora(context, false),
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text('Fin: ${_horaFin.format(context)}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text('¿Es una cursada recurrente?', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Se repetirá semanalmente en este día y hora', style: TextStyle(fontSize: 11)),
                    value: _esRecurrente,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) {
                      setState(() {
                        _esRecurrente = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<int?>(
                    value: _selectedTransaccionId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Vincular Gasto (Opcional)',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Ninguna transacción', overflow: TextOverflow.ellipsis),
                      ),
                      ...widget.expNotifier.transacciones.take(15).map((t) {
                        return DropdownMenuItem<int?>(
                          value: t.id,
                          child: Text(
                            '${t.descripcion} (\$${t.monto.toStringAsFixed(0)})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedTransaccionId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final baseDate = widget.selectedDate;
                        final start = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          _horaInicio.hour,
                          _horaInicio.minute,
                        );
                        final end = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          _horaFin.hour,
                          _horaFin.minute,
                        );

                        if (end.isBefore(start)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La hora de fin debe ser posterior a la de inicio.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await widget.notifier.guardarEvento(
                          EventosCompanion.insert(
                            titulo: _tituloController.text.trim(),
                            descripcion: drift.Value(_descripcionController.text.trim()),
                            fechaInicio: start,
                            fechaFin: end,
                            esRecurrente: drift.Value(_esRecurrente),
                            patronRecurrencia: drift.Value(_esRecurrente ? 'WEEKLY' : null),
                            transaccionId: drift.Value(_selectedTransaccionId),
                          ),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evento creado con éxito.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Guardar Evento',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
