import 'adjustment.dart';
import 'category.dart';
import 'deposit.dart';
import 'donors.dart';
import 'hold.dart';
import 'largest_remainder.dart';
import 'money.dart';
import 'transaction.dart';

final class BalanceAnchor {
  const BalanceAnchor({required this.at, required this.total});

  final DateTime at;
  final Money total;
}

final class ReportedBalance {
  ReportedBalance({
    required this.at,
    required this.bank,
    required this.cash,
    this.excluded = Money.zero,
  }) {
    if (bank.isNegative || cash.isNegative || excluded.isNegative) {
      throw ArgumentError('Balances must not be negative');
    }
  }

  final DateTime at;
  final Money bank;
  final Money cash;
  final Money excluded;

  Money get budgetTotal => bank + cash - excluded;
}

enum BalanceResolution { unlogged, distribute, ignore }

final class BalanceComparison {
  const BalanceComparison({required this.reported, required this.expected, required this.actual});

  final ReportedBalance reported;
  final Money expected;
  final Money actual;

  Money get difference => actual - expected;
  bool get matches => difference.isZero;
  bool get isShort => difference.isNegative;
}

final class BalanceCorrection {
  const BalanceCorrection({
    required this.transactions,
    required this.adjustments,
    required this.newAnchor,
    required this.uncovered,
  });

  final List<TransactionDraft> transactions;
  final List<AdjustmentDraft> adjustments;
  final BalanceAnchor? newAnchor;
  final Money uncovered;
}

abstract final class BalanceCheck {
  static BalanceComparison compare({
    required BalanceAnchor anchor,
    required Iterable<Deposit> deposits,
    required Iterable<Transaction> transactions,
    required ReportedBalance reported,
  }) {
    bool inWindow(DateTime instant) => instant.isAfter(anchor.at) && !instant.isAfter(reported.at);
    final received = Money.sum(deposits.where((deposit) => inWindow(deposit.receivedAt)).map((deposit) => deposit.amount));
    final spent = Money.sum(transactions.where((transaction) => inWindow(transaction.occurredAt)).map((transaction) => transaction.amount));
    return BalanceComparison(
      reported: reported,
      expected: anchor.total + received - spent,
      actual: reported.budgetTotal,
    );
  }

  static BalanceCorrection resolve({
    required BalanceComparison comparison,
    required BalanceResolution resolution,
    required Map<BudgetCategory, Money> balances,
    required Map<BudgetCategory, Money> cycleSpendByCategory,
    required Map<BudgetCategory, Money> cycleAllocations,
    required Money foodFloorPerDay,
    required Money petrolFloorRemaining,
    required int daysLeft,
    Money essentialsReservedForDue = Money.zero,
    Map<BudgetCategory, Money> held = const {},
  }) {
    final difference = comparison.difference;
    final at = comparison.reported.at;
    final anchor = BalanceAnchor(at: at, total: comparison.actual);
    if (resolution == BalanceResolution.ignore || difference.isZero) {
      return BalanceCorrection(
        transactions: const [],
        adjustments: const [],
        newAnchor: difference.isZero ? anchor : null,
        uncovered: Money.zero,
      );
    }
    TransactionDraft correction(BudgetCategory category, Money amount) => TransactionDraft(
          amount: amount,
          category: category,
          method: PaymentMethod.unrecorded,
          occurredAt: at,
          source: TransactionSource.balanceCheck,
          note: 'Balance check',
        );

    if (resolution == BalanceResolution.distribute) {
      final basis = _shareBasis(cycleSpendByCategory, cycleAllocations);
      final parts = LargestRemainder.splitByAmounts(Money(difference.paise.abs()), basis);
      return BalanceCorrection(
        transactions: [
          for (final entry in parts.entries)
            if (entry.value.isPositive)
              correction(entry.key, difference.isNegative ? entry.value : -entry.value),
        ],
        adjustments: const [],
        newAnchor: anchor,
        uncovered: Money.zero,
      );
    }

    if (difference.isPositive) {
      return BalanceCorrection(
        transactions: [correction(BudgetCategory.unlogged, -difference)],
        adjustments: [
          AdjustmentDraft(
            from: BudgetCategory.unlogged,
            to: BudgetCategory.buffer,
            amount: difference,
            reason: AdjustmentReason.balanceCheck,
            auto: false,
          ),
        ],
        newAnchor: anchor,
        uncovered: Money.zero,
      );
    }

    final shortfall = -difference;
    final working = Holds.spendable(balances, held);
    final drawdown = Donors.draw(
      balances: working,
      needed: shortfall,
      order: [
        const DonorLimit(BudgetCategory.trySomethingNew),
        const DonorLimit(BudgetCategory.outings),
        const DonorLimit(BudgetCategory.misc),
        const DonorLimit(BudgetCategory.buffer),
        DonorLimit(BudgetCategory.essentialsStock, essentialsReservedForDue),
        DonorLimit(BudgetCategory.petrol, petrolFloorRemaining),
        DonorLimit(BudgetCategory.food, foodFloorPerDay.times(daysLeft)),
      ],
    );
    return BalanceCorrection(
      transactions: [correction(BudgetCategory.unlogged, shortfall)],
      adjustments: drawdown.toAdjustments(
        to: BudgetCategory.unlogged,
        reason: AdjustmentReason.balanceCheck,
        auto: false,
      ),
      newAnchor: anchor,
      uncovered: drawdown.remaining,
    );
  }

  static Map<BudgetCategory, Money> _shareBasis(
    Map<BudgetCategory, Money> spend,
    Map<BudgetCategory, Money> allocations,
  ) {
    final fromSpend = {
      for (final category in BudgetCategory.spendingCategories)
        category: (spend[category] ?? Money.zero).positivePart,
    };
    if (fromSpend.values.any((amount) => amount.isPositive)) {
      return fromSpend;
    }
    final fromAllocations = {
      for (final category in BudgetCategory.spendingCategories)
        category: (allocations[category] ?? Money.zero).positivePart,
    };
    if (fromAllocations.values.any((amount) => amount.isPositive)) {
      return fromAllocations;
    }
    return {BudgetCategory.misc: const Money(1)};
  }
}
