import 'dart:io';

import 'package:budget_engine/budget_engine.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:fintrack/data/backup.dart';
import 'package:fintrack/data/budget_repository.dart';
import 'package:fintrack/data/database.dart';
import 'package:fintrack/data/demo_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

Future<Map<String, List<Map<String, dynamic>>>> dumpTables(AppDatabase db) async => {
      for (final table in db.allTables)
        table.actualTableName: [
          for (final row in await db.select(table as TableInfo<Table, dynamic>).get())
            (row as DataClass).toJson(),
        ],
    };

void main() {
  late Directory scratch;

  setUp(() {
    scratch = Directory.systemTemp.createTempSync('fintrack-backup');
  });

  tearDown(() => scratch.deleteSync(recursive: true));

  Future<AppDatabase> seeded() async {
    final db = memoryDatabase();
    await DemoSeeder(BudgetRepository(db)).seed(now: ist(2026, 6, 20, 10));
    return db;
  }

  test('restore on a clean install reproduces balances, holds, anchors and every ledger entry', () async {
    final original = await seeded();
    addTearDown(original.close);
    final bytes = await BackupService(original, scratch: scratch).create(
      passphrase: 'correct horse battery',
      now: ist(2026, 6, 20, 11),
      iterations: 1000,
    );

    final fresh = memoryDatabase();
    addTearDown(fresh.close);
    await BackupService(fresh, scratch: scratch).restore(bytes: bytes, passphrase: 'correct horse battery');

    expect(await dumpTables(fresh), await dumpTables(original));
    final before = (await BudgetRepository(original).loadLedger())!;
    final after = (await BudgetRepository(fresh).loadLedger())!;
    expect(after.balances, before.balances);
    expect(after.held, before.held);
    expect(after.holds.length, before.holds.length);
    expect(after.latestAnchor!.anchor.total, before.latestAnchor!.anchor.total);
    expect(after.latestAnchor!.at, before.latestAnchor!.at);
    expect([for (final t in after.transactions) (t.id, t.amount, t.category, t.occurredAt)],
        [for (final t in before.transactions) (t.id, t.amount, t.category, t.occurredAt)]);
    expect([for (final a in after.adjustments) (a.id, a.batchId, a.amount, a.undone)],
        [for (final a in before.adjustments) (a.id, a.batchId, a.amount, a.undone)]);
    expect(await BudgetRepository(fresh).loadBudgetSettings(), isNotNull);
    expect((await BudgetRepository(fresh).loadPreferences()).onboarded, isTrue);
  });

  test('restoring replaces whatever was there before', () async {
    final original = await seeded();
    addTearDown(original.close);
    final bytes = await BackupService(original, scratch: scratch).create(passphrase: 'passphrase1', now: DateTime.utc(2026), iterations: 1000);
    final other = memoryDatabase();
    addTearDown(other.close);
    final clock = FakeClock(ist(2026, 1, 5, 10));
    await seed(other, clock);
    await BackupService(other, scratch: scratch).restore(bytes: bytes, passphrase: 'passphrase1');
    expect(await dumpTables(other), await dumpTables(original));
  });

  test('a wrong passphrase is refused and nothing changes', () async {
    final original = await seeded();
    addTearDown(original.close);
    final bytes = await BackupService(original, scratch: scratch).create(passphrase: 'passphrase1', now: DateTime.utc(2026), iterations: 1000);
    final fresh = memoryDatabase();
    addTearDown(fresh.close);
    await expectLater(
      BackupService(fresh, scratch: scratch).restore(bytes: bytes, passphrase: 'passphrase2'),
      throwsA(isA<BackupException>().having((error) => error.failure, 'failure', BackupFailure.wrongPassphrase)),
    );
    expect((await dumpTables(fresh)).values.every((rows) => rows.isEmpty), isTrue);
  });

  test('a changed file is refused', () async {
    final original = await seeded();
    addTearDown(original.close);
    final bytes = await BackupService(original, scratch: scratch).create(passphrase: 'passphrase1', now: DateTime.utc(2026), iterations: 1000);
    final text = String.fromCharCodes(bytes).replaceFirst('"schemaVersion":2', '"schemaVersion":1');
    await expectLater(
      BackupCodec.decrypt(bytes: Uint8List.fromList(text.codeUnits), passphrase: 'passphrase1', currentSchema: 2),
      throwsA(isA<BackupException>()),
    );
    await expectLater(
      BackupCodec.decrypt(bytes: Uint8List.fromList('hello'.codeUnits), passphrase: 'passphrase1', currentSchema: 2),
      throwsA(isA<BackupException>().having((error) => error.failure, 'failure', BackupFailure.notABackup)),
    );
  });

  test('a backup from a newer app version is refused', () async {
    final bytes = await BackupCodec.encrypt(
      database: Uint8List(4),
      passphrase: 'passphrase1',
      createdAt: DateTime.utc(2026),
      schemaVersion: 99,
      iterations: 1000,
    );
    await expectLater(
      BackupCodec.decrypt(bytes: bytes, passphrase: 'passphrase1', currentSchema: 2),
      throwsA(isA<BackupException>().having((error) => error.failure, 'failure', BackupFailure.newerVersion)),
    );
  });

  test('a backup of an older schema is upgraded during restore', () async {
    final v1 = await File('test/fixtures/schema_v1.sqlite').readAsBytes();
    final bytes = await BackupCodec.encrypt(
      database: v1,
      passphrase: 'passphrase1',
      createdAt: DateTime.utc(2026, 3, 9),
      schemaVersion: 1,
      iterations: 1000,
    );
    final fresh = memoryDatabase();
    addTearDown(fresh.close);
    await BackupService(fresh, scratch: scratch).restore(bytes: bytes, passphrase: 'passphrase1');
    final ledger = (await BudgetRepository(fresh).loadLedger())!;
    expect(ledger.transactions, hasLength(2));
    expect(ledger.learnedKeywords['chai'], BudgetCategory.food);
    expect(BackupCodec.inspect(bytes).schemaVersion, 1);
  });

  test('the default key stretching works end to end and short passphrases are rejected', () async {
    final bytes = await BackupCodec.encrypt(
      database: Uint8List.fromList([1, 2, 3]),
      passphrase: 'a longer passphrase',
      createdAt: DateTime.utc(2026),
      schemaVersion: 2,
    );
    expect(await BackupCodec.decrypt(bytes: bytes, passphrase: 'a longer passphrase', currentSchema: 2), [1, 2, 3]);
    expect(
      () => BackupCodec.encrypt(database: Uint8List(1), passphrase: 'short', createdAt: DateTime.utc(2026), schemaVersion: 2),
      throwsArgumentError,
    );
  });
}
