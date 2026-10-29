import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:drift/native.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/data/gear_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

Map<String, List<Map<String, Object?>>> dump(String path) {
  final database = raw.sqlite3.open(path);
  try {
    final tables = database
        .select("select name from sqlite_master where type = 'table' and name not like 'sqlite_%' order by name")
        .map((row) => row['name'] as String);
    return {
      for (final table in tables)
        table: [
          for (final row in database.select('select * from "$table" order by rowid')) {...row},
        ],
    };
  } finally {
    database.close();
  }
}

int userVersion(String path) {
  final database = raw.sqlite3.open(path);
  try {
    return database.select('pragma user_version').first.values.first! as int;
  } finally {
    database.close();
  }
}

File copyFixture(String name) {
  final directory = Directory.systemTemp.createTempSync('fintrack-migration');
  addTearDown(() => directory.deleteSync(recursive: true));
  return File('test/fixtures/$name').copySync('${directory.path}/$name');
}

void main() {
  final current = AppDatabase(NativeDatabase.memory()).schemaVersion;

  for (final version in [1, 2, 3]) {
    group('schema v$version fixture upgrades to v$current', () {
      test('every row and column survives, and new columns get their defaults', () async {
        final file = copyFixture('schema_v$version.sqlite');
        expect(userVersion(file.path), version);
        final before = dump(file.path);

        final db = AppDatabase(NativeDatabase(file));
        await BudgetRepository(db).loadPreferences();
        await db.close();

        expect(userVersion(file.path), current);
        final after = dump(file.path);
        for (final entry in before.entries) {
          final upgraded = after[entry.key]!;
          expect(upgraded, hasLength(entry.value.length), reason: entry.key);
          for (var index = 0; index < entry.value.length; index++) {
            final old = entry.value[index];
            final now = upgraded[index];
            for (final column in old.keys) {
              expect(now[column], old[column], reason: '${entry.key}.$column row $index');
            }
          }
        }
        if (version < 2) {
          expect(after['fuel_fills'], isEmpty);
          expect(after['supply_items']!.single['saved_paise'], 0);
        }
        if (version < 3) {
          expect(after['gear_items'], isEmpty);
          expect(after['photos'], isEmpty);
        }
      });

      test('the app loads the upgraded data with the same balances', () async {
        final file = copyFixture('schema_v$version.sqlite');
        final db = AppDatabase(NativeDatabase(file));
        addTearDown(db.close);
        final repository = BudgetRepository(db);
        final ledger = (await repository.loadLedger())!;
        final settings = (await repository.loadBudgetSettings())!;
        expect(settings.foodFloorPerDay, Money.rupees(150));
        expect((await repository.loadPreferences()).onboarded, isTrue);
        expect(ledger.learnedKeywords['chai'], BudgetCategory.food);
        expect(ledger.deposits.where((deposit) => deposit.isExtra), hasLength(1));
        expect(ledger.holds.where((hold) => hold.amount.isPositive), isNotEmpty);
        expect(ledger.batches.where((batch) => batch.suggestReplan), hasLength(1));
        final spent = Money.sum(ledger.transactions.where((transaction) => !transaction.isCorrection).map((transaction) => transaction.amount));
        final corrections = Money.sum(ledger.transactions.where((transaction) => transaction.isCorrection).map((transaction) => transaction.amount));
        expect(Ledger.total(ledger.balances), Money.rupees(13000) - spent - corrections);
        if (version >= 3) {
          final gear = await GearRepository(db).loadGear();
          expect(gear.first.price, Money.rupees(99999));
          expect(await GearRepository(db).photo(gear.first.billPhotoId!), isNotNull);
        }
        if (version >= 2) {
          expect(ledger.fuelFills, hasLength(1));
          expect(ledger.bike.service.intervalKm, 3000);
          expect(ledger.latestAnchor!.bank, Money.rupees(5500));
        }
      });
    });
  }
}
