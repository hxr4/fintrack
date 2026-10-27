import 'package:budget_engine/budget_engine.dart';

BudgetSettings standardSettings() => BudgetSettings(
      foodFloorPerDay: Money.rupees(150),
      petrolFloorPerCycle: Money.rupees(1200),
      nightFoodStockTarget: Money.rupees(750),
      anchorDay: 5,
      dayBoundaryHour: 4,
      defaultWeights: CategoryWeights.fromPercent({
        BudgetCategory.food: 60,
        BudgetCategory.petrol: 14,
        BudgetCategory.outings: 9,
        BudgetCategory.trySomethingNew: 4,
        BudgetCategory.misc: 3,
        BudgetCategory.buffer: 10,
      }),
    );

const policy = BudgetPolicy();

CivilDate d(String iso) => CivilDate.parse(iso);

CycleWindow windowFrom(String start, {int anchorDay = 5}) =>
    CycleCalendar.windowStartingOn(d(start), anchorDay: anchorDay, policy: policy);

Deposit installment(int rupees, String date, {String id = 'dep'}) => Deposit(
      id: id,
      amount: Money.rupees(rupees),
      receivedAt: KolkataTime.at(d(date), 10),
      kind: DepositKind.installment,
    );

Deposit extra(int rupees, String date, {String id = 'extra'}) => Deposit(
      id: id,
      amount: Money.rupees(rupees),
      receivedAt: KolkataTime.at(d(date), 10),
      kind: DepositKind.extra,
    );

var _transactionCounter = 0;

Transaction spend(
  int rupees,
  BudgetCategory category,
  DateTime at, {
  PaymentMethod method = PaymentMethod.upi,
}) =>
    Transaction(
      id: 't${_transactionCounter++}',
      amount: Money.rupees(rupees),
      category: category,
      method: method,
      occurredAt: at,
      source: TransactionSource.manual,
    );

var _adjustmentCounter = 0;

List<Adjustment> persist(List<AdjustmentDraft> drafts, String batchId, DateTime at) => [
      for (final draft in drafts)
        Adjustment.fromDraft(
          id: 'a${_adjustmentCounter++}',
          batchId: batchId,
          createdAt: at,
          draft: draft,
        ),
    ];
