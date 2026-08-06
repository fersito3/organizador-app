import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../enums.dart';

// Este archivo generado automáticamente por Drift no existe todavía.
// Es necesario para que el generador de código sepa dónde escribir la lógica.
part 'app_database.g.dart';

// --- 1. TABLA DE CATEGORÍAS (Tanto para gastos como para ingresos) ---
class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 50)(); // Ej: "Facultad", "Comida", "Sueldo"
  TextColumn get colorHex => text().withLength(min: 6, max: 9)(); // Para pintar el calendario/gráficos
  IntColumn get tipo => intEnum<TipoTransaccion>()(); // Identifica si es categoría de ingreso o egreso
}

// --- 2. TABLA DE TRANSACCIONES FINANCIERAS (Ingresos y Egresos) ---
class Transacciones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descripcion => text().withLength(min: 1, max: 150)();
  RealColumn get monto => real()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get tipo => intEnum<TipoTransaccion>()(); // Egreso o Ingreso
  IntColumn get categoriaId => integer().references(Categorias, #id)();
  
  // Campos específicos para la integración con Mercado Pago
  TextColumn get mpPaymentId => text().nullable()(); // ID único del pago en Mercado Pago (evita duplicados)
  TextColumn get proveedor => text().withLength(min: 1, max: 50).withDefault(const Constant('MANUAL'))(); // 'MP' o 'MANUAL'

  // Campos nuevos para Conocidos (V4)
  IntColumn get conocidoId => integer().nullable().references(Conocidos, #id)();
  TextColumn get contraparteMpId => text().nullable()();
}

// --- 3. TABLA DE CONOCIDOS (Contactos / Personas) ---
class Conocidos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get apellido => text().withLength(min: 0, max: 100)();
  TextColumn get mpUserId => text().nullable().unique()(); // ID de Mercado Pago único e opcional
}

// --- 4. TABLA DE EVENTOS DE CALENDARIO (Horarios, Clases, Rutinas) ---
class Eventos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 100)(); // Ej: "Arquitectura de Computadoras"
  TextColumn get descripcion => text().nullable()();
  DateTimeColumn get fechaInicio => dateTime()();
  DateTimeColumn get fechaFin => dateTime()();
  TextColumn get colorHex => text().withDefault(const Constant('F59E0B'))(); // Color anaranjado por defecto
  
  // Soporte para Horarios Semanales y Clases Recurrentes
  BoolColumn get esRecurrente => boolean().withDefault(const Constant(false))();
  TextColumn get patronRecurrencia => text().nullable()(); // Formato iCal o JSON: "WEEKLY;BYDAY=MO,WE"
  
  // Relación opcional N:1 con Transacciones (Un evento pasado pudo haber generado un gasto)
  IntColumn get transaccionId => integer().nullable().references(Transacciones, #id)();
}

class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 100)(); // Ej: "Entrega de TPE N°1"
  TextColumn get descripcion => text().nullable()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get tipo => intEnum<TipoTarea>()(); // Parcial, Entrega, etc.
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
  
  // Relación N:1 con Eventos (Anexar una tarea/parcial a un evento específico de la cursada)
  IntColumn get eventoId => integer().nullable().references(Eventos, #id)();
}

// --- 5. TABLA DE ELEMENTOS PERSONALES (Notas, Listas, Metas) ---
@DataClassName('ElementoPersonal')
class ElementosPersonales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 150)();
  TextColumn get contenido => text().nullable()(); // Notas de texto, Alias, CBU, Enlaces
  IntColumn get tipo => intEnum<TipoElementoPersonal>()();
  TextColumn get categoria => text().withDefault(const Constant('General'))();
  IntColumn get prioridad => intEnum<Prioridad>().withDefault(const Constant(1))(); // 0: baja, 1: media, 2: alta
  BoolColumn get esFijado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaActualizacion => dateTime()(); // Para recargar/ordenar por modificación reciente

  // Campos opcionales para Metas (Objetivos)
  IntColumn get progresoActual => integer().nullable().withDefault(const Constant(0))();
  IntColumn get progresoTotal => integer().nullable().withDefault(const Constant(1))();
  DateTimeColumn get fechaObjetivo => dateTime().nullable()(); // Fecha meta límite para progreso temporal
}

// --- 6. TABLA SECUNDARIA RELACIONAL DE ÍTEMS DE LISTA (1:N) ---
@DataClassName('ItemListaData')
class ItemsLista extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get elementoId => integer().references(ElementosPersonales, #id, onDelete: KeyAction.cascade)();
  TextColumn get texto => text().withLength(min: 1, max: 200)();
  BoolColumn get completado => boolean().withDefault(const Constant(false))();
  IntColumn get orden => integer().withDefault(const Constant(0))();
}

