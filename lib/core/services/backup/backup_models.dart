import 'dart:convert';

/// Root model representing the unencrypted backup data payload.
class BackupPayload {
  final int backupVersion;
  final String appVersion;
  final String createdAt;
  final Map<String, dynamic> database;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic>? secureStorage;

  BackupPayload({
    this.backupVersion = 1,
    required this.appVersion,
    required this.createdAt,
    required this.database,
    required this.settings,
    required this.metadata,
    this.secureStorage,
  });

  Map<String, dynamic> toJson() {
    return {
      'backupVersion': backupVersion,
      'appVersion': appVersion,
      'createdAt': createdAt,
      'database': database,
      'settings': settings,
      'metadata': metadata,
      if (secureStorage != null) 'secureStorage': secureStorage,
    };
  }

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    return BackupPayload(
      backupVersion: json['backupVersion'] as int? ?? 1,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      createdAt: json['createdAt'] as String? ?? '',
      database: (json['database'] as Map<String, dynamic>?) ?? {},
      settings: (json['settings'] as Map<String, dynamic>?) ?? {},
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      secureStorage: json['secureStorage'] as Map<String, dynamic>?,
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory BackupPayload.fromRawJson(String raw) =>
      BackupPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Model representing the encrypted backup file container saved to disk (.organizador_backup).
class EncryptedBackupContainer {
  final int version;
  final String salt;
  final String iv;
  final String mac;
  final String cipherText;
  final String createdAt;

  EncryptedBackupContainer({
    required this.version,
    required this.salt,
    required this.iv,
    required this.mac,
    required this.cipherText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'salt': salt,
      'iv': iv,
      'mac': mac,
      'cipherText': cipherText,
      'createdAt': createdAt,
    };
  }

  factory EncryptedBackupContainer.fromJson(Map<String, dynamic> json) {
    return EncryptedBackupContainer(
      version: json['version'] as int? ?? 1,
      salt: json['salt'] as String? ?? '',
      iv: json['iv'] as String? ?? '',
      mac: json['mac'] as String? ?? '',
      cipherText: json['cipherText'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory EncryptedBackupContainer.fromRawJson(String raw) =>
      EncryptedBackupContainer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Content summary shown to the user before confirming import.
class BackupSummary {
  final int backupVersion;
  final String createdAt;
  final int transactionCount;
  final int categoryCount;
  final int conocidoCount;
  final int eventCount;
  final int taskCount;
  final int personalElementCount;
  final int listItemCount;
  final int projectedAdjustmentCount;
  final bool hasSecureSecrets;

  BackupSummary({
    required this.backupVersion,
    required this.createdAt,
    required this.transactionCount,
    required this.categoryCount,
    required this.conocidoCount,
    required this.eventCount,
    required this.taskCount,
    required this.personalElementCount,
    required this.listItemCount,
    required this.projectedAdjustmentCount,
    required this.hasSecureSecrets,
  });

  int get totalRecords =>
      transactionCount +
      categoryCount +
      conocidoCount +
      eventCount +
      taskCount +
      personalElementCount +
      listItemCount +
      projectedAdjustmentCount;
}
