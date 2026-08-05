import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/app_database.dart';
import 'core/navigation/app_routes.dart';
import 'features/expenses/domain/repository_interfaces/iexpenses_repository.dart';
import 'features/expenses/data/expenses_repository.dart';
import 'features/expenses/domain/usecases/get_transactions_usecase.dart';
import 'features/expenses/domain/usecases/get_categories_usecase.dart';
import 'features/expenses/domain/usecases/add_transaction_usecase.dart';
import 'features/expenses/presentation/controllers/expenses_notifier.dart';
import 'features/expenses/presentation/controllers/add_transaction_notifier.dart';

// Importaciones del nuevo Calendario y Tareas
import 'features/calendar/domain/repositories/icalendar_repository.dart';
import 'features/calendar/data/repositories/calendar_repository.dart';
import 'features/calendar/presentation/controllers/calendar_notifier.dart';
import 'features/tasks/domain/repositories/itasks_repository.dart';
import 'features/tasks/data/repositories/tasks_repository.dart';
import 'features/tasks/presentation/controllers/tasks_notifier.dart';

void main() async {
  // Asegura que las vinculaciones del motor de Flutter estén inicializadas 
  // antes de ejecutar código asíncrono en la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  // Instanciamos la base de datos SQLite
  final database = AppDatabase();

  // Poblamos las categorías y conocidos iniciales en la BDD de forma asíncrona (Future)
  await database.inicializarCategoriasBase();
  await database.inicializarConocidosBase();

  runApp(
    MultiProvider(
      providers: [
        // 1. Base de datos
        Provider<AppDatabase>(
          create: (_) => database,
          dispose: (_, db) => db.close(),
        ),
        // 2. Repositorios
        ProxyProvider<AppDatabase, IExpensesRepository>(
          update: (_, db, __) => ExpensesRepository(db),
        ),
        ProxyProvider<AppDatabase, ICalendarRepository>(
          update: (_, db, __) => CalendarRepository(db),
        ),
        ProxyProvider<AppDatabase, ITasksRepository>(
          update: (_, db, __) => TasksRepository(db),
        ),
        // 3. Casos de Uso (Dependen del Repositorio)
        ProxyProvider<IExpensesRepository, GetTransactionsUseCase>(
          update: (_, repo, __) => GetTransactionsUseCase(repo),
        ),
        ProxyProvider<IExpensesRepository, GetCategoriesUseCase>(
          update: (_, repo, __) => GetCategoriesUseCase(repo),
        ),
        ProxyProvider<IExpensesRepository, AddTransactionUseCase>(
          update: (_, repo, __) => AddTransactionUseCase(repo),
        ),
        // 4. Controladores de Estado (Notifiers)
        ChangeNotifierProvider<ExpensesNotifier>(
          create: (context) => ExpensesNotifier(
            context.read<GetTransactionsUseCase>(),
            context.read<GetCategoriesUseCase>(),
            context.read<IExpensesRepository>(),
          ),
        ),
        ChangeNotifierProvider<AddTransactionNotifier>(
          create: (context) => AddTransactionNotifier(
            context.read<GetCategoriesUseCase>(),
            context.read<AddTransactionUseCase>(),
            context.read<IExpensesRepository>(),
          ),
        ),
        ChangeNotifierProvider<CalendarNotifier>(
          create: (context) => CalendarNotifier(
            context.read<ICalendarRepository>(),
          ),
        ),
        ChangeNotifierProvider<TasksNotifier>(
          create: (context) => TasksNotifier(
            context.read<ITasksRepository>(),
          ),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.routeHome,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    ),
  );
}