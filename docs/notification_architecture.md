# Documentation: Local Notification Architecture

**Project:** `organizador_app`  
**Philosophy:** Offline-First, Local-First, Privacy-First  

---

## 1. Executive Summary

The notification system in `organizador_app` provides helpful reminders for task deadlines, academic events, and financial spending limits while **minimizing battery usage**.

- **100% Offline & Local:** Notifications use standard OS native APIs (`AndroidNotificationManager` / `iOS UserNotifications`).
- **Zero Cloud Infrastructure:** No Firebase Cloud Messaging, push servers, continuous background daemons, or polling loops are used.
- **Zero Battery Waste:** Notifications are scheduled directly into the operating system's alarm subsystem (`AndroidScheduleMode.exactAllowWhileIdle`). The operating system wakes the device only when an exact scheduled notification time arrives.

---

## 2. Notification Categories & Channels

| Category | Channel ID | Purpose | Trigger |
|---|---|---|---|
| **Finance** | `channel_finance` | Daily spending limit reminders & budget warnings | Scheduled based on user daily budget rules |
| **Tasks** | `channel_tasks` | Upcoming academic tasks, parciales, and calendar events | Scheduled 30 minutes before task due time |
| **Personal** | `channel_personal` | Personal goal progress reminders | Scheduled for goal target dates |

---

## 3. Storage & Preference Integration

Notification scheduling strictly honors preferences managed in `SettingsProvider`:

- `notificationsEnabled`: Global master switch. When set to `false`, `cancelAll()` is invoked immediately to purge pending OS alarms.
- `dailySpendingAlertsEnabled`: Toggles financial limit notifications.
- `taskRemindersEnabled`: Toggles academic task notifications.

---

## 4. Lifecycle & Cancellation Rules

1. **Task Creation / Update:** When a task with a due date is saved, `NotificationScheduler.scheduleTaskReminder` calculates the reminder time (e.g., 30 mins before) and registers a single OS alarm.
2. **Task Deletion / Completion:** When a task is deleted or marked as completed, `NotificationScheduler.cancelTaskReminder(taskId)` immediately cancels the corresponding OS alarm by ID (`NotificationIds.forTask(taskId)`).
3. **App Restart / Device Reboot:** Android automatically re-registers pending OS notifications after reboot without running app code in the background.

---

## 5. Adding Future Notification Types

1. Define a unique ID generator in `lib/core/notifications/notification_types.dart`.
2. Add a helper method in `NotificationScheduler`.
3. Check `AppSettings` preferences before calling `NotificationService.scheduleNotification`.
