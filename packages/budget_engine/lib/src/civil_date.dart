final class CivilDate implements Comparable<CivilDate> {
  factory CivilDate(int year, int month, int day) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be 1 to 12');
    }
    if (day < 1 || day > daysInMonth(year, month)) {
      throw ArgumentError.value(day, 'day', 'is outside $year-$month');
    }
    return CivilDate._(year, month, day);
  }

  factory CivilDate.clamped(int year, int month, int day) {
    final normalised = DateTime.utc(year, month);
    final lastDay = daysInMonth(normalised.year, normalised.month);
    return CivilDate._(
      normalised.year,
      normalised.month,
      day < 1 ? 1 : (day > lastDay ? lastDay : day),
    );
  }

  factory CivilDate.parse(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    if (parts.length != 3) {
      throw FormatException('Expected yyyy-mm-dd', iso);
    }
    return CivilDate(parts[0], parts[1], parts[2]);
  }

  const CivilDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }
    return lengths[month - 1];
  }

  DateTime get _utcMidnight => DateTime.utc(year, month, day);

  CivilDate addDays(int days) {
    final moved = DateTime.utc(year, month, day + days);
    return CivilDate._(moved.year, moved.month, moved.day);
  }

  int daysUntil(CivilDate other) =>
      other._utcMidnight.difference(_utcMidnight).inDays;

  bool isBefore(CivilDate other) => compareTo(other) < 0;
  bool isAfter(CivilDate other) => compareTo(other) > 0;

  bool operator <(CivilDate other) => compareTo(other) < 0;
  bool operator <=(CivilDate other) => compareTo(other) <= 0;
  bool operator >(CivilDate other) => compareTo(other) > 0;
  bool operator >=(CivilDate other) => compareTo(other) >= 0;

  @override
  int compareTo(CivilDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
