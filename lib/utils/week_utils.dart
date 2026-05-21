/// Monday-based week helpers (DateTime.weekday: Mon = 1 … Sun = 7).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Monday 00:00 of the week that contains [d] (local calendar).
DateTime mondayOfWeekContaining(DateTime d) {
  final x = dateOnly(d);
  return x.subtract(Duration(days: x.weekday - DateTime.monday));
}

DateTime addDays(DateTime d, int n) => d.add(Duration(days: n));
