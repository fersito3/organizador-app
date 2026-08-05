import '../../../../core/enums.dart';
import '../repository_interfaces/iexpenses_repository.dart';

class AddTransactionUseCase {
  final IExpensesRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> execute({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
    String? destinatarioEmisor,
    int? conocidoId,
    String? contraparteMpId,
  }) async {
    if (monto <= 0) {
      throw Exception('El monto de la transacción debe ser mayor a 0.');
    }
    if (descripcion.trim().isEmpty) {
      throw Exception('La descripción no puede estar vacía.');
    }

    await repository.agregarTransaccion(
      descripcion: descripcion.trim(),
      monto: monto,
      fecha: fecha,
      tipo: tipo,
      categoriaId: categoriaId,
      destinatarioEmisor: destinatarioEmisor?.trim().isEmpty == true ? null : destinatarioEmisor?.trim(),
      conocidoId: conocidoId,
      contraparteMpId: contraparteMpId,
    );
  }
}
