import 'package:flutter/material.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/add_transaction_screen.dart';

class AppRoutes {
  static const String routeHome = '/';
  static const String routeAddTransaction = '/add-transaction';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExpensesScreen(),
        );
      case routeAddTransaction:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddTransactionScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no definida: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
