import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums.dart';
import '../../../../core/navigation/app_routes.dart';
import '../controllers/expenses_notifier.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas & Gastos'),
        centerTitle: true,
      ),
      body: Consumer<ExpensesNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final lista = notifier.transacciones;

          if (lista.isEmpty) {
            return const Center(
              child: Text('No hay registros de gastos o ingresos.'),
            );
          }

          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              final esEgreso = item.tipo == TipoTransaccion.egreso;

              return ListTile(
                leading: Icon(
                  esEgreso ? Icons.arrow_downward : Icons.arrow_upward,
                  color: esEgreso ? Colors.red : Colors.green,
                ),
                title: Text(item.descripcion),
                subtitle: Text(item.fecha.toString().split(' ')[0]),
                trailing: Text(
                  '${esEgreso ? '-' : '+'}\$${item.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: esEgreso ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.routeAddTransaction);
        },
        tooltip: 'Nueva Transacción',
        child: const Icon(Icons.add),
      ),
    );
  }
}
