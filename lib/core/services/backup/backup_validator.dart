import 'backup_models.dart';

class BackupValidationException implements Exception {
  final String message;
  BackupValidationException(this.message);

  @override
  String toString() => message;
}

class BackupValidator {
  static const int currentSupportedBackupVersion = 1;

  /// Validates structural integrity and compatibility of [payload].
  ///
  /// Returns a [BackupSummary] detailing record counts for user confirmation.
  static BackupSummary validateAndSummarize(BackupPayload payload) {
    if (payload.backupVersion > currentSupportedBackupVersion) {
      throw BackupValidationException(
        'El archivo fue creado con una versión más reciente de la app (v${payload.backupVersion}). Actualizá la app para restaurar este backup.',
      );
    }

    final dbMap = payload.database;
    if (dbMap.isEmpty) {
      throw BackupValidationException('El archivo de backup no contiene datos de la base de datos.');
    }

    final transactions = (dbMap['transacciones'] as List<dynamic>?) ?? [];
    final categories = (dbMap['categorias'] as List<dynamic>?) ?? [];
    final conocidos = (dbMap['conocidos'] as List<dynamic>?) ?? [];
    final eventos = (dbMap['eventos'] as List<dynamic>?) ?? [];
    final tareas = (dbMap['tareas'] as List<dynamic>?) ?? [];
    final elementosPersonales = (dbMap['elementosPersonales'] as List<dynamic>?) ?? [];
    final itemsLista = (dbMap['itemsLista'] as List<dynamic>?) ?? [];
    final ajustesProyectados = (dbMap['ajustesProyectados'] as List<dynamic>?) ?? [];

    final hasSecureSecrets = payload.secureStorage != null && payload.secureStorage!.isNotEmpty;

    return BackupSummary(
      backupVersion: payload.backupVersion,
      createdAt: payload.createdAt,
      transactionCount: transactions.length,
      categoryCount: categories.length,
      conocidoCount: conocidos.length,
      eventCount: eventos.length,
      taskCount: tareas.length,
      personalElementCount: elementosPersonales.length,
      listItemCount: itemsLista.length,
      projectedAdjustmentCount: ajustesProyectados.length,
      hasSecureSecrets: hasSecureSecrets,
    );
  }
}
