import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.showText = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.08;
    final squareSize = (size * 0.44 - gap) / 2;
    final borderRadius = squareSize * 0.35;

    final iconBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Deep Slate 900
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFF334155), // Slate 700
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.2),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.44,
          height: size * 0.44,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Finanzas (Sky 500)
                  Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  // 2. Calendario (Violet 500)
                  Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3. Tareas (Amber 500)
                  Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  // 4. Estadísticas (Emerald 500)
                  Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!showText) return iconBox;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBox,
        SizedBox(width: size * 0.25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Organizador',
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'FINANZAS & ACADÉMICO',
              style: TextStyle(
                fontSize: size * 0.18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
