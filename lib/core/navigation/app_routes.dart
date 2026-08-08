import 'package:flutter/material.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/add_transaction_screen.dart';
import '../../features/home/presentation/screens/main_menu_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/expenses/presentation/screens/manage_conocidos_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/personal/presentation/screens/personal_space_screen.dart';
import '../../features/settings/presentation/screens/backup_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

class AppRoutes {
  static const String routeHome = '/';
  static const String routeExpenses = '/expenses';
  static const String routeAddTransaction = '/add-transaction';
  static const String routeCalendar = '/calendar';
  static const String routeTasks = '/tasks';
  static const String routePersonalSpace = '/personal-space';
  static const String routeManageConocidos = '/manage-conocidos';
  static const String routeStats = '/stats';
  static const String routeBackup = '/backup';
  static const String routeSettings = '/settings';
  static const String routeOnboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainMenuScreen(),
        );
      case routeOnboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
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
        final tabIndex = (settings.arguments as int?) ?? 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CalendarScreen(initialTab: tabIndex),
        );
      case routeTasks:
        final tabIndex = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CalendarScreen(initialTab: tabIndex),
        );
      case routePersonalSpace:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PersonalSpaceScreen(),
        );
      case routeManageConocidos:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ManageConocidosScreen(),
        );
      case routeStats:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const StatsScreen(),
        );
      case routeBackup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const BackupScreen(),
        );
      case routeSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
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

