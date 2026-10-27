import 'package:budget_engine/budget_engine.dart';
import 'package:drift/drift.dart';

import '../domain/cycle_planning.dart';
import '../domain/ledger_data.dart';
import '../domain/preferences.dart';
import 'codecs.dart';
import 'database.dart';
import 'ids.dart';

final class BudgetRepository {
  BudgetRepository(this.db, {IdGenerator? ids}) : ids = ids ?? IdGenerator();

  final AppDatabase db;
  final IdGenerator ids;

  Future<Map<String, String>> _settingsMap() async {
    final rows = await db.select(db.settings).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> _putSettings(Map<String, String> values) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.settings, [
        for (final entry in values.entries) SettingsCompanion.insert(key: entry.key, value: entry.value),
      ]);
    });
  }

  Future<AppPreferences> loadPreferences() async => AppPreferences.fromMap(await _settingsMap());

  Future<void> savePreferences(AppPreferences preferences) => _putSettings(preferences.toMap());

  Future<BudgetSettings?> loadBudgetSettings() async {
    final map = await _settingsMap();
    if (!map.containsKey(SettingKeys.foodFloor)) {
      return null;
    }
    return BudgetSettings(
      foodFloorPerDay: Money(int.parse(map[SettingKeys.foodFloor]!)),
      petrolFloorPerCycle: Money(int.parse(map[SettingKeys.petrolFloor]!)),
      nightFoodStockTarget: Money(int.parse(map[SettingKeys.nightFoodStock]!)),
      anchorDay: int.parse(map[SettingKeys.anchorDay]!),
      dayBoundaryHour: int.parse(map[SettingKeys.dayBoundaryHour] ?? '4'),
      defaultWeights: Codecs.parseWeights(map[SettingKeys.weights]!),
    );
  }

  Future<void> _saveBudgetSettings(BudgetSettings settings, Money excluded) => _putSettings({
        SettingKeys.foodFloor: '${settings.foodFloorPerDay.paise}',
        SettingKeys.petrolFloor: '${settings.petrolFloorPerCycle.paise}',
        SettingKeys.nightFoodStock: '${settings.nightFoodStockTarget.paise}',
        SettingKeys.anchorDay: '${settings.anchorDay}',
        SettingKeys.dayBoundaryHour: '${settings.dayBoundaryHour}',
        SettingKeys.weights: Codecs.weights(settings.defaultWeights),
        SettingKeys.excluded: '${excluded.paise}',
      });

  Future<int> _insertCycle(CyclePlan plan, Map<BudgetCategory, Money> opening, Deposit deposit) async {
    final cycleId = await db.into(db.cycles).insert(CyclesCompanion.insert(
          startDate: plan.window.start.toString(),
          expectedNextStart: plan.window.nextStart.toString(),
          weights: Codecs.weights(plan.weights),
          installmentsPaise: plan.installments.paise,
          carryInPaise: plan.carryInToPool.paise,
          baselinePaise: plan.baseline.paise,
          deltaPaise: plan.delta.paise,
          foodFloorPaise: plan.foodFloor.paise,
          petrolFloorPaise: plan.petrolFloor.paise,
          shortfallPaise: plan.shortfall.paise,
          baseDailyPaise: plan.baseDaily.paise,
        ));
    await db.batch((batch) {
      batch.insertAll(db.allocations, [
        for (final entry in opening.entries)
          if (!entry.value.isZero)
            AllocationsCompanion.insert(
              cycleId: cycleId,
              category: entry.key.name,
              amountPaise: entry.value.paise,
              kind: 'opening',
            ),
        for (final entry in plan.allocations.entries)
          if (!entry.value.isZero)
            AllocationsCompanion.insert(
              cycleId: cycleId,
              category: entry.key.name,
              amountPaise: entry.value.paise,
              kind: 'plan',
            ),
      ]);
      batch.insert(
        db.deposits,
        DepositsCompanion.insert(
          id: deposit.id,
          cycleId: cycleId,
          amountPaise: deposit.amount.paise,
          receivedAt: Codecs.instant(deposit.receivedAt),
          kind: deposit.kind.name,
        ),
      );
    });
    return cycleId;
  }

  Future<void> completeOnboarding({
    required OnboardingInput input,
    required DateTime now,
    required AppPreferences preferences,
  }) async {
    final settings = input.toSettings();
    final supplies = [
      for (final draft in input.supplies)
        NamedSupply(
          name: draft.name,
          state: SupplyItemState(
            id: ids.next('supply'),
            price: draft.price,
            lifespanDays: draft.lifespanDays,
            lastRestock: draft.lastRestock,
          ),
        ),
    ];
    final recurring = [
      for (final draft in input.recurring)
        NamedRecurringCost(
          name: draft.name,
          state: RecurringCostState(id: ids.next('recurring'), amount: draft.amount, everyMonths: draft.everyMonths),
        ),
    ];
    final deposit = Deposit(
      id: ids.next('deposit'),
      amount: input.deposit,
      receivedAt: KolkataTime.at(input.depositDate, 12),
      kind: DepositKind.installment,
    );
    final planned = CyclePlanning.plan(
      deposit: deposit,
      start: input.depositDate,
      settings: settings,
      supplies: [for (final supply in supplies) supply.state],
      recurring: [for (final cost in recurring) cost.state],
      history: CycleHistory.empty,
    );
    await db.transaction(() async {
      await _saveBudgetSettings(settings, input.excluded);
      await db.batch((batch) {
        batch.insertAll(db.supplyItems, [
          for (final supply in supplies)
            SupplyItemsCompanion.insert(
              id: supply.state.id,
              name: supply.name,
              pricePaise: supply.state.price.paise,
              lifespanDays: supply.state.lifespanDays,
              lastRestock: supply.state.lastRestock.toString(),
            ),
        ]);
        batch.insertAll(db.recurringCosts, [
          for (final cost in recurring)
            RecurringCostsCompanion.insert(
              id: cost.state.id,
              name: cost.name,
              amountPaise: cost.state.amount.paise,
              everyMonths: cost.state.everyMonths,
            ),
        ]);
        batch.insert(
          db.balanceAnchors,
          BalanceAnchorsCompanion.insert(
            at: Codecs.instant(now),
            bankPaise: input.bank.paise,
            cashPaise: input.cash.paise,
            excludedPaise: input.excluded.paise,
          ),
        );
      });
      await _insertCycle(planned.plan, const {}, deposit);
      await savePreferences(preferences.copyWith(onboarded: true, cardEnabled: input.cardEnabled));
    });
  }

  Future<CycleRow?> _openCycle() => (db.select(db.cycles)
        ..where((table) => table.closedOn.isNull())
        ..orderBy([(table) => OrderingTerm.desc(table.id)])
        ..limit(1))
      .getSingleOrNull();

  Future<LedgerData?> loadLedger() async {
    final cycle = await _openCycle();
    if (cycle == null) {
      return null;
    }
    final id = cycle.id;
    final allocationRows = await (db.select(db.allocations)..where((table) => table.cycleId.equals(id))).get();
    Map<BudgetCategory, Money> sumOf(String kind) {
      final result = <BudgetCategory, Money>{};
      for (final row in allocationRows.where((row) => row.kind == kind)) {
        final category = Codecs.category(row.category);
        result[category] = (result[category] ?? Money.zero) + Money(row.amountPaise);
      }
      return result;
    }

    final depositRows = await (db.select(db.deposits)..where((table) => table.cycleId.equals(id))).get();
    final transactionRows = await (db.select(db.transactions)
          ..where((table) => table.cycleId.equals(id))
          ..orderBy([(table) => OrderingTerm.asc(table.occurredAt)]))
        .get();
    final adjustmentRows = await (db.select(db.adjustments)..where((table) => table.cycleId.equals(id))).get();
    final holdRows = await (db.select(db.holds)..where((table) => table.cycleId.equals(id))).get();
    final batchRows = await (db.select(db.batches)..where((table) => table.cycleId.equals(id))).get();
    final supplyRows = await db.select(db.supplyItems).get();
    final recurringRows = await db.select(db.recurringCosts).get();
    final keywordRows = await db.select(db.keywordMappings).get();

    return LedgerData(
      cycle: CycleRecord(
        id: id,
        window: CycleWindow(
          start: CivilDate.parse(cycle.startDate),
          nextStart: CivilDate.parse(cycle.expectedNextStart),
        ),
        weights: Codecs.parseWeights(cycle.weights),
        installments: Money(cycle.installmentsPaise),
        carryIn: Money(cycle.carryInPaise),
        baseline: Money(cycle.baselinePaise),
        delta: Money(cycle.deltaPaise),
        foodFloor: Money(cycle.foodFloorPaise),
        petrolFloor: Money(cycle.petrolFloorPaise),
        shortfall: Money(cycle.shortfallPaise),
        baseDaily: Money(cycle.baseDailyPaise),
      ),
      opening: sumOf('opening'),
      planAllocations: sumOf('plan'),
      extraAllocations: sumOf('extra'),
      deposits: [
        for (final row in depositRows)
          Deposit(
            id: row.id,
            amount: Money(row.amountPaise),
            receivedAt: Codecs.parseInstant(row.receivedAt),
            kind: DepositKind.values.byName(row.kind),
          ),
      ],
      transactions: [for (final row in transactionRows) _transaction(row)],
      adjustments: [
        for (final row in adjustmentRows)
          Adjustment.fromDraft(
            id: row.id,
            batchId: row.batchId,
            createdAt: Codecs.parseInstant(row.createdAt),
            undone: row.undone,
            draft: AdjustmentDraft(
              from: Codecs.category(row.fromCategory),
              to: Codecs.category(row.toCategory),
              amount: Money(row.amountPaise),
              reason: AdjustmentReason.values.byName(row.reason),
              auto: row.auto,
            ),
          ),
      ],
      holds: [
        for (final row in holdRows)
          Hold.fromDraft(
            id: row.id,
            batchId: row.batchId,
            commitmentId: row.commitmentId,
            createdAt: Codecs.parseInstant(row.createdAt),
            undone: row.undone,
            draft: HoldDraft(category: Codecs.category(row.category), amount: Money(row.amountPaise)),
          ),
      ],
      batches: [
        for (final row in batchRows)
          BatchRecord(
            id: row.id,
            kind: BatchKind.values.byName(row.kind),
            createdAt: Codecs.parseInstant(row.createdAt),
            moved: Money(row.movedPaise),
            held: Money(row.heldPaise),
            shortfall: Money(row.shortfallPaise),
            targets: [
              for (final name in row.targets.split(',').where((name) => name.isNotEmpty)) Codecs.category(name),
            ],
            suggestReplan: row.suggestReplan,
            seen: row.seen,
            undone: row.undone,
          ),
      ],
      supplies: [
        for (final row in supplyRows)
          NamedSupply(
            name: row.name,
            state: SupplyItemState(
              id: row.id,
              price: Money(row.pricePaise),
              lifespanDays: row.lifespanDays,
              lastRestock: CivilDate.parse(row.lastRestock),
            ),
          ),
      ],
      recurring: [
        for (final row in recurringRows)
          NamedRecurringCost(
            name: row.name,
            state: RecurringCostState(id: row.id, amount: Money(row.amountPaise), everyMonths: row.everyMonths),
          ),
      ],
      learnedKeywords: {for (final row in keywordRows) row.keyword: Codecs.category(row.category)},
    );
  }

  Transaction _transaction(TransactionRow row) => Transaction.fromDraft(
        row.id,
        TransactionDraft(
          amount: Money(row.amountPaise),
          category: Codecs.category(row.category),
          method: PaymentMethod.values.byName(row.method),
          occurredAt: Codecs.parseInstant(row.occurredAt),
          source: TransactionSource.values.byName(row.source),
          note: row.note,
        ),
      );

  Future<Transaction> insertTransaction(int cycleId, TransactionDraft draft) async {
    final transaction = Transaction.fromDraft(ids.next('txn'), draft);
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
          id: transaction.id,
          cycleId: cycleId,
          amountPaise: draft.amount.paise,
          category: draft.category.name,
          method: draft.method.name,
          occurredAt: Codecs.instant(draft.occurredAt),
          note: draft.note,
          source: draft.source.name,
        ));
    return transaction;
  }

  Future<void> restoreTransaction(int cycleId, Transaction transaction) =>
      db.into(db.transactions).insert(TransactionsCompanion.insert(
            id: transaction.id,
            cycleId: cycleId,
            amountPaise: transaction.amount.paise,
            category: transaction.category.name,
            method: transaction.method.name,
            occurredAt: Codecs.instant(transaction.occurredAt),
            note: transaction.note,
            source: transaction.source.name,
          ));

  Future<void> deleteTransaction(String id) =>
      (db.delete(db.transactions)..where((table) => table.id.equals(id))).go();

  Future<void> insertBatch({
    required int cycleId,
    required BatchRecord batch,
    required List<Adjustment> adjustments,
    required List<Hold> holds,
  }) async {
    await db.batch((writer) {
      writer.insert(
        db.batches,
        BatchesCompanion.insert(
          id: batch.id,
          cycleId: cycleId,
          kind: batch.kind.name,
          createdAt: Codecs.instant(batch.createdAt),
          movedPaise: batch.moved.paise,
          heldPaise: batch.held.paise,
          shortfallPaise: batch.shortfall.paise,
          targets: batch.targets.map((category) => category.name).join(','),
          suggestReplan: batch.suggestReplan,
          seen: Value(batch.seen),
        ),
      );
      writer.insertAll(db.adjustments, [
        for (final adjustment in adjustments)
          AdjustmentsCompanion.insert(
            id: adjustment.id,
            cycleId: cycleId,
            batchId: adjustment.batchId,
            fromCategory: adjustment.from.name,
            toCategory: adjustment.to.name,
            amountPaise: adjustment.amount.paise,
            reason: adjustment.reason.name,
            createdAt: Codecs.instant(adjustment.createdAt),
            auto: adjustment.auto,
          ),
      ]);
      writer.insertAll(db.holds, [
        for (final hold in holds)
          HoldsCompanion.insert(
            id: hold.id,
            cycleId: cycleId,
            batchId: hold.batchId,
            commitmentId: hold.commitmentId,
            category: hold.category.name,
            amountPaise: hold.amount.paise,
            createdAt: Codecs.instant(hold.createdAt),
          ),
      ]);
    });
  }

  Future<void> markBatchSeen(String batchId) =>
      (db.update(db.batches)..where((table) => table.id.equals(batchId))).write(const BatchesCompanion(seen: Value(true)));

  Future<void> markBatchesUndone(Set<String> batchIds) async {
    await db.transaction(() async {
      await (db.update(db.batches)..where((table) => table.id.isIn(batchIds)))
          .write(const BatchesCompanion(undone: Value(true), seen: Value(true)));
      await (db.update(db.adjustments)..where((table) => table.batchId.isIn(batchIds)))
          .write(const AdjustmentsCompanion(undone: Value(true)));
      await (db.update(db.holds)..where((table) => table.batchId.isIn(batchIds)))
          .write(const HoldsCompanion(undone: Value(true)));
    });
  }

  Future<void> learnKeyword(String keyword, BudgetCategory category) =>
      db.into(db.keywordMappings).insertOnConflictUpdate(
            KeywordMappingsCompanion.insert(keyword: keyword, category: category.name),
          );

  Future<void> addExtraIncome({required int cycleId, required Deposit deposit, required Map<BudgetCategory, Money> split, required Money newBaseDaily}) async {
    await db.transaction(() async {
      await db.into(db.deposits).insert(DepositsCompanion.insert(
            id: deposit.id,
            cycleId: cycleId,
            amountPaise: deposit.amount.paise,
            receivedAt: Codecs.instant(deposit.receivedAt),
            kind: deposit.kind.name,
          ));
      await db.batch((batch) {
        batch.insertAll(db.allocations, [
          for (final entry in split.entries)
            if (!entry.value.isZero)
              AllocationsCompanion.insert(
                cycleId: cycleId,
                category: entry.key.name,
                amountPaise: entry.value.paise,
                kind: 'extra',
              ),
        ]);
      });
      await (db.update(db.cycles)..where((table) => table.id.equals(cycleId)))
          .write(CyclesCompanion(baseDailyPaise: Value(newBaseDaily.paise)));
    });
  }

  Future<CycleHistory> loadHistory({required int includingCycleId}) async {
    final cycles = await (db.select(db.cycles)
          ..where((table) => table.id.isSmallerOrEqualValue(includingCycleId))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final spends = <Map<BudgetCategory, Money>>[];
    for (final cycle in cycles) {
      final rows = await (db.select(db.transactions)..where((table) => table.cycleId.equals(cycle.id))).get();
      spends.add(CyclePlanning.blendedSpend(rows.map(_transaction)));
    }
    return CycleHistory(
      installmentTotals: [for (final cycle in cycles) Money(cycle.installmentsPaise)],
      spends: spends,
      lastWeights: cycles.isEmpty ? null : Codecs.parseWeights(cycles.last.weights),
    );
  }

  Future<void> startNextCycle({
    required int closingCycleId,
    required CivilDate closedOn,
    required NewCyclePlan next,
  }) async {
    await db.transaction(() async {
      await (db.update(db.cycles)..where((table) => table.id.equals(closingCycleId)))
          .write(CyclesCompanion(closedOn: Value(closedOn.toString())));
      await _insertCycle(next.plan, next.opening, next.deposit);
    });
  }
}
