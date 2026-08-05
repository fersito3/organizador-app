import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:organizador_app/features/expenses/domain/repository_interfaces/iexpenses_repository.dart';
import 'package:organizador_app/features/expenses/domain/usecases/get_transactions_usecase.dart';
import 'package:organizador_app/features/expenses/presentation/controllers/expenses_notifier.dart';
import 'package:organizador_app/features/expenses/domain/models/transaccion.dart';
import 'package:organizador_app/features/expenses/domain/models/categoria_domain.dart';
import 'package:organizador_app/features/expenses/domain/models/conocido.dart';
import 'package:organizador_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:organizador_app/core/enums.dart';

import 'package:organizador_app/features/expenses/domain/usecases/get_categories_usecase.dart';

class MockExpensesRepository implements IExpensesRepository {
  @override
  Stream<List<Transaccion>> watchTransacciones() {
    return Stream.value([
      Transaccion(
        id: 1,
        descripcion: 'Gasto de Prueba',
        monto: 150.0,
        fecha: DateTime(2026, 8, 4),
        tipo: TipoTransaccion.egreso,
        categoriaId: 1,
        destinatarioEmisor: 'Mercado Libre',
      ),
    ]);
  }

  @override
  Future<List<CategoriaDomain>> getCategorias() async {
    return [
      CategoriaDomain(
        id: 1,
        nombre: 'Comida',
        colorHex: 'FF9800',
        tipo: TipoTransaccion.egreso,
      ),
    ];
  }

  @override
  Future<int> agregarTransaccion({
    required String descripcion,
    required double monto,
    required DateTime fecha,
    required TipoTransaccion tipo,
    required int categoriaId,
    String? destinatarioEmisor,
    int? conocidoId,
    String? contraparteMpId,
  }) async {
    return 1;
  }

  @override
  Future<void> guardarTransaccionesSincronizadas(List<Transaccion> transacciones) async {}

  @override
  Future<void> eliminarTransaccion(int id) async {}

  @override
  Future<void> actualizarTransaccion(int id, String descripcion, int categoriaId, {int? conocidoId}) async {}

  @override
  Future<void> asociarConocidoATransaccion(int transaccionId, int conocidoId) async {}

  @override
  Future<List<Conocido>> obtenerConocidos() async => [];

  @override
  Future<int> guardarConocido({int? id, required String nombre, required String apellido, String? mpUserId}) async => 1;

  @override
  Future<void> eliminarConocido(int conocidoId) async {}

  @override
  Future<void> asociarTransaccionesConConocido({required String mpUserId, required int conocidoId, required String nombreCompleto}) async {}
}

void main() {
  testWidgets('ExpensesScreen displays transactions', (WidgetTester tester) async {
    final mockRepo = MockExpensesRepository();
    final getTxUseCase = GetTransactionsUseCase(mockRepo);
    final getCatUseCase = GetCategoriesUseCase(mockRepo);

    // Montamos la pantalla inyectando UseCase y Notifier
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<IExpensesRepository>.value(value: mockRepo),
            Provider<GetTransactionsUseCase>.value(value: getTxUseCase),
            Provider<GetCategoriesUseCase>.value(value: getCatUseCase),
            ChangeNotifierProvider<ExpensesNotifier>(
              create: (_) => ExpensesNotifier(getTxUseCase, getCatUseCase, mockRepo),
            ),
          ],
          child: const ExpensesScreen(),
        ),
      ),
    );

    // Esperamos a que se procese el stream y la carga del notifier
    await tester.pumpAndSettle();

    // Verificamos que la UI muestre la descripción y el monto formateado (en la tarjeta de resumen y en la lista)
    expect(find.text('Gasto de Prueba'), findsOneWidget);
    expect(find.text(r'-$150.00'), findsNWidgets(2));
  });
}
