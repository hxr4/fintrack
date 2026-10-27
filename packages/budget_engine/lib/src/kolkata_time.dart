import 'civil_date.dart';

abstract final class KolkataTime {
  static const offset = Duration(hours: 5, minutes: 30);

  static DateTime wallClock(DateTime instant) => instant.toUtc().add(offset);

  static CivilDate dateOf(DateTime instant) {
    final wall = wallClock(instant);
    return CivilDate(wall.year, wall.month, wall.day);
  }

  static CivilDate allowanceDateOf(DateTime instant, {required int boundaryHour}) =>
      dateOf(instant.subtract(Duration(hours: boundaryHour)));

  static bool isLateNight(DateTime instant, {required int boundaryHour}) =>
      wallClock(instant).hour < boundaryHour;

  static DateTime startOfDate(CivilDate date) =>
      DateTime.utc(date.year, date.month, date.day).subtract(offset);

  static DateTime startOfAllowanceDate(CivilDate date, {required int boundaryHour}) =>
      startOfDate(date).add(Duration(hours: boundaryHour));

  static DateTime at(CivilDate date, int hour, [int minute = 0]) =>
      startOfDate(date).add(Duration(hours: hour, minutes: minute));
}
