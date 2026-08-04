import '../models/categoria_domain.dart';
import '../repository_interfaces/iexpenses_repository.dart';

class GetCategoriesUseCase {
  final IExpensesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoriaDomain>> execute() {
    return repository.getCategorias();
  }
}
