import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/app_toast.dart';

class FutureAdjustmentsModal extends StatefulWidget {
  final DateTime focusedDate;

  const FutureAdjustmentsModal({
    super.key,
    required this.focusedDate,
  });

  static void show(BuildContext context, DateTime focusedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FutureAdjustmentsModal(focusedDate: focusedDate),
    );
  }

  static void showAddDialog(BuildContext context, DateTime focusedDate) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    bool esIngreso = false;
    DateTime fechaEstimada = focusedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Nuevo Ajuste Proyectado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Concepto (ej: Cobro cliente, Alquiler)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá un concepto' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: montoCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: r'Monto ($)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresá un monto';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null || !val.isFinite || val <= 0) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Gasto / Deuda (-)'),
                            selected: !esIngreso,
                            selectedColor: const Color(0xFFFEE2E2),
                            labelStyle: TextStyle(
                              color: !esIngreso ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setDialogState(() => esIngreso = !val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Ingreso (+)'),
                            selected: esIngreso,
                            selectedColor: const Color(0xFFD1FAE5),
                            labelStyle: TextStyle(
                              color: esIngreso ? const Color(0xFF10B981) : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setDialogState(() => esIngreso = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fechaEstimada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => fechaEstimada = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text('Fecha: ${fechaEstimada.day}/${fechaEstimada.month}/${fechaEstimada.year}'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final raw = montoCtrl.text.replaceAll(',', '.').trim();
                      final monto = double.parse(raw);

                      await db.agregarAjusteProyectado(
                        descripcion: descCtrl.text.trim(),
                        monto: monto,
                        esIngreso: esIngreso,
                        fecha: fechaEstimada,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        AppToast.show(context, message: 'Ajuste proyectado guardado correctamente');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  State<FutureAdjustmentsModal> createState() => _FutureAdjustmentsModalState();
}

class _FutureAdjustmentsModalState extends State<FutureAdjustmentsModal> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  bool _esIngreso = false; // por defecto egreso/deuda
  DateTime _fechaEstimada = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  void _mostrarFormularioCrear(BuildContext context, AppDatabase db) {
    _descCtrl.clear();
    _montoCtrl.clear();
    _esIngreso = false;
    _fechaEstimada = widget.focusedDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Nuevo Ajuste Proyectado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Concepto (ej: Pago deuda, Cobro)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá un concepto' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _montoCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: r'Monto ($)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresá un monto';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null || !val.isFinite || val <= 0) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Gasto / Deuda (-)'),
                            selected: !_esIngreso,
                            selectedColor: const Color(0xFFFEE2E2),
                            labelStyle: TextStyle(
                              color: !_esIngreso ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setDialogState(() => _esIngreso = !val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Ingreso (+)'),
                            selected: _esIngreso,
                            selectedColor: const Color(0xFFD1FAE5),
                            labelStyle: TextStyle(
                              color: _esIngreso ? const Color(0xFF10B981) : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setDialogState(() => _esIngreso = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaEstimada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => _fechaEstimada = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text('Fecha: ${_fechaEstimada.day}/${_fechaEstimada.month}/${_fechaEstimada.year}'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final raw = _montoCtrl.text.replaceAll(',', '.').trim();
                      final monto = double.parse(raw);

                      await db.agregarAjusteProyectado(
                        descripcion: _descCtrl.text.trim(),
                        monto: monto,
                        esIngreso: _esIngreso,
                        fecha: _fechaEstimada,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        AppToast.show(context, message: 'Ajuste proyectado guardado correctamente');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajustes & Variables Futuras',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Ingresos o deudas proyectadas para el mes',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton.filled(
                    onPressed: () => _mostrarFormularioCrear(context, db),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            Expanded(
              child: StreamBuilder<List<AjusteProyectado>>(
                stream: db.watchAjustesProyectados(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snapshot.data!.where((a) {
                    return a.fecha.year == widget.focusedDate.year && a.fecha.month == widget.focusedDate.month;
                  }).toList();

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note_rounded, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          const Text(
                            'No hay ajustes proyectados',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Agregá cobros o deudas futuras para contemplarlas.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final esIngreso = item.esIngreso;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: item.completado ? const Color(0xFFF8FAFC) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.completado ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: esIngreso ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                            child: Icon(
                              esIngreso ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.descripcion,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: item.completado ? TextDecoration.lineThrough : null,
                              color: item.completado ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                            ),
                          ),
                          subtitle: Text(
                            '${item.fecha.day}/${item.fecha.month}/${item.fecha.year}' +
                                (item.completado ? ' • COMPLETADO (Recibido/Pagado)' : ' • PENDIENTE'),
                            style: TextStyle(
                              fontSize: 11,
                              color: item.completado ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${esIngreso ? '+' : '-'}\$${item.monto.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: item.completado
                                      ? const Color(0xFF94A3B8)
                                      : (esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: item.completado,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  db.alternarCompletadoAjusteProyectado(item.id, val ?? false);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                onPressed: () {
                                  db.eliminarAjusteProyectado(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
