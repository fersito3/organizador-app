import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:organizador_app/core/notifications/notification_scheduler.dart';
import 'package:organizador_app/core/notifications/notification_service.dart';
import 'package:organizador_app/core/notifications/notification_types.dart';
import 'package:organizador_app/core/settings/settings_model.dart';

/// Fake implementation of FlutterLocalNotificationsPlugin for testing
class FakeFlutterLocalNotificationsPlugin implements FlutterLocalNotificationsPlugin {
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<int> canceledNotificationIds = [];
  bool cancelAllInvoked = false;

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
  }) async {
    return true;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    dynamic scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
    });
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    canceledNotificationIds.add(id);
    scheduledNotifications.removeWhere((n) => n['id'] == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllInvoked = true;
    scheduledNotifications.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Notification System Unit Tests', () {
    late FakeFlutterLocalNotificationsPlugin fakePlugin;
    late NotificationService notificationService;
    late NotificationScheduler scheduler;

    setUp(() async {
      fakePlugin = FakeFlutterLocalNotificationsPlugin();
      notificationService = NotificationService(plugin: fakePlugin);
      await notificationService.initialize();
      scheduler = NotificationScheduler(notificationService);
    });

    test('Notification ID generator maps tasks properly', () {
      final id = NotificationIds.forTask(42);
      expect(id, equals(NotificationIds.taskReminderBase + 42));
    });

    test('Task reminder is NOT scheduled if notificationsEnabled is false', () async {
      const settings = AppSettings(notificationsEnabled: false);
      final futureDate = DateTime.now().add(const Duration(hours: 2));

      await scheduler.scheduleTaskReminder(
        taskId: 1,
        title: 'Estudiar para el examen',
        dueDate: futureDate,
        settings: settings,
      );

      expect(fakePlugin.scheduledNotifications, isEmpty);
    });

    test('Task reminder is NOT scheduled if taskRemindersEnabled is false', () async {
      const settings = AppSettings(
        notificationsEnabled: true,
        taskRemindersEnabled: false,
      );
      final futureDate = DateTime.now().add(const Duration(hours: 2));

      await scheduler.scheduleTaskReminder(
        taskId: 1,
        title: 'Estudiar para el examen',
        dueDate: futureDate,
        settings: settings,
      );

      expect(fakePlugin.scheduledNotifications, isEmpty);
    });

    test('Task reminder IS scheduled if preferences are enabled', () async {
      const settings = AppSettings(
        notificationsEnabled: true,
        taskRemindersEnabled: true,
      );
      final futureDate = DateTime.now().add(const Duration(hours: 2));

      await scheduler.scheduleTaskReminder(
        taskId: 5,
        title: 'Entregar proyecto de Flutter',
        dueDate: futureDate,
        settings: settings,
      );

      expect(fakePlugin.scheduledNotifications.length, equals(1));
      expect(fakePlugin.scheduledNotifications.first['id'], equals(NotificationIds.forTask(5)));
      expect(fakePlugin.scheduledNotifications.first['body'], contains('Entregar proyecto de Flutter'));
    });

    test('Canceling task reminder invokes OS notification cancel', () async {
      await scheduler.cancelTaskReminder(5);
      expect(fakePlugin.canceledNotificationIds, contains(NotificationIds.forTask(5)));
    });

    test('Disabling global notifications cancels all OS scheduled notifications', () async {
      const settingsDisabled = AppSettings(notificationsEnabled: false);

      await scheduler.syncPreferencesState(settingsDisabled);

      expect(fakePlugin.cancelAllInvoked, isTrue);
    });
  });
}
