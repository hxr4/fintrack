import 'package:budget_engine/budget_engine.dart';

abstract final class Rupees {
  static String format(Money money, {bool showPaise = false}) {
    final negative = money.isNegative;
    final absolute = money.paise.abs();
    final whole = showPaise ? absolute ~/ 100 : (absolute + 50) ~/ 100;
    final grouped = _indianGrouping(whole);
    final paisePart = showPaise ? '.${(absolute % 100).toString().padLeft(2, '0')}' : '';
    return '${negative ? '-' : ''}₹$grouped$paisePart';
  }

  static String plain(Money money) => _indianGrouping((money.paise.abs() + 50) ~/ 100);

  static String _indianGrouping(int value) {
    final digits = value.toString();
    if (digits.length <= 3) {
      return digits;
    }
    final lastThree = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }
    return '${groups.join(',')},$lastThree';
  }

  static Money? parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[₹,\s]'), '');
    final match = RegExp(r'^(\d{1,7})(?:\.(\d{1,2}))?$').firstMatch(cleaned);
    if (match == null) {
      return null;
    }
    final rupees = int.parse(match.group(1)!);
    final paiseText = (match.group(2) ?? '').padRight(2, '0');
    return Money(rupees * 100 + int.parse(paiseText));
  }
}
