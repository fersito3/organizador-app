import '../settings/settings_model.dart';

class AppFormatters {
  /// Formatea un monto numérico según la moneda seleccionada y las cotizaciones configuradas.
  static String formatCurrency(
    double amount,
    AppCurrency currency, {
    double exchangeRateUsd = 1200.0,
    double exchangeRateEur = 1300.0,
    bool showSign = false,
    bool hideDecimals = false,
  }) {
    double convertedAmount = amount;
    if (currency == AppCurrency.usd && exchangeRateUsd > 0) {
      convertedAmount = amount / exchangeRateUsd;
    } else if (currency == AppCurrency.eur && exchangeRateEur > 0) {
      convertedAmount = amount / exchangeRateEur;
    }

    final absAmount = convertedAmount.abs();
    final parts = absAmount.toStringAsFixed(hideDecimals ? 0 : 2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // Agregar separador de millares con punto
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }
    final formattedInt = buffer.toString();
    final formattedNum = hideDecimals ? formattedInt : '$formattedInt,$decimalPart';

    String symbol = currency.symbol;
    if (currency == AppCurrency.usd) {
      symbol = 'US\$';
    }

    final sign = convertedAmount < 0
        ? '-'
        : (showSign && convertedAmount > 0 ? '+' : '');

    return '$sign$symbol $formattedNum';
  }


  /// Formatea una fecha según el formato de fecha de la configuración del usuario.
  static String formatDate(DateTime date, AppDateFormat format) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    switch (format) {
      case AppDateFormat.ddmmyyyy:
        return '$day/$month/$year';
      case AppDateFormat.mmddyyyy:
        return '$month/$day/$year';
      case AppDateFormat.yyyymmdd:
        return '$year-$month-$day';
    }
  }

  /// Retorna el inicio de la semana según el primer día configurado (Lunes o Domingo).
  static DateTime getStartOfWeek(DateTime date, FirstDayOfWeek firstDay) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    if (firstDay == FirstDayOfWeek.monday) {
      final offset = cleanDate.weekday - 1; // Lunes = 1 -> offset 0
      return cleanDate.subtract(Duration(days: offset));
    } else {
      final offset = cleanDate.weekday % 7; // Domingo = 7 -> offset 0
      return cleanDate.subtract(Duration(days: offset));
    }
  }

  /// Retorna las abreviaturas de los días de la semana según el primer día configurado e idioma.
  static List<String> getWeekDaysHeader(FirstDayOfWeek firstDay, [AppLanguage language = AppLanguage.es]) {
    final isEn = language == AppLanguage.en;
    if (firstDay == FirstDayOfWeek.monday) {
      return isEn
          ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          : ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    } else {
      return isEn
          ? ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          : ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    }
  }

  /// Nombres de los meses traducidos.
  static String getMonthName(int month, [AppLanguage language = AppLanguage.es]) {
    final esMonths = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final clampedMonth = month.clamp(1, 12);
    return language == AppLanguage.en ? enMonths[clampedMonth - 1] : esMonths[clampedMonth - 1];
  }
}
