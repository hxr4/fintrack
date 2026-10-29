import 'package:budget_engine/budget_engine.dart';
import 'package:drift/drift.dart';

import '../domain/gear.dart';
import 'codecs.dart';
import 'database.dart';
import 'ids.dart';

abstract final class ProfileKeys {
  static const name = 'profileName';
  static const details = 'profileDetails';
  static const photoId = 'profilePhotoId';
  static const gearSeeded = 'gearSeeded';
}

final class GearRepository {
  GearRepository(this.db, {IdGenerator? ids}) : ids = ids ?? IdGenerator();

  final AppDatabase db;
  final IdGenerator ids;

  Future<String?> _setting(String key) async =>
      (await (db.select(db.settings)..where((table) => table.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _put(String key, String value) =>
      db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> ensureCatalog() async {
    if (await _setting(ProfileKeys.gearSeeded) == 'true') {
      return;
    }
    await db.transaction(() async {
      for (final item in GearCatalog.items) {
        await db.into(db.gearItems).insert(_companion(item), mode: InsertMode.insertOrIgnore);
      }
      await _put(ProfileKeys.gearSeeded, 'true');
    });
  }

  GearItemsCompanion _companion(GearItem item) => GearItemsCompanion.insert(
        id: item.id,
        kind: item.kind.name,
        name: item.name,
        variant: Value(item.variant),
        specs: Value(item.specs),
        imageAsset: Value(item.imageAsset),
        photoId: Value(item.photoId),
        purchaseDate: Value(item.purchaseDate?.toString()),
        pricePaise: Value(item.price?.paise),
        seller: Value(item.seller),
        warrantyEnd: Value(item.warrantyEnd?.toString()),
        notes: Value(item.notes),
        billPhotoId: Value(item.billPhotoId),
        sortOrder: Value(item.sortOrder),
      );

  GearItem _item(GearItemRow row) => GearItem(
        id: row.id,
        kind: GearKind.values.byName(row.kind),
        name: row.name,
        variant: row.variant,
        specs: row.specs,
        imageAsset: row.imageAsset,
        photoId: row.photoId,
        purchaseDate: row.purchaseDate == null ? null : CivilDate.parse(row.purchaseDate!),
        price: row.pricePaise == null ? null : Money(row.pricePaise!),
        seller: row.seller,
        warrantyEnd: row.warrantyEnd == null ? null : CivilDate.parse(row.warrantyEnd!),
        notes: row.notes,
        billPhotoId: row.billPhotoId,
        sortOrder: row.sortOrder,
      );

  Future<List<GearItem>> loadGear() async {
    final rows = await (db.select(db.gearItems)
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder), (table) => OrderingTerm.asc(table.name)]))
        .get();
    return [for (final row in rows) _item(row)];
  }

  Future<void> upsertGear(GearItem item) => db.into(db.gearItems).insertOnConflictUpdate(_companion(item));

  Future<void> deleteGear(String id) => (db.delete(db.gearItems)..where((table) => table.id.equals(id))).go();

  Future<String> savePhoto(Uint8List bytes, DateTime now) async {
    final id = ids.next('photo');
    await db.into(db.photos).insert(PhotosCompanion.insert(id: id, bytes: bytes, createdAt: Codecs.instant(now)));
    return id;
  }

  Future<Uint8List?> photo(String id) async =>
      (await (db.select(db.photos)..where((table) => table.id.equals(id))).getSingleOrNull())?.bytes;

  Future<void> deletePhoto(String id) => (db.delete(db.photos)..where((table) => table.id.equals(id))).go();

  Future<ProfileDetails> loadProfile() async => ProfileDetails(
        name: await _setting(ProfileKeys.name) ?? '',
        details: await _setting(ProfileKeys.details) ?? '',
        photoId: await _setting(ProfileKeys.photoId),
      );

  Future<void> saveProfile(ProfileDetails profile) async {
    await _put(ProfileKeys.name, profile.name);
    await _put(ProfileKeys.details, profile.details);
    if (profile.photoId != null) {
      await _put(ProfileKeys.photoId, profile.photoId!);
    }
  }
}
