final class Money implements Comparable<Money> {
  const Money(this.paise);

  factory Money.rupees(int rupees) => Money(rupees * 100);

  static const zero = Money(0);

  final int paise;

  bool get isZero => paise == 0;
  bool get isNegative => paise < 0;
  bool get isPositive => paise > 0;

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator -() => Money(-paise);
  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  Money times(int factor) => Money(paise * factor);

  Money floorDiv(int divisor) {
    _requirePositiveDivisor(divisor);
    var quotient = paise ~/ divisor;
    if (paise < 0 && paise % divisor != 0) {
      quotient -= 1;
    }
    return Money(quotient);
  }

  Money ceilDiv(int divisor) => -(-this).floorDiv(divisor);

  int wholeTimesIn(Money unit) {
    if (!unit.isPositive) {
      throw ArgumentError.value(unit, 'unit', 'must be positive');
    }
    return Money(paise).floorDiv(unit.paise).paise;
  }

  Money atLeast(Money minimum) => this < minimum ? minimum : this;
  Money atMost(Money maximum) => this > maximum ? maximum : this;
  Money get positivePart => atLeast(zero);

  static Money max(Money a, Money b) => a >= b ? a : b;
  static Money min(Money a, Money b) => a <= b ? a : b;

  static Money sum(Iterable<Money> values) =>
      values.fold(zero, (total, value) => total + value);

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) => other is Money && other.paise == paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() {
    final sign = paise < 0 ? '-' : '';
    final absolute = paise.abs();
    final rupees = absolute ~/ 100;
    final remainder = (absolute % 100).toString().padLeft(2, '0');
    return 'Money($sign₹$rupees.$remainder)';
  }

  static void _requirePositiveDivisor(int divisor) {
    if (divisor <= 0) {
      throw ArgumentError.value(divisor, 'divisor', 'must be positive');
    }
  }
}
