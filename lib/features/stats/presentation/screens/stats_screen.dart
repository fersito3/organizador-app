import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../expenses/presentation/controllers/expenses_notifier.dart';
import '../../domain/services/financial_analytics_service.dart';
import '../widgets/financial_header_card.dart';
import '../widgets/today_spending_card.dart';
import '../widgets/future_adjustments_section.dart';
import '../widgets/financial_alerts_list.dart';
import '../widgets/historical_comparison_card.dart';
import '../widgets/top_categories_card.dart';

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

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Resumen Financiero'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. NAVEGADOR DE MES PREMIUM
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left_rounded, size: 26, color: AppColors.textSecondary(context)),
                          onPressed: () {
                            setState(() {
                              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                            });
                          },
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF6366F1)),
                            const SizedBox(width: 8),
                            Text(
                              '${_meses[_focusedDate.month - 1]} ${_focusedDate.year}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right_rounded, size: 26, color: AppColors.textSecondary(context)),
                          onPressed: () {
                            setState(() {
                              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 18),

                  // 2. TARJETA HEADER FINANCIERO (DISPONIBLE MES & DISPONIBLE DIARIO)
                  FinancialHeaderCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 16),

                  // 3. GASTO REGISTRADO HOY
                  TodaySpendingCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 20),

                  // 4. SECCIÓN DIRECTA DE AJUSTES PROYECTADOS FUTUROS (SIN BOTÓN FEO)
                  FutureAdjustmentsSection(
                    ajustes: ajustes,
                    focusedDate: _focusedDate,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  if (summary.alertas.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // 5. INSIGHTS & SALUD FINANCIERA
                    FinancialAlertsList(alertas: summary.alertas),
                  ],

                  const SizedBox(height: 24),

                  // 6. COMPARATIVA Y HÁBITOS HISTÓRICOS
                  HistoricalComparisonCard(
                    summary: summary,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 24),

                  // 7. TOP CATEGORÍAS DE MAYOR GASTO
                  TopCategoriesCard(
                    topCategorias: summary.topCategorias,
                    formatCurrency: expensesNotifier.formatearMonto,
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
