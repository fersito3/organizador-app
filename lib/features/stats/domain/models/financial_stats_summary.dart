import 'financial_alert.dart';

class CategoryExpenseSummary {
  final String categoryName;
  final double amount;
  final double percentageOfTotal;

  CategoryExpenseSummary({
    required this.categoryName,
    required this.amount,
    required this.percentageOfTotal,
  });
}

class FinancialStatsSummary {
  final double totalIngresosMes;
  final double totalGastosMes;
  final double balanceDisponibleMes;
  final double disponibleDiarioEstimado;
  final int diasRestantesMes;

  final double gastoHoy;
  final double gastoPromedioDiarioHabitual;

  final double gastoProyectadoFinMes;
  final double porcentajeIngresosConsumido;

  final double variacionMesAnteriorPct;
  final double variacionSemanaAnteriorPct;
  final double variacionPromedioHistoricoPct;
  final double promedioHistoricoMensual;

  final List<CategoryExpenseSummary> topCategorias;
  final List<FinancialAlert> alertas;

  final double ingresosFuturosPendientes;
  final double gastosFuturosPendientes;
  final double balanceDisponibleConProyeccion;

  FinancialStatsSummary({
    required this.totalIngresosMes,
    required this.totalGastosMes,
    required this.balanceDisponibleMes,
    required this.disponibleDiarioEstimado,
    required this.diasRestantesMes,
    required this.gastoHoy,
    required this.gastoPromedioDiarioHabitual,
    required this.gastoProyectadoFinMes,
    required this.porcentajeIngresosConsumido,
    required this.variacionMesAnteriorPct,
    required this.variacionSemanaAnteriorPct,
    required this.variacionPromedioHistoricoPct,
    required this.promedioHistoricoMensual,
    required this.topCategorias,
    required this.alertas,
    this.ingresosFuturosPendientes = 0.0,
    this.gastosFuturosPendientes = 0.0,
    this.balanceDisponibleConProyeccion = 0.0,
  });
}
