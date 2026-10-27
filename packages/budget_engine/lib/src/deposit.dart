import 'money.dart';

enum DepositKind { installment, extra }

final class Deposit {
  Deposit({
    required this.id,
    required this.amount,
    required this.receivedAt,
    required this.kind,
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
  }

  final String id;
  final Money amount;
  final DateTime receivedAt;
  final DepositKind kind;

  bool get isInstallment => kind == DepositKind.installment;
  bool get isExtra => kind == DepositKind.extra;
}

extension DepositTotals on Iterable<Deposit> {
  Money get installmentTotal =>
      Money.sum(where((deposit) => deposit.isInstallment).map((deposit) => deposit.amount));

  Money get extraTotal =>
      Money.sum(where((deposit) => deposit.isExtra).map((deposit) => deposit.amount));

  Money get total => Money.sum(map((deposit) => deposit.amount));
}
