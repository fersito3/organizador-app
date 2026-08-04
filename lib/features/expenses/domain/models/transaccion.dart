import '../../../../core/enums.dart';

class Transaccion {
  final int id;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final TipoTransaccion tipo;
  final int categoriaId;

  Transaccion({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.categoriaId,
  });
}
