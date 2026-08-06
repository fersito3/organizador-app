import 'package:flutter/material.dart';
import '../../domain/models/financial_stats_summary.dart';

class TopCategoriesCard extends StatelessWidget {
  final List<CategoryExpenseSummary> topCategorias;
  final String Function(double, {bool conSigno}) formatCurrency;

  const TopCategoriesCard({
    super.key,
    required this.topCategorias,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (topCategorias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías de Mayor Gasto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        ...topCategorias.map((item) {
          final pctStr = '${(item.percentageOfTotal * 100).toStringAsFixed(0)}%';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '${formatCurrency(item.amount, conSigno: false)} ($pctStr)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percentageOfTotal,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)), // Indigo
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
