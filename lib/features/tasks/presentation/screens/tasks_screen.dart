import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../../../core/enums.dart';
import '../../../../core/services/mercadopago_cobro_service.dart';
import '../controllers/tasks_notifier.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksNotifier = Provider.of<TasksNotifier>(context);
    final expensesNotifier = Provider.of<ExpensesNotifier>(context);

    final filteredList = tasksNotifier.tareasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: const Text(
          'Tareas & Evaluaciones',
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
          // 1. SEARCH BAR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => tasksNotifier.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Buscar tarea, amigo o detalle...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          tasksNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFF1F5F9), // Slate 100
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. STATE FILTER CHIPS (Todas, Pendientes, Completadas)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildStateChip(tasksNotifier, 0, 'Todas'),
                const SizedBox(width: 8),
                _buildStateChip(tasksNotifier, 1, 'Pendientes'),
                const SizedBox(width: 8),
                _buildStateChip(tasksNotifier, 2, 'Completadas'),
              ],
            ),
          ),

          // 3. TYPE FILTER CHIPS (Horizontal Scrollable list)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTypeChip(tasksNotifier, null, 'Todos'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.parcial, 'Parciales'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.entrega, 'Entregas'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.TP, 'TPs'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.estudio, 'Cumpleaños 🎂'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.deudas, 'Deudas 💵'),
                const SizedBox(width: 8),
                _buildTypeChip(tasksNotifier, TipoTarea.otro, 'Recuerdos / Notas 📝'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 4. TASK LIST
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.assignment_turned_in_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text(
                          'No hay tareas',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 18),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Intenta cambiar los filtros o agrega una nueva tarea.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildTaskTile(context, item, tasksNotifier);
                    },
                  ),
          ),
        ],
      ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 28),
          onPressed: () => _mostrarAddTaskBottomSheet(context, tasksNotifier, expensesNotifier),
        ),
      ),
    );
  }

  Widget _buildStateChip(TasksNotifier notifier, int state, String label) {
    final isSelected = notifier.filtroEstado == state;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFE2E8F0),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
      ),
      onSelected: (val) {
        if (val) notifier.setFiltroEstado(state);
      },
    );
  }

  Widget _buildTypeChip(TasksNotifier notifier, TipoTarea? tipo, String label) {
    final isSelected = notifier.filtroTipo == tipo;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: tipo == TipoTarea.deudas ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? (tipo == TipoTarea.deudas ? const Color(0xFFB45309) : const Color(0xFF0369A1))
            : const Color(0xFF64748B),
      ),
      onSelected: (val) {
        if (val) notifier.setFiltroTipo(tipo);
      },
    );
  }

  Widget _buildTaskTile(BuildContext context, Tarea t, TasksNotifier notifier) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: t.completada ? Colors.green : badgeColor, width: 5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: t.completada,
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  t.fecha.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (t.tipo == TipoTarea.deudas)
              IconButton(
                icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF009EE3)),
                tooltip: 'Generar Link de Cobro Mercado Pago',
                onPressed: () {
                  final monto = notifier.obtenerMontoDeuda(t);
                  MercadoPagoCobroService.mostrarDialogoCobro(
                    context,
                    titulo: t.titulo,
                    monto: monto > 0 ? monto : 1000.0,
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Tarea'),
                    content: const Text('¿Deseas eliminar esta tarea de la lista?'),
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
                  await notifier.eliminarTarea(t.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAddTaskBottomSheet(
    BuildContext context,
    TasksNotifier notifier,
    ExpensesNotifier expNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddTaskModal(
          notifier: notifier,
          expNotifier: expNotifier,
        );
      },
    );
  }
}

class _AddTaskModal extends StatefulWidget {
  final TasksNotifier notifier;
  final ExpensesNotifier expNotifier;

  const _AddTaskModal({
    required this.notifier,
    required this.expNotifier,
  });

  @override
  State<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<_AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  // Campos específicos para Deudas
  final _montoController = TextEditingController();
  final _amigoManualController = TextEditingController();
  int? _selectedConocidoId;

