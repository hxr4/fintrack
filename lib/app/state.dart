import 'package:budget_engine/budget_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/budget_repository.dart';
import '../data/database.dart';
import '../domain/budget_snapshot.dart';
import '../domain/cycle_planning.dart';
import '../domain/ledger_data.dart';
import '../domain/preferences.dart';
import '../platform/authenticator.dart';
import '../platform/secure_window.dart';

typedef Clock = DateTime Function();

final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider must be overridden'));

final repositoryProvider = Provider<BudgetRepository>((ref) => BudgetRepository(ref.watch(databaseProvider)));

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final authenticatorProvider = Provider<Authenticator>((ref) => DeviceAuthenticator());

final secureWindowProvider = Provider<SecureWindow>((ref) => AndroidSecureWindow());

final class AppState {
  AppState({required this.preferences, required this.settings, required this.ledger, required this.now});

  final AppPreferences preferences;
  final BudgetSettings? settings;
  final LedgerData? ledger;
  final DateTime now;

  late final BudgetSnapshot? snapshot = ledger == null || settings == null
      ? null
      : BudgetSnapshot.compute(ledger: ledger!, settings: settings!, now: now);

  bool get ready => preferences.onboarded && snapshot != null;

  AppState copyWith({AppPreferences? preferences, BudgetSettings? settings, LedgerData? ledger, DateTime? now}) =>
      AppState(
        preferences: preferences ?? this.preferences,
        settings: settings ?? this.settings,
        ledger: ledger ?? this.ledger,
        now: now ?? this.now,
      );
}

final class LogOutcome {
  const LogOutcome({required this.transaction, required this.batch});

  final Transaction transaction;
  final BatchRecord? batch;
}

final budgetProvider = AsyncNotifierProvider<BudgetController, AppState>(BudgetController.new);

class BudgetController extends AsyncNotifier<AppState> {
  BudgetRepository get _repository => ref.read(repositoryProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<AppState> build() async {
    final preferences = await _repository.loadPreferences();
    final settings = await _repository.loadBudgetSettings();
    var ledger = await _repository.loadLedger();
    final now = _now();
    if (ledger != null && settings != null) {
      ledger = await _releaseWeeklyHolds(ledger, settings, now);
    }
    await ref.read(secureWindowProvider).setSecure(preferences.secureScreen);
    return AppState(preferences: preferences, settings: settings, ledger: ledger, now: now);
  }

  AppState get _current => state.requireValue;

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final now = _now();
    var ledger = current.ledger;
    if (ledger != null && current.settings != null) {
      ledger = await _releaseWeeklyHolds(ledger, current.settings!, now);
    }
    state = AsyncData(current.copyWith(now: now, ledger: ledger));
  }

