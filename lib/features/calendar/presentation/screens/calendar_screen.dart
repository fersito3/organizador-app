import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../../../core/enums.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/services/mercadopago_cobro_service.dart';
import '../../../expenses/domain/models/transaccion.dart';
import '../controllers/calendar_notifier.dart';
import '../../../tasks/presentation/controllers/tasks_notifier.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';

class CalendarScreen extends StatefulWidget {
  final int initialTab;
  const CalendarScreen({super.key, this.initialTab = 0});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Estado para alternar entre vista semanal (horario) y mensual
  bool _vistaSemanal = true;

  // Fecha base para la vista semanal (primer día de la semana, Lunes)
  late DateTime _focusedWeekStart;

  // Filtros para la Pestaña 2: Tareas & Evaluaciones
  final _searchController = TextEditingController();
  int _estadoFiltro = 0; // 0: Todas, 1: Pendientes, 2: Completadas
  TipoTarea? _tipoFiltro; // null: Todos, o TipoTarea específico

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Color _obtenerColorTipoTarea(TipoTarea tipo) {
    switch (tipo) {
      case TipoTarea.parcial:
        return const Color(0xFFEF4444); // Red 500
      case TipoTarea.entrega:
        return const Color(0xFFF97316); // Orange 500
      case TipoTarea.TP:
        return const Color(0xFF3B82F6); // Blue 500
      case TipoTarea.estudio:
        return const Color(0xFFEC4899); // Pink 500 (Cumpleaños)
      case TipoTarea.deudas:
        return const Color(0xFFF59E0B); // Amber 500
      case TipoTarea.otro:
        return const Color(0xFF06B6D4); // Cyan 500 (Recuerdo / Notas)
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarNotifier = Provider.of<CalendarNotifier>(context);
    final tasksNotifier = Provider.of<TasksNotifier>(context);
    final expensesNotifier = Provider.of<ExpensesNotifier>(context);

    final selectedDate = calendarNotifier.selectedDate;

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBar: AppBar(
          title: const Text(
            'Agenda & Cursadas',
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
          bottom: const TabBar(
            labelColor: Color(0xFF8B5CF6),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF8B5CF6),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_month_rounded, size: 20),
                text: 'Calendario & Horarios',
              ),
              Tab(
                icon: Icon(Icons.assignment_rounded, size: 20),
                text: 'Tareas & Evaluaciones',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // PESTAÑA 1: CALENDARIO & HORARIOS
              Column(
                children: [
                  // VIEW SWITCHER TOGGLE (Semanal vs Mensual)
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

                  // CONTENIDO DE VISTA (SEMANAL / MENSUAL)
                  Expanded(
                    child: _vistaSemanal
                        ? _buildVistaSemanal(context, calendarNotifier, tasksNotifier, expensesNotifier)
                        : _buildVistaMensual(context, calendarNotifier, tasksNotifier, expensesNotifier),
                  ),
                ],
              ),

              // PESTAÑA 2: TAREAS & EVALUACIONES
              _buildVistaTareasYEvaluaciones(context, tasksNotifier, expensesNotifier),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 28),
          onPressed: () => _mostrarAddOptionsBottomSheet(
            context,
            selectedDate: selectedDate,
            calendarNotifier: calendarNotifier,
            tasksNotifier: tasksNotifier,
            expensesNotifier: expensesNotifier,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 📝 PESTAÑA 2: VISTA UNIFICADA DE TAREAS & EVALUACIONES
  // ===========================================================================
  Widget _buildVistaTareasYEvaluaciones(
    BuildContext context,
    TasksNotifier tasksNotifier,
    ExpensesNotifier expensesNotifier,
  ) {
    final todas = tasksNotifier.tareas;
    final query = _searchController.text.trim().toLowerCase();

    final tareasFiltradas = todas.where((t) {
      if (query.isNotEmpty) {
        final titulo = t.titulo.toLowerCase();
        final desc = (t.descripcion ?? '').toLowerCase();
        if (!titulo.contains(query) && !desc.contains(query)) {
          return false;
        }
      }

      if (_estadoFiltro == 1 && t.completada) return false;
      if (_estadoFiltro == 2 && !t.completada) return false;

      if (_tipoFiltro != null && t.tipo != _tipoFiltro) return false;

      return true;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar tarea, parcial o nota...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildEstadoChip('Todas', 0),
                  const SizedBox(width: 8),
                  _buildEstadoChip('Pendientes', 1),
                  const SizedBox(width: 8),
                  _buildEstadoChip('Completadas', 2),
                ],
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTipoChip('Todos', null),
                    const SizedBox(width: 6),
                    _buildTipoChip('Exámenes / Parciales 🎓', TipoTarea.parcial),
                    const SizedBox(width: 6),
                    _buildTipoChip('Entregas', TipoTarea.entrega),
                    const SizedBox(width: 6),
                    _buildTipoChip('TPs', TipoTarea.TP),
                    const SizedBox(width: 6),
                    _buildTipoChip('Cumpleaños 🎂', TipoTarea.estudio),
                    const SizedBox(width: 6),
                    _buildTipoChip('Deudas 💵', TipoTarea.deudas),
                    const SizedBox(width: 6),
                    _buildTipoChip('Recuerdos 📝', TipoTarea.otro),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: tareasFiltradas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.assignment_turned_in_rounded, size: 54, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text(
                          'No hay tareas o evaluaciones',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B)),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'No se encontraron pendientes con los filtros seleccionados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: tareasFiltradas.length,
                  itemBuilder: (context, index) {
                    final t = tareasFiltradas[index];
                    return GestureDetector(
                      onTap: () => _mostrarOpcionesTarea(context, t, tasksNotifier),
                      child: _buildTareaCard(context, t, tasksNotifier),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEstadoChip(String label, int index) {
    final seleccionado = _estadoFiltro == index;
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor: const Color(0xFF8B5CF6),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : const Color(0xFF475569),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) {
        setState(() {
          _estadoFiltro = index;
        });
      },
    );
  }

  Widget _buildTipoChip(String label, TipoTarea? tipo) {
    final seleccionado = _tipoFiltro == tipo;
    final color = tipo != null ? _obtenerColorTipoTarea(tipo) : const Color(0xFF8B5CF6);

    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      selectedColor: color,
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : const Color(0xFF334155),
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) {
        setState(() {
          _tipoFiltro = tipo;
        });
      },
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

    // Franjas horarias ultrachatas (slotHeight = 36.0 px)
    final horas = List.generate(16, (index) => index + 7);
    const double slotHeight = 36.0;
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

        // Cabecera de días de la semana + Badges a TODO COLOR Y RELLENO abajo del día
        Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.only(left: 50, right: 8, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: diasDeLaSemana.map((date) {
              final esHoy = date.year == hoy.year && date.month == hoy.month && date.day == hoy.day;
              
              // 1. Contar eventos del día
              final eventosCount = calendarNotifier.eventos.where((e) {
                final inicio = e.fechaInicio;
                final inicioOnly = DateTime(inicio.year, inicio.month, inicio.day);
                final dayOnly = DateTime(date.year, date.month, date.day);
                if (dayOnly.isBefore(inicioOnly)) return false;
                if (e.esRecurrente && e.patronRecurrencia == 'WEEKLY') {
                  return dayOnly.weekday == inicioOnly.weekday;
                }
                final finOnly = DateTime(e.fechaFin.year, e.fechaFin.month, e.fechaFin.day);
                return !dayOnly.isAfter(finOnly);
              }).length;

              // 2. Agrupar tareas del día por tipo
              final tareasDelDia = tasksNotifier.tareas.where((t) =>
                  t.fecha.year == date.year &&
                  t.fecha.month == date.month &&
                  t.fecha.day == date.day).toList();

              final Map<TipoTarea, int> conteoPorTipo = {};
              for (final t in tareasDelDia) {
                conteoPorTipo[t.tipo] = (conteoPorTipo[t.tipo] ?? 0) + 1;
              }

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
                    const SizedBox(height: 4),

                    // Badge de Eventos (Relleno morado)
                    if (eventosCount > 0) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$eventosCount ${eventosCount == 1 ? 'Evento' : 'Eventos'}',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Badges de Tareas por Tipo (FULL COLOR Y RELLENO)
                    ...conteoPorTipo.entries.map((entry) {
                      final tipo = entry.key;
                      final count = entry.value;
                      final tipoColor = _obtenerColorTipoTarea(tipo);

                      String nombreTipo = 'Tarea';
                      switch (tipo) {
                        case TipoTarea.parcial:
                          nombreTipo = count == 1 ? 'Parcial' : 'Parciales';
                          break;
                        case TipoTarea.entrega:
                          nombreTipo = count == 1 ? 'Entrega' : 'Entregas';
                          break;
                        case TipoTarea.TP:
                          nombreTipo = count == 1 ? 'TP' : 'TPs';
                          break;
                        case TipoTarea.estudio:
                          nombreTipo = count == 1 ? 'Cumpleaños' : 'Cumpleaños';
                          break;
                        case TipoTarea.deudas:
                          nombreTipo = count == 1 ? 'Deuda' : 'Deudas';
                          break;
                        case TipoTarea.otro:
                          nombreTipo = count == 1 ? 'Recuerdo' : 'Recuerdos/Notas';
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: tipoColor, // RELLENO DE COLOR COMPLETO
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$count $nombreTipo',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
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
                              fontSize: 10,
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
                                      _mostrarAddOptionsBottomSheet(
                                        context,
                                        selectedDate: dayDate,
                                        initialHour: h,
                                        calendarNotifier: calendarNotifier,
                                        tasksNotifier: tasksNotifier,
                                        expensesNotifier: expensesNotifier,
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

                              // Capa 2: RECTÁNGULOS DE TAREAS QUE RECORREN TODO EL DÍA EN LA MATRIZ (SIN RELLENO, SOLO BORDES DE COLOR)
                              ...tareasDelDia.asMap().entries.map((entry) {
                                final index = entry.key;
                                final t = entry.value;
                                final tipoColor = _obtenerColorTipoTarea(t.tipo);

                                double leftPadding = 1.0 + (index * 2.0);
                                double rightPadding = 1.0 + (index * 2.0);
                                double topPadding = 1.0 + (index * 16.0);

                                return Positioned(
                                  top: topPadding,
                                  bottom: 1.0,
                                  left: leftPadding,
                                  right: rightPadding,
                                  child: GestureDetector(
                                    onTap: () => _mostrarOpcionesTarea(context, t, tasksNotifier),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 2, left: 3, right: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent, // SIN RELLENO PARA QUE SE VEAN LOS EVENTOS EN EL CENTRO
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: t.completada ? Colors.green : tipoColor,
                                          width: 2.0, // BORDE DE COLOR DEL TIPO DE TAREA
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: (t.completada ? Colors.green : tipoColor).withOpacity(0.95),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            t.titulo,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // Capa 3: Rectángulos continuos de Eventos (Multi-hour blocks FULL LLENOS DE COLOR)
                              ...eventosDelDia.map((e) {
                                double startHourFloat = e.fechaInicio.hour + (e.fechaInicio.minute / 60.0);
                                double endHourFloat = e.fechaFin.hour + (e.fechaFin.minute / 60.0);
                                
                                if (endHourFloat <= startHourFloat) {
                                  endHourFloat = startHourFloat + 1.0;
                                }

                                double clampedStart = startHourFloat.clamp(7.0, 23.0);
                                double clampedEnd = endHourFloat.clamp(7.0, 23.0);

                                if (clampedEnd <= clampedStart) return const SizedBox.shrink();

                                double topOffset = (clampedStart - 7.0) * slotHeight;
                                double blockHeight = (clampedEnd - clampedStart) * slotHeight;

                                final horaInicioStr = '${e.fechaInicio.hour.toString().padLeft(2, '0')}:${e.fechaInicio.minute.toString().padLeft(2, '0')}';
                                final horaFinStr = '${e.fechaFin.hour.toString().padLeft(2, '0')}:${e.fechaFin.minute.toString().padLeft(2, '0')}';

                                double leftMargin = tareasDelDia.isNotEmpty ? 4.0 : 2.0;

                                return Positioned(
                                  top: topOffset + 1.0,
                                  left: leftMargin,
                                  right: leftMargin,
                                  height: blockHeight - 2.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _mostrarOpcionesEvento(
                                        context,
                                        e,
                                        calendarNotifier,
                                        expensesNotifier,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.titulo,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '$horaInicioStr - $horaFinStr',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 7.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (e.descripcion != null && e.descripcion!.isNotEmpty && blockHeight >= 45) ...[
                                              Text(
                                                e.descripcion!,
                                                style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 7.0,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
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

  // ===========================================================================
  // 🔘 BOTTOM SHEET DE OPCIONES PARA AGREGAR (Evento, Parcial, Entrega, Deuda, Recuerdo)
  // ===========================================================================
  void _mostrarAddOptionsBottomSheet(
    BuildContext context, {
    required DateTime selectedDate,
    int? initialHour,
    required CalendarNotifier calendarNotifier,
    required TasksNotifier tasksNotifier,
    required ExpensesNotifier expensesNotifier,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Qué deseas agregar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 20),

                // 1. EVENTO / CURSADA
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF8B5CF6),
                    child: Icon(Icons.event_rounded, color: Colors.white),
                  ),
                  title: const Text('Agregar Evento / Cursada', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Clases semanales, horarios o reuniones'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarAddEventBottomSheet(
                      context,
                      selectedDate: selectedDate,
                      initialHour: initialHour,
                      notifier: calendarNotifier,
                      expNotifier: expensesNotifier,
                    );
                  },
                ),
                const Divider(),

                // 2. PARCIAL / EXAMEN
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEF4444),
                    child: Icon(Icons.assignment_late_rounded, color: Colors.white),
                  ),
                  title: const Text('Agregar Parcial / Examen 🎓', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Evaluación o fecha de examen'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarAddTareaBottomSheet(
                      context,
                      selectedDate: selectedDate,
                      initialHour: initialHour,
                      initialTipo: TipoTarea.parcial,
                      notifier: tasksNotifier,
                    );
                  },
                ),
                const Divider(),

                // 3. ENTREGA / TP
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF97316),
                    child: Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
                  ),
                  title: const Text('Agregar Entrega / Trabajo Práctico', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Entrega de TP o proyecto'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarAddTareaBottomSheet(
                      context,
                      selectedDate: selectedDate,
                      initialHour: initialHour,
                      initialTipo: TipoTarea.entrega,
                      notifier: tasksNotifier,
                    );
                  },
                ),
                const Divider(),

                // 4. DEUDA
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF59E0B),
                    child: Icon(Icons.attach_money_rounded, color: Colors.white),
                  ),
                  title: const Text('Agregar Deuda / Préstamo 💵', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Registro de dinero cobrable con MP'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarAddTareaBottomSheet(
                      context,
                      selectedDate: selectedDate,
                      initialHour: initialHour,
                      initialTipo: TipoTarea.deudas,
                      notifier: tasksNotifier,
                    );
                  },
                ),
                const Divider(),

                // 5. RECUERDO / NOTA
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF06B6D4),
                    child: Icon(Icons.notes_rounded, color: Colors.white),
                  ),
                  title: const Text('Agregar Recuerdo / Nota 📝', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Recordatorio o nota general'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarAddTareaBottomSheet(
                      context,
                      selectedDate: selectedDate,
                      initialHour: initialHour,
                      initialTipo: TipoTarea.otro,
                      notifier: tasksNotifier,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modal para ver opciones de evento (Editar / Eliminar)
  void _mostrarOpcionesEvento(
    BuildContext context,
    Evento e,
    CalendarNotifier notifier,
    ExpensesNotifier expNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
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
                      onPressed: () {
                        Navigator.pop(context);
                        _mostrarAddEventBottomSheet(
                          context,
                          selectedDate: e.fechaInicio,
                          eventoToEdit: e,
                          notifier: notifier,
                          expNotifier: expNotifier,
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF8B5CF6)),
                      label: const Text('Editar', style: TextStyle(color: Color(0xFF8B5CF6))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await notifier.eliminarEvento(e.id);
                        if (context.mounted) {
                          AppToast.show(context, message: 'Evento eliminado.', isError: true);
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
        ),
      );
    },
  );
}

  // Modal para ver opciones de tarea (Marcar / Editar / Eliminar)
  void _mostrarOpcionesTarea(BuildContext context, Tarea t, TasksNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
            ),
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
              if (t.tipo == TipoTarea.deudas) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final monto = notifier.obtenerMontoDeuda(t);
                      MercadoPagoCobroService.mostrarDialogoCobro(
                        context,
                        titulo: t.titulo,
                        monto: monto > 0 ? monto : 1000.0,
                      );
                    },
                    icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                    label: const Text('Generar Link de Cobro MP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009EE3), // Mercado Pago Blue
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
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
                      label: Text(t.completada ? 'Pendiente' : 'Completar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: t.completada ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarAddTareaBottomSheet(
                        context,
                        selectedDate: t.fecha,
                        tareaToEdit: t,
                        notifier: notifier,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await notifier.eliminarTarea(t.id);
                      if (context.mounted) {
                        AppToast.show(context, message: 'Tarea eliminada.', isError: true);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
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
        badgeText = 'Cumpleaños 🎂';
        badgeColor = const Color(0xFFEC4899);
        break;
      case TipoTarea.deudas:
        final monto = notifier.obtenerMontoDeuda(t);
        badgeText = 'Deuda: \$${monto.toStringAsFixed(0)}';
        badgeColor = const Color(0xFFF59E0B);
        break;
      case TipoTarea.otro:
        badgeText = 'Recuerdo / Notas 📝';
        badgeColor = const Color(0xFF06B6D4);
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
    Evento? eventoToEdit,
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
          eventoToEdit: eventoToEdit,
          notifier: notifier,
          expNotifier: expNotifier,
        );
      },
    );
  }

  void _mostrarAddTareaBottomSheet(
    BuildContext context, {
    required DateTime selectedDate,
    int? initialHour,
    Tarea? tareaToEdit,
    TipoTarea? initialTipo,
    required TasksNotifier notifier,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddTareaModal(
          selectedDate: selectedDate,
          initialHour: initialHour,
          tareaToEdit: tareaToEdit,
          initialTipo: initialTipo,
          notifier: notifier,
        );
      },
    );
  }
}

