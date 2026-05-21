/// Picks a [DateTime] for [MealEntry.loggedAt] so the meal rolls up under [calendarDay].
class MealLogTime {
  MealLogTime._();

  /// If [calendarDay] is **today**, uses clock now; otherwise noon on that date (local).
  static DateTime onCalendarDay(DateTime calendarDay) {
    final now = DateTime.now();
    final y = calendarDay.year;
    final m = calendarDay.month;
    final d = calendarDay.day;
    if (now.year == y && now.month == m && now.day == d) {
      return now;
    }
    return DateTime(y, m, d, 12, now.minute % 60, now.second % 60);
  }
}