  Future<void> completeOnboarding(OnboardingInput input) async {
    await _repository.completeOnboarding(input: input, now: _now(), preferences: _current.preferences);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updatePreferences(AppPreferences preferences) async {
    await _repository.savePreferences(preferences);
    await ref.read(secureWindowProvider).setSecure(preferences.secureScreen);
    state = AsyncData(_current.copyWith(preferences: preferences));
  }

  Future<LogOutcome> log({
    required Money amount,
    required BudgetCategory category,
    required PaymentMethod method,
    required TransactionSource source,
    String note = '',
    String? learnKeyword,
  }) async {
    final current = _current;
    final ledger = current.ledger!;
    final settings = current.settings!;
    final now = _now();
    final transaction = await _repository.insertTransaction(
      ledger.cycle.id,
      TransactionDraft(
        amount: amount,
        category: category,
        method: method,
        occurredAt: now,
        source: source,
        note: note,
      ),
    );
    var updated = ledger.copyWith(transactions: [...ledger.transactions, transaction]);
    if (learnKeyword != null && learnKeyword.isNotEmpty) {
      await _repository.learnKeyword(learnKeyword, category);
      updated = updated.copyWith(learnedKeywords: {...updated.learnedKeywords, learnKeyword: category});
    }
    final snapshot = BudgetSnapshot.compute(ledger: updated, settings: settings, now: now);
    final result = AutoAdjuster.run(
      balances: updated.balances,
      foodFloorPerDay: settings.foodFloorPerDay,
      petrolFloorForCycle: updated.cycle.petrolFloor,
      cycleLength: updated.cycle.window.length,
      daysLeft: snapshot.daysLeft,
      dayOfCycle: snapshot.dayNumber,
      holds: updated.holds,
      essentialsReservedForDue: snapshot.essentialsReservedForDue,
    );
    BatchRecord? batch;
    if (result.moved) {
      final targets = {
        for (final move in result.allMoves) move.to,
      }.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final persisted = await _persistEvent(
        updated,
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
      updated = persisted.$1;
      batch = persisted.$2;
    }
    state = AsyncData(current.copyWith(ledger: updated, now: now));
    return LogOutcome(transaction: transaction, batch: batch);
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    final ledger = _current.ledger!;
    await _repository.deleteTransaction(transaction.id);
    state = AsyncData(_current.copyWith(
      ledger: ledger.copyWith(
        transactions: ledger.transactions.where((item) => item.id != transaction.id).toList(),
      ),
      now: _now(),
    ));
  }

  Future<void> restoreTransaction(Transaction transaction) async {
    final ledger = _current.ledger!;
    await _repository.restoreTransaction(ledger.cycle.id, transaction);
    final transactions = [...ledger.transactions, transaction]
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    state = AsyncData(_current.copyWith(ledger: ledger.copyWith(transactions: transactions), now: _now()));
  }

  Future<void> markSummarySeen(String batchId) async {
    final ledger = _current.ledger!;
    await _repository.markBatchSeen(batchId);
    state = AsyncData(_current.copyWith(
      ledger: ledger.copyWith(batches: [
        for (final batch in ledger.batches) batch.id == batchId ? batch.copyWith(seen: true) : batch,
      ]),
    ));
  }

  Future<void> undoBatch(String batchId) async {
    final ledger = _current.ledger!;
    final result = BatchUndo.undo(adjustments: ledger.adjustments, holds: ledger.holds, batchId: batchId);
    await _repository.markBatchesUndone(result.undoneBatches);
    state = AsyncData(_current.copyWith(
      ledger: ledger.copyWith(
        adjustments: result.adjustments,
        holds: result.holds,
        batches: [
          for (final batch in ledger.batches)
            result.undoneBatches.contains(batch.id) ? batch.copyWith(undone: true, seen: true) : batch,
        ],
      ),
      now: _now(),
    ));
  }

  Future<void> moveBanked({required Money amount, required BudgetCategory to}) async {
    final current = _current;
    final ledger = current.ledger!;
    final snapshot = current.snapshot!;
    final moves = BankedMover.move(
      amount: amount,
      to: to,
      banked: snapshot.allowance.banked,
      balances: ledger.balances,
      foodFloorPerDay: current.settings!.foodFloorPerDay,
      daysLeft: snapshot.daysLeft,
      held: ledger.held,
    );
    final now = _now();
    final batchId = _repository.ids.next('batch');
    final adjustments = [
      for (final move in moves)
        Adjustment.fromDraft(id: _repository.ids.next('adj'), batchId: batchId, createdAt: now, draft: move),
    ];
    await _repository.insertBatch(
      cycleId: ledger.cycle.id,
      batch: BatchRecord(
        id: batchId,
        kind: BatchKind.release,
        createdAt: now,
        moved: amount,
        held: Money.zero,
        shortfall: Money.zero,
        targets: [to],
        suggestReplan: false,
        seen: true,
        undone: false,
      ),
      adjustments: adjustments,
      holds: const [],
    );
    state = AsyncData(current.copyWith(
      ledger: ledger.copyWith(adjustments: [...ledger.adjustments, ...adjustments]),
      now: now,
    ));
  }

  Future<void> logDeposit({required Money amount, required CivilDate date, required DepositKind kind}) async {
    final current = _current;
    final ledger = current.ledger!;
    final settings = current.settings!;
    final now = _now();
    final deposit = Deposit(
      id: _repository.ids.next('deposit'),
      amount: amount,
      receivedAt: KolkataTime.at(date, 12),
      kind: kind,
    );
    if (kind == DepositKind.extra) {
      final split = ExtraIncome.split(deposit, CyclePlanning.policy);
      final extras = {
        for (final category in BudgetCategory.values)
          category: (ledger.extraAllocations[category] ?? Money.zero) + (split[category] ?? Money.zero),
      };
      final withExtra = ledger.copyWith(extraAllocations: extras);
      final snapshot = BudgetSnapshot.compute(ledger: withExtra, settings: settings, now: now);
      final baseDaily = snapshot.pool.positivePart.floorDiv(snapshot.daysLeft);
      await _repository.addExtraIncome(
        cycleId: ledger.cycle.id,
        deposit: deposit,
        split: split,
        newBaseDaily: baseDaily,
      );
      state = AsyncData(current.copyWith(
        ledger: withExtra.copyWith(
          deposits: [...ledger.deposits, deposit],
          cycle: ledger.cycle.withBaseDaily(baseDaily),
        ),
        now: now,
      ));
      return;
    }
    final carry = CyclePlanning.close(ledger: ledger, settings: settings);
    final history = await _repository.loadHistory(includingCycleId: ledger.cycle.id);
    final next = CyclePlanning.plan(
      deposit: deposit,
      start: date,
      settings: settings,
      supplies: [for (final supply in ledger.supplies) supply.state],
      recurring: [for (final cost in ledger.recurring) cost.state],
      history: history,
      opening: carry.openingBalances,
      carryInToPool: carry.carryInToPool,
    );
    await _repository.startNextCycle(closingCycleId: ledger.cycle.id, closedOn: date, next: next);
    final reloaded = await _repository.loadLedger();
    state = AsyncData(current.copyWith(ledger: reloaded, now: now));
  }

  Future<LedgerData> _releaseWeeklyHolds(LedgerData ledger, BudgetSettings settings, DateTime now) async {
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
    final moved = Money.sum(releases.map((release) => release.moved));
    final persisted = await _persistEvent(
      ledger,
      kind: BatchKind.release,
      at: now,
      moves: const [],
      newHolds: const [],
      releases: releases,
      moved: moved,
      held: Money.zero,
      shortfall: Money.zero,
      targets: const [BudgetCategory.food],
      suggestReplan: false,
      seen: true,
    );
    return persisted.$1;
  }

  Future<(LedgerData, BatchRecord)> _persistEvent(
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
    final ids = _repository.ids;
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
    await _repository.insertBatch(cycleId: ledger.cycle.id, batch: batch, adjustments: adjustments, holds: holds);
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

final lockProvider = NotifierProvider<LockController, bool>(LockController.new);

class LockController extends Notifier<bool> {
  static const backgroundLimit = Duration(seconds: 30);

  DateTime? _backgroundedAt;

  @override
  bool build() => true;

  void lock() => state = true;

  void unlock() {
    _backgroundedAt = null;
    state = false;
  }

  void onBackground(DateTime at) => _backgroundedAt ??= at;

  void onForeground(DateTime at) {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since != null && at.difference(since) >= backgroundLimit) {
      state = true;
    }
  }
}
