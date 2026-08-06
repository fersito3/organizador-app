import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../expenses/presentation/controllers/expenses_notifier.dart';
import '../../domain/services/financial_analytics_service.dart';
import '../widgets/financial_header_card.dart';
import '../widgets/today_spending_card.dart';
import '../widgets/financial_alerts_list.dart';
import '../widgets/historical_comparison_card.dart';
import '../widgets/top_categories_card.dart';
import '../widgets/future_adjustments_modal.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final expensesNotifier = Provider.of<ExpensesNotifier>(context);

    return StreamBuilder<List<AjusteProyectado>>(
      stream: db.watchAjustesProyectados(),
      builder: (context, snapshot) {
        final ajustes = snapshot.data ?? [];

        final summary = FinancialAnalyticsService.calcularResumenFinanciero(
          transacciones: expensesNotifier.transacciones,
          categorias: expensesNotifier.categorias,
          focusedDate: _focusedDate,
          ajustesProyectados: ajustes,
        );

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
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF0F172A)),
                tooltip: 'Ajustes Proyectados Futuros',
                onPressed: () => FutureAdjustmentsModal.show(context, _focusedDate),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAVEGADOR DE MES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Color(0xFF475569)),
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                          });
                        },
                      ),
                      Text(
                        '${_meses[_focusedDate.month - 1]} ${_focusedDate.year}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 28, color: Color(0xFF475569)),
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // BOTÓN RAPIDO PARA AJUSTES PROYECTADOS
                  OutlinedButton.icon(
                    onPressed: () => FutureAdjustmentsModal.show(context, _focusedDate),
                    icon: const Icon(Icons.auto_graph_rounded, size: 18, color: Color(0xFF4F46E5)),
                    label: Text(
                      ajustes.isEmpty
                          ? '⚙️ Agregar ingresos/deudas futuras del mes'
                          : '⚙️ Ver ajustes proyectados futuros (${ajustes.length})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF2FF),
                      side: const BorderSide(color: Color(0xFFC7D2FE)),
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1. TARJETA HEADER (DISPONIBLE MES & DISPONIBLE DIARIO ESTIMADO)
                  FinancialHeaderCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 16),

                  // 2. GASTO REGISTRADO HOY
                  TodaySpendingCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  if (summary.alertas.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // 3. SECCIÓN DE ALERTAS INTELIGENTES NEUTRALES
                    FinancialAlertsList(alertas: summary.alertas),
                  ],

                  const SizedBox(height: 24),

                  // 4. COMPARATIVA Y HÁBITOS HISTÓRICOS
                  HistoricalComparisonCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 24),

                  // 5. TOP CATEGORÍAS DE MAYOR GASTO
                  TopCategoriesCard(
                    topCategorias: summary.topCategorias,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
