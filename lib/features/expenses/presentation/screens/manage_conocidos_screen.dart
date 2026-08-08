import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';

import '../controllers/expenses_notifier.dart';
import '../../domain/models/conocido.dart';

class ManageConocidosScreen extends StatefulWidget {
  const ManageConocidosScreen({super.key});

  @override
  State<ManageConocidosScreen> createState() => _ManageConocidosScreenState();
}

class _ManageConocidosScreenState extends State<ManageConocidosScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpensesNotifier>(context, listen: false).cargarConocidos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final notifier = Provider.of<ExpensesNotifier>(context);
    final list = notifier.conocidos.where((c) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final coincideNom = c.nombre.toLowerCase().contains(query);
      final coincideApe = c.apellido.toLowerCase().contains(query);
      final coincideMp = c.mpUserId?.toLowerCase().contains(query) ?? false;
      return coincideNom || coincideApe || coincideMp;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Administrar Contactos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar contacto o ID...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contacts List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty ? Icons.people_outline_rounded : Icons.search_off_rounded,
                          size: 64,
                          color: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No tienes contactos' : 'Sin resultados',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Crea un contacto conocido con el botón de abajo.'
                              : 'Prueba con otro término de búsqueda.',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final c = list[index];
                      return _buildContactoTile(context, c, notifier);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        tooltip: 'Nuevo Contacto',
        child: const Icon(Icons.person_add_alt_1_rounded, size: 26),
        onPressed: () => _mostrarUpsertContactoDialog(context, notifier),
      ),
    );
  }

  Widget _buildContactoTile(BuildContext context, Conocido c, ExpensesNotifier notifier) {
    final isDark = AppColors.isDarkMode(context);
    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);

    final sinMpId = c.mpUserId == null || c.mpUserId!.trim().isEmpty;
    final initialsUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(c.nombreCompleto)}&background=${isDark ? "1E293B" : "0F172A"}&color=ffffff&bold=true&size=128';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: borderColor) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            initialsUrl,
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => CircleAvatar(
              backgroundColor: isDark ? AppColors.darkSubSurface : Colors.grey.shade200,
              child: Icon(Icons.person_rounded, color: isDark ? AppColors.darkTextSecondary : Colors.grey),
            ),
          ),
        ),
        title: Text(
          c.nombreCompleto,
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (sinMpId)
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    'Sin ID de Mercado Pago',
                    style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'ID MP: ${c.mpUserId}',
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: textSecondary, size: 20),
              onPressed: () => _mostrarUpsertContactoDialog(context, notifier, conocido: c),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
              onPressed: () => _eliminarContactoConfirmacion(context, c, notifier),
            ),
          ],
        ),
      ),
    );

  }

  void _eliminarContactoConfirmacion(BuildContext context, Conocido c, ExpensesNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Contacto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${c.nombreCompleto}? '
          'Todas sus transacciones vinculadas volverán a mostrarse sin un contacto asociado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await notifier.eliminarConocido(c.id);
              if (context.mounted) {
                AppToast.show(context, message: 'Contacto ${c.nombreCompleto} eliminado.', isError: true);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarUpsertContactoDialog(
    BuildContext context,
    ExpensesNotifier notifier, {
    Conocido? conocido,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _UpsertContactoDialog(
          notifier: notifier,
          conocido: conocido,
        );
      },
    );
  }
}

class _UpsertContactoDialog extends StatefulWidget {
  final ExpensesNotifier notifier;
  final Conocido? conocido;

  const _UpsertContactoDialog({
    required this.notifier,
    this.conocido,
  });

  @override
  State<_UpsertContactoDialog> createState() => _UpsertContactoDialogState();
}

class _UpsertContactoDialogState extends State<_UpsertContactoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _mpUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.conocido != null) {
      _nombreController.text = widget.conocido!.nombre;
      _apellidoController.text = widget.conocido!.apellido;
      _mpUserController.text = widget.conocido!.mpUserId ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _mpUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.conocido != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        esEdicion ? 'Editar Contacto' : 'Nuevo Contacto',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mpUserController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID de Mercado Pago (Opcional)',
                  border: OutlineInputBorder(),
                  helperText: 'Se usa para asociar automáticamente las transferencias',
                  helperStyle: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final nom = _nombreController.text.trim();
              final ape = _apellidoController.text.trim();
              final mpId = _mpUserController.text.trim().isEmpty ? null : _mpUserController.text.trim();

              if (esEdicion) {
                // Actualizar contacto existente
                await widget.notifier.guardarConocido(
                  id: widget.conocido!.id,
                  nombre: nom,
                  apellido: ape,
                  mpUserId: mpId,
                );
                // Si cambiamos el ID de MP, re-asociamos todas las transacciones históricas con ese ID!
                if (mpId != null) {
                  await widget.notifier.asociarTransaccionesConConocido(
                    mpUserId: mpId,
                    conocidoId: widget.conocido!.id,
                    nombreCompleto: '$nom $ape'.trim(),
                  );
                }
              } else {
                // Crear contacto de cero
                final newId = await widget.notifier.guardarConocido(
                  nombre: nom,
                  apellido: ape,
                  mpUserId: mpId,
                );
                // Si el contacto nuevo tiene un ID de MP cargado, asociamos cualquier transacción existente!
                if (mpId != null) {
                  await widget.notifier.asociarTransaccionesConConocido(
                    mpUserId: mpId,
                    conocidoId: newId,
                    nombreCompleto: '$nom $ape'.trim(),
                  );
                }
              }

              if (context.mounted) {
                Navigator.pop(context);
                AppToast.show(context, message: esEdicion ? 'Contacto actualizado.' : 'Contacto creado.');
              }
            }
          },
          child: Text(
            esEdicion ? 'Guardar Cambios' : 'Crear Contacto',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
