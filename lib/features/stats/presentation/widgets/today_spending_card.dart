import 'package:flutter/material.dart';
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: esMayorAlPromedio
                ? const Color(0xFFFEF3C7) // Amber 100
                : const Color(0xFFECFDF5), // Emerald 100
            child: Icon(
              Icons.shopping_bag_outlined,
              color: esMayorAlPromedio ? const Color(0xFFD97706) : const Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gasto Registrado Hoy',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(gastoHoy, conSigno: false),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Promedio Diario', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              Text(
                formatCurrency(promDiario, conSigno: false),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
