import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_types.dart';

/// Central wrapper around flutter_local_notifications plugin.
///
/// Follows strict battery-efficient design: uses native OS AlarmManager/NotificationManager
/// scheduling without background loops or continuous process execution.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;

  /// Initializes timezone data and native notification channels.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      final result = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('🔔 [NotificationService] Notification tapped: ${details.payload}');
        },
      );

      _isInitialized = result ?? true;
      return _isInitialized;
    } catch (e) {
      debugPrint('❌ [NotificationService] Initialization error: $e');
      return false;
    }
  }

  /// Requests notification permissions (Android 13+ & iOS).
  ///
  /// Only invoked when the user explicitly enables notifications in settings.
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await androidImplementation?.requestNotificationsPermission();

      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return (androidGranted ?? false) || (iosGranted ?? false);
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Permission request exception: $e');
      return false;
    }
  }

  /// Displays an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationCategory category,
    String? payload,
  }) async {
    try {
      final details = _getNotificationDetails(category);
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('❌ [NotificationService] Error showing notification $id: $e');
    }
  }

  /// Schedules an OS notification for a future date/time.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationCategory category,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ [NotificationService] Cannot schedule notification in the past ($scheduledDate)');
      return;
    }

    try {
      final details = _getNotificationDetails(category);
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ [NotificationService] Error scheduling notification $id: $e');
    }
  }

  /// Cancels a specific scheduled notification by ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('❌ [NotificationService] Error canceling notification $id: $e');
    }
  }

  /// Cancels all pending notifications across all categories.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('❌ [NotificationService] Error canceling all notifications: $e');
    }
  }

  NotificationDetails _getNotificationDetails(NotificationCategory category) {
    String channelId;
    String channelName;
    String channelDesc;

    switch (category) {
      case NotificationCategory.finance:
        channelId = NotificationChannels.channelFinanceId;
        channelName = NotificationChannels.channelFinanceName;
        channelDesc = NotificationChannels.channelFinanceDesc;
        break;
      case NotificationCategory.tasks:
        channelId = NotificationChannels.channelTasksId;
        channelName = NotificationChannels.channelTasksName;
        channelDesc = NotificationChannels.channelTasksDesc;
        break;
      case NotificationCategory.personal:
        channelId = NotificationChannels.channelPersonalId;
        channelName = NotificationChannels.channelPersonalName;
        channelDesc = NotificationChannels.channelPersonalDesc;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    return NotificationDetails(android: androidDetails, iOS: darwinDetails);
  }
}
