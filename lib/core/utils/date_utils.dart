class AppDateUtils {
  static DateTime getStartOfToday() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime getEndOfToday() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfWeek() {
    final DateTime now = DateTime.now();
    final int daysToSubtract = now.weekday - 1;
    final DateTime monday = now.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static DateTime getStartOfMonth() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime getStartOfYear() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  static DateTime getStartOfPreviousWeek() {
    final DateTime startOfThisWeek = getStartOfWeek();
    return startOfThisWeek.subtract(const Duration(days: 7));
  }

  static DateTime getEndOfPreviousWeek() {
    final DateTime startOfThisWeek = getStartOfWeek();
    return startOfThisWeek.subtract(const Duration(milliseconds: 1));
  }
}
