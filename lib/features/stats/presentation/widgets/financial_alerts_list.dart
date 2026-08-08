import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/financial_alert.dart';

class FinancialAlertsList extends StatelessWidget {
  final List<FinancialAlert> alertas;

  const FinancialAlertsList({
    super.key,
    required this.alertas,
  });

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) return const SizedBox.shrink();

    final isDark = AppColors.isDarkMode(context);
    final textPrimary = AppColors.textPrimary(context);


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF6366F1)),
            ),
            const SizedBox(width: 10),
            Text(
              'Insights & Salud Financiera',
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
        ...alertas.map((alert) {
          Color bg = isDark ? AppColors.darkCard : const Color(0xFFF8FAFC);
          Color border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
          Color iconColor = const Color(0xFF64748B);
          IconData iconData = Icons.info_outline_rounded;
          String badgeText = 'INFO';

          switch (alert.level) {
            case AlertLevel.warning:
              bg = isDark ? const Color(0xFF2E1C0C) : const Color(0xFFFFFBEB);
              border = isDark ? const Color(0xFF7C2D12) : const Color(0xFFFDE68A);
              iconColor = const Color(0xFFF59E0B);
              iconData = Icons.warning_amber_rounded;
              badgeText = 'ALERTA';
              break;
            case AlertLevel.success:
              bg = isDark ? const Color(0xFF062C1E) : const Color(0xFFECFDF5);
              border = isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);
              iconColor = const Color(0xFF10B981);
              iconData = Icons.check_circle_outline_rounded;
              badgeText = 'POSITIVO';
              break;
            case AlertLevel.info:
              bg = isDark ? const Color(0xFF0F2342) : const Color(0xFFEFF6FF);
              border = isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE);
              iconColor = const Color(0xFF3B82F6);
              iconData = Icons.lightbulb_outline_rounded;
              badgeText = 'INSIGHT';
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: iconColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.detail,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? textPrimary : const Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
