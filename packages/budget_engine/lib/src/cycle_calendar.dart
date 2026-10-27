import 'civil_date.dart';
import 'policy.dart';

final class CycleWindow {
  CycleWindow({required this.start, required this.nextStart}) {
    if (!start.isBefore(nextStart)) {
      throw ArgumentError.value(nextStart, 'nextStart', 'must be after $start');
    }
  }

  final CivilDate start;
  final CivilDate nextStart;

  int get length => start.daysUntil(nextStart);

  CivilDate get lastDay => nextStart.addDays(-1);

  bool contains(CivilDate date) => date >= start && date < nextStart;

  int dayNumber(CivilDate date) => start.daysUntil(date) + 1;

  int daysLeftIncluding(CivilDate date) {
    if (!contains(date)) {
      throw ArgumentError.value(date, 'date', 'is outside $start to $lastDay');
    }
    return date.daysUntil(nextStart);
  }

  CycleWindow endingEarlyOn(CivilDate newNextStart) =>
      CycleWindow(start: start, nextStart: newNextStart);

  @override
  bool operator ==(Object other) =>
      other is CycleWindow && other.start == start && other.nextStart == nextStart;

  @override
  int get hashCode => Object.hash(start, nextStart);

  @override
  String toString() => 'CycleWindow($start to $lastDay, $length days)';
}

abstract final class CycleCalendar {
  static CivilDate expectedNextStart(
    CivilDate start, {
    required int anchorDay,
    required BudgetPolicy policy,
  }) {
    var monthOffset = 0;
    while (true) {
      final candidate = CivilDate.clamped(start.year, start.month + monthOffset, anchorDay);
      if (candidate.isAfter(start) && start.daysUntil(candidate) >= policy.minimumCycleDays) {
        return candidate;
      }
      monthOffset += 1;
    }
  }

  static CycleWindow windowStartingOn(
    CivilDate start, {
    required int anchorDay,
    required BudgetPolicy policy,
  }) =>
      CycleWindow(
        start: start,
        nextStart: expectedNextStart(start, anchorDay: anchorDay, policy: policy),
      );

  static bool isAwaitingDeposit(CycleWindow window, CivilDate today) =>
      !today.isBefore(window.nextStart);

  static int awaitingPlanDays({
    required CivilDate expectedStart,
    required CivilDate today,
    required BudgetPolicy policy,
  }) {
    final planned = today.daysUntil(expectedStart.addDays(policy.awaitingGraceDays)) + 1;
    return planned < policy.awaitingMinimumDays ? policy.awaitingMinimumDays : planned;
  }
}
