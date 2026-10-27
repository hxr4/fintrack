import 'adjustment.dart';
import 'category.dart';
import 'money.dart';

final class DonorLimit {
  const DonorLimit(this.category, [this.keep = Money.zero]);

  final BudgetCategory category;
  final Money keep;
}

final class Draw {
  const Draw(this.category, this.amount);

  final BudgetCategory category;
  final Money amount;
}

final class Drawdown {
  const Drawdown(this.draws, this.remaining);

  final List<Draw> draws;
  final Money remaining;

  Money get taken => Money.sum(draws.map((draw) => draw.amount));

  List<AdjustmentDraft> toAdjustments({
    required BudgetCategory to,
    required AdjustmentReason reason,
    required bool auto,
  }) => [
        for (final draw in draws)
          AdjustmentDraft(from: draw.category, to: to, amount: draw.amount, reason: reason, auto: auto),
      ];
}

abstract final class Donors {
  static Drawdown draw({
    required Map<BudgetCategory, Money> balances,
    required Money needed,
    required List<DonorLimit> order,
  }) {
    final draws = <Draw>[];
    var remaining = needed;
    for (final donor in order) {
      if (!remaining.isPositive) {
        break;
      }
      final spare = ((balances[donor.category] ?? Money.zero) - donor.keep).positivePart;
      final take = Money.min(spare, remaining);
      if (take.isPositive) {
        draws.add(Draw(donor.category, take));
        balances[donor.category] = balances[donor.category]! - take;
        remaining -= take;
      }
    }
    return Drawdown(draws, remaining.positivePart);
  }
}
