import '../../../../core/enums.dart';
import '../models/categoria_domain.dart';
import '../models/transaccion.dart';
import '../models/conocido.dart';

abstract class IExpensesRepository {
  Stream<List<Transaccion>> watchTransacciones();
  Future<List<CategoriaDomain>> getCategorias();
  Future<int> agregarTransaccion({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
    int? conocidoId,
    String? contraparteMpId,
  });
  Future<void> guardarTransaccionesSincronizadas(List<Transaccion> transacciones);
  Future<void> eliminarTransaccion(int id);
  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId, {int? conocidoId});
  Future<void> asociarConocidoATransaccion(int transaccionId, int conocidoId);
  
  // Métodos para Conocidos
  Future<List<Conocido>> obtenerConocidos();
  Future<int> guardarConocido({required String nombre, required String apellido, String? mpUserId});
  Future<void> eliminarConocido(int conocidoId);
  Future<void> asociarTransaccionesConConocido({required String mpUserId, required int conocidoId, required String nombreCompleto});
}
