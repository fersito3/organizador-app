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
    final iconBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6), // Violet 500
            Color(0xFF0EA5E9), // Sky 500
            Color(0xFF10B981), // Emerald 500
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle background pattern circle
          Positioned(
            right: -size * 0.1,
            top: -size * 0.1,
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          // Combined Calendar + Chart Icon Motif
          Icon(
            Icons.auto_graph_rounded,
            size: size * 0.52,
            color: Colors.white,
          ),
        ],
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
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'FINANZAS & ACADÉMICO',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
