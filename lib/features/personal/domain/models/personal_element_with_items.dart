import '../../../../core/database/app_database.dart';

class ElementoPersonalConItems {
  final ElementoPersonal elemento;
  final List<ItemListaData> items;

  ElementoPersonalConItems({
    required this.elemento,
    this.items = const [],
  });

  double get porcentajeListaCompletado {
    if (items.isEmpty) return 0.0;
    final completados = items.where((i) => i.completado).length;
    return completados / items.length;
  }
}