  TipoTarea _tipoSeleccionado = TipoTarea.otro;
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _montoController.dispose();
    _amigoManualController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final esDeuda = _tipoSeleccionado == TipoTarea.deudas;

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
                  esDeuda ? 'Registrar Deuda' : 'Agregar Tarea',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),

                // --- DROP DOWN TIPO ---
                DropdownButtonFormField<TipoTarea>(
                  value: _tipoSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Tarea',
                    prefixIcon: Icon(Icons.category_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: TipoTarea.parcial, child: Text('Parcial', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: TipoTarea.entrega, child: Text('Entrega', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: TipoTarea.TP, child: Text('Trabajo Práctico (TP)', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: TipoTarea.estudio, child: Text('Cumpleaños 🎂', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: TipoTarea.deudas, child: Text('Deuda 💵', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: TipoTarea.otro, child: Text('Recuerdo / Notas 📝', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _tipoSeleccionado = val;
                        // Si cambiamos a deuda, autodefinimos el título preliminar
                        if (_tipoSeleccionado == TipoTarea.deudas && _tituloController.text.isEmpty) {
                          _tituloController.text = 'Deuda';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // --- TÍTULO ---
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: esDeuda ? 'Concepto de la Deuda' : 'Título de la Tarea',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // --- DEUDA SPECIALIZED FIELDS ---
                if (esDeuda) ...[
                  // 1. Campo numérico para Monto
                  TextFormField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: r'Monto de la Deuda ($)',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa un monto';
                      if (double.tryParse(v) == null) return 'Monto inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Selector de Conocidos + Entrada Manual
                  DropdownButtonFormField<int?>(
                    value: _selectedConocidoId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'A quién le debes (Conocido)',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Otro (Escribir nombre abajo)', overflow: TextOverflow.ellipsis),
                      ),
                      ...widget.expNotifier.conocidos.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.nombreCompleto, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedConocidoId = val;
                        // Actualizar título automáticamente si seleccionan a alguien
                        if (_selectedConocidoId != null) {
                          final c = widget.expNotifier.conocidos.firstWhere((x) => x.id == _selectedConocidoId);
                          _tituloController.text = 'Deuda con ${c.nombre}';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_selectedConocidoId == null) ...[
                    TextFormField(
                      controller: _amigoManualController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del amigo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (_selectedConocidoId == null && (v == null || v.trim().isEmpty)) {
                          return 'Ingresa el nombre del amigo';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        if (_selectedConocidoId == null) {
                          _tituloController.text = 'Deuda con $val';
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Detalles adicionales
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles adicionales (Ej: Pizza, Asado)',
                      prefixIcon: Icon(Icons.info_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // --- CAMPO DESCRIPCIÓN NORMAL ---
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Detalles de la tarea',
                      prefixIcon: Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                ],

                // --- FECHA LÍMITE ---
                OutlinedButton.icon(
                  onPressed: () => _seleccionarFecha(context),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text('Fecha Límite: ${_fechaSeleccionada.toString().split(' ')[0]}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String finalDesc = _descripcionController.text.trim();

                      if (esDeuda) {
                        final double monto = double.parse(_montoController.text);
                        String amigoName = '';
                        if (_selectedConocidoId != null) {
                          final c = widget.expNotifier.conocidos.firstWhere((x) => x.id == _selectedConocidoId);
                          amigoName = c.nombreCompleto;
                        } else {
                          amigoName = _amigoManualController.text.trim();
                        }
                        finalDesc = TasksNotifier.formatearDescripcionDeuda(
                          monto,
                          amigoName,
                          _descripcionController.text.trim(),
                        );
                      }

                      await widget.notifier.guardarTarea(
                        TareasCompanion.insert(
                          titulo: _tituloController.text.trim(),
                          descripcion: drift.Value(finalDesc.isEmpty ? null : finalDesc),
                          fecha: _fechaSeleccionada,
                          tipo: _tipoSeleccionado,
                          completada: const drift.Value(false),
                        ),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(esDeuda ? 'Deuda registrada con éxito.' : 'Tarea agregada con éxito.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    esDeuda ? 'Guardar Deuda' : 'Guardar Tarea',
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
