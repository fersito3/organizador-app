import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/financial_stats_summary.dart';

class TodaySpendingCard extends StatelessWidget {
  final FinancialStatsSummary summary;
  final String Function(double, {bool conSigno}) formatCurrency;

  const TodaySpendingCard({
    super.key,
    required this.summary,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final gastoHoy = summary.gastoHoy;
    final promDiario = summary.gastoPromedioDiarioHabitual;
    final esMayorAlPromedio = promDiario > 0 && gastoHoy > promDiario;

    final isDark = AppColors.isDarkMode(context);
    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: esMayorAlPromedio
                ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: esMayorAlPromedio
                  ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                  : (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gasto Registrado Hoy',
                  style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(gastoHoy, conSigno: false),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Promedio Diario', style: TextStyle(fontSize: 11, color: textSecondary)),
              const SizedBox(height: 2),
              Text(
                formatCurrency(promDiario, conSigno: false),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
