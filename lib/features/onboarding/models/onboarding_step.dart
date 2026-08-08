import 'package:flutter/material.dart';

enum OnboardingStepType {
  welcome,
  privacy,
  personalization,
  backup,
  notifications,
}

class OnboardingStepModel {
  final OnboardingStepType type;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingStepModel({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
