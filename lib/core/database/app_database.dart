import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Este archivo generado automáticamente por Drift no existe todavía.
// Es necesario para que el generador de código sepa dónde escribir la lógica.
part 'app_database.g.dart';

// --- ENUMS PARA CATEGORIZAR ---
enum TipoTransaccion { egreso, ingreso }
enum TipoTarea { parcial, entrega, TP, estudio, otro }

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
}

// --- 3. TABLA DE EVENTOS DE CALENDARIO (Horarios, Clases, Rutinas) ---
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
@DriftDatabase(tables: [Categorias, Transacciones, Eventos, Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Incrementamos la versión del esquema
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}