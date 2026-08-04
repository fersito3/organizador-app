import '../models/transaccion.dart';
import '../repository_interfaces/iexpenses_repository.dart';

class GetTransactionsUseCase {
  final IExpensesRepository repository;

  GetTransactionsUseCase(this.repository);

  Stream<List<Transaccion>> execute() {
    return repository.watchTransacciones();
  }
}
