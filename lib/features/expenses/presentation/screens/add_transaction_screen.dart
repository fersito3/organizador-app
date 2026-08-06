import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums.dart';
import '../../../../core/widgets/app_toast.dart';
import '../controllers/add_transaction_notifier.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  final _destinatarioEmisorController = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    _destinatarioEmisorController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction(AddTransactionNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final rawMonto = _montoController.text.replaceAll(',', '.').trim();
    final monto = double.tryParse(rawMonto);
    if (monto == null || !monto.isFinite || monto <= 0) {
      AppToast.show(context, message: 'Ingresá un monto válido mayor a 0.', isError: true);
      return;
    }

    try {
      await notifier.save(
        descripcion: _descripcionController.text,
        monto: monto,
        destinatarioEmisor: _destinatarioEmisorController.text.trim().isEmpty
            ? null
            : _destinatarioEmisorController.text,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Error al guardar la transacción: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        centerTitle: true,
      ),
      body: Consumer<AddTransactionNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoadingCategories) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SELECTOR DE TIPO (EGRESO / INGRESO) ---
                  Center(
                    child: SegmentedButton<TipoTransaccion>(
                      segments: const [
                        ButtonSegment(
                          value: TipoTransaccion.egreso,
                          label: Text('Gasto / Egreso'),
                          icon: Icon(Icons.arrow_downward, color: Colors.red),
                        ),
                        ButtonSegment(
                          value: TipoTransaccion.ingreso,
                          label: Text('Ingreso'),
                          icon: Icon(Icons.arrow_upward, color: Colors.green),
                        ),
                      ],
                      selected: {notifier.tipoSeleccionado},
                      onSelectionChanged: (Set<TipoTransaccion> selection) {
                        notifier.selectTipo(selection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CAMPO MONTO ---
                  TextFormField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: r'Monto ($)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DESCRIPCIÓN ---
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa una descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- SELECTOR DE CONOCIDO ---
                  DropdownButtonFormField<int?>(
                    value: notifier.conocidoIdSeleccionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Contacto (Conocido)',
                      prefixIcon: Icon(Icons.people_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text(
                          'Ninguno (Desconocido / Temporal)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...notifier.conocidos.map((c) {
                        final descStr = c.mpUserId != null ? '(Mercado Pago)' : '(Sin MP)';
                        return DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(
                            '${c.nombreCompleto} $descStr',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (int? value) {
                      notifier.selectConocido(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DESTINATARIO / EMISOR (Solo si es desconocido) ---
                  if (notifier.conocidoIdSeleccionado == null) ...[
                    TextFormField(
                      controller: _destinatarioEmisorController,
                      decoration: const InputDecoration(
                        labelText: 'Destinatario / Emisor (Opcional)',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- CAMPO CATEGORÍA (FILTRADO DINÁMICO) ---
                  DropdownButtonFormField<int>(
                    value: notifier.categoriaIdSeleccionada,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: notifier.filteredCategories.map((cat) {
                      int colorValue = 0xFF9E9E9E;
                      try {
                        colorValue = int.parse('FF${cat.colorHex}', radix: 16);
                      } catch (_) {}

                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      notifier.selectCategoria(val);
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona una categoría' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- SELECTOR DE FECHA ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          'Fecha: ${notifier.fechaSeleccionada.toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final chosen = await showDatePicker(
                              context: context,
                              initialDate: notifier.fechaSeleccionada,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (chosen != null) {
                              notifier.selectFecha(chosen);
                            }
                          },
                          child: const Text('Cambiar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- BOTÓN DE GUARDAR ---
                  ElevatedButton(
                    onPressed: notifier.isSaving ? null : () => _saveTransaction(notifier),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: notifier.isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar Transacción',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
