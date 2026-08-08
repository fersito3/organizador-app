import 'package:flutter/foundation.dart';
import '../settings/settings_model.dart';
import 'notification_service.dart';
import 'notification_types.dart';

class NotificationScheduler {
  final NotificationService _service;

  NotificationScheduler(this._service);

  /// Schedules a local notification for an upcoming task if user preferences allow.
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required DateTime dueDate,
    required AppSettings settings,
  }) async {
    if (!settings.notificationsEnabled || !settings.taskRemindersEnabled) {
      return;
    }

    final id = NotificationIds.forTask(taskId);
    final reminderTime = dueDate.subtract(const Duration(minutes: 30));

    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _service.scheduleNotification(
      id: id,
      title: 'Recordatorio de Tarea',
      body: 'Tenés pendiente: $title',
      scheduledDate: reminderTime,
      category: NotificationCategory.tasks,
      payload: 'task_$taskId',
    );
  }

  /// Cancels a task reminder when the task is completed or deleted.
  Future<void> cancelTaskReminder(int taskId) async {
    final id = NotificationIds.forTask(taskId);
    await _service.cancelNotification(id);
  }

  /// Schedules a daily spending limit reminder if enabled.
  Future<void> scheduleDailySpendingAlert({
    required double dailyLimit,
    required AppSettings settings,
  }) async {
    if (!settings.notificationsEnabled || !settings.dailySpendingAlertsEnabled) {
      await _service.cancelNotification(NotificationIds.dailySpendingAlert);
      return;
    }

    final now = DateTime.now();
    // Schedule for 20:00 today or tomorrow
    var targetDate = DateTime(now.year, now.month, now.day, 20, 0);
    if (targetDate.isBefore(now)) {
      targetDate = targetDate.add(const Duration(days: 1));
    }

    await _service.scheduleNotification(
      id: NotificationIds.dailySpendingAlert,
      title: 'Recordatorio de Presupuesto',
      body: 'Tu límite diario recomendado de hoy es \$${dailyLimit.toStringAsFixed(2)}.',
      scheduledDate: targetDate,
      category: NotificationCategory.finance,
      payload: 'finance_daily_alert',
    );
  }

  /// Reacts to changes in AppSettings: if notifications are disabled globally or per category,
  /// pending OS notifications are canceled immediately.
  Future<void> syncPreferencesState(AppSettings settings) async {
    if (!settings.notificationsEnabled) {
      await _service.cancelAll();
      debugPrint('🔔 [NotificationScheduler] All notifications canceled due to global disabled preference.');
    }
  }
}
