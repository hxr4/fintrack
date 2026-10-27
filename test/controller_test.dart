import 'package:budget_engine/budget_engine.dart';
import 'package:fintrack/app/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  late FakeClock clock;

  Future<ProviderContainer> start() async {
    final db = memoryDatabase();
    clock = FakeClock(ist(2026, 3, 5, 10));
    await seed(db, clock);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      authenticatorProvider.overrideWithValue(FakeAuthenticator()),
      secureWindowProvider.overrideWithValue(FakeSecureWindow()),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    await container.read(budgetProvider.future);
    return container;
  }

  test('monthly money starts a new cycle with carried balances and the generosity delta', () async {
    final container = await start();
    final controller = container.read(budgetProvider.notifier);
    clock.now = ist(2026, 3, 20, 13);
    await controller.log(
      amount: Money.rupees(200),
      category: BudgetCategory.nightFoodStock,
      method: PaymentMethod.upi,
      source: TransactionSource.manual,
    );
    final before = container.read(budgetProvider).requireValue.ledger!;
    final moneyLeft = Ledger.total(before.balances);

    clock.now = ist(2026, 4, 5, 9);
    await controller.logDeposit(amount: Money.rupees(13000), date: CivilDate(2026, 4, 5), kind: DepositKind.installment);
    final after = container.read(budgetProvider).requireValue;
    final ledger = after.ledger!;
    expect(ledger.cycle.id, isNot(before.cycle.id));
    expect(ledger.cycle.window.start, CivilDate(2026, 4, 5));
    expect(ledger.cycle.delta, Money.rupees(1000));
    expect(ledger.transactions, isEmpty);
    expect(ledger.opening[BudgetCategory.nightFoodStock], Money.rupees(550));
    expect(ledger.planAllocations[BudgetCategory.nightFoodStock], Money.rupees(200));
    expect(Ledger.total(ledger.balances), moneyLeft + Money.rupees(13000));
    expect(after.snapshot!.dayNumber, 1);
  });

  test('extra income is split by the generosity rule and raises the usual daily amount', () async {
    final container = await start();
    final controller = container.read(budgetProvider.notifier);
    final base = container.read(budgetProvider).requireValue.ledger!.cycle.baseDaily;
    clock.now = ist(2026, 3, 15, 12);
    await controller.logDeposit(amount: Money.rupees(1000), date: CivilDate(2026, 3, 15), kind: DepositKind.extra);
    final ledger = container.read(budgetProvider).requireValue.ledger!;
    expect(ledger.extraAllocations[BudgetCategory.food], Money.rupees(500));
    expect(ledger.extraAllocations[BudgetCategory.goals], Money.rupees(100));
    expect(ledger.deposits.where((deposit) => deposit.isExtra), hasLength(1));
    expect(ledger.cycle.baseDaily > base, isTrue);
  });

  test('held money is released into Food at the weekly rollover when the app refreshes', () async {
    final container = await start();
    final controller = container.read(budgetProvider.notifier);
    clock.now = ist(2026, 3, 6, 13);
    final outcome = await controller.log(
      amount: Money.rupees(7000),
      category: BudgetCategory.food,
      method: PaymentMethod.upi,
      source: TransactionSource.manual,
    );
    expect(outcome.batch!.held.isPositive, isTrue);
    final heldBefore = container.read(budgetProvider).requireValue.snapshot!.held;
    clock.now = ist(2026, 3, 13, 9);
    await controller.refresh();
    final state = container.read(budgetProvider).requireValue;
    expect(Money.sum(state.snapshot!.held.values) < Money.sum(heldBefore.values), isTrue);
    expect(state.ledger!.batches.where((batch) => batch.kind.name == 'release'), hasLength(1));
  });

  test('a corrected category is learned for next time', () async {
    final container = await start();
    final controller = container.read(budgetProvider.notifier);
    await controller.log(
      amount: Money.rupees(60),
      category: BudgetCategory.outings,
      method: PaymentMethod.upi,
      source: TransactionSource.typed,
      note: 'chai',
      learnKeyword: 'chai',
    );
    expect(container.read(budgetProvider).requireValue.ledger!.learnedKeywords['chai'], BudgetCategory.outings);
  });
}
