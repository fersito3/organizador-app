import '../../../../core/enums.dart';
import '../models/categoria_domain.dart';
import '../models/transaccion.dart';

abstract class IExpensesRepository {
  Stream<List<Transaccion>> watchTransacciones();
  Future<List<CategoriaDomain>> getCategorias();
  Future<int> agregarTransaccion({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
  });
}
