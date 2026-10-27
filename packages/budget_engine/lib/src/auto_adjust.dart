import 'adjustment.dart';
import 'category.dart';
import 'civil_date.dart';
import 'donors.dart';
import 'hold.dart';
import 'kolkata_time.dart';
import 'money.dart';
import 'policy.dart';

final class AutoAdjustResult {
  const AutoAdjustResult({
    required this.moves,
    required this.newHolds,
    required this.releases,
    required this.uncovered,
    required this.holdShortfall,
    required this.suggestReplan,
  });

  final List<AdjustmentDraft> moves;
  final List<HoldDraft> newHolds;
  final List<HoldRelease> releases;
  final Map<BudgetCategory, Money> uncovered;
  final Money holdShortfall;
  final bool suggestReplan;

  bool get moved => moves.isNotEmpty || newHolds.isNotEmpty || releases.isNotEmpty;
  bool get shortfall => uncovered.values.any((amount) => amount.isPositive) || holdShortfall.isPositive;

  List<AdjustmentDraft> get allMoves => [
        ...moves,
        for (final release in releases) ...release.moves,
      ];

  Money get totalMoved => Money.sum(allMoves.map((move) => move.amount));
  Money get totalHeld => Money.sum(newHolds.map((hold) => hold.amount));
}

abstract final class AutoAdjuster {
  static Money refillTarget({
    required BudgetCategory category,
    required Money foodFloorPerDay,
    required Money petrolFloorForCycle,
    required int cycleLength,
    required int daysLeft,
    BudgetPolicy policy = const BudgetPolicy(),
  }) =>
      switch (category) {
        BudgetCategory.food => foodFloorPerDay.times(_refillDays(daysLeft, policy)),
        BudgetCategory.petrol => petrolFloorForCycle.times(daysLeft).ceilDiv(cycleLength),
        BudgetCategory.nightFoodStock => Money.zero,
        _ => throw ArgumentError.value(category, 'category', 'is not essential'),
      };

  static Money foodHoldTarget({
    required Money foodFloorPerDay,
    required int daysLeft,
    BudgetPolicy policy = const BudgetPolicy(),
  }) =>
      foodFloorPerDay.times(daysLeft - _refillDays(daysLeft, policy));

  static int _refillDays(int daysLeft, BudgetPolicy policy) =>
      daysLeft < policy.foodRefillDays ? daysLeft : policy.foodRefillDays;

  static AutoAdjustResult run({
    required Map<BudgetCategory, Money> balances,
    required Money foodFloorPerDay,
    required Money petrolFloorForCycle,
    required int cycleLength,
    required int daysLeft,
    required int dayOfCycle,
    Iterable<Hold> holds = const [],
    Money essentialsReservedForDue = Money.zero,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    final working = Map<BudgetCategory, Money>.of(balances);
    final held = Holds.heldByCategory(holds);
    final moves = <AdjustmentDraft>[];
    final newHolds = <HoldDraft>[];
    final releases = <HoldRelease>[];
    final uncovered = <BudgetCategory, Money>{};
    var holdShortfall = Money.zero;
    var suggestReplan = false;

    List<DonorLimit> donorLimits() => [
          const DonorLimit(BudgetCategory.buffer),
          const DonorLimit(BudgetCategory.trySomethingNew),
          const DonorLimit(BudgetCategory.outings),
          DonorLimit(BudgetCategory.essentialsStock, essentialsReservedForDue),
        ];

    Drawdown drawFromDonors(Money needed) {
      final spendable = Holds.spendable(working, held);
      return Donors.draw(balances: spendable, needed: needed, order: donorLimits());
    }

    for (final category in BudgetCategory.essentials) {
      final balance = working[category] ?? Money.zero;
      if (balance.isPositive) {
        continue;
      }
      final target = refillTarget(
        category: category,
        foodFloorPerDay: foodFloorPerDay,
        petrolFloorForCycle: petrolFloorForCycle,
        cycleLength: cycleLength,
        daysLeft: daysLeft,
        policy: policy,
      );
      var needed = target - balance;
      if (!needed.isPositive) {
        continue;
      }

      if (category == BudgetCategory.food) {
        suggestReplan = dayOfCycle < policy.replanPromptBeforeDay;
        for (final commitment in Holds.commitments(holds)) {
          if (!needed.isPositive) {
            break;
          }
          final release = Holds.release(commitment: commitment, amount: needed, balances: working);
          for (final draft in release.holds) {
            held[draft.category] = (held[draft.category]! + draft.amount).positivePart;
          }
          needed -= release.moved;
          releases.add(release);
        }
      }

      if (needed.isPositive) {
        final drawdown = drawFromDonors(needed);
        for (final draw in drawdown.draws) {
          working[draw.category] = working[draw.category]! - draw.amount;
        }
        working[category] = working[category]! + drawdown.taken;
        moves.addAll(drawdown.toAdjustments(to: category, reason: AdjustmentReason.autoRefill, auto: true));
        if (drawdown.remaining.isPositive) {
          uncovered[category] = drawdown.remaining;
        }
      }

      if (category == BudgetCategory.food) {
        final holdNeeded = foodHoldTarget(foodFloorPerDay: foodFloorPerDay, daysLeft: daysLeft, policy: policy) -
            Money.sum(held.values);
        if (holdNeeded.isPositive) {
          final placement = drawFromDonors(holdNeeded);
          for (final draw in placement.draws) {
            held[draw.category] = held[draw.category]! + draw.amount;
            newHolds.add(HoldDraft(category: draw.category, amount: draw.amount));
          }
          holdShortfall = placement.remaining;
        }
      }
    }
    return AutoAdjustResult(
      moves: moves,
      newHolds: newHolds,
      releases: releases,
      uncovered: uncovered,
      holdShortfall: holdShortfall,
      suggestReplan: suggestReplan,
    );
  }
}

abstract final class WeeklyHoldRelease {
  static List<HoldRelease> due({
    required Iterable<Hold> holds,
    required Map<BudgetCategory, Money> balances,
    required CivilDate today,
    required int boundaryHour,
    required Money foodFloorPerDay,
    BudgetPolicy policy = const BudgetPolicy(),
  }) {
    final working = Map<BudgetCategory, Money>.of(balances);
    final releases = <HoldRelease>[];
    for (final commitment in Holds.commitments(holds)) {
      final lastActivity = KolkataTime.allowanceDateOf(commitment.lastActivityAt, boundaryHour: boundaryHour);
      if (lastActivity.daysUntil(today) < policy.foodRefillDays) {
        continue;
      }
      releases.add(Holds.release(
        commitment: commitment,
        amount: foodFloorPerDay.times(policy.foodRefillDays),
        balances: working,
      ));
    }
    return releases;
  }
}
