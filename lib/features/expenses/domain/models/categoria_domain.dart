import '../../../../core/enums.dart';

class CategoriaDomain {
  final int id;
  final String nombre;
  final String colorHex;
  final TipoTransaccion tipo;

  CategoriaDomain({
    required this.id,
    required this.nombre,
    required this.colorHex,
    required this.tipo,
  });
}
