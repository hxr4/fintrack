import 'package:budget_engine/budget_engine.dart';
import 'package:test/test.dart';

void main() {
  test('rupees convert to paise exactly', () {
    expect(Money.rupees(12000).paise, 1200000);
  });

  test('floor and ceiling division round towards the right side', () {
    expect(const Money(7).floorDiv(2), const Money(3));
    expect(const Money(-7).floorDiv(2), const Money(-4));
    expect(const Money(7).ceilDiv(2), const Money(4));
    expect(const Money(-7).ceilDiv(2), const Money(-3));
    expect(const Money(8).ceilDiv(2), const Money(4));
  });

  test('division by zero or a negative divisor is rejected', () {
    expect(() => const Money(5).floorDiv(0), throwsArgumentError);
    expect(() => const Money(5).floorDiv(-1), throwsArgumentError);
  });

  test('comparison, clamping and sums', () {
    expect(Money.rupees(5) > Money.rupees(4), isTrue);
    expect(const Money(-3).positivePart, Money.zero);
    expect(const Money(10).atMost(const Money(4)), const Money(4));
    expect(Money.sum([const Money(1), const Money(2), const Money(-1)]), const Money(2));
  });

  test('whole times counts complete units only', () {
    expect(const Money(999).wholeTimesIn(const Money(100)), 9);
    expect(() => const Money(5).wholeTimesIn(Money.zero), throwsArgumentError);
  });

  test('toString shows rupees and paise', () {
    expect(const Money(123456).toString(), 'Money(₹1234.56)');
    expect(const Money(-5).toString(), 'Money(-₹0.05)');
  });
}
