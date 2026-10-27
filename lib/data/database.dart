import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('CycleRow')
class Cycles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startDate => text()();
  TextColumn get expectedNextStart => text()();
  TextColumn get closedOn => text().nullable()();
  TextColumn get weights => text()();
  IntColumn get installmentsPaise => integer()();
  IntColumn get carryInPaise => integer()();
  IntColumn get baselinePaise => integer()();
  IntColumn get deltaPaise => integer()();
  IntColumn get foodFloorPaise => integer()();
  IntColumn get petrolFloorPaise => integer()();
  IntColumn get shortfallPaise => integer()();
  IntColumn get baseDailyPaise => integer()();
}

@DataClassName('AllocationRow')
class Allocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  TextColumn get category => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get kind => text()();
}

@DataClassName('DepositRow')
class Deposits extends Table {
  TextColumn get id => text()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  IntColumn get amountPaise => integer()();
  IntColumn get receivedAt => integer()();
  TextColumn get kind => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  IntColumn get amountPaise => integer()();
  TextColumn get category => text()();
  TextColumn get method => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get note => text()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AdjustmentRow')
class Adjustments extends Table {
  TextColumn get id => text()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  TextColumn get batchId => text()();
  TextColumn get fromCategory => text()();
  TextColumn get toCategory => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get reason => text()();
  IntColumn get createdAt => integer()();
  BoolColumn get auto => boolean()();
  BoolColumn get undone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HoldRow')
class Holds extends Table {
  TextColumn get id => text()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  TextColumn get batchId => text()();
  TextColumn get commitmentId => text()();
  TextColumn get category => text()();
  IntColumn get amountPaise => integer()();
  IntColumn get createdAt => integer()();
  BoolColumn get undone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BatchRow')
class Batches extends Table {
  TextColumn get id => text()();
  IntColumn get cycleId => integer().references(Cycles, #id)();
  TextColumn get kind => text()();
  IntColumn get createdAt => integer()();
  IntColumn get movedPaise => integer()();
  IntColumn get heldPaise => integer()();
  IntColumn get shortfallPaise => integer()();
  TextColumn get targets => text()();
  BoolColumn get suggestReplan => boolean()();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();
  BoolColumn get undone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SupplyItemRow')
class SupplyItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get pricePaise => integer()();
  IntColumn get lifespanDays => integer()();
  TextColumn get lastRestock => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurringCostRow')
class RecurringCosts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountPaise => integer()();
  IntColumn get everyMonths => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BalanceAnchorRow')
class BalanceAnchors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get at => integer()();
  IntColumn get bankPaise => integer()();
  IntColumn get cashPaise => integer()();
  IntColumn get excludedPaise => integer()();
}

@DataClassName('KeywordMappingRow')
class KeywordMappings extends Table {
  TextColumn get keyword => text()();
  TextColumn get category => text()();

  @override
  Set<Column<Object>> get primaryKey => {keyword};
}

@DataClassName('StreakDayRow')
class StreakDays extends Table {
  TextColumn get date => text()();
  BoolColumn get noSpend => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DriftDatabase(
  tables: [
    Settings,
    Cycles,
    Allocations,
    Deposits,
    Transactions,
    Adjustments,
    Holds,
    Batches,
    SupplyItems,
    RecurringCosts,
    BalanceAnchors,
    KeywordMappings,
    StreakDays,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open() : super(driftDatabase(name: 'fintrack'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
