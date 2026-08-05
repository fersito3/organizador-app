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
  static const List<String> _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

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

    final focusedMonth = calendarNotifier.focusedMonth;
    final selectedDate = calendarNotifier.selectedDate;
    final diasGrid = _generarDiasDelMes(focusedMonth);

    // Filtrar tareas que vencen en el día seleccionado
    final tareasDelDia = tasksNotifier.tareas.where((t) {
      final tDate = t.fecha;
      return tDate.year == selectedDate.year &&
          tDate.month == selectedDate.month &&
          tDate.day == selectedDate.day;
    }).toList();

    final eventosDelDia = calendarNotifier.eventosDelDia;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Calendario & Horarios',
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
      body: Column(
        children: [
          // 1. MONTH SELECTOR HEADER
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

          // 2. CALENDAR GRID CONTAINER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Days of week header
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
                          color: Color(0xFF94A3B8), // Slate 400
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Days grid
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

                    // Comprobar eventos y tareas en este día
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
                          color: esSeleccionado
                              ? const Color(0xFF8B5CF6) // Violet 500
                              : Colors.transparent,
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
                                        : const Color(0xFFCBD5E1), // Slate 300 para meses adyacentes
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
                                        color: esSeleccionado ? Colors.white : const Color(0xFFF59E0B), // Amber 500
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

          // 3. SELECTED DAY LIST
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
                  // Render Events
                  ...eventosDelDia.map((e) => _buildEventoCard(context, e, calendarNotifier, expensesNotifier)),
                  // Render Tasks/Evaluations
                  ...tareasDelDia.map((t) => _buildTareaCard(context, t, tasksNotifier)),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
        onPressed: () => _mostrarAddEventBottomSheet(context, selectedDate, calendarNotifier, expensesNotifier),
      ),
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
    BuildContext context,
    DateTime selectedDate,
    CalendarNotifier notifier,
    ExpensesNotifier expNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddEventModal(
          selectedDate: selectedDate,
          notifier: notifier,
          expNotifier: expNotifier,
        );
      },
    );
  }
}

class _AddEventModal extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarNotifier notifier;
  final ExpensesNotifier expNotifier;

  const _AddEventModal({
    required this.selectedDate,
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

  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 10, minute: 0);

  bool _esRecurrente = false;
  int? _selectedTransaccionId;

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
          // Ajustar hora fin automáticamente a 1 hora después
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
                  'Agregar Evento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título del Evento',
                    prefixIcon: Icon(Icons.title_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Ubicación (Opcional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Time Pickers Row
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
                  title: const Text('¿Es un evento recurrente?', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Se repetirá semanalmente en este día', style: TextStyle(fontSize: 11)),
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

                // Transaction Linker dropdown
                DropdownButtonFormField<int?>(
                  value: _selectedTransaccionId,
                  decoration: const InputDecoration(
                    labelText: 'Vincular Gasto / Transacción (Opcional)',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Ninguna transacción'),
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
                    }),
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

                      // Guardar evento
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
    );
  }
}
