import 'package:flutter/material.dart';
import 'core/database/app_database.dart';

// Instancia global de la base de datos SQLite
late final AppDatabase db;

void main() {
  // Asegura que las vinculaciones del motor gráfico de Flutter estén listas
  // antes de intentar abrir el archivo físico de la base de datos.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la conexión SQLite local
  db = AppDatabase();

  runApp(const MiOrganizadorApp());
}

class MiOrganizadorApp extends StatelessWidget {
  const MiOrganizadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizador Personal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Base de Datos relacional Drift cargada correctamente.'),
        ),
      ),
    );
  }
}