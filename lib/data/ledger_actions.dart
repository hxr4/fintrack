import 'package:budget_engine/budget_engine.dart';

import '../domain/budget_snapshot.dart';
import '../domain/cycle_planning.dart';
import '../domain/ledger_data.dart';
import 'budget_repository.dart';

final class LogOutcome {
  const LogOutcome({required this.ledger, required this.transaction, required this.batch});

  final LedgerData ledger;
  final Transaction transaction;
  final BatchRecord? batch;
}

final class DeletedEntry {
  const DeletedEntry({required this.transaction, required this.fuelFill});

  final Transaction transaction;
  final LinkedFuelFill? fuelFill;
}

final class BalanceCheckOutcome {
  const BalanceCheckOutcome({required this.ledger, required this.comparison, required this.uncovered, required this.refill});

  final LedgerData ledger;
  final BalanceComparison comparison;
  final Money uncovered;
  final BatchRecord? refill;
}

final class LedgerActions {
  LedgerActions(this.repository);

  final BudgetRepository repository;

  BudgetSnapshot _snapshot(LedgerData ledger, BudgetSettings settings, DateTime now) =>
      BudgetSnapshot.compute(ledger: ledger, settings: settings, now: now);

  Future<LogOutcome> log(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required Money amount,
    required BudgetCategory category,
    required PaymentMethod method,
    required TransactionSource source,
    String note = '',
    String? learnKeyword,
    DateTime? occurredAt,
  }) async {
    final transaction = await repository.insertTransaction(
      ledger.cycle.id,
      TransactionDraft(
        amount: amount,
        category: category,
        method: method,
        occurredAt: occurredAt ?? now,
        source: source,
        note: note,
      ),
    );
    var updated = ledger.copyWith(transactions: [...ledger.transactions, transaction]);
    if (learnKeyword != null && learnKeyword.isNotEmpty) {
      await repository.learnKeyword(learnKeyword, category);
      updated = updated.copyWith(learnedKeywords: {...updated.learnedKeywords, learnKeyword: category});
    }
    final adjusted = await runAutoAdjust(updated, settings, now);
    return LogOutcome(ledger: adjusted.$1, transaction: transaction, batch: adjusted.$2);
  }

  Future<(LedgerData, BatchRecord?)> runAutoAdjust(LedgerData ledger, BudgetSettings settings, DateTime now) async {
    final snapshot = _snapshot(ledger, settings, now);
    final result = AutoAdjuster.run(
      balances: ledger.balances,
      foodFloorPerDay: settings.foodFloorPerDay,
      petrolFloorForCycle: ledger.cycle.petrolFloor,
      cycleLength: ledger.cycle.window.length,
      daysLeft: snapshot.daysLeft,
      dayOfCycle: snapshot.dayNumber,
      holds: ledger.holds,
      essentialsReservedForDue: snapshot.essentialsReservedForDue,
    );
    if (!result.moved) {
      return (ledger, null);
    }
    final targets = {for (final move in result.allMoves) move.to}.toList()..sort((a, b) => a.index.compareTo(b.index));
    return persistEvent(
      ledger,
      kind: BatchKind.refill,
      at: now,
      moves: result.moves,
      newHolds: result.newHolds,
      releases: result.releases,
      moved: result.totalMoved,
      held: result.totalHeld,
      shortfall: result.holdShortfall + Money.sum(result.uncovered.values),
      targets: targets,
      suggestReplan: result.suggestReplan,
      seen: false,
    );
  }

  Future<(LedgerData, DeletedEntry)> deleteTransaction(LedgerData ledger, Transaction transaction) async {
    final linked = ledger.fuelFills.where((fill) => fill.transactionId == transaction.id).firstOrNull;
    await repository.deleteTransaction(transaction.id);
    return (
      ledger.copyWith(
        transactions: ledger.transactions.where((item) => item.id != transaction.id).toList(),
        fuelFills: ledger.fuelFills.where((fill) => fill.transactionId != transaction.id).toList(),
      ),
      DeletedEntry(transaction: transaction, fuelFill: linked),
    );
  }

  Future<LedgerData> restore(LedgerData ledger, DeletedEntry entry) async {
    await repository.restoreTransaction(ledger.cycle.id, entry.transaction);
    final fill = entry.fuelFill;
    if (fill != null) {
      await repository.insertFuelFill(ledger.cycle.id, fill);
    }
    final transactions = [...ledger.transactions, entry.transaction]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return ledger.copyWith(
      transactions: transactions,
      fuelFills: fill == null ? null : [...ledger.fuelFills, fill],
    );
  }

  Future<LedgerData> markSummarySeen(LedgerData ledger, String batchId) async {
    await repository.markBatchSeen(batchId);
    return ledger.copyWith(batches: [
      for (final batch in ledger.batches) batch.id == batchId ? batch.copyWith(seen: true) : batch,
    ]);
  }

  Future<LedgerData> undoBatch(LedgerData ledger, String batchId) async {
    final result = BatchUndo.undo(adjustments: ledger.adjustments, holds: ledger.holds, batchId: batchId);
    await repository.markBatchesUndone(result.undoneBatches);
    return ledger.copyWith(
      adjustments: result.adjustments,
      holds: result.holds,
      batches: [
        for (final batch in ledger.batches)
          result.undoneBatches.contains(batch.id) ? batch.copyWith(undone: true, seen: true) : batch,
      ],
    );
  }

  Future<LedgerData> moveBanked(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required Money amount,
    required BudgetCategory to,
  }) async {
    final snapshot = _snapshot(ledger, settings, now);
    final moves = BankedMover.move(
      amount: amount,
      to: to,
      banked: snapshot.allowance.banked,
      balances: ledger.balances,
      foodFloorPerDay: settings.foodFloorPerDay,
      daysLeft: snapshot.daysLeft,
      held: ledger.held,
    );
    final persisted = await persistEvent(
      ledger,
      kind: BatchKind.release,
      at: now,
      moves: moves,
      newHolds: const [],
      releases: const [],
      moved: amount,
      held: Money.zero,
      shortfall: Money.zero,
      targets: [to],
      suggestReplan: false,
      seen: true,
    );
    return persisted.$1;
  }

  Future<LedgerData> releaseWeeklyHolds(LedgerData ledger, BudgetSettings settings, DateTime now) async {
    final today = KolkataTime.allowanceDateOf(now, boundaryHour: settings.dayBoundaryHour);
    final releases = WeeklyHoldRelease.due(
      holds: ledger.holds,
      balances: ledger.balances,
      today: today,
      boundaryHour: settings.dayBoundaryHour,
      foodFloorPerDay: settings.foodFloorPerDay,
    );
    if (releases.isEmpty) {
      return ledger;
    }
    final persisted = await persistEvent(
      ledger,
      kind: BatchKind.release,
      at: now,
      moves: const [],
      newHolds: const [],
      releases: releases,
      moved: Money.sum(releases.map((release) => release.moved)),
      held: Money.zero,
      shortfall: Money.zero,
      targets: const [BudgetCategory.food],
      suggestReplan: false,
      seen: true,
    );
    return persisted.$1;
  }

  Money bikeFundIncrementFor(LedgerData ledger, CycleWindow window, Money fundBalance, CivilDate today) {
    if (!ledger.bike.service.cost.isPositive) {
      return Money.zero;
    }
    return BikeSchedule.fundIncrement(
      serviceCost: ledger.bike.service.cost,
      fundBalance: fundBalance,
      daysUntilDue: ledger.serviceDue(today).daysLeft,
      cycleLength: window.length,
    );
  }

  Future<LedgerData> logDeposit(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required Money amount,
    required CivilDate date,
    required DepositKind kind,
  }) async {
    final deposit = Deposit(
      id: repository.ids.next('deposit'),
      amount: amount,
      receivedAt: receivedInstant(date, now),
      kind: kind,
    );
    if (kind == DepositKind.extra) {
      final split = ExtraIncome.split(deposit, CyclePlanning.policy);
      final extras = {
        for (final category in BudgetCategory.values)
          category: (ledger.extraAllocations[category] ?? Money.zero) + (split[category] ?? Money.zero),
      };
      final withExtra = ledger.copyWith(extraAllocations: extras);
      final snapshot = _snapshot(withExtra, settings, now);
      final baseDaily = snapshot.pool.positivePart.floorDiv(snapshot.daysLeft);
      await repository.addExtraIncome(
        cycleId: ledger.cycle.id,
        deposit: deposit,
        split: split,
        newBaseDaily: baseDaily,
      );
      return withExtra.copyWith(
        deposits: [...ledger.deposits, deposit],
        cycle: ledger.cycle.withBaseDaily(baseDaily),
      );
    }
    final carry = CyclePlanning.close(ledger: ledger, settings: settings);
    final history = await repository.loadHistory(includingCycleId: ledger.cycle.id);
    final window = CycleCalendar.windowStartingOn(date, anchorDay: settings.anchorDay, policy: CyclePlanning.policy);
    final next = CyclePlanning.plan(
      deposit: deposit,
      start: date,
      settings: settings,
      supplies: [for (final supply in ledger.supplies) supply.state],
      recurring: [for (final cost in ledger.recurring) cost.state],
      history: history,
      opening: carry.openingBalances,
      carryInToPool: carry.carryInToPool,
      bikeFundIncrement: bikeFundIncrementFor(
        ledger,
        window,
        carry.openingBalances[BudgetCategory.bikeFund] ?? Money.zero,
        date,
      ),
    );
    await repository.startNextCycle(
      closingCycleId: ledger.cycle.id,
      closedOn: date,
      next: next,
      supplies: ledger.supplies,
    );
    return (await repository.loadLedger())!;
  }

  Future<LedgerData> _coverFund(LedgerData ledger, BudgetCategory fund, DateTime now) async {
    final balance = ledger.balances[fund]!;
    if (!balance.isNegative) {
      return ledger;
    }
    final working = Holds.spendable(ledger.balances, ledger.held);
    final drawdown = Donors.draw(
      balances: working,
      needed: -balance,
      order: const [DonorLimit(BudgetCategory.buffer)],
    );
    if (drawdown.draws.isEmpty) {
      return ledger;
    }
    final persisted = await persistEvent(
      ledger,
      kind: BatchKind.fundCover,
      at: now,
      moves: drawdown.toAdjustments(to: fund, reason: AdjustmentReason.fundCover, auto: true),
      newHolds: const [],
      releases: const [],
      moved: drawdown.taken,
      held: Money.zero,
      shortfall: drawdown.remaining,
      targets: [fund],
      suggestReplan: false,
      seen: true,
    );
    return persisted.$1;
  }

  Future<LedgerData> restock(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required String supplyId,
    required Money paid,
    required PaymentMethod method,
  }) async {
    final supply = ledger.supplies.firstWhere((item) => item.state.id == supplyId);
    final today = KolkataTime.dateOf(now);
    final outcome = await log(
      ledger,
      settings,
      now,
      amount: paid,
      category: BudgetCategory.essentialsStock,
      method: method,
      source: TransactionSource.manual,
      note: supply.name,
    );
    final updatedSupply = supply.withState(ReserveCalculator.restock(supply.state, on: today, paid: paid));
    await repository.upsertSupply(updatedSupply);
    final withSupply = outcome.ledger.copyWith(supplies: [
      for (final item in outcome.ledger.supplies) item.state.id == supplyId ? updatedSupply : item,
    ]);
    return _coverFund(withSupply, BudgetCategory.essentialsStock, now);
  }

  Future<LogOutcome> logFuel(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required Money amount,
    required Money pricePerLitre,
    required int odometerKm,
    required bool fullTank,
    required PaymentMethod method,
  }) async {
    final outcome = await log(
      ledger,
      settings,
      now,
      amount: amount,
      category: BudgetCategory.petrol,
      method: method,
      source: TransactionSource.manual,
      note: '$odometerKm km',
    );
    final linked = LinkedFuelFill(
      transactionId: outcome.transaction.id,
      fill: FuelFill(
        id: repository.ids.next('fuel'),
        date: KolkataTime.dateOf(now),
        amount: amount,
        pricePerLitre: pricePerLitre,
        odometerKm: odometerKm,
        fullTank: fullTank,
      ),
    );
    await repository.insertFuelFill(ledger.cycle.id, linked);
    return LogOutcome(
      ledger: outcome.ledger.copyWith(fuelFills: [...outcome.ledger.fuelFills, linked]),
      transaction: outcome.transaction,
      batch: outcome.batch,
    );
  }

  Future<LedgerData> saveBike(LedgerData ledger, BikeProfile bike) async {
    await repository.saveBike(bike);
    return ledger.copyWith(bike: bike);
  }

  Future<LedgerData> payService(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required Money amount,
    required int odometerKm,
    required PaymentMethod method,
  }) async {
    final outcome = await log(
      ledger,
      settings,
      now,
      amount: amount,
      category: BudgetCategory.bikeFund,
      method: method,
      source: TransactionSource.manual,
      note: '$odometerKm km',
    );
    final service = ledger.bike.service;
    final bike = ledger.bike.withService(BikeServicePlan(
      intervalKm: service.intervalKm,
      intervalMonths: service.intervalMonths,
      cost: service.cost,
      lastServiceDate: KolkataTime.dateOf(now),
      lastServiceKm: odometerKm,
    ));
    final withBike = await saveBike(outcome.ledger, bike);
    return _coverFund(withBike, BudgetCategory.bikeFund, now);
  }

  Future<LedgerData> payRecurring(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required String costId,
    required Money amount,
    required PaymentMethod method,
  }) async {
    final cost = ledger.recurring.firstWhere((item) => item.state.id == costId);
    final outcome = await log(
      ledger,
      settings,
      now,
      amount: amount,
      category: BudgetCategory.recurringFund,
      method: method,
      source: TransactionSource.manual,
      note: cost.name,
    );
    return _coverFund(outcome.ledger, BudgetCategory.recurringFund, now);
  }

  Future<LedgerData> upsertSupply(LedgerData ledger, NamedSupply supply) async {
    await repository.upsertSupply(supply);
    final exists = ledger.supplies.any((item) => item.state.id == supply.state.id);
    return ledger.copyWith(supplies: [
      if (exists)
        for (final item in ledger.supplies) item.state.id == supply.state.id ? supply : item
      else ...[...ledger.supplies, supply],
    ]);
  }

  Future<LedgerData> deleteSupply(LedgerData ledger, String id) async {
    await repository.deleteSupply(id);
    return ledger.copyWith(supplies: ledger.supplies.where((item) => item.state.id != id).toList());
  }

  Future<LedgerData> upsertRecurring(LedgerData ledger, NamedRecurringCost cost) async {
    await repository.upsertRecurring(cost);
    final exists = ledger.recurring.any((item) => item.state.id == cost.state.id);
    return ledger.copyWith(recurring: [
      if (exists)
        for (final item in ledger.recurring) item.state.id == cost.state.id ? cost : item
      else ...[...ledger.recurring, cost],
    ]);
  }

  Future<LedgerData> deleteRecurring(LedgerData ledger, String id) async {
    await repository.deleteRecurring(id);
    return ledger.copyWith(recurring: ledger.recurring.where((item) => item.state.id != id).toList());
  }

  Future<BalanceComparison?> compareBalance(LedgerData ledger, ReportedBalance reported) async {
    final anchor = ledger.latestAnchor;
    if (anchor == null) {
      return null;
    }
    final (deposits, transactions) = await repository.activitySince(anchor.at);
    return BalanceCheck.compare(
      anchor: anchor.anchor,
      deposits: deposits,
      transactions: transactions,
      reported: reported,
    );
  }

  Future<BalanceCheckOutcome> applyBalanceCheck(
    LedgerData ledger,
    BudgetSettings settings,
    DateTime now, {
    required ReportedBalance reported,
    required BalanceResolution resolution,
  }) async {
    final comparison = await compareBalance(ledger, reported);
    final record = AnchorRecord(at: reported.at, bank: reported.bank, cash: reported.cash, excluded: reported.excluded);
    if (comparison == null) {
      await repository.insertAnchor(record);
      return BalanceCheckOutcome(
        ledger: ledger.copyWith(latestAnchor: record),
        comparison: BalanceComparison(reported: reported, expected: reported.budgetTotal, actual: reported.budgetTotal),
        uncovered: Money.zero,
        refill: null,
      );
    }
    final snapshot = _snapshot(ledger, settings, now);
    final spend = {
      for (final category in BudgetCategory.values)
        category: Money.sum(ledger.transactions
            .where((transaction) => transaction.category == category && !transaction.isCorrection)
            .map((transaction) => transaction.amount)),
    };
    final correction = BalanceCheck.resolve(
      comparison: comparison,
      resolution: resolution,
      balances: ledger.balances,
      cycleSpendByCategory: spend,
      cycleAllocations: ledger.allocations,
      foodFloorPerDay: settings.foodFloorPerDay,
      petrolFloorRemaining: ledger.cycle.petrolFloor.times(snapshot.daysLeft).ceilDiv(ledger.cycle.window.length),
      daysLeft: snapshot.daysLeft,
      essentialsReservedForDue: snapshot.essentialsReservedForDue,
      held: ledger.held,
    );
    if (correction.newAnchor == null) {
      return BalanceCheckOutcome(ledger: ledger, comparison: comparison, uncovered: Money.zero, refill: null);
    }
    var updated = ledger;
    for (final draft in correction.transactions) {
      final transaction = await repository.insertTransaction(ledger.cycle.id, draft);
      updated = updated.copyWith(transactions: [...updated.transactions, transaction]);
    }
    if (correction.adjustments.isNotEmpty) {
      final persisted = await persistEvent(
        updated,
        kind: BatchKind.correction,
        at: now,
        moves: correction.adjustments,
        newHolds: const [],
        releases: const [],
        moved: Money.sum(correction.adjustments.map((move) => move.amount)),
        held: Money.zero,
        shortfall: correction.uncovered,
        targets: const [BudgetCategory.unlogged],
        suggestReplan: false,
        seen: true,
      );
      updated = persisted.$1;
    }
    await repository.insertAnchor(record);
    updated = updated.copyWith(latestAnchor: record);
    final adjusted = await runAutoAdjust(updated, settings, now);
    updated = adjusted.$1;
    final replanned = _snapshot(updated, settings, now);
    final baseDaily = replanned.pool.positivePart.floorDiv(replanned.daysLeft);
    final cycle = updated.cycle.withBaseDaily(baseDaily);
    await repository.updateCycle(cycle);
    return BalanceCheckOutcome(
      ledger: updated.copyWith(cycle: cycle),
      comparison: comparison,
      uncovered: correction.uncovered,
      refill: adjusted.$2,
    );
  }

  Future<(LedgerData, BudgetSettings)> updateBudgetValues(
    LedgerData ledger,
    BudgetSettings next,
    DateTime now,
  ) async {
    await repository.saveBudgetSettings(next);
    final window = ledger.cycle.window;
    final today = KolkataTime.allowanceDateOf(now, boundaryHour: next.dayBoundaryHour);
    final candidate = CycleCalendar.expectedNextStart(window.start, anchorDay: next.anchorDay, policy: CyclePlanning.policy);
    final nextStart = candidate.isAfter(today) ? candidate : window.nextStart;
    final newWindow = CycleWindow(start: window.start, nextStart: nextStart);
    final cycle = ledger.cycle.copyWith(
      window: newWindow,
      foodFloor: next.foodFloorPerDay.times(newWindow.length),
      petrolFloor: next.petrolFloorPerCycle.times(newWindow.length).ceilDiv(CyclePlanning.policy.petrolFloorReferenceDays),
    );
    await repository.updateCycle(cycle);
    return (ledger.copyWith(cycle: cycle), next);
  }

  Future<(LedgerData, BatchRecord)> persistEvent(
    LedgerData ledger, {
    required BatchKind kind,
    required DateTime at,
    required List<AdjustmentDraft> moves,
    required List<HoldDraft> newHolds,
    required List<HoldRelease> releases,
    required Money moved,
    required Money held,
    required Money shortfall,
    required List<BudgetCategory> targets,
    required bool suggestReplan,
    required bool seen,
  }) async {
    final ids = repository.ids;
    final batchId = ids.next('batch');
    final adjustments = [
      for (final draft in [...moves, for (final release in releases) ...release.moves])
        Adjustment.fromDraft(id: ids.next('adj'), batchId: batchId, createdAt: at, draft: draft),
    ];
    final holds = [
      for (final draft in newHolds)
        Hold.fromDraft(id: ids.next('hold'), batchId: batchId, commitmentId: batchId, createdAt: at, draft: draft),
      for (final release in releases)
        for (final draft in release.holds)
          Hold.fromDraft(
            id: ids.next('hold'),
            batchId: batchId,
            commitmentId: release.commitmentId,
            createdAt: at,
            draft: draft,
          ),
    ];
    final batch = BatchRecord(
      id: batchId,
      kind: kind,
      createdAt: at,
      moved: moved,
      held: held,
      shortfall: shortfall,
      targets: targets,
      suggestReplan: suggestReplan,
      seen: seen,
      undone: false,
    );
    await repository.insertBatch(cycleId: ledger.cycle.id, batch: batch, adjustments: adjustments, holds: holds);
    return (
      ledger.copyWith(
        adjustments: [...ledger.adjustments, ...adjustments],
        holds: [...ledger.holds, ...holds],
        batches: [...ledger.batches, batch],
      ),
      batch,
    );
  }
}
