import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/financial_stats_summary.dart';

class HistoricalComparisonCard extends StatelessWidget {
  final FinancialStatsSummary summary;
  final String Function(double, {bool conSigno}) formatCurrency;

  const HistoricalComparisonCard({
    super.key,
    required this.summary,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);
    final cardColor = AppColors.cardBackground(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparativa & Hábitos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        const SizedBox(height: 12),

        // TARJETA DE HÁBITOS HISTÓRICOS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'vs. Promedio Histórico',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  _buildTrendChip(context, summary.variacionPromedioHistoricoPct),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Este mes gastaste un ${_formatearPct(summary.variacionPromedioHistoricoPct)} que tu promedio histórico de los últimos meses (${formatCurrency(summary.promedioHistoricoMensual, conSigno: false)}).',
                style: TextStyle(fontSize: 13, color: textSecondary, height: 1.3),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // FILA DE COMPARATIVA PAREADA (Mes Anterior / Semana Anterior)
        Row(
          children: [
            Expanded(
              child: _buildComparisonTile(
                context,
                title: 'vs. Mes Anterior',
                pct: summary.variacionMesAnteriorPct,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonTile(
                context,
                title: 'vs. Semana Anterior',
                pct: summary.variacionSemanaAnteriorPct,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonTile(BuildContext context, {required String title, required double pct}) {
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);
    final cardColor = AppColors.cardBackground(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTrendChip(context, pct),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChip(BuildContext context, double pct) {
    final isDark = AppColors.isDarkMode(context);
    final aumento = pct > 0;
    final esIgual = pct.abs() < 0.1;

    Color bg = isDark ? AppColors.darkSubSurface : const Color(0xFFF1F5F9);
    Color txt = AppColors.textSecondary(context);
    IconData icon = Icons.remove_rounded;

    if (!esIgual) {
      if (aumento) {
        bg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        txt = const Color(0xFFEF4444);
        icon = Icons.trending_up_rounded;
      } else {
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        txt = const Color(0xFF10B981);
        icon = Icons.trending_down_rounded;
      }
    }

    final strPct = '${pct > 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: txt),
          const SizedBox(width: 4),
          Text(
            esIgual ? '0.0%' : strPct,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: txt),
          ),
        ],
      ),
    );
  }

  String _formatearPct(double pct) {
    if (pct.abs() < 0.1) return '0%';
    final absPct = pct.abs().toStringAsFixed(1);
    return pct > 0 ? '$absPct% más' : '$absPct% menos';
  }
}
