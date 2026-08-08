import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/financial_stats_summary.dart';

class TopCategoriesCard extends StatelessWidget {
  final List<CategoryExpenseSummary> topCategorias;
  final String Function(double, {bool conSigno}) formatCurrency;

  static const List<Color> _catColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Sky
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  const TopCategoriesCard({
    super.key,
    required this.topCategorias,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (topCategorias.isEmpty) return const SizedBox.shrink();

    final textPrimary = AppColors.textPrimary(context);
    final borderColor = AppColors.borderColor(context);
    final cardColor = AppColors.cardBackground(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pie_chart_outline_rounded, size: 18, color: Color(0xFF0EA5E9)),
            ),
            const SizedBox(width: 10),
            Text(
              'Categorías de Mayor Gasto',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: List.generate(topCategorias.length, (index) {
              final item = topCategorias[index];
              final pctStr = '${(item.percentageOfTotal * 100).toStringAsFixed(0)}%';
              final color = _catColors[index % _catColors.length];

              return Padding(
                padding: EdgeInsets.only(bottom: index == topCategorias.length - 1 ? 0 : 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.categoryName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${formatCurrency(item.amount, conSigno: false)} ($pctStr)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.percentageOfTotal,
                        minHeight: 8,
                        backgroundColor: color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
