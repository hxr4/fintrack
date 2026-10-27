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

var _holdCounter = 0;

final class PersistedEvent {
  const PersistedEvent(this.adjustments, this.holds);

  final List<Adjustment> adjustments;
  final List<Hold> holds;
}

PersistedEvent persistEvent({
  required String batchId,
  required DateTime at,
  List<AdjustmentDraft> moves = const [],
  List<HoldDraft> newHolds = const [],
  List<HoldRelease> releases = const [],
}) {
  Hold hold(HoldDraft draft, String commitmentId) => Hold.fromDraft(
        id: 'h${_holdCounter++}',
        batchId: batchId,
        commitmentId: commitmentId,
        createdAt: at,
        draft: draft,
      );
  return PersistedEvent(
    persist([...moves, for (final release in releases) ...release.moves], batchId, at),
    [
      for (final draft in newHolds) hold(draft, batchId),
      for (final release in releases)
        for (final draft in release.holds) hold(draft, release.commitmentId),
    ],
  );
}

PersistedEvent persistResult(AutoAdjustResult result, String batchId, DateTime at) => persistEvent(
      batchId: batchId,
      at: at,
      moves: result.moves,
      newHolds: result.newHolds,
      releases: result.releases,
    );
