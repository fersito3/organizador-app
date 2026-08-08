import 'dart:math';
import '../../../../core/database/app_database.dart';
import '../../../../core/enums.dart';
import '../../../expenses/domain/models/transaccion.dart';
import '../../../expenses/domain/models/categoria_domain.dart';
import '../models/financial_alert.dart';
import '../models/financial_stats_summary.dart';

class FinancialAnalyticsService {
  static FinancialStatsSummary calcularResumenFinanciero({
    required List<Transaccion> transacciones,
    required List<CategoriaDomain> categorias,
    required DateTime focusedDate,
    List<AjusteProyectado> ajustesProyectados = const [],
  }) {
    final now = DateTime.now();

    // 1. Fechas y Rangos
    final diasEnMes = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;
    final esMesActual = focusedDate.year == now.year && focusedDate.month == now.month;
    final diaActual = esMesActual ? min(now.day, diasEnMes) : diasEnMes;
    final diasRestantes = max(1, diasEnMes - diaActual + 1);

    // 2. Transacciones del mes enfocado
    final txsMes = transacciones.where((t) {
      return t.fecha.year == focusedDate.year && t.fecha.month == focusedDate.month;
    }).toList();

    double totalIngresosMes = 0.0;
    double totalGastosMes = 0.0;
    final Map<int, double> gastosPorCategoriaId = {};

    for (final tx in txsMes) {
      if (tx.tipo == TipoTransaccion.ingreso) {
        totalIngresosMes += tx.monto;
      } else {
        totalGastosMes += tx.monto;
        gastosPorCategoriaId[tx.categoriaId] = (gastosPorCategoriaId[tx.categoriaId] ?? 0.0) + tx.monto;
      }
    }

    final balanceDisponibleMes = totalIngresosMes - totalGastosMes;

    // 2.b. Ajustes Proyectados Futuros del mes
    double ingresosFuturosPendientes = 0.0;
    double gastosFuturosPendientes = 0.0;

    for (final a in ajustesProyectados) {
      if (!a.completado && a.fecha.year == focusedDate.year && a.fecha.month == focusedDate.month) {
        if (a.esIngreso) {
          ingresosFuturosPendientes += a.monto;
        } else {
          gastosFuturosPendientes += a.monto;
        }
      }
    }

    final balanceDisponibleConProyeccion = balanceDisponibleMes + ingresosFuturosPendientes - gastosFuturosPendientes;

    // 3. Disponible Diario Estimado
    final disponibleDiarioEstimado = balanceDisponibleConProyeccion > 0
        ? (balanceDisponibleConProyeccion / diasRestantes)
        : 0.0;

    // 4. Gasto de Hoy y Promedio Diario Habitual
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final gastoHoy = transacciones
        .where((t) => t.tipo == TipoTransaccion.egreso && !t.fecha.isBefore(startOfToday) && !t.fecha.isAfter(endOfToday))
        .fold(0.0, (sum, t) => sum + t.monto);

    final gastoPromedioDiarioHabitual = diaActual > 0 ? (totalGastosMes / diaActual) : 0.0;

    // 5. Proyección a fin de mes (incluyendo egresos/deudas futuras proyectadas)
    final totalIngresosProyectados = totalIngresosMes + ingresosFuturosPendientes;
    final totalGastosFuturos = totalGastosMes + gastosFuturosPendientes;
    final gastoProyectadoFinMes = totalGastosFuturos + (gastoPromedioDiarioHabitual * (diasEnMes - diaActual));

    // 6. Porcentaje de Ingresos Consumido (considerando ingresos proyectados)
    final porcentajeIngresosConsumido = totalIngresosProyectados > 0
        ? ((totalGastosMes / totalIngresosProyectados) * 100).clamp(0.0, 999.0)
        : 0.0;

    // 7. Comparativas (Mes Anterior y Semana Anterior)
    final prevMonthDate = DateTime(focusedDate.year, focusedDate.month - 1);
    final gastosMesAnterior = transacciones
        .where((t) => t.tipo == TipoTransaccion.egreso && t.fecha.year == prevMonthDate.year && t.fecha.month == prevMonthDate.month)
        .fold(0.0, (sum, t) => sum + t.monto);

    final variacionMesAnteriorPct = gastosMesAnterior > 0
        ? ((totalGastosMes - gastosMesAnterior) / gastosMesAnterior) * 100
        : 0.0;

    // Comparativa semanal
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    final startOfPrevWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfPrevWeek = startOfWeek.subtract(const Duration(seconds: 1));

    final gastosSemanaActual = transacciones
        .where((t) => t.tipo == TipoTransaccion.egreso && !t.fecha.isBefore(startOfWeek) && !t.fecha.isAfter(endOfWeek))
        .fold(0.0, (sum, t) => sum + t.monto);

    final gastosSemanaAnterior = transacciones
        .where((t) => t.tipo == TipoTransaccion.egreso && !t.fecha.isBefore(startOfPrevWeek) && !t.fecha.isAfter(endOfPrevWeek))
        .fold(0.0, (sum, t) => sum + t.monto);

    final variacionSemanaAnteriorPct = gastosSemanaAnterior > 0
        ? ((gastosSemanaActual - gastosSemanaAnterior) / gastosSemanaAnterior) * 100
        : 0.0;

    // 8. Hábitos Históricos (últimos 3 meses anteriores)
    double sumaGastosHistoricos = 0.0;
    int mesesConDatos = 0;
    for (int i = 1; i <= 3; i++) {
      final pastDate = DateTime(focusedDate.year, focusedDate.month - i);
      final sum = transacciones
          .where((t) => t.tipo == TipoTransaccion.egreso && t.fecha.year == pastDate.year && t.fecha.month == pastDate.month)
          .fold(0.0, (s, t) => s + t.monto);
      if (sum > 0) {
        sumaGastosHistoricos += sum;
        mesesConDatos++;
      }
    }

    final promedioHistoricoMensual = mesesConDatos > 0 ? (sumaGastosHistoricos / mesesConDatos) : totalGastosMes;
    final variacionPromedioHistoricoPct = promedioHistoricoMensual > 0
        ? ((totalGastosMes - promedioHistoricoMensual) / promedioHistoricoMensual) * 100
        : 0.0;

    // 9. Top Categorías de Mayor Gasto
    final List<CategoryExpenseSummary> topCategorias = [];
    final Map<int, String> catMap = {for (var c in categorias) c.id: c.nombre};

    final entriesOrdenadas = gastosPorCategoriaId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in entriesOrdenadas.take(5)) {
      final name = catMap[entry.key] ?? 'Categoría #${entry.key}';
      final pct = totalGastosMes > 0 ? (entry.value / totalGastosMes) : 0.0;
      topCategorias.add(CategoryExpenseSummary(
        categoryName: name,
        amount: entry.value,
        percentageOfTotal: pct,
      ));
    }

