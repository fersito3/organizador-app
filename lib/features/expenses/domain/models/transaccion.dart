import '../../../../core/enums.dart';

class Transaccion {
  final int id;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final TipoTransaccion tipo;
  final int categoriaId;
  final String? destinatarioEmisor; // Emisor/Receptor de la transferencia o pago
  final String? mpPaymentId; // ID de pago en Mercado Pago
  final String proveedor; // 'MP' o 'MANUAL'
  final int? conocidoId; // ID del conocido asociado (V4)
  final String? contraparteMpId; // ID MP de la contraparte (V4)

  Transaccion({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.categoriaId,
    this.destinatarioEmisor,
    this.mpPaymentId,
    this.proveedor = 'MANUAL',
    this.conocidoId,
    this.contraparteMpId,
  });
}
