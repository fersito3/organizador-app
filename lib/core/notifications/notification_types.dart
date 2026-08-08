enum NotificationCategory {
  finance,
  tasks,
  personal,
}

class NotificationChannels {
  static const String channelFinanceId = 'channel_finance';
  static const String channelFinanceName = 'Alertas de Finanzas';
  static const String channelFinanceDesc = 'Avisos de límite de gasto diario y presupuesto.';

  static const String channelTasksId = 'channel_tasks';
  static const String channelTasksName = 'Recordatorios de Tareas';
  static const String channelTasksDesc = 'Avisos sobre entregas de tareas y eventos de calendario.';

  static const String channelPersonalId = 'channel_personal';
  static const String channelPersonalName = 'Espacio Personal';
  static const String channelPersonalDesc = 'Avisos sobre objetivos y recordatorios personales.';
}

class NotificationIds {
  static const int dailySpendingAlert = 1001;
  static const int budgetWarningAlert = 1002;
  static const int taskReminderBase = 2000;
  static const int personalGoalBase = 3000;

  static int forTask(int taskId) => taskReminderBase + taskId;
  static int forGoal(int goalId) => personalGoalBase + goalId;
}
