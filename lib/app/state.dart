import 'package:budget_engine/budget_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/budget_repository.dart';
import '../data/ledger_actions.dart';
import '../data/database.dart';
import '../data/demo_seeder.dart';
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

final budgetProvider = AsyncNotifierProvider<BudgetController, AppState>(BudgetController.new);

class BudgetController extends AsyncNotifier<AppState> {
  BudgetRepository get _repository => ref.read(repositoryProvider);
  LedgerActions get _actions => LedgerActions(_repository);
  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<AppState> build() async {
    final preferences = await _repository.loadPreferences();
    final settings = await _repository.loadBudgetSettings();
    var ledger = await _repository.loadLedger();
    final now = _now();
    if (ledger != null && settings != null) {
      ledger = await _actions.releaseWeeklyHolds(ledger, settings, now);
    }
    await ref.read(secureWindowProvider).setSecure(preferences.secureScreen);
    return AppState(preferences: preferences, settings: settings, ledger: ledger, now: now);
  }

  AppState get _current => state.requireValue;
  LedgerData get _ledger => _current.ledger!;
  BudgetSettings get _settings => _current.settings!;

  void _commit(LedgerData ledger, {DateTime? now, BudgetSettings? settings}) {
    state = AsyncData(_current.copyWith(ledger: ledger, now: now ?? _now(), settings: settings));
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final now = _now();
    var ledger = current.ledger;
    if (ledger != null && current.settings != null) {
      ledger = await _actions.releaseWeeklyHolds(ledger, current.settings!, now);
    }
    state = AsyncData(current.copyWith(now: now, ledger: ledger));
  }

  Future<void> completeOnboarding(OnboardingInput input) async {
    await _repository.completeOnboarding(input: input, now: _now(), preferences: _current.preferences);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadDemo() async {
    await DemoSeeder(_repository).seed(now: _now());
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
    final now = _now();
    final outcome = await _actions.log(
      _ledger,
      _settings,
      now,
      amount: amount,
      category: category,
      method: method,
      source: source,
      note: note,
      learnKeyword: learnKeyword,
    );
    _commit(outcome.ledger, now: now);
    return outcome;
  }

  Future<DeletedEntry> deleteTransaction(Transaction transaction) async {
    final (ledger, entry) = await _actions.deleteTransaction(_ledger, transaction);
    _commit(ledger);
    return entry;
  }

  Future<void> restore(DeletedEntry entry) async => _commit(await _actions.restore(_ledger, entry));

  Future<void> markSummarySeen(String batchId) async => _commit(await _actions.markSummarySeen(_ledger, batchId));

  Future<void> undoBatch(String batchId) async => _commit(await _actions.undoBatch(_ledger, batchId));

  Future<void> moveBanked({required Money amount, required BudgetCategory to}) async {
    final now = _now();
    _commit(await _actions.moveBanked(_ledger, _settings, now, amount: amount, to: to), now: now);
  }

  Future<void> logDeposit({required Money amount, required CivilDate date, required DepositKind kind}) async {
    final now = _now();
    _commit(await _actions.logDeposit(_ledger, _settings, now, amount: amount, date: date, kind: kind), now: now);
  }

  Future<void> restock({required String supplyId, required Money paid, required PaymentMethod method}) async {
    final now = _now();
    _commit(await _actions.restock(_ledger, _settings, now, supplyId: supplyId, paid: paid, method: method), now: now);
  }

  Future<LogOutcome> logFuel({
    required Money amount,
    required Money pricePerLitre,
    required int odometerKm,
    required bool fullTank,
    required PaymentMethod method,
  }) async {
    final now = _now();
    final outcome = await _actions.logFuel(
      _ledger,
      _settings,
      now,
      amount: amount,
      pricePerLitre: pricePerLitre,
      odometerKm: odometerKm,
      fullTank: fullTank,
      method: method,
    );
    _commit(outcome.ledger, now: now);
    return outcome;
  }

  Future<void> saveBike(BikeProfile bike) async => _commit(await _actions.saveBike(_ledger, bike));

  Future<void> payService({required Money amount, required int odometerKm, required PaymentMethod method}) async {
    final now = _now();
    _commit(
      await _actions.payService(_ledger, _settings, now, amount: amount, odometerKm: odometerKm, method: method),
      now: now,
    );
  }

  Future<void> payRecurring({required String costId, required Money amount, required PaymentMethod method}) async {
    final now = _now();
    _commit(
      await _actions.payRecurring(_ledger, _settings, now, costId: costId, amount: amount, method: method),
      now: now,
    );
  }

  Future<void> upsertSupply(NamedSupply supply) async => _commit(await _actions.upsertSupply(_ledger, supply));

  Future<void> deleteSupply(String id) async => _commit(await _actions.deleteSupply(_ledger, id));

  Future<void> upsertRecurring(NamedRecurringCost cost) async => _commit(await _actions.upsertRecurring(_ledger, cost));

  Future<void> deleteRecurring(String id) async => _commit(await _actions.deleteRecurring(_ledger, id));

  Future<BalanceComparison?> previewBalance(ReportedBalance reported) => _actions.compareBalance(_ledger, reported);

  Future<BalanceCheckOutcome> applyBalanceCheck({
    required ReportedBalance reported,
    required BalanceResolution resolution,
  }) async {
    final now = _now();
    final outcome = await _actions.applyBalanceCheck(
      _ledger,
      _settings,
      now,
      reported: reported,
      resolution: resolution,
    );
    _commit(outcome.ledger, now: now);
    return outcome;
  }

  Future<void> updateBudgetValues(BudgetSettings next) async {
    final now = _now();
    final (ledger, settings) = await _actions.updateBudgetValues(_ledger, next, now);
    _commit(ledger, now: now, settings: settings);
  }

  String newId(String prefix) => _repository.ids.next(prefix);
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
