import 'category.dart';
import 'money.dart';

enum PaymentMethod { cash, upi, card, unrecorded }

enum TransactionSource { manual, quickAdd, typed, notification, balanceCheck }

final class TransactionDraft {
  TransactionDraft({
    required this.amount,
    required this.category,
    required this.method,
    required this.occurredAt,
    required this.source,
    this.note = '',
  }) {
    final isCorrection = source == TransactionSource.balanceCheck;
    if (isCorrection) {
      if (method != PaymentMethod.unrecorded) {
        throw ArgumentError.value(method, 'method', 'corrections are unrecorded');
      }
      if (amount.isZero) {
        throw ArgumentError.value(amount, 'amount', 'must not be zero');
      }
    } else {
      if (!amount.isPositive) {
        throw ArgumentError.value(amount, 'amount', 'must be positive');
      }
      if (method == PaymentMethod.unrecorded) {
        throw ArgumentError.value(method, 'method', 'is reserved for corrections');
      }
      if (category == BudgetCategory.unlogged) {
        throw ArgumentError.value(category, 'category', 'is reserved for corrections');
      }
    }
  }

  final Money amount;
  final BudgetCategory category;
  final PaymentMethod method;
  final DateTime occurredAt;
  final TransactionSource source;
  final String note;

  bool get isCorrection => source == TransactionSource.balanceCheck;
}

final class Transaction {
  Transaction({
    required this.id,
    required Money amount,
    required BudgetCategory category,
    required PaymentMethod method,
    required DateTime occurredAt,
    required TransactionSource source,
    String note = '',
  }) : draft = TransactionDraft(
          amount: amount,
          category: category,
          method: method,
          occurredAt: occurredAt,
          source: source,
          note: note,
        );

  Transaction.fromDraft(this.id, this.draft);

  final String id;
  final TransactionDraft draft;

  Money get amount => draft.amount;
  BudgetCategory get category => draft.category;
  PaymentMethod get method => draft.method;
  DateTime get occurredAt => draft.occurredAt;
  TransactionSource get source => draft.source;
  String get note => draft.note;
  bool get isCorrection => draft.isCorrection;
}
