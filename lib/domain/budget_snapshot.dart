import 'package:budget_engine/budget_engine.dart';

import 'category_prediction.dart';
import 'health.dart';
import 'ledger_data.dart';

final class CategoryView {
  const CategoryView({
    required this.category,
    required this.left,
    required this.held,
    required this.spent,
    required this.total,
    required this.health,
  });

  final BudgetCategory category;
  final Money left;
  final Money held;
  final Money spent;
  final Money total;
  final CategoryHealth health;

  int get leftPermille {
    if (!total.isPositive) {
      return 0;
    }
    final value = (left.positivePart.paise * 1000) ~/ total.paise;
    return value > 1000 ? 1000 : value;
  }

  bool get isSpendable => category != BudgetCategory.goals;
}

final class BudgetSnapshot {
  const BudgetSnapshot({
    required this.now,
    required this.today,
    required this.isLateNight,
    required this.awaitingDeposit,
    required this.dayNumber,
    required this.cycleLength,
    required this.daysLeft,
    required this.balances,
    required this.held,
    required this.allowance,
    required this.ringHealth,
    required this.runway,
    required this.categories,
    required this.pendingSummary,
    required this.predictedCategory,
    required this.essentialsReservedForDue,
  });

  static const homeCategories = [
    BudgetCategory.food,
    BudgetCategory.petrol,
    BudgetCategory.nightFoodStock,
    BudgetCategory.essentialsStock,
    BudgetCategory.outings,
    BudgetCategory.trySomethingNew,
    BudgetCategory.misc,
    BudgetCategory.buffer,
    BudgetCategory.goals,
  ];

  final DateTime now;
  final CivilDate today;
  final bool isLateNight;
  final bool awaitingDeposit;
  final int dayNumber;
  final int cycleLength;
  final int daysLeft;
  final Map<BudgetCategory, Money> balances;
  final Map<BudgetCategory, Money> held;
  final DailyAllowance allowance;
  final HealthState ringHealth;
  final Runway? runway;
  final List<CategoryView> categories;
  final BatchRecord? pendingSummary;
  final BudgetCategory predictedCategory;
  final Money essentialsReservedForDue;

  Money get pool => Ledger.pool(balances, held: held);

  CategoryView view(BudgetCategory category) =>
      categories.firstWhere((view) => view.category == category);

  int get ringSpentPermille {
    final ring = allowance.ringAmount;
    if (!ring.isPositive) {
      return allowance.spentToday.isPositive ? 1000 : 0;
    }
    final value = (allowance.spentToday.paise * 1000) ~/ ring.paise;
    return value > 1000 ? 1000 : value;
  }

  static BudgetSnapshot compute({
    required LedgerData ledger,
    required BudgetSettings settings,
    required DateTime now,
  }) {
    final boundary = settings.dayBoundaryHour;
    final today = KolkataTime.allowanceDateOf(now, boundaryHour: boundary);
    final window = ledger.cycle.window;
    final awaiting = CycleCalendar.isAwaitingDeposit(window, today);
    final daysLeft = awaiting
        ? CycleCalendar.awaitingPlanDays(expectedStart: window.nextStart, today: today, policy: const BudgetPolicy())
        : (today.isBefore(window.start) ? window.length : window.daysLeftIncluding(today));
    final dayNumber = today.isBefore(window.start) ? 1 : window.dayNumber(today);
    final cycleLength = awaiting ? daysLeft : window.length;

    final balances = ledger.balances;
    final held = ledger.held;
    final spendable = Holds.spendable(balances, held);

    final spentToday = BudgetCategory.filled(Money.zero);
    final spentInCycle = BudgetCategory.filled(Money.zero);
    final poolSpendByDay = <CivilDate, Money>{};
    for (final transaction in ledger.transactions) {
      if (transaction.isCorrection) {
        continue;
      }
      final day = KolkataTime.allowanceDateOf(transaction.occurredAt, boundaryHour: boundary);
      spentInCycle[transaction.category] = spentInCycle[transaction.category]! + transaction.amount;
      if (day == today) {
        spentToday[transaction.category] = spentToday[transaction.category]! + transaction.amount;
      }
      if (transaction.category.isInSpendablePool) {
        poolSpendByDay[day] = (poolSpendByDay[day] ?? Money.zero) + transaction.amount;
      }
    }

    final poolAtStart = DailyAllowanceCalculator.poolAtStartOfDay(
      balancesNow: balances,
      spentTodayByCategory: spentToday,
      held: held,
    );
    final allowance = DailyAllowanceCalculator.compute(
      poolAtStartOfDay: poolAtStart,
      spentToday: Money.sum(BudgetCategory.spendablePool.map((category) => spentToday[category]!)),
      daysLeft: daysLeft,
      baseDaily: ledger.cycle.baseDaily,
    );

    final runway = awaiting || today.isBefore(window.start)
        ? null
        : RunwayCalculator.compute(
            pool: Ledger.pool(balances, held: held),
            today: today,
            window: window,
            poolSpendByDay: poolSpendByDay,
            baseDaily: ledger.cycle.baseDaily,
          );

    final categories = [
      for (final category in homeCategories)
        CategoryView(
          category: category,
          left: spendable[category]!,
          held: held[category]!,
          spent: spentInCycle[category]!,
          total: balances[category]! + spentInCycle[category]!,
          health: CategoryHealth.of(
            category: category,
            left: spendable[category]!,
            total: balances[category]! + spentInCycle[category]!,
            daysLeft: daysLeft,
            cycleLength: cycleLength,
          ),
        ),
    ];

    final poolTotal = Money.sum(BudgetCategory.spendablePool
        .map((category) => balances[category]! + spentInCycle[category]!));
    final ringHealth = CategoryHealth.stateFor(
      left: Ledger.pool(balances, held: held),
      total: poolTotal,
      daysLeft: daysLeft,
      cycleLength: cycleLength,
    );

    final pending = ledger.batches
        .where((batch) => batch.kind == BatchKind.refill && !batch.seen && !batch.undone)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final dueSupplies = ledger.supplies
        .where((supply) => supply.state.daysLeftOn(today) < daysLeft)
        .map((supply) => supply.state.price);

    return BudgetSnapshot(
      now: now,
      today: today,
      isLateNight: KolkataTime.isLateNight(now, boundaryHour: boundary),
      awaitingDeposit: awaiting,
      dayNumber: dayNumber,
      cycleLength: window.length,
      daysLeft: daysLeft,
      balances: balances,
      held: held,
      allowance: allowance,
      ringHealth: ringHealth,
      runway: runway,
      categories: categories,
      pendingSummary: pending.isEmpty ? null : pending.first,
      predictedCategory: CategoryPrediction.predict(
        now: now,
        recent: ledger.transactions,
        boundaryHour: boundary,
      ),
      essentialsReservedForDue: Money.sum(dueSupplies),
    );
  }
}
