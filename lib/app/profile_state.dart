import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/gear_repository.dart';
import '../domain/gear.dart';
import '../platform/photo_picker.dart';
import 'state.dart';

final gearRepositoryProvider = Provider<GearRepository>((ref) => GearRepository(ref.watch(databaseProvider)));

final photoPickerProvider = Provider<PhotoPicker>((ref) => DevicePhotoPicker());

final photoProvider = FutureProvider.family<Uint8List?, String>(
  (ref, id) => ref.watch(gearRepositoryProvider).photo(id),
);

final class ProfileState {
  const ProfileState({required this.details, required this.gear});

  final ProfileDetails details;
  final List<GearItem> gear;

  GearItem? item(String id) => gear.where((item) => item.id == id).firstOrNull;
}

final profileProvider = AsyncNotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileController extends AsyncNotifier<ProfileState> {
  GearRepository get _repository => ref.read(gearRepositoryProvider);

  @override
  Future<ProfileState> build() async {
    ref.watch(budgetProvider.select((value) => value.value?.ready));
    await _repository.ensureCatalog();
    return ProfileState(details: await _repository.loadProfile(), gear: await _repository.loadGear());
  }

  ProfileState get _current => state.requireValue;

  Future<void> saveDetails(ProfileDetails details) async {
    await _repository.saveProfile(details);
    state = AsyncData(ProfileState(details: details, gear: _current.gear));
  }

  Future<void> saveGear(GearItem item) async {
    await _repository.upsertGear(item);
    final exists = _current.gear.any((existing) => existing.id == item.id);
    final gear = exists
        ? [for (final existing in _current.gear) existing.id == item.id ? item : existing]
        : [..._current.gear, item];
    state = AsyncData(ProfileState(details: _current.details, gear: gear));
  }

  Future<void> deleteGear(String id) async {
    await _repository.deleteGear(id);
    state = AsyncData(ProfileState(
      details: _current.details,
      gear: _current.gear.where((item) => item.id != id).toList(),
    ));
  }

  Future<String?> pickPhoto(PhotoSource source) async {
    ref.read(lockProvider.notifier).expectExternal();
    final bytes = await ref.read(photoPickerProvider).pick(source);
    if (bytes == null) {
      return null;
    }
    return _repository.savePhoto(bytes, ref.read(clockProvider)());
  }

  String newGearId() => _repository.ids.next('gear');
}
