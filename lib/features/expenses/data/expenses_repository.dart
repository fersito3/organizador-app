import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../domain/models/categoria_domain.dart';
import '../domain/models/transaccion.dart';
import '../domain/repository_interfaces/iexpenses_repository.dart';

class ExpensesRepository implements IExpensesRepository {
  final AppDatabase db;

  ExpensesRepository(this.db);

  @override
  Stream<List<Transaccion>> watchTransacciones() {
    return (db.select(db.transacciones)
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch()
        .map((list) => list.map(_mapToDomainTransaccion).toList());
  }

  @override
  Future<List<CategoriaDomain>> getCategorias() {
    return db.select(db.categorias).get().then(
          (list) => list.map(_mapToDomainCategoria).toList(),
        );
  }

  @override
  Future<int> agregarTransaccion({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
  }) {
    return db.into(db.transacciones).insert(
          TransaccionesCompanion.insert(
            descripcion: descripcion,
            monto: monto,
            fecha: fecha,
            tipo: tipo,
            categoriaId: categoriaId,
          ),
        );
  }

  Transaccion _mapToDomainTransaccion(Transaccione t) {
    return Transaccion(
      id: t.id,
      descripcion: t.descripcion,
      monto: t.monto,
      fecha: t.fecha,
      tipo: t.tipo,
      categoriaId: t.categoriaId,
    );
  }

  CategoriaDomain _mapToDomainCategoria(Categoria c) {
    return CategoriaDomain(
      id: c.id,
      nombre: c.nombre,
      colorHex: c.colorHex,
      tipo: c.tipo,
    );
  }
}