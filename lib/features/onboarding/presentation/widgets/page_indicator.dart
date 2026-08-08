import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = const Color(0xFF0EA5E9),
    this.inactiveColor = const Color(0xFFCBD5E1),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }
}
