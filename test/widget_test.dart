import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:organizador_app/features/expenses/domain/repository_interfaces/iexpenses_repository.dart';
import 'package:organizador_app/features/expenses/domain/usecases/get_transactions_usecase.dart';
import 'package:organizador_app/features/expenses/presentation/controllers/expenses_notifier.dart';
import 'package:organizador_app/features/expenses/domain/models/transaccion.dart';
import 'package:organizador_app/features/expenses/domain/models/categoria_domain.dart';
import 'package:organizador_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:organizador_app/core/enums.dart';

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
  }) async {
    return 1;
  }
}

void main() {
  testWidgets('ExpensesScreen displays transactions', (WidgetTester tester) async {
    final mockRepo = MockExpensesRepository();
    final getTxUseCase = GetTransactionsUseCase(mockRepo);

    // Montamos la pantalla inyectando UseCase y Notifier
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<IExpensesRepository>.value(value: mockRepo),
            Provider<GetTransactionsUseCase>.value(value: getTxUseCase),
            ChangeNotifierProvider<ExpensesNotifier>(
              create: (_) => ExpensesNotifier(getTxUseCase),
            ),
          ],
          child: const ExpensesScreen(),
        ),
      ),
    );

    // Esperamos a que se procese el stream y la carga del notifier
    await tester.pumpAndSettle();

    // Verificamos que la UI muestre la descripción y el monto formateado
    expect(find.text('Gasto de Prueba'), findsOneWidget);
    expect(find.text(r'-$150.00'), findsOneWidget);
  });
}
