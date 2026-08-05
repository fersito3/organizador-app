import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../domain/models/transaccion.dart';
import '../../domain/models/categoria_domain.dart';
import '../controllers/expenses_notifier.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Limpiamos filtros al entrar para asegurar estado fresco
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<ExpensesNotifier>(context, listen: false);
      notifier.setFiltroBusqueda('');
      notifier.setFiltroTipo(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        title: const Text(
          'Finanzas & Gastos',
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
        actions: [
          Consumer<ExpensesNotifier>(
            builder: (context, notifier, child) {
              if (notifier.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF0F172A)),
                tooltip: 'Sincronizar Mercado Pago',
                onPressed: () async {
                  await notifier.sincronizarMercadoPago();
                  if (context.mounted) {
                    final err = notifier.syncErrorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err != null
                            ? 'Error al sincronizar: $err'
                            : 'Sincronización de Mercado Pago completada con éxito.'),
                        backgroundColor: err != null ? Colors.red : Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpensesNotifier>(
        builder: (context, notifier, child) {
          return Column(
            children: [
              // 1. FILTER SUMMARY CARD (DASHBOARD CARD FOR FILTERED VALUE)
              _buildFilteredSummaryCard(notifier),

              // Status banner for background synchronization
              if (notifier.isSyncing || notifier.syncErrorMessage != null)
                _buildSyncStatusBanner(notifier),

              // 2. SEARCH BAR & CHIPS SECTION
              _buildSearchAndFilters(notifier),

              // 3. TRANSACTIONS LIST
              Expanded(
                child: notifier.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTransactionsList(notifier),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.routeAddTransaction);
        },
        backgroundColor: const Color(0xFF0F172A), // Slate 900
        tooltip: 'Nueva Transacción',
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  // Interactive Summary Card (Filtered totals)
  Widget _buildFilteredSummaryCard(ExpensesNotifier notifier) {
    final balance = notifier.balanceFiltrado;
    final ingresos = notifier.totalIngresosFiltrados;
    final egresos = notifier.totalEgresosFiltrados;
    final esNegativo = balance < 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B), // Slate 800
            Color(0xFF0F172A), // Slate 900
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo de Selección',
            style: TextStyle(
              color: Color(0xFF94A3B8), // Slate 400
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${esNegativo ? '-' : ''}\$${balance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: esNegativo ? const Color(0xFFF87171) : Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, color: Color(0xFF34D399), size: 16),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ingresos', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        Text(
                          '\$${ingresos.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(height: 24, width: 1, color: const Color(0xFF334155)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.arrow_downward_rounded, color: Color(0xFFF87171), size: 16),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gastos', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        Text(
                          '\$${egresos.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Search input and Category/Type chips
  Widget _buildSearchAndFilters(ExpensesNotifier notifier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: _searchController,
            onChanged: (val) => notifier.setFiltroBusqueda(val),
            decoration: InputDecoration(
              hintText: 'Buscar descripción, emisor o receptor...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        notifier.setFiltroBusqueda('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FilterChip(
                label: const Text('Todos'),
                selected: notifier.filtroTipo == null,
                selectedColor: const Color(0xFFE2E8F0),
                labelStyle: TextStyle(
                  color: notifier.filtroTipo == null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.setFiltroTipo(null),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Ingresos'),
                selected: notifier.filtroTipo == TipoTransaccion.ingreso,
                selectedColor: const Color(0xFFD1FAE5), // Soft green
                labelStyle: TextStyle(
                  color: notifier.filtroTipo == TipoTransaccion.ingreso
                      ? const Color(0xFF065F46)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.setFiltroTipo(TipoTransaccion.ingreso),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Gastos'),
                selected: notifier.filtroTipo == TipoTransaccion.egreso,
                selectedColor: const Color(0xFFFEE2E2), // Soft red
                labelStyle: TextStyle(
                  color: notifier.filtroTipo == TipoTransaccion.egreso
                      ? const Color(0xFF991B1B)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                onSelected: (_) => notifier.setFiltroTipo(TipoTransaccion.egreso),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Transactions list view
  Widget _buildTransactionsList(ExpensesNotifier notifier) {
    final list = notifier.transaccionesFiltradas;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron transacciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Prueba ajustando los filtros o añade un nuevo registro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = list[index];
        final esEgreso = item.tipo == TipoTransaccion.egreso;
        final categoria = notifier.findCategoriaById(item.categoriaId);

        // Parse category color
        int colorValue = 0xFF9E9E9E; // Default grey
        if (categoria != null) {
          try {
            colorValue = int.parse('FF${categoria.colorHex}', radix: 16);
          } catch (_) {}
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showTransactionDetails(context, item, categoria),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Circular profile picture or fallback arrow icon
                      Builder(
                        builder: (context) {
                          final tieneEntidad = item.destinatarioEmisor != null && item.destinatarioEmisor!.isNotEmpty;
                          if (tieneEntidad) {
                            final initialsUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(item.destinatarioEmisor!)}&background=0F172A&color=ffffff&bold=true&size=128';
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                initialsUrl,
                                width: 44,
                                height: 44,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Color(colorValue).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      esEgreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      color: Color(colorValue),
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(colorValue).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              esEgreso ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: Color(colorValue),
                              size: 20,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      // Core details (Description, category, sender/receiver)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.descripcion,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Category Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(colorValue).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    categoria?.nombre ?? 'Varios',
                                    style: TextStyle(
                                      color: Color(colorValue),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Date text
                                Text(
                                  item.fecha.toString().split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            if (item.destinatarioEmisor != null &&
                                item.destinatarioEmisor!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.destinatarioEmisor!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF475569),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Amount
                      Text(
                        '${esEgreso ? '-' : '+'}\$${item.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: esEgreso ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaccion item,
    CategoriaDomain? categoria,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _TransactionDetailModal(
          item: item,
          initialCategoria: categoria,
        );
      },
    );
  }

  // Banner informativo del estado de la sincronización de Mercado Pago
  Widget _buildSyncStatusBanner(ExpensesNotifier notifier) {
    final isError = notifier.syncErrorMessage != null;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF), // Rojo suave o Azul suave
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? const Color(0xFFFCA5A5) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 16,
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF1D4ED8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isError
                  ? 'Error al conectar con Render: ${notifier.syncErrorMessage}. Vuelve a intentar.'
                  : 'Despertando servidor en Render y sincronizando... (puede tardar hasta 1 minuto por arranque en frío)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isError ? const Color(0xFF991B1B) : const Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailModal extends StatefulWidget {
  final Transaccion item;
  final CategoriaDomain? initialCategoria;

  const _TransactionDetailModal({
    Key? key,
    required this.item,
    this.initialCategoria,
  }) : super(key: key);

  @override
  State<_TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<_TransactionDetailModal> {
  bool _isEditing = false;
  late TextEditingController _descripcionController;
  int? _selectedCategoriaId;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.item.descripcion);
    _selectedCategoriaId = widget.item.categoriaId;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ExpensesNotifier>(context);
    final esEgreso = widget.item.tipo == TipoTransaccion.egreso;
    
    final categoria = notifier.categorias.firstWhere(
      (c) => c.id == _selectedCategoriaId,
      orElse: () => widget.initialCategoria ?? CategoriaDomain(id: 0, nombre: 'Varios', colorHex: '9E9E9E', tipo: widget.item.tipo),
    );

    int colorValue = 0xFF9E9E9E;
    try {
      colorValue = int.parse('FF${categoria.colorHex}', radix: 16);
    } catch (_) {}

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar Transacción' : 'Detalle de Transacción',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.visibility_rounded : Icons.edit_rounded,
                      color: const Color(0xFF0F172A),
                    ),
                    tooltip: _isEditing ? 'Ver detalle' : 'Editar transacción',
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_isEditing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.descripcion,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      '${esEgreso ? '-' : '+'}\$${widget.item.monto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: esEgreso ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 20),

                _buildDetailRow(
                  icon: Icons.category_rounded,
                  label: 'Categoría',
                  valueWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(colorValue).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categoria.nombre,
                      style: TextStyle(
                        color: Color(colorValue),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Fecha',
                  value: widget.item.fecha.toString().split(' ')[0],
                ),
                const SizedBox(height: 14),

                _buildDetailRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Tipo',
                  value: esEgreso ? 'Gasto / Egreso' : 'Ingreso',
                ),
                const SizedBox(height: 14),

                if (widget.item.destinatarioEmisor != null && widget.item.destinatarioEmisor!.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.person_rounded,
                    label: esEgreso ? 'Destinatario' : 'Emisor / Remitente',
                    value: widget.item.destinatarioEmisor!,
                  ),
                  const SizedBox(height: 14),
                ],

                _buildDetailRow(
                  icon: Icons.source_rounded,
                  label: 'Origen / Canal',
                  value: widget.item.proveedor == 'MP' ? 'Mercado Pago' : 'Manual',
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Eliminación'),
                              content: const Text('¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            if (context.mounted) {
                              await notifier.eliminarTransaccion(widget.item.id);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transacción eliminada con éxito.'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción / Título',
                    hintText: 'Ej. Compra en Coto',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: _selectedCategoriaId,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: notifier.categorias
                      .where((c) => c.tipo == widget.item.tipo)
                      .map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.nombre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoriaId = val;
                    });
                  },
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _descripcionController.text = widget.item.descripcion;
                            _selectedCategoriaId = widget.item.categoriaId;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF64748B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final nuevaDesc = _descripcionController.text.trim();
                          if (nuevaDesc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('La descripción no puede estar vacía.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          await notifier.actualizarTransaccion(
                            widget.item.id,
                            nuevaDesc,
                            _selectedCategoriaId ?? widget.item.categoriaId,
                          );

                          setState(() {
                            _isEditing = false;
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cambios guardados con éxito.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget
        else if (value != null)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
      ],
    );
  }
}