// --- 7. TABLA DE AJUSTES PROYECTADOS FUTUROS EN ESTADÍSTICAS ---
@DataClassName('AjusteProyectado')
class AjustesProyectados extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get descripcion => text().withLength(min: 1, max: 150)();
  RealColumn get monto => real()();
  BoolColumn get esIngreso => boolean()(); // true = ingreso futuro, false = gasto futuro
  DateTimeColumn get fecha => dateTime()();
  BoolColumn get completado => boolean().withDefault(const Constant(false))(); // true = pagado/recibido
}

// --- CLASE PRINCIPAL DE LA BASE DE DATOS ---
@DriftDatabase(tables: [Categorias, Transacciones, Eventos, Tareas, Conocidos, ElementosPersonales, ItemsLista, AjustesProyectados])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7; // Incrementamos a versión 7 para colorHex en Eventos y AjustesProyectados

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          // Crear la nueva tabla de Conocidos y añadir campos a Transacciones
          await m.createTable(conocidos);
          await m.addColumn(transacciones, transacciones.conocidoId);
          await m.addColumn(transacciones, transacciones.contraparteMpId);
        }
        if (from < 5) {
          // MIGRACIÓN SEGURA (DAT-01): Se elimina la recreación destructiva de la tabla transacciones.
          try {
            await customStatement('ALTER TABLE transacciones DROP COLUMN destinatario_emisor');
          } catch (_) {
            // Ignoramos si la columna no existe o si la versión de SQLite no admite DROP COLUMN.
          }
        }
        if (from < 6) {
          // MIGRACIÓN V6: Creación segura y aditiva de tablas de Espacio Personal
          await m.createTable(elementosPersonales);
          await m.createTable(itemsLista);
        }
        if (from < 7) {
          // MIGRACIÓN V7: Creación segura y aditiva de columna colorHex en Eventos y tabla AjustesProyectados
          await m.addColumn(eventos, eventos.colorHex);
          await m.createTable(ajustesProyectados);
        }
      },
      beforeOpen: (details) async {
        // Habilitar claves foráneas en SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> inicializarCategoriasBase() async {
    final categoriasExistentes = await select(categorias).get();
    
    Future<void> insertarSiNoExiste(String nombre, String colorHex, TipoTransaccion tipo) async {
      final match = categoriasExistentes.where((c) => c.nombre.toLowerCase() == nombre.toLowerCase());
      if (match.isEmpty) {
        await into(categorias).insert(CategoriasCompanion.insert(
          nombre: nombre,
          colorHex: colorHex,
          tipo: tipo,
        ));
      }
    }

    await insertarSiNoExiste('Comida', 'FF9800', TipoTransaccion.egreso);
    await insertarSiNoExiste('Comida', 'FF9800', TipoTransaccion.egreso);
    await insertarSiNoExiste('Transporte', '2196F3', TipoTransaccion.egreso);
    await insertarSiNoExiste('Servicios', '9C27B0', TipoTransaccion.egreso);
    await insertarSiNoExiste('Sueldo', '4CAF50', TipoTransaccion.ingreso);
    await insertarSiNoExiste('Varios', '9E9E9E', TipoTransaccion.egreso);
  }

  // --- MÉTODOS DE AJUSTES PROYECTADOS FUTUROS ---
  Stream<List<AjusteProyectado>> watchAjustesProyectados() {
    return (select(ajustesProyectados)..orderBy([(a) => OrderingTerm.asc(a.fecha)])).watch();
  }

  Future<int> agregarAjusteProyectado({
    required String descripcion,
    required double monto,
    required bool esIngreso,
    required DateTime fecha,
  }) {
    return into(ajustesProyectados).insert(
      AjustesProyectadosCompanion.insert(
        descripcion: descripcion,
        monto: monto,
        esIngreso: esIngreso,
        fecha: fecha,
      ),
    );
  }

  Future<void> alternarCompletadoAjusteProyectado(int id, bool completado) {
    return (update(ajustesProyectados)..where((a) => a.id.equals(id)))
        .write(AjustesProyectadosCompanion(completado: Value(completado)));
  }

  Future<void> eliminarAjusteProyectado(int id) {
    return (delete(ajustesProyectados)..where((a) => a.id.equals(id))).go();
  }

  Future<void> inicializarConocidosBase() async {
    final conocidosExistentes = await select(conocidos).get();
    
    Future<void> insertarSiNoExiste(String nombre, String apellido, String mpUserId) async {
      final match = conocidosExistentes.where((c) => c.mpUserId == mpUserId);
      if (match.isEmpty) {
        await into(conocidos).insert(ConocidosCompanion.insert(
          nombre: nombre,
          apellido: apellido,
          mpUserId: Value(mpUserId),
        ));
      }
    }

    // 1. Yo mismo: Fersito (446191311)
    await insertarSiNoExiste('Fersito', 'Yo Mismo', '446191311');
    // 2. Mi Mamá (343761118)
    await insertarSiNoExiste('Mamá', '', '343761118');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}