    // 10. Motor de Alertas Inteligentes (Lenguaje Neutral y Descriptivo)
    final List<FinancialAlert> alertas = [];

    // Alerta 1: Desviación por categoría (Aumento > 25% respecto al promedio histórico por categoría)
    for (final entry in gastosPorCategoriaId.entries) {
      final catId = entry.key;
      final montoMes = entry.value;

      double sumaHistCat = 0.0;
      int mesesCat = 0;
      for (int i = 1; i <= 3; i++) {
        final pastDate = DateTime(focusedDate.year, focusedDate.month - i);
        final sumHist = transacciones
            .where((t) => t.tipo == TipoTransaccion.egreso && t.categoriaId == catId && t.fecha.year == pastDate.year && t.fecha.month == pastDate.month)
            .fold(0.0, (s, t) => s + t.monto);
        if (sumHist > 0) {
          sumaHistCat += sumHist;
          mesesCat++;
        }
      }

      if (mesesCat > 0) {
        final promCat = sumaHistCat / mesesCat;
        if (montoMes > promCat * 1.25) {
          final incPct = ((montoMes - promCat) / promCat * 100).toInt();
          final catName = catMap[catId] ?? 'Categoría';
          alertas.add(FinancialAlert(
            title: 'Desviación en categoría',
            detail: '$catName aumentó un $incPct% respecto a tu promedio histórico.',
            level: AlertLevel.info,
          ));
        }
      }
    }

