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

void main() async {
  // Asegura que las vinculaciones del motor de Flutter estén inicializadas 
  // antes de ejecutar código asíncrono en la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  // Instanciamos la base de datos SQLite
  final database = AppDatabase();

  // Poblamos las categorías iniciales en la BDD de forma asíncrona (Future)
  await database.inicializarCategoriasBase();

  runApp(
    MultiProvider(
      providers: [
        // 1. Base de datos
        Provider<AppDatabase>(
          create: (_) => database,
          dispose: (_, db) => db.close(),
        ),
        // 2. Repositorio
        ProxyProvider<AppDatabase, IExpensesRepository>(
          update: (_, db, __) => ExpensesRepository(db),
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
        // 4. Controladores de Estado (Notifiers - Dependen de Casos de Uso)
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