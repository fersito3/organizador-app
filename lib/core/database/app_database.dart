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

// --- CLASE PRINCIPAL DE LA BASE DE DATOS ---
@DriftDatabase(tables: [Categorias, Transacciones, Eventos, Tareas, Conocidos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Incrementamos a la versión 5 para Conocidos avanzados

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
          // Como eliminamos destinatarioEmisor, recreamos la tabla limpia
          await m.deleteTable('transacciones');
          await m.createTable(transacciones);
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
    await insertarSiNoExiste('Facultad', '2196F3', TipoTransaccion.egreso);
    await insertarSiNoExiste('Transporte', '4CAF50', TipoTransaccion.egreso);
    await insertarSiNoExiste('Varios', '9C27B0', TipoTransaccion.egreso);
    await insertarSiNoExiste('Ingreso/Sueldo', '009688', TipoTransaccion.ingreso);
    await insertarSiNoExiste('Amigos', 'E91E63', TipoTransaccion.egreso); // Rosa/Amigos
    await insertarSiNoExiste('Farmacia', '00BCD4', TipoTransaccion.egreso); // Cyan/Farmacia
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