import 'dart:io';
import 'dart:typed_data';

import 'package:budget_engine/budget_engine.dart';
import 'package:fintrack/app/state.dart';
import 'package:fintrack/data/backup.dart';
import 'package:fintrack/data/gear_repository.dart';
import 'package:fintrack/domain/gear.dart';
import 'package:fintrack/domain/ledger_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('gear catalogue', () {
    test('every bundled image exists and is listed in SOURCES.md', () {
      final sources = File('assets/gear/SOURCES.md').readAsStringSync();
      for (final item in GearCatalog.items.where((item) => item.imageAsset != null)) {
        expect(File(item.imageAsset!).existsSync(), isTrue, reason: item.imageAsset);
        expect(sources.contains(item.imageAsset!.split('/').last), isTrue, reason: item.imageAsset);
      }
      expect(GearCatalog.items.where((item) => item.isBike), hasLength(1));
    });

    test('is added once, and a removed item does not come back', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final repository = GearRepository(db);
      await repository.ensureCatalog();
      expect(await repository.loadGear(), hasLength(6));
      await repository.deleteGear('gear-powerbank');
      await repository.ensureCatalog();
      expect(await repository.loadGear(), hasLength(5));
    });

    test('cost per day uses days owned including today, and warranty counts down', () {
      final item = GearCatalog.items.first.copyWith(
        price: Money.rupees(99999),
        purchaseDate: CivilDate(2026, 1, 1),
        warrantyEnd: CivilDate(2027, 1, 1),
      );
      final today = CivilDate(2026, 1, 10);
      expect(item.daysOwned(today), 10);
      expect(item.costPerDay(today), Money(999990));
      expect(item.warrantyDaysLeft(today), 356);
      expect(GearCatalog.items.first.costPerDay(today), isNull);
    });

    test('photos are stored in the database and travel with a backup', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final repository = GearRepository(db);
      await repository.ensureCatalog();
      final photo = await repository.savePhoto(Uint8List.fromList([1, 2, 3, 4]), DateTime.utc(2026));
      final phone = (await repository.loadGear()).first;
      await repository.upsertGear(phone.copyWith(billPhotoId: photo, price: Money.rupees(80000)));
      final scratch = Directory.systemTemp.createTempSync('fintrack-gear');
      addTearDown(() => scratch.deleteSync(recursive: true));
      final bytes = await BackupService(db, scratch: scratch).create(passphrase: 'passphrase1', now: DateTime.utc(2026), iterations: 1000);
      final fresh = memoryDatabase();
      addTearDown(fresh.close);
      await BackupService(fresh, scratch: scratch).restore(bytes: bytes, passphrase: 'passphrase1');
      final restored = GearRepository(fresh);
      final restoredPhone = (await restored.loadGear()).first;
      expect(restoredPhone.price, Money.rupees(80000));
      expect(await restored.photo(restoredPhone.billPhotoId!), [1, 2, 3, 4]);
    });
  });

  group('profile and gear screens', () {
    Future<ProviderContainer> containerOf(WidgetTester tester) async =>
        ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

    testWidgets('profile shows all six gear cards and the bike card reads the bike profile', (tester) async {
      final db = memoryDatabase();
      final clock = FakeClock(ist(2026, 3, 10, 14));
      await seed(db, clock);
      await pumpApp(tester, db: db, clock: clock);
      final container = await containerOf(tester);
      final ledger = container.read(budgetProvider).requireValue.ledger!;
      await container.read(budgetProvider.notifier).saveBike(BikeProfile(
        service: ledger.bike.service,
        insuranceExpiry: CivilDate(2026, 8, 1),
      ));
      await container.read(budgetProvider.notifier).logFuel(
            amount: Money.rupees(300),
            pricePerLitre: Money(10250),
            odometerKm: 23456,
            fullTank: true,
            method: PaymentMethod.upi,
          );
      await settle(tester);

      await tester.tap(find.byKey(const Key('open-profile')));
      await settle(tester);
      for (final item in GearCatalog.items) {
        await tester.ensureVisible(find.byKey(Key('gear-${item.id}')));
        expect(find.byKey(Key('gear-${item.id}')), findsOneWidget);
      }
      expect(find.text('23456 km'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('gear-gear-bike')));
      await tester.tap(find.byKey(const Key('gear-gear-bike')));
      await settle(tester);
      expect(find.byKey(const Key('bike-section')), findsOneWidget);
      expect(find.text('Odometer: 23456 km'), findsOneWidget);
      expect(find.text('1 Aug'), findsOneWidget);
      await unmount(tester);
      await db.close();
    });

    testWidgets('editing a gear item saves price and a bill photo', (tester) async {
      final db = memoryDatabase();
      final clock = FakeClock(ist(2026, 3, 10, 14));
      await seed(db, clock);
      await GearRepository(db).ensureCatalog();
      final phone = (await GearRepository(db).loadGear()).first;
      await GearRepository(db).upsertGear(phone.copyWith(purchaseDate: CivilDate(2026, 3, 1)));
      final photos = FakePhotoPicker(tinyPng);
      await pumpApp(tester, db: db, clock: clock, photos: photos);
      await tester.tap(find.byKey(const Key('open-profile')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('gear-gear-phone')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('gear-price')));
      await tester.enterText(find.byKey(const Key('gear-price')), '1000');
      await settle(tester);
      expect(find.text('₹100 per day so far'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('gear-bill')));
      await tester.tap(find.byKey(const Key('gear-bill')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('pick-gallery')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('gear-save')));
      await tester.tap(find.byKey(const Key('gear-save')));
      await settle(tester);
      final saved = (await tester.runAsync(() => GearRepository(db).loadGear()))!.first;
      expect(saved.price, Money.rupees(1000));
      expect(await tester.runAsync(() => GearRepository(db).photo(saved.billPhotoId!)), tinyPng);
      await unmount(tester);
      await db.close();
    });
  });
}
