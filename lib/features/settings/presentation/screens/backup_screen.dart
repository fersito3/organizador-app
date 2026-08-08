import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/services/backup/backup_crypto_service.dart';
import '../../../../core/services/backup/backup_manager.dart';
import '../../../../core/services/backup/backup_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';


class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isProcessing = false;
  bool _includeSecrets = false;

  Future<void> _exportBackup() async {
    final passwordControllers = await _showPasswordCreationDialog();
    if (passwordControllers == null) return;

    final password = passwordControllers['password']!;

    setState(() => _isProcessing = true);

    try {
      final db = context.read<AppDatabase>();
      final secureStorage = context.read<SecureStorageService>();
      final manager = BackupManager(db: db, secureStorage: secureStorage);

      final rawBackupJson = await manager.exportBackup(
        password: password,
        includeExternalSecrets: _includeSecrets,
      );

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'organizador_backup_$timestamp.organizador_backup';

      final resultPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar backup encriptado',
        fileName: fileName,
        bytes: utf8.encode(rawBackupJson),
      );

      if (resultPath != null) {
        final savedFile = File(resultPath);
        if (!await savedFile.exists()) {
          await savedFile.writeAsString(rawBackupJson);
        }
        final bytesCount = await savedFile.length();
        final kbSize = (bytesCount / 1024).toStringAsFixed(1);

        if (mounted) {
          _showExportSuccessDialog(
            fileName: pBasename(resultPath),
            fileSize: '$kbSize KB',
            savedPath: resultPath,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Error al exportar: $e', icon: Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importBackup() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        dialogTitle: 'Seleccionar archivo de backup (.organizador_backup)',
        type: FileType.any,
      );

      if (pickerResult == null || pickerResult.files.single.path == null) return;

      final filePath = pickerResult.files.single.path!;
      final file = File(filePath);
      final rawContainerJson = await file.readAsString();

      if (!mounted) return;

      final password = await _showPasswordPromptDialog();
      if (password == null) return;

      setState(() => _isProcessing = true);

      final db = context.read<AppDatabase>();
      final secureStorage = context.read<SecureStorageService>();
      final manager = BackupManager(db: db, secureStorage: secureStorage);

      // Preview & Validate before restoring
      final summary = await manager.previewBackup(
        rawContainerJson: rawContainerJson,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      final confirmed = await _showImportConfirmationDialog(summary);
      if (confirmed != true) return;

      setState(() => _isProcessing = true);

      await manager.restoreBackup(
        rawContainerJson: rawContainerJson,
        password: password,
        restoreSecureSecrets: summary.hasSecureSecrets,
      );

      if (mounted) {
        AppToast.show(
          context,
          message: '¡Restauración completada con éxito!',
          icon: Icons.check_circle_rounded,
        );
      }
    } on BackupCryptoException catch (e) {
      if (mounted) {
        _showErrorDialog('Error de desprotección', e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al importar backup', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String pBasename(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  Future<Map<String, String>?> _showPasswordCreationDialog() {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePass = true;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Color(0xFF0EA5E9)),
                  SizedBox(width: 10),
                  Text('Contraseña del Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Definí una contraseña para cifrar el archivo. Solo vos podrás desbloquearlo.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Contraseña (mínimo 6 caracteres)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setDialogState(() => obscurePass = !obscurePass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v != passCtrl.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx, {'password': passCtrl.text});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Generar Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showPasswordPromptDialog() {
    final passCtrl = TextEditingController();
    bool obscurePass = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.key_rounded, color: Color(0xFF0EA5E9)),
                  SizedBox(width: 10),
                  Text('Ingresar Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresá la contraseña elegida al momento de crear este backup.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscurePass,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña del backup',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscurePass = !obscurePass),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, passCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Desbloquear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showImportConfirmationDialog(BackupSummary summary) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 28),
              SizedBox(width: 10),
              Text('Confirmar Restauración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este backup contiene:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(Icons.receipt_long_rounded, '${summary.transactionCount} transacciones'),
                _buildSummaryRow(Icons.task_alt_rounded, '${summary.taskCount} tareas / parciales'),
                _buildSummaryRow(Icons.event_rounded, '${summary.eventCount} eventos de calendario'),
                _buildSummaryRow(Icons.note_alt_rounded, '${summary.personalElementCount} notas y elementos'),
                _buildSummaryRow(Icons.list_alt_rounded, '${summary.listItemCount} ítems de lista'),
                _buildSummaryRow(Icons.people_outline_rounded, '${summary.conocidoCount} conocidos'),
                _buildSummaryRow(Icons.trending_up_rounded, '${summary.projectedAdjustmentCount} ajustes proyectados'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Text(
                    '⚠️ Esta acción reemplazará los datos actuales por los del backup. Se creará una copia temporal automática de seguridad antes de proceder.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reemplazar y Restaurar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0EA5E9)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  void _showExportSuccessDialog({
    required String fileName,
    required String fileSize,
    required String savedPath,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Backup Creado Exitosamente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivo: $fileName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Tamaño: $fileSize', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            Text('Ubicación: $savedPath', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final cardColor = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final borderColor = AppColors.borderColor(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Gestión de Backups',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER INFORMATIVO ARCHITECTURE PRIVACY FIRST
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: borderColor) : null,
                  boxShadow: isDark
                      ? []
                      : const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Tus datos son tuyos',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toda tu información permanece 100% en tu dispositivo. La app no sube tus datos automáticamente a ningún servidor. '
                      'Podés exportar un backup cifrado y guardarlo donde quieras (Google Drive, pendrive, etc.).',
                      style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECCIÓN EXPORTAR
              Text('Exportar Información', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: borderColor) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creá un archivo cifrado (.organizador_backup) protegido con tu contraseña.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Incluir tokens y cuentas conectadas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                      subtitle: Text('Desactivado por defecto por seguridad.', style: TextStyle(fontSize: 11, color: textSecondary)),
                      value: _includeSecrets,
                      onChanged: (val) => setState(() => _includeSecrets = val),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _exportBackup,
                        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                        label: const Text('Crear Backup Encriptado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECCIÓN IMPORTAR
              Text('Restaurar Información', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: borderColor) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccioná un archivo de backup previamente creado para recuperar tus datos.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _importBackup,
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF0EA5E9)),
                        label: const Text('Restaurar desde Backup', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                      SizedBox(height: 12),
                      Text('Procesando datos...', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
