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
                      // Leading color circle and arrow icon
                      Container(
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
                                      esEgreso
                                          ? 'Para: ${item.destinatarioEmisor}'
                                          : 'De: ${item.destinatarioEmisor}',
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

  // Display detail Modal Bottom Sheet
  void _showTransactionDetails(
    BuildContext context,
    Transaccion item,
    CategoriaDomain? categoria,
  ) {
    final esEgreso = item.tipo == TipoTransaccion.egreso;

    // Parse category color
    int colorValue = 0xFF9E9E9E; // Default grey
    if (categoria != null) {
      try {
        colorValue = int.parse('FF${categoria.colorHex}', radix: 16);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Indicator line
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Modal Title
                const Text(
                  'Detalle de Transacción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.descripcion,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      '${esEgreso ? '-' : '+'}\$${item.monto.toStringAsFixed(2)}',
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

                // Info Rows
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
                      categoria?.nombre ?? 'Sin Categoría',
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
                  value: item.fecha.toString().split(' ')[0],
                ),
                const SizedBox(height: 14),

                _buildDetailRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Tipo',
                  value: esEgreso ? 'Gasto / Egreso' : 'Ingreso',
                ),
                const SizedBox(height: 14),

                if (item.destinatarioEmisor != null && item.destinatarioEmisor!.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.person_rounded,
                    label: esEgreso ? 'Destinatario' : 'Emisor / Remitente',
                    value: item.destinatarioEmisor!,
                  ),
                  const SizedBox(height: 14),
                ],

                _buildDetailRow(
                  icon: Icons.source_rounded,
                  label: 'Origen / Canal',
                  value: 'Manual', // Currently all added manual, we'll implement MP later
                ),

                const SizedBox(height: 24),
                
                // Close button
                SizedBox(
                  width: double.infinity,
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
          ),
        );
      },
    );
  }

  // Helper row builder for details
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
