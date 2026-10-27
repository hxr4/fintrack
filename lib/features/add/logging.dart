import 'dart:async';

import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state.dart';
import '../../app/strings.dart';
import '../../domain/rupees.dart';

PaymentMethod lastUsedMethod(AppState state) {
  final transactions = state.ledger?.transactions ?? const [];
  for (final transaction in transactions.reversed) {
    if (!transaction.isCorrection) {
      if (transaction.method == PaymentMethod.card && !state.preferences.cardEnabled) {
        break;
      }
      return transaction.method;
    }
  }
  return PaymentMethod.upi;
}

Future<void> logAndConfirm(
  BuildContext context,
  WidgetRef ref, {
  required Money amount,
  required BudgetCategory category,
  required TransactionSource source,
  PaymentMethod? method,
  String note = '',
  String? learnKeyword,
}) async {
  final controller = ref.read(budgetProvider.notifier);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final chosenMethod = method ?? lastUsedMethod(ref.read(budgetProvider).requireValue);
  final outcome = await controller.log(
    amount: amount,
    category: category,
    method: chosenMethod,
    source: source,
    note: note,
    learnKeyword: learnKeyword,
  );
  unawaited(HapticFeedback.lightImpact());
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(S.logged(Rupees.format(amount), category)),
      action: SnackBarAction(
        label: S.undo,
        onPressed: () async {
          final batch = outcome.batch;
          if (batch != null) {
            await controller.undoBatch(batch.id);
          }
          await controller.deleteTransaction(outcome.transaction);
        },
      ),
    ));
}
