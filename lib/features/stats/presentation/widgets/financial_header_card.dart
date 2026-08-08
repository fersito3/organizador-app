import 'package:flutter/material.dart';
import '../../domain/models/financial_stats_summary.dart';

class FinancialHeaderCard extends StatelessWidget {
  final FinancialStatsSummary summary;
  final String Function(double, {bool conSigno}) formatCurrency;

  const FinancialHeaderCard({
    super.key,
    required this.summary,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final balancePositivo = summary.balanceDisponibleMes >= 0;
    final tieneProyecciones = summary.ingresosFuturosPendientes > 0 || summary.gastosFuturosPendientes > 0;
    final pctConsumido = summary.porcentajeIngresosConsumido;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: balancePositivo
              ? [const Color(0xFF0F172A), const Color(0xFF1E1E38)]
              : [const Color(0xFF450A0A), const Color(0xFF2E0909)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (balancePositivo ? const Color(0xFF0F172A) : const Color(0xFF450A0A)).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILA DE ENCABEZADO: TÍTULO Y BADGE DE CONSUMO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: balancePositivo ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BALANCE DEL MES',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Gastado: ${pctConsumido.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // SI TIENE PROYECCIONES FUTURAS: MOSTRAR DOS COLUMNAS DE IGUAL JERARQUÍA Y GRAN TAMAÑO DE FUENTE
          if (tieneProyecciones) ...[
            Row(
              children: [
                // COLUMNA 1: DISPONIBLE ACTUAL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Disponible Actual',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatCurrency(summary.balanceDisponibleMes),
                          style: TextStyle(
                            color: balancePositivo ? Colors.white : const Color(0xFFFCA5A5),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.15),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                // COLUMNA 2: PROYECTADO FIN DE MES
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF818CF8)),
                          SizedBox(width: 4),
                          Text(
                            'Proyectado',
                            style: TextStyle(
                              color: Color(0xFFA5B4FC),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatCurrency(summary.balanceDisponibleConProyeccion),
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // MONTO ÚNICO SI NO HAY PROYECCIONES
            Text(
              formatCurrency(summary.balanceDisponibleMes),
              style: TextStyle(
                color: balancePositivo ? Colors.white : const Color(0xFFFCA5A5),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // BARRA DE PROGRESO DE CONSUMO DE INGRESOS
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pctConsumido / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                pctConsumido > 90
                    ? const Color(0xFFEF4444)
                    : (pctConsumido > 70 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // TARJETA INTERNA: DISPONIBLE DIARIO ESTIMADO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Disponible Diario Estimado',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatCurrency(summary.disponibleDiarioEstimado, conSigno: false)} / día',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${summary.diasRestantesMes} días restantes',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
