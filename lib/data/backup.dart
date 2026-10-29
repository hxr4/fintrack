import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'database.dart';

enum BackupFailure { notABackup, wrongPassphrase, newerVersion, damaged }

final class BackupException implements Exception {
  const BackupException(this.failure);

  final BackupFailure failure;

  @override
  String toString() => 'BackupException(${failure.name})';
}

final class BackupInfo {
  const BackupInfo({required this.createdAt, required this.schemaVersion});

  final DateTime createdAt;
  final int schemaVersion;
}

abstract final class BackupCodec {
  static const format = 'fintrack-backup';
  static const formatVersion = 1;
  static const kdfName = 'pbkdf2-hmac-sha256';
  static const cipherName = 'aes-256-gcm';
  static const defaultIterations = 200000;
  static const minimumPassphraseLength = 8;

  static Map<String, Object> _header({
    required DateTime createdAt,
    required int schemaVersion,
    required int iterations,
    required String salt,
  }) =>
      {
        'format': format,
        'version': formatVersion,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'schemaVersion': schemaVersion,
        'kdf': {'name': kdfName, 'iterations': iterations, 'salt': salt},
      };

  static Future<SecretKey> _key(String passphrase, List<int> salt, int iterations) =>
      Pbkdf2.hmacSha256(iterations: iterations, bits: 256).deriveKeyFromPassword(password: passphrase, nonce: salt);

  static Future<Uint8List> encrypt({
    required Uint8List database,
    required String passphrase,
    required DateTime createdAt,
    required int schemaVersion,
    int iterations = defaultIterations,
  }) async {
    if (passphrase.length < minimumPassphraseLength) {
      throw ArgumentError.value(passphrase.length, 'passphrase', 'is too short');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final nonce = List<int>.generate(12, (_) => random.nextInt(256));
    final header = _header(
      createdAt: createdAt,
      schemaVersion: schemaVersion,
      iterations: iterations,
      salt: base64Encode(salt),
    );
    final box = await Isolate.run(() async {
      final key = await _key(passphrase, salt, iterations);
      return AesGcm.with256bits().encrypt(
        gzip.encode(database),
        secretKey: key,
        nonce: nonce,
        aad: utf8.encode(jsonEncode(header)),
      );
    });
    final file = {
      ...header,
      'cipher': {'name': cipherName, 'nonce': base64Encode(box.nonce), 'mac': base64Encode(box.mac.bytes)},
      'data': base64Encode(box.cipherText),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(file)));
  }

  static Map<String, Object?> _parse(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?> || decoded['format'] != format) {
        throw const BackupException(BackupFailure.notABackup);
      }
      return decoded;
    } on FormatException {
      throw const BackupException(BackupFailure.notABackup);
    }
  }

  static BackupInfo inspect(Uint8List bytes) {
    final file = _parse(bytes);
    try {
      return BackupInfo(
        createdAt: DateTime.parse(file['createdAt']! as String),
        schemaVersion: file['schemaVersion']! as int,
      );
    } on Object {
      throw const BackupException(BackupFailure.damaged);
    }
  }

  static Future<Uint8List> decrypt({required Uint8List bytes, required String passphrase, required int currentSchema}) async {
    final file = _parse(bytes);
    final int iterations;
    final List<int> salt;
    final SecretBox box;
    final Map<String, Object> header;
    try {
      if (file['version'] != formatVersion) {
        throw const BackupException(BackupFailure.newerVersion);
      }
      final kdf = file['kdf']! as Map<String, Object?>;
      final cipher = file['cipher']! as Map<String, Object?>;
      if (kdf['name'] != kdfName || cipher['name'] != cipherName) {
        throw const BackupException(BackupFailure.damaged);
      }
      iterations = kdf['iterations']! as int;
      salt = base64Decode(kdf['salt']! as String);
      header = _header(
        createdAt: DateTime.parse(file['createdAt']! as String),
        schemaVersion: file['schemaVersion']! as int,
        iterations: iterations,
        salt: kdf['salt']! as String,
      );
      box = SecretBox(
        base64Decode(file['data']! as String),
        nonce: base64Decode(cipher['nonce']! as String),
        mac: Mac(base64Decode(cipher['mac']! as String)),
      );
    } on BackupException {
      rethrow;
    } on Object {
      throw const BackupException(BackupFailure.damaged);
    }
    if ((file['schemaVersion']! as int) > currentSchema) {
      throw const BackupException(BackupFailure.newerVersion);
    }
    final aad = utf8.encode(jsonEncode(header));
    try {
      final clear = await Isolate.run(() async {
        final key = await _key(passphrase, salt, iterations);
        return AesGcm.with256bits().decrypt(box, secretKey: key, aad: aad);
      });
      return Uint8List.fromList(gzip.decode(clear));
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupFailure.wrongPassphrase);
    } on FormatException {
      throw const BackupException(BackupFailure.damaged);
    }
  }
}

final class BackupService {
  BackupService(this.db, {required this.scratch});

  final AppDatabase db;
  final Directory scratch;

  File _scratchFile(String name) {
    scratch.createSync(recursive: true);
    return File('${scratch.path}/$name-${DateTime.now().microsecondsSinceEpoch}.sqlite');
  }

  Future<Uint8List> snapshot() async {
    final file = _scratchFile('snapshot');
    try {
      await db.customStatement('VACUUM INTO ?', [file.path]);
      return await file.readAsBytes();
    } finally {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<Uint8List> create({required String passphrase, required DateTime now, int iterations = BackupCodec.defaultIterations}) async =>
      BackupCodec.encrypt(
        database: await snapshot(),
        passphrase: passphrase,
        createdAt: now,
        schemaVersion: db.schemaVersion,
        iterations: iterations,
      );

  Future<void> restore({required Uint8List bytes, required String passphrase}) async {
    final database = await BackupCodec.decrypt(bytes: bytes, passphrase: passphrase, currentSchema: db.schemaVersion);
    final file = _scratchFile('restore');
    await file.writeAsBytes(database, flush: true);
    final source = AppDatabase(NativeDatabase(file));
    try {
      try {
        await source.customSelect('select count(*) from settings').get();
      } on Object {
        throw const BackupException(BackupFailure.damaged);
      }
      await replaceAllWith(source);
    } finally {
      await source.close();
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<void> replaceAllWith(AppDatabase source) async {
    final targets = db.allTables.toList();
    final sources = source.allTables.toList();
    final rows = <List<Insertable<dynamic>>>[];
    for (final table in sources) {
      final selected = await source.select(table as TableInfo<Table, dynamic>).get();
      rows.add([for (final row in selected) row as Insertable<dynamic>]);
    }
    await db.transaction(() async {
      for (final table in targets.reversed) {
        await db.delete(table).go();
      }
      for (var index = 0; index < targets.length; index++) {
        final target = targets[index] as TableInfo<Table, dynamic>;
        await db.batch((batch) => batch.insertAll(target, rows[index]));
      }
    });
  }
}