// =============================================================================
// 📝 MODAL PARA AGREGAR / EDITAR EVENTOS
// =============================================================================
class _AddEventModal extends StatefulWidget {
  final DateTime selectedDate;
  final int? initialHour;
  final Evento? eventoToEdit;
  final CalendarNotifier notifier;
  final ExpensesNotifier expNotifier;

  const _AddEventModal({
    required this.selectedDate,
    this.initialHour,
    this.eventoToEdit,
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

  late DateTime _fechaSeleccionada;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;

  bool _esRecurrente = false;
  int? _selectedTransaccionId;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.eventoToEdit?.fechaInicio ?? widget.selectedDate;
    if (widget.eventoToEdit != null) {
      final e = widget.eventoToEdit!;
      _tituloController.text = e.titulo;
      _descripcionController.text = e.descripcion ?? '';
      _horaInicio = TimeOfDay(hour: e.fechaInicio.hour, minute: e.fechaInicio.minute);
      _horaFin = TimeOfDay(hour: e.fechaFin.hour, minute: e.fechaFin.minute);
      _esRecurrente = e.esRecurrente;
      _selectedTransaccionId = e.transaccionId;
    } else {
      final startH = widget.initialHour ?? 9;
      _horaInicio = TimeOfDay(hour: startH, minute: 0);
      _horaFin = TimeOfDay(hour: (startH + 1) % 24, minute: 0);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
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
    final esEdicion = widget.eventoToEdit != null;

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
                  Text(
                    esEdicion ? 'Editar Evento / Cursada' : 'Agregar Evento / Cursada',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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

                  OutlinedButton.icon(
                    onPressed: () => _seleccionarFecha(context),
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text('Fecha: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                        final baseDate = _fechaSeleccionada;
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
                          AppToast.show(context, message: 'La hora de fin debe ser posterior a la de inicio.', isError: true);
                          return;
                        }

                        final companion = EventosCompanion(
                          id: esEdicion ? drift.Value(widget.eventoToEdit!.id) : const drift.Value.absent(),
                          titulo: drift.Value(_tituloController.text.trim()),
                          descripcion: drift.Value(_descripcionController.text.trim()),
                          fechaInicio: drift.Value(start),
                          fechaFin: drift.Value(end),
                          esRecurrente: drift.Value(_esRecurrente),
                          patronRecurrencia: drift.Value(_esRecurrente ? 'WEEKLY' : null),
                          transaccionId: drift.Value(_selectedTransaccionId),
                        );

                        await widget.notifier.guardarEvento(companion);

                        if (mounted) {
                          Navigator.pop(context);
                          AppToast.show(context, message: esEdicion ? 'Evento actualizado.' : 'Evento creado con éxito.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      esEdicion ? 'Guardar Cambios' : 'Guardar Evento',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

// =============================================================================
// 📝 MODAL PARA AGREGAR / EDITAR TAREAS DESDE EL CALENDARIO
// =============================================================================
class _AddTareaModal extends StatefulWidget {
  final DateTime selectedDate;
  final int? initialHour;
  final Tarea? tareaToEdit;
  final TipoTarea? initialTipo;
  final TasksNotifier notifier;

  const _AddTareaModal({
    required this.selectedDate,
    this.initialHour,
    this.tareaToEdit,
    this.initialTipo,
    required this.notifier,
  });

  @override
  State<_AddTareaModal> createState() => _AddTareaModalState();
}

class _AddTareaModalState extends State<_AddTareaModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  late DateTime _fechaSeleccionada;
  TipoTarea _tipoSeleccionado = TipoTarea.entrega;
  late TimeOfDay _horaVencimiento;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.tareaToEdit?.fecha ?? widget.selectedDate;
    if (widget.tareaToEdit != null) {
      final t = widget.tareaToEdit!;
      _tituloController.text = t.titulo;
      _descripcionController.text = t.descripcion ?? '';
      _tipoSeleccionado = t.tipo;
      _horaVencimiento = TimeOfDay(hour: t.fecha.hour, minute: t.fecha.minute);
    } else {
      _tipoSeleccionado = widget.initialTipo ?? TipoTarea.entrega;
      final startH = widget.initialHour ?? 12;
      _horaVencimiento = TimeOfDay(hour: startH, minute: 0);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaVencimiento,
    );
    if (picked != null) {
      setState(() {
        _horaVencimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.tareaToEdit != null;

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
                  Text(
                    esEdicion ? 'Editar Tarea / Evaluación' : 'Agregar Tarea / Evaluación',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la Tarea / Evaluación',
                      prefixIcon: Icon(Icons.assignment_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<TipoTarea>(
                    value: _tipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Actividad',
                      prefixIcon: Icon(Icons.category_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: TipoTarea.entrega, child: Text('Entrega de Trabajo')),
                      DropdownMenuItem(value: TipoTarea.parcial, child: Text('Parcial / Examen')),
                      DropdownMenuItem(value: TipoTarea.TP, child: Text('Trabajo Práctico (TP)')),
                      DropdownMenuItem(value: TipoTarea.estudio, child: Text('Cumpleaños 🎂')),
                      DropdownMenuItem(value: TipoTarea.otro, child: Text('Recuerdo / Notas 📝')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _tipoSeleccionado = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Detalles (Opcional)',
                      prefixIcon: Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _seleccionarFecha(context),
                          icon: const Icon(Icons.calendar_today_rounded),
                          label: Text('Fecha: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _seleccionarHora(context),
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text('Hora: ${_horaVencimiento.format(context)}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final baseDate = _fechaSeleccionada;
                        final fechaCompleta = DateTime(
                          baseDate.year,
                          baseDate.month,
                          baseDate.day,
                          _horaVencimiento.hour,
                          _horaVencimiento.minute,
                        );

                        final companion = TareasCompanion(
                          id: esEdicion ? drift.Value(widget.tareaToEdit!.id) : const drift.Value.absent(),
                          titulo: drift.Value(_tituloController.text.trim()),
                          descripcion: drift.Value(_descripcionController.text.trim()),
                          fecha: drift.Value(fechaCompleta),
                          tipo: drift.Value(_tipoSeleccionado),
                          completada: esEdicion ? drift.Value(widget.tareaToEdit!.completada) : const drift.Value(false),
                        );

                        await widget.notifier.guardarTarea(companion);

                        if (mounted) {
                          Navigator.pop(context);
                          AppToast.show(context, message: esEdicion ? 'Tarea actualizada.' : 'Tarea agregada con éxito.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      esEdicion ? 'Guardar Cambios' : 'Guardar Tarea',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
