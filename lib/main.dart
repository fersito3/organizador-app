import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/database/app_database.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/app_localizations.dart';
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
import 'features/personal/domain/repositories/ipersonal_repository.dart';
import 'features/personal/data/repositories/personal_repository.dart';
import 'features/personal/presentation/controllers/personal_notifier.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/security/secure_storage_service.dart';
import 'core/settings/settings_model.dart';
import 'core/settings/settings_repository.dart';
import 'core/settings/settings_provider.dart';


import 'core/notifications/notification_service.dart';
import 'core/notifications/notification_scheduler.dart';

void main() async {
  // Asegura que las vinculaciones del motor de Flutter estén inicializadas 
  // antes de ejecutar código asíncrono en la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences y servicios de seguridad y notificaciones
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService();
  final settingsRepository = SettingsRepository(prefs: prefs, secureStorage: secureStorage);
  final settingsProvider = SettingsProvider(settingsRepository);

  final notificationService = NotificationService();
  await notificationService.initialize();
  final notificationScheduler = NotificationScheduler(notificationService);

  // Solicitar permiso nativo al abrir la app por primera vez o sincronizar con preferencias del sistema
  if (!settingsProvider.hasCompletedOnboarding || settingsProvider.notificationsEnabled) {
    final granted = await notificationService.requestPermissions();
    if (!granted && settingsProvider.notificationsEnabled) {
      await settingsProvider.toggleNotifications(false);
    }
  }

  // Instanciamos la base de datos SQLite
  final database = AppDatabase();


  // Poblamos las categorías y conocidos iniciales en la BDD de forma asíncrona (Future)
  await database.inicializarCategoriasBase();
  await database.inicializarConocidosBase();

  runApp(
    MultiProvider(
      providers: [
        // 0. Servicios de Seguridad, Configuración y Notificaciones
        Provider<SecureStorageService>.value(
          value: secureStorage,
        ),
        Provider<SettingsRepository>.value(
          value: settingsRepository,
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
        Provider<NotificationService>.value(
          value: notificationService,
        ),
        Provider<NotificationScheduler>.value(
          value: notificationScheduler,
        ),
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
        ProxyProvider<AppDatabase, IPersonalRepository>(
          update: (_, db, __) => PersonalRepository(db),
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
        ChangeNotifierProvider<PersonalNotifier>(
          create: (context) => PersonalNotifier(
            context.read<IPersonalRepository>(),
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final isDark = settings.themeMode == AppThemeMode.dark ||
              (settings.themeMode == AppThemeMode.system &&
                  WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

          // Actualizar overlay dinámicamente según el tema activo
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ));

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(settings.language.name),
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: settings.themeMode.toThemeMode(),
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.sky500,
                brightness: Brightness.light,
                surface: AppColors.lightSurface,
                surfaceContainerHighest: AppColors.lightSubSurface,
              ),
              scaffoldBackgroundColor: AppColors.lightBackground,
              cardColor: AppColors.lightCard,
              dialogBackgroundColor: AppColors.lightSurface,
              dividerColor: AppColors.lightBorder,
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.lightSurface,
                surfaceTintColor: Colors.transparent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightSurface,
                foregroundColor: AppColors.lightTextPrimary,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.sky500,
                brightness: Brightness.dark,
                surface: AppColors.darkSurface,
                surfaceContainerHighest: AppColors.darkSubSurface,
                onSurface: AppColors.darkTextPrimary,
                onSurfaceVariant: AppColors.darkTextSecondary,
              ),
              scaffoldBackgroundColor: AppColors.darkBackground,
              cardColor: AppColors.darkCard,
              dialogBackgroundColor: AppColors.darkCard,
              dividerColor: AppColors.darkBorder,
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.darkCard,
                surfaceTintColor: Colors.transparent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkBackground,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            initialRoute: settings.hasCompletedOnboarding
                ? AppRoutes.routeHome
                : AppRoutes.routeOnboarding,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    ),
  );
}