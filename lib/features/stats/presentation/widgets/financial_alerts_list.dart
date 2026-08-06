import 'package:flutter/material.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Alertas Financieras',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        ...alertas.map((alert) {
          Color bg = const Color(0xFFF1F5F9);
          Color border = const Color(0xFFE2E8F0);
          Color iconColor = const Color(0xFF64748B);
          IconData iconData = Icons.info_outline_rounded;

          switch (alert.level) {
            case AlertLevel.warning:
              bg = const Color(0xFFFFFBEB);
              border = const Color(0xFFFDE68A);
              iconColor = const Color(0xFFD97706);
              iconData = Icons.warning_amber_rounded;
              break;
            case AlertLevel.success:
              bg = const Color(0xFFECFDF5);
              border = const Color(0xFFA7F3D0);
              iconColor = const Color(0xFF059669);
              iconData = Icons.check_circle_outline_rounded;
              break;
            case AlertLevel.info:
              bg = const Color(0xFFEFF6FF);
              border = const Color(0xFFBFDBFE);
              iconColor = const Color(0xFF2563EB);
              iconData = Icons.info_outline_rounded;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(iconData, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: iconColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.detail,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.3),
                      ),
                    ],
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
