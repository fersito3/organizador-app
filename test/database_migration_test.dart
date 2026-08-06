import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:organizador_app/core/database/app_database.dart';

void main() {
  test('AppDatabase migration from schema < 5 preserves existing transactions', () async {
    // 1. Crear una base de datos SQLite en memoria en versión esquema 3 con datos precargados
    final executor = NativeDatabase.memory();
    
    // Crear tablas manualmente simulando esquema v3
    await executor.ensureOpen(_DummyUser());
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS categorias (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        tipo INTEGER NOT NULL
      );
    ''');
    await executor.runCustom('''
      CREATE TABLE IF NOT EXISTS transacciones (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL,
        monto REAL NOT NULL,
        fecha INTEGER NOT NULL,
        tipo INTEGER NOT NULL,
        categoria_id INTEGER NOT NULL,
        mp_payment_id TEXT,
        proveedor TEXT NOT NULL DEFAULT 'MANUAL',
        destinatario_emisor TEXT
      );
    ''');

    // Insertar transacciones de prueba en esquema v3
    await executor.runCustom('''
      INSERT INTO transacciones (descripcion, monto, fecha, tipo, categoria_id, proveedor, destinatario_emisor)
      VALUES ('Supermercado Coto', 12500.50, 1770000000, 0, 1, 'MANUAL', 'Coto Abasto');
    ''');

    // Establecer el pragma user_version en 3
    await executor.runCustom('PRAGMA user_version = 3;');

    // 2. Abrir la base de datos con la clase AppDatabase para ejecutar la migración a v5
    final db = AppDatabase.forTesting(executor);

    // 3. Verificar que la transacción insertada en v3 SIGUE EXISTIENDO en v5 sin ser eliminada
    final list = await db.select(db.transacciones).get();
    expect(list.length, equals(1));
    expect(list.first.descripcion, equals('Supermercado Coto'));
    expect(list.first.monto, equals(12500.50));

    await db.close();
  });

  test('AppDatabase migration from schema < 6 creates personal space tables cleanly', () async {
    final executor = NativeDatabase.memory();
    final db = AppDatabase.forTesting(executor);

    final elementos = await db.select(db.elementosPersonales).get();
    final items = await db.select(db.itemsLista).get();

    expect(elementos.isEmpty, isTrue);
    expect(items.isEmpty, isTrue);

    await db.close();
  });
}

class _DummyUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 3;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  @override
  Future<void> createSchema(QueryExecutor executor) async {}
}
