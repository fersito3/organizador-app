enum AlertLevel {
  info,
  warning,
  success,
}

class FinancialAlert {
  final String title;
  final String detail;
  final AlertLevel level;

  FinancialAlert({
    required this.title,
    required this.detail,
    required this.level,
  });
}
