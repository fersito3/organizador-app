import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import 'future_adjustments_modal.dart';

class FutureAdjustmentsSection extends StatelessWidget {
  final List<AjusteProyectado> ajustes;
  final DateTime focusedDate;
  final String Function(double, {bool conSigno}) formatCurrency;

  const FutureAdjustmentsSection({
    super.key,
    required this.ajustes,
    required this.focusedDate,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final isDark = AppColors.isDarkMode(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);
    final cardColor = AppColors.cardBackground(context);

    // Filter adjustments for the focused date month
    final mesAjustes = ajustes.where((a) {
      return a.fecha.year == focusedDate.year && a.fecha.month == focusedDate.month;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO LIMPIO Y SIN DESBORDAMIENTOS (OVERFLOW)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_repeat_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajustes Proyectados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cobros y deudas futuras del mes',
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => FutureAdjustmentsModal.showAddDialog(context, focusedDate),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // LISTA O ESTADO VACÍO LIMPIO
          if (mesAjustes.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSubSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_graph_rounded, size: 32, color: textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'No hay ajustes proyectados para este mes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Agregá cobros pendientes o gastos pactados para proyectar tu disponible real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => FutureAdjustmentsModal.showAddDialog(context, focusedDate),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('Planificar Ajuste', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: BorderSide(color: isDark ? const Color(0xFF4338CA) : const Color(0xFFC7D2FE)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mesAjustes.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final item = mesAjustes[i];
                final esIngreso = item.esIngreso;
                final completado = item.completado;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: completado
                        ? (isDark ? AppColors.darkSubSurface : const Color(0xFFF8FAFC))
                        : cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: completado,
                          activeColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) async {
                            if (val != null) {
                              await db.alternarCompletadoAjusteProyectado(item.id, val);
                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  message: val ? 'Marcado como realizado' : 'Marcado como pendiente',
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Ícono Ingreso/Egreso
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: esIngreso
                            ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                            : (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2)),
                        child: Icon(
                          esIngreso ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Concepto y fecha
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.descripcion,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: completado ? textSecondary : textPrimary,
                                decoration: completado ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.fecha.day}/${item.fecha.month}/${item.fecha.year} • ${completado ? 'Realizado' : 'Pendiente'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Monto
                      Text(
                        '${esIngreso ? '+' : '-'}${formatCurrency(item.monto, conSigno: false)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: completado
                              ? textSecondary
                              : (esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                          decoration: completado ? TextDecoration.lineThrough : null,
                        ),
                      ),

                      // Botón eliminar
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () async {
                          await db.eliminarAjusteProyectado(item.id);
                          if (context.mounted) {
                            AppToast.show(context, message: 'Ajuste eliminado');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