    // Alerta 2: Proyección mensual considerando ingresos y deudas futuras
    if (totalIngresosProyectados > 0 && gastoProyectadoFinMes > totalIngresosProyectados) {
      final ex = gastoProyectadoFinMes - totalIngresosProyectados;
      alertas.add(FinancialAlert(
        title: 'Proyección de balance',
        detail: 'Con las proyecciones y tu ritmo de consumo, el gasto total a fin de mes superará tus ingresos proyectados por \$${ex.toStringAsFixed(0)}.',
        level: AlertLevel.warning,
      ));
    } else if (totalIngresosProyectados == 0 && (totalGastosMes > 0 || gastosFuturosPendientes > 0)) {
      alertas.add(FinancialAlert(
        title: 'Sin ingresos registrados',
        detail: 'Registraste gastos y/o compromisos futuros por \$${(totalGastosMes + gastosFuturosPendientes).toStringAsFixed(0)} pero no tenés ingresos cargados en este mes.',
        level: AlertLevel.info,
      ));
    }

    // Alerta 3: Ingresos futuros pendientes
    if (ingresosFuturosPendientes > 0) {
      alertas.add(FinancialAlert(
        title: 'Ingresos futuros pendientes',
        detail: 'Tenés \$${ingresosFuturosPendientes.toStringAsFixed(0)} en cobros o ingresos proyectados para este mes.',
        level: AlertLevel.success,
      ));
    }

    // Alerta 4: Deudas o compromisos futuros pendientes
    if (gastosFuturosPendientes > 0) {
      alertas.add(FinancialAlert(
        title: 'Compromisos de pago futuros',
        detail: 'Tenés \$${gastosFuturosPendientes.toStringAsFixed(0)} en egresos o deudas futuras programadas para este mes.',
        level: AlertLevel.info,
      ));
    }

    // Alerta 5: Tendencia de ahorro positiva
    if (promedioHistoricoMensual > 0 && totalGastosMes < promedioHistoricoMensual * 0.9) {
      final redPct = ((1 - (totalGastosMes / promedioHistoricoMensual)) * 100).toInt();
      alertas.add(FinancialAlert(
        title: 'Tendencia de gasto favorable',
        detail: 'Tus gastos acumulados están un $redPct% por debajo de tu promedio histórico.',
        level: AlertLevel.success,
      ));
    }

    // Alerta 6: Consumo acelerado en primera mitad de mes
    if (diaActual <= 15 && totalIngresosProyectados > 0 && porcentajeIngresosConsumido > 65) {
      alertas.add(FinancialAlert(
        title: 'Ritmo de consumo alto',
        detail: 'Ya has ejecutado el ${porcentajeIngresosConsumido.toInt()}% de los ingresos proyectados en la primera mitad del mes.',
        level: AlertLevel.info,
      ));
    }

    return FinancialStatsSummary(
      totalIngresosMes: totalIngresosMes,
      totalGastosMes: totalGastosMes,
      balanceDisponibleMes: balanceDisponibleMes,
      disponibleDiarioEstimado: disponibleDiarioEstimado,
      diasRestantesMes: diasRestantes,
      gastoHoy: gastoHoy,
      gastoPromedioDiarioHabitual: gastoPromedioDiarioHabitual,
      gastoProyectadoFinMes: gastoProyectadoFinMes,
      porcentajeIngresosConsumido: porcentajeIngresosConsumido,
      variacionMesAnteriorPct: variacionMesAnteriorPct,
      variacionSemanaAnteriorPct: variacionSemanaAnteriorPct,
      variacionPromedioHistoricoPct: variacionPromedioHistoricoPct,
      promedioHistoricoMensual: promedioHistoricoMensual,
      topCategorias: topCategorias,
      alertas: alertas,
      ingresosFuturosPendientes: ingresosFuturosPendientes,
      gastosFuturosPendientes: gastosFuturosPendientes,
      balanceDisponibleConProyeccion: balanceDisponibleConProyeccion,
    );
  }
}
