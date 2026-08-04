import 'package:flutter/material.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/add_transaction_screen.dart';
import '../../features/home/presentation/screens/main_menu_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';

class AppRoutes {
  static const String routeHome = '/';
  static const String routeExpenses = '/expenses';
  static const String routeAddTransaction = '/add-transaction';
  static const String routeCalendar = '/calendar';
  static const String routeTasks = '/tasks';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainMenuScreen(),
        );
      case routeExpenses:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExpensesScreen(),
        );
      case routeAddTransaction:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddTransactionScreen(),
        );
      case routeCalendar:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CalendarScreen(),
        );
      case routeTasks:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TasksScreen(),
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

