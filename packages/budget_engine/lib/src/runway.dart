import 'civil_date.dart';
import 'cycle_calendar.dart';
import 'money.dart';
import 'policy.dart';

final class Runway {
  const Runway({
    required this.averageDailySpend,
    required this.coveredDays,
    required this.daysLeft,
    required this.runsOutOn,
  });

  final Money averageDailySpend;
  final int? coveredDays;
  final int daysLeft;
  final CivilDate? runsOutOn;

  bool get isComfortable => coveredDays == null;
  int get daysSpare => coveredDays == null ? daysLeft : coveredDays! - daysLeft;
  bool get isShort => daysSpare < 0;
  int get daysShort => isShort ? -daysSpare : 0;
}

abstract final class RunwayCalculator {
  static Runway compute({
    required Money pool,
    required CivilDate today,
    required CycleWindow window,
    required Map<CivilDate, Money> poolSpendByDay,
    required Money baseDaily,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    final daysLeft = window.daysLeftIncluding(today);
    final trailingStart = today.addDays(-policy.runwayWindowDays);
    final firstDay = trailingStart < window.start ? window.start : trailingStart;
    final countedDays = firstDay.daysUntil(today);
    final average = countedDays == 0
        ? baseDaily
        : Money.sum([
            for (var offset = 0; offset < countedDays; offset++)
              poolSpendByDay[firstDay.addDays(offset)] ?? Money.zero,
          ]).floorDiv(countedDays);
    if (!average.isPositive) {
      return Runway(averageDailySpend: average, coveredDays: null, daysLeft: daysLeft, runsOutOn: null);
    }
    final covered = pool.positivePart.wholeTimesIn(average);
    return Runway(
      averageDailySpend: average,
      coveredDays: covered,
      daysLeft: daysLeft,
      runsOutOn: today.addDays(covered),
    );
  }
}
