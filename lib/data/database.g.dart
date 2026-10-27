// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CyclesTable extends Cycles with TableInfo<$CyclesTable, CycleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedNextStartMeta = const VerificationMeta(
    'expectedNextStart',
  );
  @override
  late final GeneratedColumn<String> expectedNextStart =
      GeneratedColumn<String>(
        'expected_next_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _closedOnMeta = const VerificationMeta(
    'closedOn',
  );
  @override
  late final GeneratedColumn<String> closedOn = GeneratedColumn<String>(
    'closed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightsMeta = const VerificationMeta(
    'weights',
  );
  @override
  late final GeneratedColumn<String> weights = GeneratedColumn<String>(
    'weights',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installmentsPaiseMeta = const VerificationMeta(
    'installmentsPaise',
  );
  @override
  late final GeneratedColumn<int> installmentsPaise = GeneratedColumn<int>(
    'installments_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carryInPaiseMeta = const VerificationMeta(
    'carryInPaise',
  );
  @override
  late final GeneratedColumn<int> carryInPaise = GeneratedColumn<int>(
    'carry_in_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baselinePaiseMeta = const VerificationMeta(
    'baselinePaise',
  );
  @override
  late final GeneratedColumn<int> baselinePaise = GeneratedColumn<int>(
    'baseline_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaPaiseMeta = const VerificationMeta(
    'deltaPaise',
  );
  @override
  late final GeneratedColumn<int> deltaPaise = GeneratedColumn<int>(
    'delta_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodFloorPaiseMeta = const VerificationMeta(
    'foodFloorPaise',
  );
  @override
  late final GeneratedColumn<int> foodFloorPaise = GeneratedColumn<int>(
    'food_floor_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _petrolFloorPaiseMeta = const VerificationMeta(
    'petrolFloorPaise',
  );
  @override
  late final GeneratedColumn<int> petrolFloorPaise = GeneratedColumn<int>(
    'petrol_floor_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortfallPaiseMeta = const VerificationMeta(
    'shortfallPaise',
  );
  @override
  late final GeneratedColumn<int> shortfallPaise = GeneratedColumn<int>(
    'shortfall_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseDailyPaiseMeta = const VerificationMeta(
    'baseDailyPaise',
  );
  @override
  late final GeneratedColumn<int> baseDailyPaise = GeneratedColumn<int>(
    'base_daily_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    expectedNextStart,
    closedOn,
    weights,
    installmentsPaise,
    carryInPaise,
    baselinePaise,
    deltaPaise,
    foodFloorPaise,
    petrolFloorPaise,
    shortfallPaise,
    baseDailyPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('expected_next_start')) {
      context.handle(
        _expectedNextStartMeta,
        expectedNextStart.isAcceptableOrUnknown(
          data['expected_next_start']!,
          _expectedNextStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedNextStartMeta);
    }
    if (data.containsKey('closed_on')) {
      context.handle(
        _closedOnMeta,
        closedOn.isAcceptableOrUnknown(data['closed_on']!, _closedOnMeta),
      );
    }
    if (data.containsKey('weights')) {
      context.handle(
        _weightsMeta,
        weights.isAcceptableOrUnknown(data['weights']!, _weightsMeta),
      );
    } else if (isInserting) {
      context.missing(_weightsMeta);
    }
    if (data.containsKey('installments_paise')) {
      context.handle(
        _installmentsPaiseMeta,
        installmentsPaise.isAcceptableOrUnknown(
          data['installments_paise']!,
          _installmentsPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentsPaiseMeta);
    }
    if (data.containsKey('carry_in_paise')) {
      context.handle(
        _carryInPaiseMeta,
        carryInPaise.isAcceptableOrUnknown(
          data['carry_in_paise']!,
          _carryInPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carryInPaiseMeta);
    }
    if (data.containsKey('baseline_paise')) {
      context.handle(
        _baselinePaiseMeta,
        baselinePaise.isAcceptableOrUnknown(
          data['baseline_paise']!,
          _baselinePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselinePaiseMeta);
    }
    if (data.containsKey('delta_paise')) {
      context.handle(
        _deltaPaiseMeta,
        deltaPaise.isAcceptableOrUnknown(data['delta_paise']!, _deltaPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaPaiseMeta);
    }
    if (data.containsKey('food_floor_paise')) {
      context.handle(
        _foodFloorPaiseMeta,
        foodFloorPaise.isAcceptableOrUnknown(
          data['food_floor_paise']!,
          _foodFloorPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodFloorPaiseMeta);
    }
    if (data.containsKey('petrol_floor_paise')) {
      context.handle(
        _petrolFloorPaiseMeta,
        petrolFloorPaise.isAcceptableOrUnknown(
          data['petrol_floor_paise']!,
          _petrolFloorPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_petrolFloorPaiseMeta);
    }
    if (data.containsKey('shortfall_paise')) {
      context.handle(
        _shortfallPaiseMeta,
        shortfallPaise.isAcceptableOrUnknown(
          data['shortfall_paise']!,
          _shortfallPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shortfallPaiseMeta);
    }
    if (data.containsKey('base_daily_paise')) {
      context.handle(
        _baseDailyPaiseMeta,
        baseDailyPaise.isAcceptableOrUnknown(
          data['base_daily_paise']!,
          _baseDailyPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseDailyPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      expectedNextStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_next_start'],
      )!,
      closedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_on'],
      ),
      weights: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weights'],
      )!,
      installmentsPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installments_paise'],
      )!,
      carryInPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carry_in_paise'],
      )!,
      baselinePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baseline_paise'],
      )!,
      deltaPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta_paise'],
      )!,
      foodFloorPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_floor_paise'],
      )!,
      petrolFloorPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}petrol_floor_paise'],
      )!,
      shortfallPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shortfall_paise'],
      )!,
      baseDailyPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_daily_paise'],
      )!,
    );
  }

  @override
  $CyclesTable createAlias(String alias) {
    return $CyclesTable(attachedDatabase, alias);
  }
}

class CycleRow extends DataClass implements Insertable<CycleRow> {
  final int id;
  final String startDate;
  final String expectedNextStart;
  final String? closedOn;
  final String weights;
  final int installmentsPaise;
  final int carryInPaise;
  final int baselinePaise;
  final int deltaPaise;
  final int foodFloorPaise;
  final int petrolFloorPaise;
  final int shortfallPaise;
  final int baseDailyPaise;
  const CycleRow({
    required this.id,
    required this.startDate,
    required this.expectedNextStart,
    this.closedOn,
    required this.weights,
    required this.installmentsPaise,
    required this.carryInPaise,
    required this.baselinePaise,
    required this.deltaPaise,
    required this.foodFloorPaise,
    required this.petrolFloorPaise,
    required this.shortfallPaise,
    required this.baseDailyPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_date'] = Variable<String>(startDate);
    map['expected_next_start'] = Variable<String>(expectedNextStart);
    if (!nullToAbsent || closedOn != null) {
      map['closed_on'] = Variable<String>(closedOn);
    }
    map['weights'] = Variable<String>(weights);
    map['installments_paise'] = Variable<int>(installmentsPaise);
    map['carry_in_paise'] = Variable<int>(carryInPaise);
    map['baseline_paise'] = Variable<int>(baselinePaise);
    map['delta_paise'] = Variable<int>(deltaPaise);
    map['food_floor_paise'] = Variable<int>(foodFloorPaise);
    map['petrol_floor_paise'] = Variable<int>(petrolFloorPaise);
    map['shortfall_paise'] = Variable<int>(shortfallPaise);
    map['base_daily_paise'] = Variable<int>(baseDailyPaise);
    return map;
  }

  CyclesCompanion toCompanion(bool nullToAbsent) {
    return CyclesCompanion(
      id: Value(id),
      startDate: Value(startDate),
      expectedNextStart: Value(expectedNextStart),
      closedOn: closedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(closedOn),
      weights: Value(weights),
      installmentsPaise: Value(installmentsPaise),
      carryInPaise: Value(carryInPaise),
      baselinePaise: Value(baselinePaise),
      deltaPaise: Value(deltaPaise),
      foodFloorPaise: Value(foodFloorPaise),
      petrolFloorPaise: Value(petrolFloorPaise),
      shortfallPaise: Value(shortfallPaise),
      baseDailyPaise: Value(baseDailyPaise),
    );
  }

  factory CycleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleRow(
      id: serializer.fromJson<int>(json['id']),
      startDate: serializer.fromJson<String>(json['startDate']),
      expectedNextStart: serializer.fromJson<String>(json['expectedNextStart']),
      closedOn: serializer.fromJson<String?>(json['closedOn']),
      weights: serializer.fromJson<String>(json['weights']),
      installmentsPaise: serializer.fromJson<int>(json['installmentsPaise']),
      carryInPaise: serializer.fromJson<int>(json['carryInPaise']),
      baselinePaise: serializer.fromJson<int>(json['baselinePaise']),
      deltaPaise: serializer.fromJson<int>(json['deltaPaise']),
      foodFloorPaise: serializer.fromJson<int>(json['foodFloorPaise']),
      petrolFloorPaise: serializer.fromJson<int>(json['petrolFloorPaise']),
      shortfallPaise: serializer.fromJson<int>(json['shortfallPaise']),
      baseDailyPaise: serializer.fromJson<int>(json['baseDailyPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startDate': serializer.toJson<String>(startDate),
      'expectedNextStart': serializer.toJson<String>(expectedNextStart),
      'closedOn': serializer.toJson<String?>(closedOn),
      'weights': serializer.toJson<String>(weights),
      'installmentsPaise': serializer.toJson<int>(installmentsPaise),
      'carryInPaise': serializer.toJson<int>(carryInPaise),
      'baselinePaise': serializer.toJson<int>(baselinePaise),
      'deltaPaise': serializer.toJson<int>(deltaPaise),
      'foodFloorPaise': serializer.toJson<int>(foodFloorPaise),
      'petrolFloorPaise': serializer.toJson<int>(petrolFloorPaise),
      'shortfallPaise': serializer.toJson<int>(shortfallPaise),
      'baseDailyPaise': serializer.toJson<int>(baseDailyPaise),
    };
  }

  CycleRow copyWith({
    int? id,
    String? startDate,
    String? expectedNextStart,
    Value<String?> closedOn = const Value.absent(),
    String? weights,
    int? installmentsPaise,
    int? carryInPaise,
    int? baselinePaise,
    int? deltaPaise,
    int? foodFloorPaise,
    int? petrolFloorPaise,
    int? shortfallPaise,
    int? baseDailyPaise,
  }) => CycleRow(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    expectedNextStart: expectedNextStart ?? this.expectedNextStart,
    closedOn: closedOn.present ? closedOn.value : this.closedOn,
    weights: weights ?? this.weights,
    installmentsPaise: installmentsPaise ?? this.installmentsPaise,
    carryInPaise: carryInPaise ?? this.carryInPaise,
    baselinePaise: baselinePaise ?? this.baselinePaise,
    deltaPaise: deltaPaise ?? this.deltaPaise,
    foodFloorPaise: foodFloorPaise ?? this.foodFloorPaise,
    petrolFloorPaise: petrolFloorPaise ?? this.petrolFloorPaise,
    shortfallPaise: shortfallPaise ?? this.shortfallPaise,
    baseDailyPaise: baseDailyPaise ?? this.baseDailyPaise,
  );
  CycleRow copyWithCompanion(CyclesCompanion data) {
    return CycleRow(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      expectedNextStart: data.expectedNextStart.present
          ? data.expectedNextStart.value
          : this.expectedNextStart,
      closedOn: data.closedOn.present ? data.closedOn.value : this.closedOn,
      weights: data.weights.present ? data.weights.value : this.weights,
      installmentsPaise: data.installmentsPaise.present
          ? data.installmentsPaise.value
          : this.installmentsPaise,
      carryInPaise: data.carryInPaise.present
          ? data.carryInPaise.value
          : this.carryInPaise,
      baselinePaise: data.baselinePaise.present
          ? data.baselinePaise.value
          : this.baselinePaise,
      deltaPaise: data.deltaPaise.present
          ? data.deltaPaise.value
          : this.deltaPaise,
      foodFloorPaise: data.foodFloorPaise.present
          ? data.foodFloorPaise.value
          : this.foodFloorPaise,
      petrolFloorPaise: data.petrolFloorPaise.present
          ? data.petrolFloorPaise.value
          : this.petrolFloorPaise,
      shortfallPaise: data.shortfallPaise.present
          ? data.shortfallPaise.value
          : this.shortfallPaise,
      baseDailyPaise: data.baseDailyPaise.present
          ? data.baseDailyPaise.value
          : this.baseDailyPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleRow(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('expectedNextStart: $expectedNextStart, ')
          ..write('closedOn: $closedOn, ')
          ..write('weights: $weights, ')
          ..write('installmentsPaise: $installmentsPaise, ')
          ..write('carryInPaise: $carryInPaise, ')
          ..write('baselinePaise: $baselinePaise, ')
          ..write('deltaPaise: $deltaPaise, ')
          ..write('foodFloorPaise: $foodFloorPaise, ')
          ..write('petrolFloorPaise: $petrolFloorPaise, ')
          ..write('shortfallPaise: $shortfallPaise, ')
          ..write('baseDailyPaise: $baseDailyPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startDate,
    expectedNextStart,
    closedOn,
    weights,
    installmentsPaise,
    carryInPaise,
    baselinePaise,
    deltaPaise,
    foodFloorPaise,
    petrolFloorPaise,
    shortfallPaise,
    baseDailyPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleRow &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.expectedNextStart == this.expectedNextStart &&
          other.closedOn == this.closedOn &&
          other.weights == this.weights &&
          other.installmentsPaise == this.installmentsPaise &&
          other.carryInPaise == this.carryInPaise &&
          other.baselinePaise == this.baselinePaise &&
          other.deltaPaise == this.deltaPaise &&
          other.foodFloorPaise == this.foodFloorPaise &&
          other.petrolFloorPaise == this.petrolFloorPaise &&
          other.shortfallPaise == this.shortfallPaise &&
          other.baseDailyPaise == this.baseDailyPaise);
}

class CyclesCompanion extends UpdateCompanion<CycleRow> {
  final Value<int> id;
  final Value<String> startDate;
  final Value<String> expectedNextStart;
  final Value<String?> closedOn;
  final Value<String> weights;
  final Value<int> installmentsPaise;
  final Value<int> carryInPaise;
  final Value<int> baselinePaise;
  final Value<int> deltaPaise;
  final Value<int> foodFloorPaise;
  final Value<int> petrolFloorPaise;
  final Value<int> shortfallPaise;
  final Value<int> baseDailyPaise;
  const CyclesCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.expectedNextStart = const Value.absent(),
    this.closedOn = const Value.absent(),
    this.weights = const Value.absent(),
    this.installmentsPaise = const Value.absent(),
    this.carryInPaise = const Value.absent(),
    this.baselinePaise = const Value.absent(),
    this.deltaPaise = const Value.absent(),
    this.foodFloorPaise = const Value.absent(),
    this.petrolFloorPaise = const Value.absent(),
    this.shortfallPaise = const Value.absent(),
    this.baseDailyPaise = const Value.absent(),
  });
  CyclesCompanion.insert({
    this.id = const Value.absent(),
    required String startDate,
    required String expectedNextStart,
    this.closedOn = const Value.absent(),
    required String weights,
    required int installmentsPaise,
    required int carryInPaise,
    required int baselinePaise,
    required int deltaPaise,
    required int foodFloorPaise,
    required int petrolFloorPaise,
    required int shortfallPaise,
    required int baseDailyPaise,
  }) : startDate = Value(startDate),
       expectedNextStart = Value(expectedNextStart),
       weights = Value(weights),
       installmentsPaise = Value(installmentsPaise),
       carryInPaise = Value(carryInPaise),
       baselinePaise = Value(baselinePaise),
       deltaPaise = Value(deltaPaise),
       foodFloorPaise = Value(foodFloorPaise),
       petrolFloorPaise = Value(petrolFloorPaise),
       shortfallPaise = Value(shortfallPaise),
       baseDailyPaise = Value(baseDailyPaise);
  static Insertable<CycleRow> custom({
    Expression<int>? id,
    Expression<String>? startDate,
    Expression<String>? expectedNextStart,
    Expression<String>? closedOn,
    Expression<String>? weights,
    Expression<int>? installmentsPaise,
    Expression<int>? carryInPaise,
    Expression<int>? baselinePaise,
    Expression<int>? deltaPaise,
    Expression<int>? foodFloorPaise,
    Expression<int>? petrolFloorPaise,
    Expression<int>? shortfallPaise,
    Expression<int>? baseDailyPaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (expectedNextStart != null) 'expected_next_start': expectedNextStart,
      if (closedOn != null) 'closed_on': closedOn,
      if (weights != null) 'weights': weights,
      if (installmentsPaise != null) 'installments_paise': installmentsPaise,
      if (carryInPaise != null) 'carry_in_paise': carryInPaise,
      if (baselinePaise != null) 'baseline_paise': baselinePaise,
      if (deltaPaise != null) 'delta_paise': deltaPaise,
      if (foodFloorPaise != null) 'food_floor_paise': foodFloorPaise,
      if (petrolFloorPaise != null) 'petrol_floor_paise': petrolFloorPaise,
      if (shortfallPaise != null) 'shortfall_paise': shortfallPaise,
      if (baseDailyPaise != null) 'base_daily_paise': baseDailyPaise,
    });
  }

  CyclesCompanion copyWith({
    Value<int>? id,
    Value<String>? startDate,
    Value<String>? expectedNextStart,
    Value<String?>? closedOn,
    Value<String>? weights,
    Value<int>? installmentsPaise,
    Value<int>? carryInPaise,
    Value<int>? baselinePaise,
    Value<int>? deltaPaise,
    Value<int>? foodFloorPaise,
    Value<int>? petrolFloorPaise,
    Value<int>? shortfallPaise,
    Value<int>? baseDailyPaise,
  }) {
    return CyclesCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      expectedNextStart: expectedNextStart ?? this.expectedNextStart,
      closedOn: closedOn ?? this.closedOn,
      weights: weights ?? this.weights,
      installmentsPaise: installmentsPaise ?? this.installmentsPaise,
      carryInPaise: carryInPaise ?? this.carryInPaise,
      baselinePaise: baselinePaise ?? this.baselinePaise,
      deltaPaise: deltaPaise ?? this.deltaPaise,
      foodFloorPaise: foodFloorPaise ?? this.foodFloorPaise,
      petrolFloorPaise: petrolFloorPaise ?? this.petrolFloorPaise,
      shortfallPaise: shortfallPaise ?? this.shortfallPaise,
      baseDailyPaise: baseDailyPaise ?? this.baseDailyPaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (expectedNextStart.present) {
      map['expected_next_start'] = Variable<String>(expectedNextStart.value);
    }
    if (closedOn.present) {
      map['closed_on'] = Variable<String>(closedOn.value);
    }
    if (weights.present) {
      map['weights'] = Variable<String>(weights.value);
    }
    if (installmentsPaise.present) {
      map['installments_paise'] = Variable<int>(installmentsPaise.value);
    }
    if (carryInPaise.present) {
      map['carry_in_paise'] = Variable<int>(carryInPaise.value);
    }
    if (baselinePaise.present) {
      map['baseline_paise'] = Variable<int>(baselinePaise.value);
    }
    if (deltaPaise.present) {
      map['delta_paise'] = Variable<int>(deltaPaise.value);
    }
    if (foodFloorPaise.present) {
      map['food_floor_paise'] = Variable<int>(foodFloorPaise.value);
    }
    if (petrolFloorPaise.present) {
      map['petrol_floor_paise'] = Variable<int>(petrolFloorPaise.value);
    }
    if (shortfallPaise.present) {
      map['shortfall_paise'] = Variable<int>(shortfallPaise.value);
    }
    if (baseDailyPaise.present) {
      map['base_daily_paise'] = Variable<int>(baseDailyPaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclesCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('expectedNextStart: $expectedNextStart, ')
          ..write('closedOn: $closedOn, ')
          ..write('weights: $weights, ')
          ..write('installmentsPaise: $installmentsPaise, ')
          ..write('carryInPaise: $carryInPaise, ')
          ..write('baselinePaise: $baselinePaise, ')
          ..write('deltaPaise: $deltaPaise, ')
          ..write('foodFloorPaise: $foodFloorPaise, ')
          ..write('petrolFloorPaise: $petrolFloorPaise, ')
          ..write('shortfallPaise: $shortfallPaise, ')
          ..write('baseDailyPaise: $baseDailyPaise')
          ..write(')'))
        .toString();
  }
}

class $AllocationsTable extends Allocations
    with TableInfo<$AllocationsTable, AllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    category,
    amountPaise,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $AllocationsTable createAlias(String alias) {
    return $AllocationsTable(attachedDatabase, alias);
  }
}

class AllocationRow extends DataClass implements Insertable<AllocationRow> {
  final int id;
  final int cycleId;
  final String category;
  final int amountPaise;
  final String kind;
  const AllocationRow({
    required this.id,
    required this.cycleId,
    required this.category,
    required this.amountPaise,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['category'] = Variable<String>(category);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  AllocationsCompanion toCompanion(bool nullToAbsent) {
    return AllocationsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      category: Value(category),
      amountPaise: Value(amountPaise),
      kind: Value(kind),
    );
  }

  factory AllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationRow(
      id: serializer.fromJson<int>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      category: serializer.fromJson<String>(json['category']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'category': serializer.toJson<String>(category),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'kind': serializer.toJson<String>(kind),
    };
  }

  AllocationRow copyWith({
    int? id,
    int? cycleId,
    String? category,
    int? amountPaise,
    String? kind,
  }) => AllocationRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    category: category ?? this.category,
    amountPaise: amountPaise ?? this.amountPaise,
    kind: kind ?? this.kind,
  );
  AllocationRow copyWithCompanion(AllocationsCompanion data) {
    return AllocationRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      category: data.category.present ? data.category.value : this.category,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleId, category, amountPaise, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.category == this.category &&
          other.amountPaise == this.amountPaise &&
          other.kind == this.kind);
}

class AllocationsCompanion extends UpdateCompanion<AllocationRow> {
  final Value<int> id;
  final Value<int> cycleId;
  final Value<String> category;
  final Value<int> amountPaise;
  final Value<String> kind;
  const AllocationsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.category = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.kind = const Value.absent(),
  });
  AllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int cycleId,
    required String category,
    required int amountPaise,
    required String kind,
  }) : cycleId = Value(cycleId),
       category = Value(category),
       amountPaise = Value(amountPaise),
       kind = Value(kind);
  static Insertable<AllocationRow> custom({
    Expression<int>? id,
    Expression<int>? cycleId,
    Expression<String>? category,
    Expression<int>? amountPaise,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (category != null) 'category': category,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (kind != null) 'kind': kind,
    });
  }

  AllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleId,
    Value<String>? category,
    Value<int>? amountPaise,
    Value<String>? kind,
  }) {
    return AllocationsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllocationsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $DepositsTable extends Deposits
    with TableInfo<$DepositsTable, DepositRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepositsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    amountPaise,
    receivedAt,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deposits';
  @override
  VerificationContext validateIntegrity(
    Insertable<DepositRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DepositRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DepositRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $DepositsTable createAlias(String alias) {
    return $DepositsTable(attachedDatabase, alias);
  }
}

class DepositRow extends DataClass implements Insertable<DepositRow> {
  final String id;
  final int cycleId;
  final int amountPaise;
  final int receivedAt;
  final String kind;
  const DepositRow({
    required this.id,
    required this.cycleId,
    required this.amountPaise,
    required this.receivedAt,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['received_at'] = Variable<int>(receivedAt);
    map['kind'] = Variable<String>(kind);
    return map;
  }

  DepositsCompanion toCompanion(bool nullToAbsent) {
    return DepositsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      amountPaise: Value(amountPaise),
      receivedAt: Value(receivedAt),
      kind: Value(kind),
    );
  }

  factory DepositRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DepositRow(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'kind': serializer.toJson<String>(kind),
    };
  }

  DepositRow copyWith({
    String? id,
    int? cycleId,
    int? amountPaise,
    int? receivedAt,
    String? kind,
  }) => DepositRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    amountPaise: amountPaise ?? this.amountPaise,
    receivedAt: receivedAt ?? this.receivedAt,
    kind: kind ?? this.kind,
  );
  DepositRow copyWithCompanion(DepositsCompanion data) {
    return DepositRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DepositRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleId, amountPaise, receivedAt, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DepositRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.amountPaise == this.amountPaise &&
          other.receivedAt == this.receivedAt &&
          other.kind == this.kind);
}

class DepositsCompanion extends UpdateCompanion<DepositRow> {
  final Value<String> id;
  final Value<int> cycleId;
  final Value<int> amountPaise;
  final Value<int> receivedAt;
  final Value<String> kind;
  final Value<int> rowid;
  const DepositsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DepositsCompanion.insert({
    required String id,
    required int cycleId,
    required int amountPaise,
    required int receivedAt,
    required String kind,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       amountPaise = Value(amountPaise),
       receivedAt = Value(receivedAt),
       kind = Value(kind);
  static Insertable<DepositRow> custom({
    Expression<String>? id,
    Expression<int>? cycleId,
    Expression<int>? amountPaise,
    Expression<int>? receivedAt,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (receivedAt != null) 'received_at': receivedAt,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DepositsCompanion copyWith({
    Value<String>? id,
    Value<int>? cycleId,
    Value<int>? amountPaise,
    Value<int>? receivedAt,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return DepositsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      amountPaise: amountPaise ?? this.amountPaise,
      receivedAt: receivedAt ?? this.receivedAt,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepositsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    amountPaise,
    category,
    method,
    occurredAt,
    note,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final int cycleId;
  final int amountPaise;
  final String category;
  final String method;
  final int occurredAt;
  final String note;
  final String source;
  const TransactionRow({
    required this.id,
    required this.cycleId,
    required this.amountPaise,
    required this.category,
    required this.method,
    required this.occurredAt,
    required this.note,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category'] = Variable<String>(category);
    map['method'] = Variable<String>(method);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['note'] = Variable<String>(note);
    map['source'] = Variable<String>(source);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      amountPaise: Value(amountPaise),
      category: Value(category),
      method: Value(method),
      occurredAt: Value(occurredAt),
      note: Value(note),
      source: Value(source),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      category: serializer.fromJson<String>(json['category']),
      method: serializer.fromJson<String>(json['method']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      note: serializer.fromJson<String>(json['note']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'category': serializer.toJson<String>(category),
      'method': serializer.toJson<String>(method),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'note': serializer.toJson<String>(note),
      'source': serializer.toJson<String>(source),
    };
  }

  TransactionRow copyWith({
    String? id,
    int? cycleId,
    int? amountPaise,
    String? category,
    String? method,
    int? occurredAt,
    String? note,
    String? source,
  }) => TransactionRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    amountPaise: amountPaise ?? this.amountPaise,
    category: category ?? this.category,
    method: method ?? this.method,
    occurredAt: occurredAt ?? this.occurredAt,
    note: note ?? this.note,
    source: source ?? this.source,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      category: data.category.present ? data.category.value : this.category,
      method: data.method.present ? data.method.value : this.method,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('method: $method, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    amountPaise,
    category,
    method,
    occurredAt,
    note,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.amountPaise == this.amountPaise &&
          other.category == this.category &&
          other.method == this.method &&
          other.occurredAt == this.occurredAt &&
          other.note == this.note &&
          other.source == this.source);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<int> cycleId;
  final Value<int> amountPaise;
  final Value<String> category;
  final Value<String> method;
  final Value<int> occurredAt;
  final Value<String> note;
  final Value<String> source;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.category = const Value.absent(),
    this.method = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int cycleId,
    required int amountPaise,
    required String category,
    required String method,
    required int occurredAt,
    required String note,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       amountPaise = Value(amountPaise),
       category = Value(category),
       method = Value(method),
       occurredAt = Value(occurredAt),
       note = Value(note),
       source = Value(source);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<int>? cycleId,
    Expression<int>? amountPaise,
    Expression<String>? category,
    Expression<String>? method,
    Expression<int>? occurredAt,
    Expression<String>? note,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (category != null) 'category': category,
      if (method != null) 'method': method,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? cycleId,
    Value<int>? amountPaise,
    Value<String>? category,
    Value<String>? method,
    Value<int>? occurredAt,
    Value<String>? note,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      amountPaise: amountPaise ?? this.amountPaise,
      category: category ?? this.category,
      method: method ?? this.method,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('method: $method, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdjustmentsTable extends Adjustments
    with TableInfo<$AdjustmentsTable, AdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromCategoryMeta = const VerificationMeta(
    'fromCategory',
  );
  @override
  late final GeneratedColumn<String> fromCategory = GeneratedColumn<String>(
    'from_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toCategoryMeta = const VerificationMeta(
    'toCategory',
  );
  @override
  late final GeneratedColumn<String> toCategory = GeneratedColumn<String>(
    'to_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoMeta = const VerificationMeta('auto');
  @override
  late final GeneratedColumn<bool> auto = GeneratedColumn<bool>(
    'auto',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto" IN (0, 1))',
    ),
  );
  static const VerificationMeta _undoneMeta = const VerificationMeta('undone');
  @override
  late final GeneratedColumn<bool> undone = GeneratedColumn<bool>(
    'undone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("undone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    batchId,
    fromCategory,
    toCategory,
    amountPaise,
    reason,
    createdAt,
    auto,
    undone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdjustmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('from_category')) {
      context.handle(
        _fromCategoryMeta,
        fromCategory.isAcceptableOrUnknown(
          data['from_category']!,
          _fromCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromCategoryMeta);
    }
    if (data.containsKey('to_category')) {
      context.handle(
        _toCategoryMeta,
        toCategory.isAcceptableOrUnknown(data['to_category']!, _toCategoryMeta),
      );
    } else if (isInserting) {
      context.missing(_toCategoryMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('auto')) {
      context.handle(
        _autoMeta,
        auto.isAcceptableOrUnknown(data['auto']!, _autoMeta),
      );
    } else if (isInserting) {
      context.missing(_autoMeta);
    }
    if (data.containsKey('undone')) {
      context.handle(
        _undoneMeta,
        undone.isAcceptableOrUnknown(data['undone']!, _undoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdjustmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      fromCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_category'],
      )!,
      toCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_category'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      auto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto'],
      )!,
      undone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}undone'],
      )!,
    );
  }

  @override
  $AdjustmentsTable createAlias(String alias) {
    return $AdjustmentsTable(attachedDatabase, alias);
  }
}

class AdjustmentRow extends DataClass implements Insertable<AdjustmentRow> {
  final String id;
  final int cycleId;
  final String batchId;
  final String fromCategory;
  final String toCategory;
  final int amountPaise;
  final String reason;
  final int createdAt;
  final bool auto;
  final bool undone;
  const AdjustmentRow({
    required this.id,
    required this.cycleId,
    required this.batchId,
    required this.fromCategory,
    required this.toCategory,
    required this.amountPaise,
    required this.reason,
    required this.createdAt,
    required this.auto,
    required this.undone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['batch_id'] = Variable<String>(batchId);
    map['from_category'] = Variable<String>(fromCategory);
    map['to_category'] = Variable<String>(toCategory);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<int>(createdAt);
    map['auto'] = Variable<bool>(auto);
    map['undone'] = Variable<bool>(undone);
    return map;
  }

  AdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return AdjustmentsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      batchId: Value(batchId),
      fromCategory: Value(fromCategory),
      toCategory: Value(toCategory),
      amountPaise: Value(amountPaise),
      reason: Value(reason),
      createdAt: Value(createdAt),
      auto: Value(auto),
      undone: Value(undone),
    );
  }

  factory AdjustmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdjustmentRow(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      fromCategory: serializer.fromJson<String>(json['fromCategory']),
      toCategory: serializer.fromJson<String>(json['toCategory']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      auto: serializer.fromJson<bool>(json['auto']),
      undone: serializer.fromJson<bool>(json['undone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'batchId': serializer.toJson<String>(batchId),
      'fromCategory': serializer.toJson<String>(fromCategory),
      'toCategory': serializer.toJson<String>(toCategory),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<int>(createdAt),
      'auto': serializer.toJson<bool>(auto),
      'undone': serializer.toJson<bool>(undone),
    };
  }

  AdjustmentRow copyWith({
    String? id,
    int? cycleId,
    String? batchId,
    String? fromCategory,
    String? toCategory,
    int? amountPaise,
    String? reason,
    int? createdAt,
    bool? auto,
    bool? undone,
  }) => AdjustmentRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    batchId: batchId ?? this.batchId,
    fromCategory: fromCategory ?? this.fromCategory,
    toCategory: toCategory ?? this.toCategory,
    amountPaise: amountPaise ?? this.amountPaise,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
    auto: auto ?? this.auto,
    undone: undone ?? this.undone,
  );
  AdjustmentRow copyWithCompanion(AdjustmentsCompanion data) {
    return AdjustmentRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      fromCategory: data.fromCategory.present
          ? data.fromCategory.value
          : this.fromCategory,
      toCategory: data.toCategory.present
          ? data.toCategory.value
          : this.toCategory,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      auto: data.auto.present ? data.auto.value : this.auto,
      undone: data.undone.present ? data.undone.value : this.undone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('batchId: $batchId, ')
          ..write('fromCategory: $fromCategory, ')
          ..write('toCategory: $toCategory, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('auto: $auto, ')
          ..write('undone: $undone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    batchId,
    fromCategory,
    toCategory,
    amountPaise,
    reason,
    createdAt,
    auto,
    undone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdjustmentRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.batchId == this.batchId &&
          other.fromCategory == this.fromCategory &&
          other.toCategory == this.toCategory &&
          other.amountPaise == this.amountPaise &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.auto == this.auto &&
          other.undone == this.undone);
}

class AdjustmentsCompanion extends UpdateCompanion<AdjustmentRow> {
  final Value<String> id;
  final Value<int> cycleId;
  final Value<String> batchId;
  final Value<String> fromCategory;
  final Value<String> toCategory;
  final Value<int> amountPaise;
  final Value<String> reason;
  final Value<int> createdAt;
  final Value<bool> auto;
  final Value<bool> undone;
  final Value<int> rowid;
  const AdjustmentsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.fromCategory = const Value.absent(),
    this.toCategory = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.auto = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdjustmentsCompanion.insert({
    required String id,
    required int cycleId,
    required String batchId,
    required String fromCategory,
    required String toCategory,
    required int amountPaise,
    required String reason,
    required int createdAt,
    required bool auto,
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       batchId = Value(batchId),
       fromCategory = Value(fromCategory),
       toCategory = Value(toCategory),
       amountPaise = Value(amountPaise),
       reason = Value(reason),
       createdAt = Value(createdAt),
       auto = Value(auto);
  static Insertable<AdjustmentRow> custom({
    Expression<String>? id,
    Expression<int>? cycleId,
    Expression<String>? batchId,
    Expression<String>? fromCategory,
    Expression<String>? toCategory,
    Expression<int>? amountPaise,
    Expression<String>? reason,
    Expression<int>? createdAt,
    Expression<bool>? auto,
    Expression<bool>? undone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (batchId != null) 'batch_id': batchId,
      if (fromCategory != null) 'from_category': fromCategory,
      if (toCategory != null) 'to_category': toCategory,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (auto != null) 'auto': auto,
      if (undone != null) 'undone': undone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? cycleId,
    Value<String>? batchId,
    Value<String>? fromCategory,
    Value<String>? toCategory,
    Value<int>? amountPaise,
    Value<String>? reason,
    Value<int>? createdAt,
    Value<bool>? auto,
    Value<bool>? undone,
    Value<int>? rowid,
  }) {
    return AdjustmentsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      batchId: batchId ?? this.batchId,
      fromCategory: fromCategory ?? this.fromCategory,
      toCategory: toCategory ?? this.toCategory,
      amountPaise: amountPaise ?? this.amountPaise,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      auto: auto ?? this.auto,
      undone: undone ?? this.undone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (fromCategory.present) {
      map['from_category'] = Variable<String>(fromCategory.value);
    }
    if (toCategory.present) {
      map['to_category'] = Variable<String>(toCategory.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (auto.present) {
      map['auto'] = Variable<bool>(auto.value);
    }
    if (undone.present) {
      map['undone'] = Variable<bool>(undone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('batchId: $batchId, ')
          ..write('fromCategory: $fromCategory, ')
          ..write('toCategory: $toCategory, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('auto: $auto, ')
          ..write('undone: $undone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldsTable extends Holds with TableInfo<$HoldsTable, HoldRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commitmentIdMeta = const VerificationMeta(
    'commitmentId',
  );
  @override
  late final GeneratedColumn<String> commitmentId = GeneratedColumn<String>(
    'commitment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _undoneMeta = const VerificationMeta('undone');
  @override
  late final GeneratedColumn<bool> undone = GeneratedColumn<bool>(
    'undone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("undone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    batchId,
    commitmentId,
    category,
    amountPaise,
    createdAt,
    undone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holds';
  @override
  VerificationContext validateIntegrity(
    Insertable<HoldRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('commitment_id')) {
      context.handle(
        _commitmentIdMeta,
        commitmentId.isAcceptableOrUnknown(
          data['commitment_id']!,
          _commitmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commitmentIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('undone')) {
      context.handle(
        _undoneMeta,
        undone.isAcceptableOrUnknown(data['undone']!, _undoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HoldRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HoldRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      commitmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commitment_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      undone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}undone'],
      )!,
    );
  }

  @override
  $HoldsTable createAlias(String alias) {
    return $HoldsTable(attachedDatabase, alias);
  }
}

class HoldRow extends DataClass implements Insertable<HoldRow> {
  final String id;
  final int cycleId;
  final String batchId;
  final String commitmentId;
  final String category;
  final int amountPaise;
  final int createdAt;
  final bool undone;
  const HoldRow({
    required this.id,
    required this.cycleId,
    required this.batchId,
    required this.commitmentId,
    required this.category,
    required this.amountPaise,
    required this.createdAt,
    required this.undone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['batch_id'] = Variable<String>(batchId);
    map['commitment_id'] = Variable<String>(commitmentId);
    map['category'] = Variable<String>(category);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['created_at'] = Variable<int>(createdAt);
    map['undone'] = Variable<bool>(undone);
    return map;
  }

  HoldsCompanion toCompanion(bool nullToAbsent) {
    return HoldsCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      batchId: Value(batchId),
      commitmentId: Value(commitmentId),
      category: Value(category),
      amountPaise: Value(amountPaise),
      createdAt: Value(createdAt),
      undone: Value(undone),
    );
  }

  factory HoldRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HoldRow(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      commitmentId: serializer.fromJson<String>(json['commitmentId']),
      category: serializer.fromJson<String>(json['category']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      undone: serializer.fromJson<bool>(json['undone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'batchId': serializer.toJson<String>(batchId),
      'commitmentId': serializer.toJson<String>(commitmentId),
      'category': serializer.toJson<String>(category),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'createdAt': serializer.toJson<int>(createdAt),
      'undone': serializer.toJson<bool>(undone),
    };
  }

  HoldRow copyWith({
    String? id,
    int? cycleId,
    String? batchId,
    String? commitmentId,
    String? category,
    int? amountPaise,
    int? createdAt,
    bool? undone,
  }) => HoldRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    batchId: batchId ?? this.batchId,
    commitmentId: commitmentId ?? this.commitmentId,
    category: category ?? this.category,
    amountPaise: amountPaise ?? this.amountPaise,
    createdAt: createdAt ?? this.createdAt,
    undone: undone ?? this.undone,
  );
  HoldRow copyWithCompanion(HoldsCompanion data) {
    return HoldRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      commitmentId: data.commitmentId.present
          ? data.commitmentId.value
          : this.commitmentId,
      category: data.category.present ? data.category.value : this.category,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      undone: data.undone.present ? data.undone.value : this.undone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HoldRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('batchId: $batchId, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('undone: $undone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    batchId,
    commitmentId,
    category,
    amountPaise,
    createdAt,
    undone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.batchId == this.batchId &&
          other.commitmentId == this.commitmentId &&
          other.category == this.category &&
          other.amountPaise == this.amountPaise &&
          other.createdAt == this.createdAt &&
          other.undone == this.undone);
}

class HoldsCompanion extends UpdateCompanion<HoldRow> {
  final Value<String> id;
  final Value<int> cycleId;
  final Value<String> batchId;
  final Value<String> commitmentId;
  final Value<String> category;
  final Value<int> amountPaise;
  final Value<int> createdAt;
  final Value<bool> undone;
  final Value<int> rowid;
  const HoldsCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.commitmentId = const Value.absent(),
    this.category = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HoldsCompanion.insert({
    required String id,
    required int cycleId,
    required String batchId,
    required String commitmentId,
    required String category,
    required int amountPaise,
    required int createdAt,
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       batchId = Value(batchId),
       commitmentId = Value(commitmentId),
       category = Value(category),
       amountPaise = Value(amountPaise),
       createdAt = Value(createdAt);
  static Insertable<HoldRow> custom({
    Expression<String>? id,
    Expression<int>? cycleId,
    Expression<String>? batchId,
    Expression<String>? commitmentId,
    Expression<String>? category,
    Expression<int>? amountPaise,
    Expression<int>? createdAt,
    Expression<bool>? undone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (batchId != null) 'batch_id': batchId,
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (category != null) 'category': category,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (createdAt != null) 'created_at': createdAt,
      if (undone != null) 'undone': undone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HoldsCompanion copyWith({
    Value<String>? id,
    Value<int>? cycleId,
    Value<String>? batchId,
    Value<String>? commitmentId,
    Value<String>? category,
    Value<int>? amountPaise,
    Value<int>? createdAt,
    Value<bool>? undone,
    Value<int>? rowid,
  }) {
    return HoldsCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      batchId: batchId ?? this.batchId,
      commitmentId: commitmentId ?? this.commitmentId,
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      createdAt: createdAt ?? this.createdAt,
      undone: undone ?? this.undone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (commitmentId.present) {
      map['commitment_id'] = Variable<String>(commitmentId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (undone.present) {
      map['undone'] = Variable<bool>(undone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldsCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('batchId: $batchId, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('undone: $undone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, BatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycles (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movedPaiseMeta = const VerificationMeta(
    'movedPaise',
  );
  @override
  late final GeneratedColumn<int> movedPaise = GeneratedColumn<int>(
    'moved_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heldPaiseMeta = const VerificationMeta(
    'heldPaise',
  );
  @override
  late final GeneratedColumn<int> heldPaise = GeneratedColumn<int>(
    'held_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortfallPaiseMeta = const VerificationMeta(
    'shortfallPaise',
  );
  @override
  late final GeneratedColumn<int> shortfallPaise = GeneratedColumn<int>(
    'shortfall_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetsMeta = const VerificationMeta(
    'targets',
  );
  @override
  late final GeneratedColumn<String> targets = GeneratedColumn<String>(
    'targets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestReplanMeta = const VerificationMeta(
    'suggestReplan',
  );
  @override
  late final GeneratedColumn<bool> suggestReplan = GeneratedColumn<bool>(
    'suggest_replan',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("suggest_replan" IN (0, 1))',
    ),
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _undoneMeta = const VerificationMeta('undone');
  @override
  late final GeneratedColumn<bool> undone = GeneratedColumn<bool>(
    'undone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("undone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleId,
    kind,
    createdAt,
    movedPaise,
    heldPaise,
    shortfallPaise,
    targets,
    suggestReplan,
    seen,
    undone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('moved_paise')) {
      context.handle(
        _movedPaiseMeta,
        movedPaise.isAcceptableOrUnknown(data['moved_paise']!, _movedPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_movedPaiseMeta);
    }
    if (data.containsKey('held_paise')) {
      context.handle(
        _heldPaiseMeta,
        heldPaise.isAcceptableOrUnknown(data['held_paise']!, _heldPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_heldPaiseMeta);
    }
    if (data.containsKey('shortfall_paise')) {
      context.handle(
        _shortfallPaiseMeta,
        shortfallPaise.isAcceptableOrUnknown(
          data['shortfall_paise']!,
          _shortfallPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shortfallPaiseMeta);
    }
    if (data.containsKey('targets')) {
      context.handle(
        _targetsMeta,
        targets.isAcceptableOrUnknown(data['targets']!, _targetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetsMeta);
    }
    if (data.containsKey('suggest_replan')) {
      context.handle(
        _suggestReplanMeta,
        suggestReplan.isAcceptableOrUnknown(
          data['suggest_replan']!,
          _suggestReplanMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suggestReplanMeta);
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    if (data.containsKey('undone')) {
      context.handle(
        _undoneMeta,
        undone.isAcceptableOrUnknown(data['undone']!, _undoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      movedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moved_paise'],
      )!,
      heldPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}held_paise'],
      )!,
      shortfallPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shortfall_paise'],
      )!,
      targets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}targets'],
      )!,
      suggestReplan: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}suggest_replan'],
      )!,
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
      undone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}undone'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class BatchRow extends DataClass implements Insertable<BatchRow> {
  final String id;
  final int cycleId;
  final String kind;
  final int createdAt;
  final int movedPaise;
  final int heldPaise;
  final int shortfallPaise;
  final String targets;
  final bool suggestReplan;
  final bool seen;
  final bool undone;
  const BatchRow({
    required this.id,
    required this.cycleId,
    required this.kind,
    required this.createdAt,
    required this.movedPaise,
    required this.heldPaise,
    required this.shortfallPaise,
    required this.targets,
    required this.suggestReplan,
    required this.seen,
    required this.undone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<int>(cycleId);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<int>(createdAt);
    map['moved_paise'] = Variable<int>(movedPaise);
    map['held_paise'] = Variable<int>(heldPaise);
    map['shortfall_paise'] = Variable<int>(shortfallPaise);
    map['targets'] = Variable<String>(targets);
    map['suggest_replan'] = Variable<bool>(suggestReplan);
    map['seen'] = Variable<bool>(seen);
    map['undone'] = Variable<bool>(undone);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      kind: Value(kind),
      createdAt: Value(createdAt),
      movedPaise: Value(movedPaise),
      heldPaise: Value(heldPaise),
      shortfallPaise: Value(shortfallPaise),
      targets: Value(targets),
      suggestReplan: Value(suggestReplan),
      seen: Value(seen),
      undone: Value(undone),
    );
  }

  factory BatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchRow(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<int>(json['cycleId']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      movedPaise: serializer.fromJson<int>(json['movedPaise']),
      heldPaise: serializer.fromJson<int>(json['heldPaise']),
      shortfallPaise: serializer.fromJson<int>(json['shortfallPaise']),
      targets: serializer.fromJson<String>(json['targets']),
      suggestReplan: serializer.fromJson<bool>(json['suggestReplan']),
      seen: serializer.fromJson<bool>(json['seen']),
      undone: serializer.fromJson<bool>(json['undone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<int>(cycleId),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<int>(createdAt),
      'movedPaise': serializer.toJson<int>(movedPaise),
      'heldPaise': serializer.toJson<int>(heldPaise),
      'shortfallPaise': serializer.toJson<int>(shortfallPaise),
      'targets': serializer.toJson<String>(targets),
      'suggestReplan': serializer.toJson<bool>(suggestReplan),
      'seen': serializer.toJson<bool>(seen),
      'undone': serializer.toJson<bool>(undone),
    };
  }

  BatchRow copyWith({
    String? id,
    int? cycleId,
    String? kind,
    int? createdAt,
    int? movedPaise,
    int? heldPaise,
    int? shortfallPaise,
    String? targets,
    bool? suggestReplan,
    bool? seen,
    bool? undone,
  }) => BatchRow(
    id: id ?? this.id,
    cycleId: cycleId ?? this.cycleId,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
    movedPaise: movedPaise ?? this.movedPaise,
    heldPaise: heldPaise ?? this.heldPaise,
    shortfallPaise: shortfallPaise ?? this.shortfallPaise,
    targets: targets ?? this.targets,
    suggestReplan: suggestReplan ?? this.suggestReplan,
    seen: seen ?? this.seen,
    undone: undone ?? this.undone,
  );
  BatchRow copyWithCompanion(BatchesCompanion data) {
    return BatchRow(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      movedPaise: data.movedPaise.present
          ? data.movedPaise.value
          : this.movedPaise,
      heldPaise: data.heldPaise.present ? data.heldPaise.value : this.heldPaise,
      shortfallPaise: data.shortfallPaise.present
          ? data.shortfallPaise.value
          : this.shortfallPaise,
      targets: data.targets.present ? data.targets.value : this.targets,
      suggestReplan: data.suggestReplan.present
          ? data.suggestReplan.value
          : this.suggestReplan,
      seen: data.seen.present ? data.seen.value : this.seen,
      undone: data.undone.present ? data.undone.value : this.undone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchRow(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('movedPaise: $movedPaise, ')
          ..write('heldPaise: $heldPaise, ')
          ..write('shortfallPaise: $shortfallPaise, ')
          ..write('targets: $targets, ')
          ..write('suggestReplan: $suggestReplan, ')
          ..write('seen: $seen, ')
          ..write('undone: $undone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cycleId,
    kind,
    createdAt,
    movedPaise,
    heldPaise,
    shortfallPaise,
    targets,
    suggestReplan,
    seen,
    undone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchRow &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt &&
          other.movedPaise == this.movedPaise &&
          other.heldPaise == this.heldPaise &&
          other.shortfallPaise == this.shortfallPaise &&
          other.targets == this.targets &&
          other.suggestReplan == this.suggestReplan &&
          other.seen == this.seen &&
          other.undone == this.undone);
}

class BatchesCompanion extends UpdateCompanion<BatchRow> {
  final Value<String> id;
  final Value<int> cycleId;
  final Value<String> kind;
  final Value<int> createdAt;
  final Value<int> movedPaise;
  final Value<int> heldPaise;
  final Value<int> shortfallPaise;
  final Value<String> targets;
  final Value<bool> suggestReplan;
  final Value<bool> seen;
  final Value<bool> undone;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.movedPaise = const Value.absent(),
    this.heldPaise = const Value.absent(),
    this.shortfallPaise = const Value.absent(),
    this.targets = const Value.absent(),
    this.suggestReplan = const Value.absent(),
    this.seen = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required int cycleId,
    required String kind,
    required int createdAt,
    required int movedPaise,
    required int heldPaise,
    required int shortfallPaise,
    required String targets,
    required bool suggestReplan,
    this.seen = const Value.absent(),
    this.undone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cycleId = Value(cycleId),
       kind = Value(kind),
       createdAt = Value(createdAt),
       movedPaise = Value(movedPaise),
       heldPaise = Value(heldPaise),
       shortfallPaise = Value(shortfallPaise),
       targets = Value(targets),
       suggestReplan = Value(suggestReplan);
  static Insertable<BatchRow> custom({
    Expression<String>? id,
    Expression<int>? cycleId,
    Expression<String>? kind,
    Expression<int>? createdAt,
    Expression<int>? movedPaise,
    Expression<int>? heldPaise,
    Expression<int>? shortfallPaise,
    Expression<String>? targets,
    Expression<bool>? suggestReplan,
    Expression<bool>? seen,
    Expression<bool>? undone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (movedPaise != null) 'moved_paise': movedPaise,
      if (heldPaise != null) 'held_paise': heldPaise,
      if (shortfallPaise != null) 'shortfall_paise': shortfallPaise,
      if (targets != null) 'targets': targets,
      if (suggestReplan != null) 'suggest_replan': suggestReplan,
      if (seen != null) 'seen': seen,
      if (undone != null) 'undone': undone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<int>? cycleId,
    Value<String>? kind,
    Value<int>? createdAt,
    Value<int>? movedPaise,
    Value<int>? heldPaise,
    Value<int>? shortfallPaise,
    Value<String>? targets,
    Value<bool>? suggestReplan,
    Value<bool>? seen,
    Value<bool>? undone,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      movedPaise: movedPaise ?? this.movedPaise,
      heldPaise: heldPaise ?? this.heldPaise,
      shortfallPaise: shortfallPaise ?? this.shortfallPaise,
      targets: targets ?? this.targets,
      suggestReplan: suggestReplan ?? this.suggestReplan,
      seen: seen ?? this.seen,
      undone: undone ?? this.undone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (movedPaise.present) {
      map['moved_paise'] = Variable<int>(movedPaise.value);
    }
    if (heldPaise.present) {
      map['held_paise'] = Variable<int>(heldPaise.value);
    }
    if (shortfallPaise.present) {
      map['shortfall_paise'] = Variable<int>(shortfallPaise.value);
    }
    if (targets.present) {
      map['targets'] = Variable<String>(targets.value);
    }
    if (suggestReplan.present) {
      map['suggest_replan'] = Variable<bool>(suggestReplan.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (undone.present) {
      map['undone'] = Variable<bool>(undone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('movedPaise: $movedPaise, ')
          ..write('heldPaise: $heldPaise, ')
          ..write('shortfallPaise: $shortfallPaise, ')
          ..write('targets: $targets, ')
          ..write('suggestReplan: $suggestReplan, ')
          ..write('seen: $seen, ')
          ..write('undone: $undone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplyItemsTable extends SupplyItems
    with TableInfo<$SupplyItemsTable, SupplyItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplyItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePaiseMeta = const VerificationMeta(
    'pricePaise',
  );
  @override
  late final GeneratedColumn<int> pricePaise = GeneratedColumn<int>(
    'price_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifespanDaysMeta = const VerificationMeta(
    'lifespanDays',
  );
  @override
  late final GeneratedColumn<int> lifespanDays = GeneratedColumn<int>(
    'lifespan_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRestockMeta = const VerificationMeta(
    'lastRestock',
  );
  @override
  late final GeneratedColumn<String> lastRestock = GeneratedColumn<String>(
    'last_restock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    pricePaise,
    lifespanDays,
    lastRestock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supply_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplyItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_paise')) {
      context.handle(
        _pricePaiseMeta,
        pricePaise.isAcceptableOrUnknown(data['price_paise']!, _pricePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_pricePaiseMeta);
    }
    if (data.containsKey('lifespan_days')) {
      context.handle(
        _lifespanDaysMeta,
        lifespanDays.isAcceptableOrUnknown(
          data['lifespan_days']!,
          _lifespanDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lifespanDaysMeta);
    }
    if (data.containsKey('last_restock')) {
      context.handle(
        _lastRestockMeta,
        lastRestock.isAcceptableOrUnknown(
          data['last_restock']!,
          _lastRestockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastRestockMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplyItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplyItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pricePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_paise'],
      )!,
      lifespanDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifespan_days'],
      )!,
      lastRestock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_restock'],
      )!,
    );
  }

  @override
  $SupplyItemsTable createAlias(String alias) {
    return $SupplyItemsTable(attachedDatabase, alias);
  }
}

class SupplyItemRow extends DataClass implements Insertable<SupplyItemRow> {
  final String id;
  final String name;
  final int pricePaise;
  final int lifespanDays;
  final String lastRestock;
  const SupplyItemRow({
    required this.id,
    required this.name,
    required this.pricePaise,
    required this.lifespanDays,
    required this.lastRestock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price_paise'] = Variable<int>(pricePaise);
    map['lifespan_days'] = Variable<int>(lifespanDays);
    map['last_restock'] = Variable<String>(lastRestock);
    return map;
  }

  SupplyItemsCompanion toCompanion(bool nullToAbsent) {
    return SupplyItemsCompanion(
      id: Value(id),
      name: Value(name),
      pricePaise: Value(pricePaise),
      lifespanDays: Value(lifespanDays),
      lastRestock: Value(lastRestock),
    );
  }

  factory SupplyItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplyItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pricePaise: serializer.fromJson<int>(json['pricePaise']),
      lifespanDays: serializer.fromJson<int>(json['lifespanDays']),
      lastRestock: serializer.fromJson<String>(json['lastRestock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'pricePaise': serializer.toJson<int>(pricePaise),
      'lifespanDays': serializer.toJson<int>(lifespanDays),
      'lastRestock': serializer.toJson<String>(lastRestock),
    };
  }

  SupplyItemRow copyWith({
    String? id,
    String? name,
    int? pricePaise,
    int? lifespanDays,
    String? lastRestock,
  }) => SupplyItemRow(
    id: id ?? this.id,
    name: name ?? this.name,
    pricePaise: pricePaise ?? this.pricePaise,
    lifespanDays: lifespanDays ?? this.lifespanDays,
    lastRestock: lastRestock ?? this.lastRestock,
  );
  SupplyItemRow copyWithCompanion(SupplyItemsCompanion data) {
    return SupplyItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      pricePaise: data.pricePaise.present
          ? data.pricePaise.value
          : this.pricePaise,
      lifespanDays: data.lifespanDays.present
          ? data.lifespanDays.value
          : this.lifespanDays,
      lastRestock: data.lastRestock.present
          ? data.lastRestock.value
          : this.lastRestock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplyItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pricePaise: $pricePaise, ')
          ..write('lifespanDays: $lifespanDays, ')
          ..write('lastRestock: $lastRestock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, pricePaise, lifespanDays, lastRestock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplyItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.pricePaise == this.pricePaise &&
          other.lifespanDays == this.lifespanDays &&
          other.lastRestock == this.lastRestock);
}

class SupplyItemsCompanion extends UpdateCompanion<SupplyItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> pricePaise;
  final Value<int> lifespanDays;
  final Value<String> lastRestock;
  final Value<int> rowid;
  const SupplyItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pricePaise = const Value.absent(),
    this.lifespanDays = const Value.absent(),
    this.lastRestock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplyItemsCompanion.insert({
    required String id,
    required String name,
    required int pricePaise,
    required int lifespanDays,
    required String lastRestock,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       pricePaise = Value(pricePaise),
       lifespanDays = Value(lifespanDays),
       lastRestock = Value(lastRestock);
  static Insertable<SupplyItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? pricePaise,
    Expression<int>? lifespanDays,
    Expression<String>? lastRestock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pricePaise != null) 'price_paise': pricePaise,
      if (lifespanDays != null) 'lifespan_days': lifespanDays,
      if (lastRestock != null) 'last_restock': lastRestock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplyItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? pricePaise,
    Value<int>? lifespanDays,
    Value<String>? lastRestock,
    Value<int>? rowid,
  }) {
    return SupplyItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePaise: pricePaise ?? this.pricePaise,
      lifespanDays: lifespanDays ?? this.lifespanDays,
      lastRestock: lastRestock ?? this.lastRestock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pricePaise.present) {
      map['price_paise'] = Variable<int>(pricePaise.value);
    }
    if (lifespanDays.present) {
      map['lifespan_days'] = Variable<int>(lifespanDays.value);
    }
    if (lastRestock.present) {
      map['last_restock'] = Variable<String>(lastRestock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplyItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pricePaise: $pricePaise, ')
          ..write('lifespanDays: $lifespanDays, ')
          ..write('lastRestock: $lastRestock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringCostsTable extends RecurringCosts
    with TableInfo<$RecurringCostsTable, RecurringCostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _everyMonthsMeta = const VerificationMeta(
    'everyMonths',
  );
  @override
  late final GeneratedColumn<int> everyMonths = GeneratedColumn<int>(
    'every_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, amountPaise, everyMonths];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringCostRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('every_months')) {
      context.handle(
        _everyMonthsMeta,
        everyMonths.isAcceptableOrUnknown(
          data['every_months']!,
          _everyMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_everyMonthsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringCostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringCostRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      everyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}every_months'],
      )!,
    );
  }

  @override
  $RecurringCostsTable createAlias(String alias) {
    return $RecurringCostsTable(attachedDatabase, alias);
  }
}

class RecurringCostRow extends DataClass
    implements Insertable<RecurringCostRow> {
  final String id;
  final String name;
  final int amountPaise;
  final int everyMonths;
  const RecurringCostRow({
    required this.id,
    required this.name,
    required this.amountPaise,
    required this.everyMonths,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['every_months'] = Variable<int>(everyMonths);
    return map;
  }

  RecurringCostsCompanion toCompanion(bool nullToAbsent) {
    return RecurringCostsCompanion(
      id: Value(id),
      name: Value(name),
      amountPaise: Value(amountPaise),
      everyMonths: Value(everyMonths),
    );
  }

  factory RecurringCostRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringCostRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      everyMonths: serializer.fromJson<int>(json['everyMonths']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'everyMonths': serializer.toJson<int>(everyMonths),
    };
  }

  RecurringCostRow copyWith({
    String? id,
    String? name,
    int? amountPaise,
    int? everyMonths,
  }) => RecurringCostRow(
    id: id ?? this.id,
    name: name ?? this.name,
    amountPaise: amountPaise ?? this.amountPaise,
    everyMonths: everyMonths ?? this.everyMonths,
  );
  RecurringCostRow copyWithCompanion(RecurringCostsCompanion data) {
    return RecurringCostRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      everyMonths: data.everyMonths.present
          ? data.everyMonths.value
          : this.everyMonths,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCostRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('everyMonths: $everyMonths')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amountPaise, everyMonths);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringCostRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountPaise == this.amountPaise &&
          other.everyMonths == this.everyMonths);
}

class RecurringCostsCompanion extends UpdateCompanion<RecurringCostRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> amountPaise;
  final Value<int> everyMonths;
  final Value<int> rowid;
  const RecurringCostsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.everyMonths = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringCostsCompanion.insert({
    required String id,
    required String name,
    required int amountPaise,
    required int everyMonths,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       amountPaise = Value(amountPaise),
       everyMonths = Value(everyMonths);
  static Insertable<RecurringCostRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? amountPaise,
    Expression<int>? everyMonths,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (everyMonths != null) 'every_months': everyMonths,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringCostsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? amountPaise,
    Value<int>? everyMonths,
    Value<int>? rowid,
  }) {
    return RecurringCostsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountPaise: amountPaise ?? this.amountPaise,
      everyMonths: everyMonths ?? this.everyMonths,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (everyMonths.present) {
      map['every_months'] = Variable<int>(everyMonths.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCostsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('everyMonths: $everyMonths, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceAnchorsTable extends BalanceAnchors
    with TableInfo<$BalanceAnchorsTable, BalanceAnchorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceAnchorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankPaiseMeta = const VerificationMeta(
    'bankPaise',
  );
  @override
  late final GeneratedColumn<int> bankPaise = GeneratedColumn<int>(
    'bank_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashPaiseMeta = const VerificationMeta(
    'cashPaise',
  );
  @override
  late final GeneratedColumn<int> cashPaise = GeneratedColumn<int>(
    'cash_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excludedPaiseMeta = const VerificationMeta(
    'excludedPaise',
  );
  @override
  late final GeneratedColumn<int> excludedPaise = GeneratedColumn<int>(
    'excluded_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    bankPaise,
    cashPaise,
    excludedPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_anchors';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceAnchorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('bank_paise')) {
      context.handle(
        _bankPaiseMeta,
        bankPaise.isAcceptableOrUnknown(data['bank_paise']!, _bankPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_bankPaiseMeta);
    }
    if (data.containsKey('cash_paise')) {
      context.handle(
        _cashPaiseMeta,
        cashPaise.isAcceptableOrUnknown(data['cash_paise']!, _cashPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_cashPaiseMeta);
    }
    if (data.containsKey('excluded_paise')) {
      context.handle(
        _excludedPaiseMeta,
        excludedPaise.isAcceptableOrUnknown(
          data['excluded_paise']!,
          _excludedPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_excludedPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BalanceAnchorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceAnchorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      bankPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_paise'],
      )!,
      cashPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_paise'],
      )!,
      excludedPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}excluded_paise'],
      )!,
    );
  }

  @override
  $BalanceAnchorsTable createAlias(String alias) {
    return $BalanceAnchorsTable(attachedDatabase, alias);
  }
}

class BalanceAnchorRow extends DataClass
    implements Insertable<BalanceAnchorRow> {
  final int id;
  final int at;
  final int bankPaise;
  final int cashPaise;
  final int excludedPaise;
  const BalanceAnchorRow({
    required this.id,
    required this.at,
    required this.bankPaise,
    required this.cashPaise,
    required this.excludedPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<int>(at);
    map['bank_paise'] = Variable<int>(bankPaise);
    map['cash_paise'] = Variable<int>(cashPaise);
    map['excluded_paise'] = Variable<int>(excludedPaise);
    return map;
  }

  BalanceAnchorsCompanion toCompanion(bool nullToAbsent) {
    return BalanceAnchorsCompanion(
      id: Value(id),
      at: Value(at),
      bankPaise: Value(bankPaise),
      cashPaise: Value(cashPaise),
      excludedPaise: Value(excludedPaise),
    );
  }

  factory BalanceAnchorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceAnchorRow(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<int>(json['at']),
      bankPaise: serializer.fromJson<int>(json['bankPaise']),
      cashPaise: serializer.fromJson<int>(json['cashPaise']),
      excludedPaise: serializer.fromJson<int>(json['excludedPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<int>(at),
      'bankPaise': serializer.toJson<int>(bankPaise),
      'cashPaise': serializer.toJson<int>(cashPaise),
      'excludedPaise': serializer.toJson<int>(excludedPaise),
    };
  }

  BalanceAnchorRow copyWith({
    int? id,
    int? at,
    int? bankPaise,
    int? cashPaise,
    int? excludedPaise,
  }) => BalanceAnchorRow(
    id: id ?? this.id,
    at: at ?? this.at,
    bankPaise: bankPaise ?? this.bankPaise,
    cashPaise: cashPaise ?? this.cashPaise,
    excludedPaise: excludedPaise ?? this.excludedPaise,
  );
  BalanceAnchorRow copyWithCompanion(BalanceAnchorsCompanion data) {
    return BalanceAnchorRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      bankPaise: data.bankPaise.present ? data.bankPaise.value : this.bankPaise,
      cashPaise: data.cashPaise.present ? data.cashPaise.value : this.cashPaise,
      excludedPaise: data.excludedPaise.present
          ? data.excludedPaise.value
          : this.excludedPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAnchorRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('bankPaise: $bankPaise, ')
          ..write('cashPaise: $cashPaise, ')
          ..write('excludedPaise: $excludedPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, bankPaise, cashPaise, excludedPaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceAnchorRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.bankPaise == this.bankPaise &&
          other.cashPaise == this.cashPaise &&
          other.excludedPaise == this.excludedPaise);
}

class BalanceAnchorsCompanion extends UpdateCompanion<BalanceAnchorRow> {
  final Value<int> id;
  final Value<int> at;
  final Value<int> bankPaise;
  final Value<int> cashPaise;
  final Value<int> excludedPaise;
  const BalanceAnchorsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.bankPaise = const Value.absent(),
    this.cashPaise = const Value.absent(),
    this.excludedPaise = const Value.absent(),
  });
  BalanceAnchorsCompanion.insert({
    this.id = const Value.absent(),
    required int at,
    required int bankPaise,
    required int cashPaise,
    required int excludedPaise,
  }) : at = Value(at),
       bankPaise = Value(bankPaise),
       cashPaise = Value(cashPaise),
       excludedPaise = Value(excludedPaise);
  static Insertable<BalanceAnchorRow> custom({
    Expression<int>? id,
    Expression<int>? at,
    Expression<int>? bankPaise,
    Expression<int>? cashPaise,
    Expression<int>? excludedPaise,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (bankPaise != null) 'bank_paise': bankPaise,
      if (cashPaise != null) 'cash_paise': cashPaise,
      if (excludedPaise != null) 'excluded_paise': excludedPaise,
    });
  }

  BalanceAnchorsCompanion copyWith({
    Value<int>? id,
    Value<int>? at,
    Value<int>? bankPaise,
    Value<int>? cashPaise,
    Value<int>? excludedPaise,
  }) {
    return BalanceAnchorsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      bankPaise: bankPaise ?? this.bankPaise,
      cashPaise: cashPaise ?? this.cashPaise,
      excludedPaise: excludedPaise ?? this.excludedPaise,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (bankPaise.present) {
      map['bank_paise'] = Variable<int>(bankPaise.value);
    }
    if (cashPaise.present) {
      map['cash_paise'] = Variable<int>(cashPaise.value);
    }
    if (excludedPaise.present) {
      map['excluded_paise'] = Variable<int>(excludedPaise.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAnchorsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('bankPaise: $bankPaise, ')
          ..write('cashPaise: $cashPaise, ')
          ..write('excludedPaise: $excludedPaise')
          ..write(')'))
        .toString();
  }
}

class $KeywordMappingsTable extends KeywordMappings
    with TableInfo<$KeywordMappingsTable, KeywordMappingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeywordMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [keyword, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'keyword_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeywordMappingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {keyword};
  @override
  KeywordMappingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeywordMappingRow(
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $KeywordMappingsTable createAlias(String alias) {
    return $KeywordMappingsTable(attachedDatabase, alias);
  }
}

class KeywordMappingRow extends DataClass
    implements Insertable<KeywordMappingRow> {
  final String keyword;
  final String category;
  const KeywordMappingRow({required this.keyword, required this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['keyword'] = Variable<String>(keyword);
    map['category'] = Variable<String>(category);
    return map;
  }

  KeywordMappingsCompanion toCompanion(bool nullToAbsent) {
    return KeywordMappingsCompanion(
      keyword: Value(keyword),
      category: Value(category),
    );
  }

  factory KeywordMappingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeywordMappingRow(
      keyword: serializer.fromJson<String>(json['keyword']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'keyword': serializer.toJson<String>(keyword),
      'category': serializer.toJson<String>(category),
    };
  }

  KeywordMappingRow copyWith({String? keyword, String? category}) =>
      KeywordMappingRow(
        keyword: keyword ?? this.keyword,
        category: category ?? this.category,
      );
  KeywordMappingRow copyWithCompanion(KeywordMappingsCompanion data) {
    return KeywordMappingRow(
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeywordMappingRow(')
          ..write('keyword: $keyword, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(keyword, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeywordMappingRow &&
          other.keyword == this.keyword &&
          other.category == this.category);
}

class KeywordMappingsCompanion extends UpdateCompanion<KeywordMappingRow> {
  final Value<String> keyword;
  final Value<String> category;
  final Value<int> rowid;
  const KeywordMappingsCompanion({
    this.keyword = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeywordMappingsCompanion.insert({
    required String keyword,
    required String category,
    this.rowid = const Value.absent(),
  }) : keyword = Value(keyword),
       category = Value(category);
  static Insertable<KeywordMappingRow> custom({
    Expression<String>? keyword,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyword != null) 'keyword': keyword,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeywordMappingsCompanion copyWith({
    Value<String>? keyword,
    Value<String>? category,
    Value<int>? rowid,
  }) {
    return KeywordMappingsCompanion(
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeywordMappingsCompanion(')
          ..write('keyword: $keyword, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakDaysTable extends StreakDays
    with TableInfo<$StreakDaysTable, StreakDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noSpendMeta = const VerificationMeta(
    'noSpend',
  );
  @override
  late final GeneratedColumn<bool> noSpend = GeneratedColumn<bool>(
    'no_spend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_spend" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [date, noSpend];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('no_spend')) {
      context.handle(
        _noSpendMeta,
        noSpend.isAcceptableOrUnknown(data['no_spend']!, _noSpendMeta),
      );
    } else if (isInserting) {
      context.missing(_noSpendMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  StreakDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakDayRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      noSpend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_spend'],
      )!,
    );
  }

  @override
  $StreakDaysTable createAlias(String alias) {
    return $StreakDaysTable(attachedDatabase, alias);
  }
}

class StreakDayRow extends DataClass implements Insertable<StreakDayRow> {
  final String date;
  final bool noSpend;
  const StreakDayRow({required this.date, required this.noSpend});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['no_spend'] = Variable<bool>(noSpend);
    return map;
  }

  StreakDaysCompanion toCompanion(bool nullToAbsent) {
    return StreakDaysCompanion(date: Value(date), noSpend: Value(noSpend));
  }

  factory StreakDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakDayRow(
      date: serializer.fromJson<String>(json['date']),
      noSpend: serializer.fromJson<bool>(json['noSpend']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'noSpend': serializer.toJson<bool>(noSpend),
    };
  }

  StreakDayRow copyWith({String? date, bool? noSpend}) =>
      StreakDayRow(date: date ?? this.date, noSpend: noSpend ?? this.noSpend);
  StreakDayRow copyWithCompanion(StreakDaysCompanion data) {
    return StreakDayRow(
      date: data.date.present ? data.date.value : this.date,
      noSpend: data.noSpend.present ? data.noSpend.value : this.noSpend,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakDayRow(')
          ..write('date: $date, ')
          ..write('noSpend: $noSpend')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, noSpend);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakDayRow &&
          other.date == this.date &&
          other.noSpend == this.noSpend);
}

class StreakDaysCompanion extends UpdateCompanion<StreakDayRow> {
  final Value<String> date;
  final Value<bool> noSpend;
  final Value<int> rowid;
  const StreakDaysCompanion({
    this.date = const Value.absent(),
    this.noSpend = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakDaysCompanion.insert({
    required String date,
    required bool noSpend,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       noSpend = Value(noSpend);
  static Insertable<StreakDayRow> custom({
    Expression<String>? date,
    Expression<bool>? noSpend,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (noSpend != null) 'no_spend': noSpend,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakDaysCompanion copyWith({
    Value<String>? date,
    Value<bool>? noSpend,
    Value<int>? rowid,
  }) {
    return StreakDaysCompanion(
      date: date ?? this.date,
      noSpend: noSpend ?? this.noSpend,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (noSpend.present) {
      map['no_spend'] = Variable<bool>(noSpend.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakDaysCompanion(')
          ..write('date: $date, ')
          ..write('noSpend: $noSpend, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $CyclesTable cycles = $CyclesTable(this);
  late final $AllocationsTable allocations = $AllocationsTable(this);
  late final $DepositsTable deposits = $DepositsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AdjustmentsTable adjustments = $AdjustmentsTable(this);
  late final $HoldsTable holds = $HoldsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $SupplyItemsTable supplyItems = $SupplyItemsTable(this);
  late final $RecurringCostsTable recurringCosts = $RecurringCostsTable(this);
  late final $BalanceAnchorsTable balanceAnchors = $BalanceAnchorsTable(this);
  late final $KeywordMappingsTable keywordMappings = $KeywordMappingsTable(
    this,
  );
  late final $StreakDaysTable streakDays = $StreakDaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    cycles,
    allocations,
    deposits,
    transactions,
    adjustments,
    holds,
    batches,
    supplyItems,
    recurringCosts,
    balanceAnchors,
    keywordMappings,
    streakDays,
  ];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$CyclesTableCreateCompanionBuilder = CyclesCompanion Function({
  Value<int> id,
  required String startDate,
  required String expectedNextStart,
  Value<String?> closedOn,
  required String weights,
  required int installmentsPaise,
  required int carryInPaise,
  required int baselinePaise,
  required int deltaPaise,
  required int foodFloorPaise,
  required int petrolFloorPaise,
  required int shortfallPaise,
  required int baseDailyPaise,
});
typedef $$CyclesTableUpdateCompanionBuilder = CyclesCompanion Function({
  Value<int> id,
  Value<String> startDate,
  Value<String> expectedNextStart,
  Value<String?> closedOn,
  Value<String> weights,
  Value<int> installmentsPaise,
  Value<int> carryInPaise,
  Value<int> baselinePaise,
  Value<int> deltaPaise,
  Value<int> foodFloorPaise,
  Value<int> petrolFloorPaise,
  Value<int> shortfallPaise,
  Value<int> baseDailyPaise,
});

final class $$CyclesTableReferences
    extends BaseReferences<_$AppDatabase, $CyclesTable, CycleRow> {
  $$CyclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AllocationsTable, List<AllocationRow>>
  _allocationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.allocations,
    aliasName: 'cycles__id__allocations__cycle_id',
  );

  $$AllocationsTableProcessedTableManager get allocationsRefs {
    final manager = $$AllocationsTableTableManager(
      $_db,
      $_db.allocations,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_allocationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DepositsTable, List<DepositRow>>
  _depositsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deposits,
    aliasName: 'cycles__id__deposits__cycle_id',
  );

  $$DepositsTableProcessedTableManager get depositsRefs {
    final manager = $$DepositsTableTableManager(
      $_db,
      $_db.deposits,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_depositsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRow>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'cycles__id__transactions__cycle_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdjustmentsTable, List<AdjustmentRow>>
  _adjustmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adjustments,
    aliasName: 'cycles__id__adjustments__cycle_id',
  );

  $$AdjustmentsTableProcessedTableManager get adjustmentsRefs {
    final manager = $$AdjustmentsTableTableManager(
      $_db,
      $_db.adjustments,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_adjustmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldsTable, List<HoldRow>> _holdsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holds,
    aliasName: 'cycles__id__holds__cycle_id',
  );

  $$HoldsTableProcessedTableManager get holdsRefs {
    final manager = $$HoldsTableTableManager(
      $_db,
      $_db.holds,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<BatchRow>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'cycles__id__batches__cycle_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CyclesTableFilterComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedNextStart => $composableBuilder(
    column: $table.expectedNextStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weights => $composableBuilder(
    column: $table.weights,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentsPaise => $composableBuilder(
    column: $table.installmentsPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carryInPaise => $composableBuilder(
    column: $table.carryInPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baselinePaise => $composableBuilder(
    column: $table.baselinePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foodFloorPaise => $composableBuilder(
    column: $table.foodFloorPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get petrolFloorPaise => $composableBuilder(
    column: $table.petrolFloorPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseDailyPaise => $composableBuilder(
    column: $table.baseDailyPaise,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> allocationsRefs(
    Expression<bool> Function($$AllocationsTableFilterComposer f) f,
  ) {
    final $$AllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AllocationsTableFilterComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> depositsRefs(
    Expression<bool> Function($$DepositsTableFilterComposer f) f,
  ) {
    final $$DepositsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deposits,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepositsTableFilterComposer(
            $db: $db,
            $table: $db.deposits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adjustmentsRefs(
    Expression<bool> Function($$AdjustmentsTableFilterComposer f) f,
  ) {
    final $$AdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adjustments,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.adjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdsRefs(
    Expression<bool> Function($$HoldsTableFilterComposer f) f,
  ) {
    final $$HoldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holds,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldsTableFilterComposer(
            $db: $db,
            $table: $db.holds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedNextStart => $composableBuilder(
    column: $table.expectedNextStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weights => $composableBuilder(
    column: $table.weights,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentsPaise => $composableBuilder(
    column: $table.installmentsPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carryInPaise => $composableBuilder(
    column: $table.carryInPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baselinePaise => $composableBuilder(
    column: $table.baselinePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodFloorPaise => $composableBuilder(
    column: $table.foodFloorPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get petrolFloorPaise => $composableBuilder(
    column: $table.petrolFloorPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseDailyPaise => $composableBuilder(
    column: $table.baseDailyPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get expectedNextStart => $composableBuilder(
    column: $table.expectedNextStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedOn =>
      $composableBuilder(column: $table.closedOn, builder: (column) => column);

  GeneratedColumn<String> get weights =>
      $composableBuilder(column: $table.weights, builder: (column) => column);

  GeneratedColumn<int> get installmentsPaise => $composableBuilder(
    column: $table.installmentsPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get carryInPaise => $composableBuilder(
    column: $table.carryInPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baselinePaise => $composableBuilder(
    column: $table.baselinePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deltaPaise => $composableBuilder(
    column: $table.deltaPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foodFloorPaise => $composableBuilder(
    column: $table.foodFloorPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get petrolFloorPaise => $composableBuilder(
    column: $table.petrolFloorPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseDailyPaise => $composableBuilder(
    column: $table.baseDailyPaise,
    builder: (column) => column,
  );

  Expression<T> allocationsRefs<T extends Object>(
    Expression<T> Function($$AllocationsTableAnnotationComposer a) f,
  ) {
    final $$AllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> depositsRefs<T extends Object>(
    Expression<T> Function($$DepositsTableAnnotationComposer a) f,
  ) {
    final $$DepositsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deposits,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DepositsTableAnnotationComposer(
            $db: $db,
            $table: $db.deposits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adjustmentsRefs<T extends Object>(
    Expression<T> Function($$AdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$AdjustmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adjustments,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdjustmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.adjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdsRefs<T extends Object>(
    Expression<T> Function($$HoldsTableAnnotationComposer a) f,
  ) {
    final $$HoldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holds,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldsTableAnnotationComposer(
            $db: $db,
            $table: $db.holds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CyclesTable,
          CycleRow,
          $$CyclesTableFilterComposer,
          $$CyclesTableOrderingComposer,
          $$CyclesTableAnnotationComposer,
          $$CyclesTableCreateCompanionBuilder,
          $$CyclesTableUpdateCompanionBuilder,
          (CycleRow, $$CyclesTableReferences),
          CycleRow,
          PrefetchHooks Function({
            bool allocationsRefs,
            bool depositsRefs,
            bool transactionsRefs,
            bool adjustmentsRefs,
            bool holdsRefs,
            bool batchesRefs,
          })
        > {
  $$CyclesTableTableManager(_$AppDatabase db, $CyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> expectedNextStart = const Value.absent(),
                Value<String?> closedOn = const Value.absent(),
                Value<String> weights = const Value.absent(),
                Value<int> installmentsPaise = const Value.absent(),
                Value<int> carryInPaise = const Value.absent(),
                Value<int> baselinePaise = const Value.absent(),
                Value<int> deltaPaise = const Value.absent(),
                Value<int> foodFloorPaise = const Value.absent(),
                Value<int> petrolFloorPaise = const Value.absent(),
                Value<int> shortfallPaise = const Value.absent(),
                Value<int> baseDailyPaise = const Value.absent(),
              }) => CyclesCompanion(
                id: id,
                startDate: startDate,
                expectedNextStart: expectedNextStart,
                closedOn: closedOn,
                weights: weights,
                installmentsPaise: installmentsPaise,
                carryInPaise: carryInPaise,
                baselinePaise: baselinePaise,
                deltaPaise: deltaPaise,
                foodFloorPaise: foodFloorPaise,
                petrolFloorPaise: petrolFloorPaise,
                shortfallPaise: shortfallPaise,
                baseDailyPaise: baseDailyPaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startDate,
                required String expectedNextStart,
                Value<String?> closedOn = const Value.absent(),
                required String weights,
                required int installmentsPaise,
                required int carryInPaise,
                required int baselinePaise,
                required int deltaPaise,
                required int foodFloorPaise,
                required int petrolFloorPaise,
                required int shortfallPaise,
                required int baseDailyPaise,
              }) => CyclesCompanion.insert(
                id: id,
                startDate: startDate,
                expectedNextStart: expectedNextStart,
                closedOn: closedOn,
                weights: weights,
                installmentsPaise: installmentsPaise,
                carryInPaise: carryInPaise,
                baselinePaise: baselinePaise,
                deltaPaise: deltaPaise,
                foodFloorPaise: foodFloorPaise,
                petrolFloorPaise: petrolFloorPaise,
                shortfallPaise: shortfallPaise,
                baseDailyPaise: baseDailyPaise,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CyclesTable, CycleRow>(table),
                  $$CyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                allocationsRefs = false,
                depositsRefs = false,
                transactionsRefs = false,
                adjustmentsRefs = false,
                holdsRefs = false,
                batchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (allocationsRefs) db.allocations,
                    if (depositsRefs) db.deposits,
                    if (transactionsRefs) db.transactions,
                    if (adjustmentsRefs) db.adjustments,
                    if (holdsRefs) db.holds,
                    if (batchesRefs) db.batches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (allocationsRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          AllocationRow,
                          $AllocationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._allocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).allocationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                      if (depositsRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          DepositRow,
                          $DepositsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._depositsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).depositsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          TransactionRow,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                      if (adjustmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          AdjustmentRow,
                          $AdjustmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._adjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).adjustmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                      if (holdsRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          HoldRow,
                          $HoldsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._holdsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(db, table, p0).holdsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedDataByColumns<
                          CycleRow,
                          $CyclesTable,
                          BatchRow,
                          $BatchesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CyclesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CyclesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cycle_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CyclesTable,
      CycleRow,
      $$CyclesTableFilterComposer,
      $$CyclesTableOrderingComposer,
      $$CyclesTableAnnotationComposer,
      $$CyclesTableCreateCompanionBuilder,
      $$CyclesTableUpdateCompanionBuilder,
      (CycleRow, $$CyclesTableReferences),
      CycleRow,
      PrefetchHooks Function({
        bool allocationsRefs,
        bool depositsRefs,
        bool transactionsRefs,
        bool adjustmentsRefs,
        bool holdsRefs,
        bool batchesRefs,
      })
    >;
typedef $$AllocationsTableCreateCompanionBuilder =
    AllocationsCompanion Function({
      Value<int> id,
      required int cycleId,
      required String category,
      required int amountPaise,
      required String kind,
    });
typedef $$AllocationsTableUpdateCompanionBuilder =
    AllocationsCompanion Function({
      Value<int> id,
      Value<int> cycleId,
      Value<String> category,
      Value<int> amountPaise,
      Value<String> kind,
    });

final class $$AllocationsTableReferences
    extends BaseReferences<_$AppDatabase, $AllocationsTable, AllocationRow> {
  $$AllocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('allocations__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllocationsTable> {
  $$AllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllocationsTable,
          AllocationRow,
          $$AllocationsTableFilterComposer,
          $$AllocationsTableOrderingComposer,
          $$AllocationsTableAnnotationComposer,
          $$AllocationsTableCreateCompanionBuilder,
          $$AllocationsTableUpdateCompanionBuilder,
          (AllocationRow, $$AllocationsTableReferences),
          AllocationRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$AllocationsTableTableManager(_$AppDatabase db, $AllocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> kind = const Value.absent(),
              }) => AllocationsCompanion(
                id: id,
                cycleId: cycleId,
                category: category,
                amountPaise: amountPaise,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cycleId,
                required String category,
                required int amountPaise,
                required String kind,
              }) => AllocationsCompanion.insert(
                id: id,
                cycleId: cycleId,
                category: category,
                amountPaise: amountPaise,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AllocationsTable, AllocationRow>(table),
                  $$AllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$AllocationsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$AllocationsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllocationsTable,
      AllocationRow,
      $$AllocationsTableFilterComposer,
      $$AllocationsTableOrderingComposer,
      $$AllocationsTableAnnotationComposer,
      $$AllocationsTableCreateCompanionBuilder,
      $$AllocationsTableUpdateCompanionBuilder,
      (AllocationRow, $$AllocationsTableReferences),
      AllocationRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$DepositsTableCreateCompanionBuilder = DepositsCompanion Function({
  required String id,
  required int cycleId,
  required int amountPaise,
  required int receivedAt,
  required String kind,
  Value<int> rowid,
});
typedef $$DepositsTableUpdateCompanionBuilder = DepositsCompanion Function({
  Value<String> id,
  Value<int> cycleId,
  Value<int> amountPaise,
  Value<int> receivedAt,
  Value<String> kind,
  Value<int> rowid,
});

final class $$DepositsTableReferences
    extends BaseReferences<_$AppDatabase, $DepositsTable, DepositRow> {
  $$DepositsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('deposits__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DepositsTableFilterComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DepositsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DepositsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DepositsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DepositsTable,
          DepositRow,
          $$DepositsTableFilterComposer,
          $$DepositsTableOrderingComposer,
          $$DepositsTableAnnotationComposer,
          $$DepositsTableCreateCompanionBuilder,
          $$DepositsTableUpdateCompanionBuilder,
          (DepositRow, $$DepositsTableReferences),
          DepositRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$DepositsTableTableManager(_$AppDatabase db, $DepositsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepositsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepositsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepositsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DepositsCompanion(
                id: id,
                cycleId: cycleId,
                amountPaise: amountPaise,
                receivedAt: receivedAt,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int cycleId,
                required int amountPaise,
                required int receivedAt,
                required String kind,
                Value<int> rowid = const Value.absent(),
              }) => DepositsCompanion.insert(
                id: id,
                cycleId: cycleId,
                amountPaise: amountPaise,
                receivedAt: receivedAt,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DepositsTable, DepositRow>(table),
                  $$DepositsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$DepositsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$DepositsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DepositsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DepositsTable,
      DepositRow,
      $$DepositsTableFilterComposer,
      $$DepositsTableOrderingComposer,
      $$DepositsTableAnnotationComposer,
      $$DepositsTableCreateCompanionBuilder,
      $$DepositsTableUpdateCompanionBuilder,
      (DepositRow, $$DepositsTableReferences),
      DepositRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int cycleId,
      required int amountPaise,
      required String category,
      required String method,
      required int occurredAt,
      required String note,
      required String source,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> cycleId,
      Value<int> amountPaise,
      Value<String> category,
      Value<String> method,
      Value<int> occurredAt,
      Value<String> note,
      Value<String> source,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('transactions__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$TransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                cycleId: cycleId,
                amountPaise: amountPaise,
                category: category,
                method: method,
                occurredAt: occurredAt,
                note: note,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int cycleId,
                required int amountPaise,
                required String category,
                required String method,
                required int occurredAt,
                required String note,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                cycleId: cycleId,
                amountPaise: amountPaise,
                category: category,
                method: method,
                occurredAt: occurredAt,
                note: note,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$TransactionsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$TransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$AdjustmentsTableCreateCompanionBuilder =
    AdjustmentsCompanion Function({
      required String id,
      required int cycleId,
      required String batchId,
      required String fromCategory,
      required String toCategory,
      required int amountPaise,
      required String reason,
      required int createdAt,
      required bool auto,
      Value<bool> undone,
      Value<int> rowid,
    });
typedef $$AdjustmentsTableUpdateCompanionBuilder =
    AdjustmentsCompanion Function({
      Value<String> id,
      Value<int> cycleId,
      Value<String> batchId,
      Value<String> fromCategory,
      Value<String> toCategory,
      Value<int> amountPaise,
      Value<String> reason,
      Value<int> createdAt,
      Value<bool> auto,
      Value<bool> undone,
      Value<int> rowid,
    });

final class $$AdjustmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AdjustmentsTable, AdjustmentRow> {
  $$AdjustmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('adjustments__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCategory => $composableBuilder(
    column: $table.fromCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toCategory => $composableBuilder(
    column: $table.toCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get auto => $composableBuilder(
    column: $table.auto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCategory => $composableBuilder(
    column: $table.fromCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toCategory => $composableBuilder(
    column: $table.toCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get auto => $composableBuilder(
    column: $table.auto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get fromCategory => $composableBuilder(
    column: $table.fromCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toCategory => $composableBuilder(
    column: $table.toCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get auto =>
      $composableBuilder(column: $table.auto, builder: (column) => column);

  GeneratedColumn<bool> get undone =>
      $composableBuilder(column: $table.undone, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdjustmentsTable,
          AdjustmentRow,
          $$AdjustmentsTableFilterComposer,
          $$AdjustmentsTableOrderingComposer,
          $$AdjustmentsTableAnnotationComposer,
          $$AdjustmentsTableCreateCompanionBuilder,
          $$AdjustmentsTableUpdateCompanionBuilder,
          (AdjustmentRow, $$AdjustmentsTableReferences),
          AdjustmentRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$AdjustmentsTableTableManager(_$AppDatabase db, $AdjustmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdjustmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> fromCategory = const Value.absent(),
                Value<String> toCategory = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> auto = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdjustmentsCompanion(
                id: id,
                cycleId: cycleId,
                batchId: batchId,
                fromCategory: fromCategory,
                toCategory: toCategory,
                amountPaise: amountPaise,
                reason: reason,
                createdAt: createdAt,
                auto: auto,
                undone: undone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int cycleId,
                required String batchId,
                required String fromCategory,
                required String toCategory,
                required int amountPaise,
                required String reason,
                required int createdAt,
                required bool auto,
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdjustmentsCompanion.insert(
                id: id,
                cycleId: cycleId,
                batchId: batchId,
                fromCategory: fromCategory,
                toCategory: toCategory,
                amountPaise: amountPaise,
                reason: reason,
                createdAt: createdAt,
                auto: auto,
                undone: undone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdjustmentsTable, AdjustmentRow>(table),
                  $$AdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$AdjustmentsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$AdjustmentsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdjustmentsTable,
      AdjustmentRow,
      $$AdjustmentsTableFilterComposer,
      $$AdjustmentsTableOrderingComposer,
      $$AdjustmentsTableAnnotationComposer,
      $$AdjustmentsTableCreateCompanionBuilder,
      $$AdjustmentsTableUpdateCompanionBuilder,
      (AdjustmentRow, $$AdjustmentsTableReferences),
      AdjustmentRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$HoldsTableCreateCompanionBuilder = HoldsCompanion Function({
  required String id,
  required int cycleId,
  required String batchId,
  required String commitmentId,
  required String category,
  required int amountPaise,
  required int createdAt,
  Value<bool> undone,
  Value<int> rowid,
});
typedef $$HoldsTableUpdateCompanionBuilder = HoldsCompanion Function({
  Value<String> id,
  Value<int> cycleId,
  Value<String> batchId,
  Value<String> commitmentId,
  Value<String> category,
  Value<int> amountPaise,
  Value<int> createdAt,
  Value<bool> undone,
  Value<int> rowid,
});

final class $$HoldsTableReferences
    extends BaseReferences<_$AppDatabase, $HoldsTable, HoldRow> {
  $$HoldsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('holds__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HoldsTableFilterComposer extends Composer<_$AppDatabase, $HoldsTable> {
  $$HoldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commitmentId => $composableBuilder(
    column: $table.commitmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldsTable> {
  $$HoldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commitmentId => $composableBuilder(
    column: $table.commitmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldsTable> {
  $$HoldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get commitmentId => $composableBuilder(
    column: $table.commitmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get undone =>
      $composableBuilder(column: $table.undone, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldsTable,
          HoldRow,
          $$HoldsTableFilterComposer,
          $$HoldsTableOrderingComposer,
          $$HoldsTableAnnotationComposer,
          $$HoldsTableCreateCompanionBuilder,
          $$HoldsTableUpdateCompanionBuilder,
          (HoldRow, $$HoldsTableReferences),
          HoldRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$HoldsTableTableManager(_$AppDatabase db, $HoldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> commitmentId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HoldsCompanion(
                id: id,
                cycleId: cycleId,
                batchId: batchId,
                commitmentId: commitmentId,
                category: category,
                amountPaise: amountPaise,
                createdAt: createdAt,
                undone: undone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int cycleId,
                required String batchId,
                required String commitmentId,
                required String category,
                required int amountPaise,
                required int createdAt,
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HoldsCompanion.insert(
                id: id,
                cycleId: cycleId,
                batchId: batchId,
                commitmentId: commitmentId,
                category: category,
                amountPaise: amountPaise,
                createdAt: createdAt,
                undone: undone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HoldsTable, HoldRow>(table),
                  $$HoldsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$HoldsTableReferences._cycleIdTable(
                          db,
                        ),
                        referencedColumn: $$HoldsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HoldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldsTable,
      HoldRow,
      $$HoldsTableFilterComposer,
      $$HoldsTableOrderingComposer,
      $$HoldsTableAnnotationComposer,
      $$HoldsTableCreateCompanionBuilder,
      $$HoldsTableUpdateCompanionBuilder,
      (HoldRow, $$HoldsTableReferences),
      HoldRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  required String id,
  required int cycleId,
  required String kind,
  required int createdAt,
  required int movedPaise,
  required int heldPaise,
  required int shortfallPaise,
  required String targets,
  required bool suggestReplan,
  Value<bool> seen,
  Value<bool> undone,
  Value<int> rowid,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<String> id,
  Value<int> cycleId,
  Value<String> kind,
  Value<int> createdAt,
  Value<int> movedPaise,
  Value<int> heldPaise,
  Value<int> shortfallPaise,
  Value<String> targets,
  Value<bool> suggestReplan,
  Value<bool> seen,
  Value<bool> undone,
  Value<int> rowid,
});

final class $$BatchesTableReferences
    extends BaseReferences<_$AppDatabase, $BatchesTable, BatchRow> {
  $$BatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTable _cycleIdTable(_$AppDatabase db) =>
      db.cycles.createAlias('batches__cycle_id__cycles__id');

  $$CyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$CyclesTableTableManager(
      $_db,
      $_db.cycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movedPaise => $composableBuilder(
    column: $table.movedPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heldPaise => $composableBuilder(
    column: $table.heldPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targets => $composableBuilder(
    column: $table.targets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get suggestReplan => $composableBuilder(
    column: $table.suggestReplan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnFilters(column),
  );

  $$CyclesTableFilterComposer get cycleId {
    final $$CyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableFilterComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movedPaise => $composableBuilder(
    column: $table.movedPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heldPaise => $composableBuilder(
    column: $table.heldPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targets => $composableBuilder(
    column: $table.targets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get suggestReplan => $composableBuilder(
    column: $table.suggestReplan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get undone => $composableBuilder(
    column: $table.undone,
    builder: (column) => ColumnOrderings(column),
  );

  $$CyclesTableOrderingComposer get cycleId {
    final $$CyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableOrderingComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get movedPaise => $composableBuilder(
    column: $table.movedPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heldPaise =>
      $composableBuilder(column: $table.heldPaise, builder: (column) => column);

  GeneratedColumn<int> get shortfallPaise => $composableBuilder(
    column: $table.shortfallPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targets =>
      $composableBuilder(column: $table.targets, builder: (column) => column);

  GeneratedColumn<bool> get suggestReplan => $composableBuilder(
    column: $table.suggestReplan,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);

  GeneratedColumn<bool> get undone =>
      $composableBuilder(column: $table.undone, builder: (column) => column);

  $$CyclesTableAnnotationComposer get cycleId {
    final $$CyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.cycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.cycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          BatchRow,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (BatchRow, $$BatchesTableReferences),
          BatchRow,
          PrefetchHooks Function({bool cycleId})
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> movedPaise = const Value.absent(),
                Value<int> heldPaise = const Value.absent(),
                Value<int> shortfallPaise = const Value.absent(),
                Value<String> targets = const Value.absent(),
                Value<bool> suggestReplan = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                cycleId: cycleId,
                kind: kind,
                createdAt: createdAt,
                movedPaise: movedPaise,
                heldPaise: heldPaise,
                shortfallPaise: shortfallPaise,
                targets: targets,
                suggestReplan: suggestReplan,
                seen: seen,
                undone: undone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int cycleId,
                required String kind,
                required int createdAt,
                required int movedPaise,
                required int heldPaise,
                required int shortfallPaise,
                required String targets,
                required bool suggestReplan,
                Value<bool> seen = const Value.absent(),
                Value<bool> undone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                cycleId: cycleId,
                kind: kind,
                createdAt: createdAt,
                movedPaise: movedPaise,
                heldPaise: heldPaise,
                shortfallPaise: shortfallPaise,
                targets: targets,
                suggestReplan: suggestReplan,
                seen: seen,
                undone: undone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatchesTable, BatchRow>(table),
                  $$BatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$BatchesTableReferences._cycleIdTable(
                          db,
                        ),
                        referencedColumn: $$BatchesTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      BatchRow,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (BatchRow, $$BatchesTableReferences),
      BatchRow,
      PrefetchHooks Function({bool cycleId})
    >;
typedef $$SupplyItemsTableCreateCompanionBuilder =
    SupplyItemsCompanion Function({
      required String id,
      required String name,
      required int pricePaise,
      required int lifespanDays,
      required String lastRestock,
      Value<int> rowid,
    });
typedef $$SupplyItemsTableUpdateCompanionBuilder =
    SupplyItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> pricePaise,
      Value<int> lifespanDays,
      Value<String> lastRestock,
      Value<int> rowid,
    });

class $$SupplyItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplyItemsTable> {
  $$SupplyItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePaise => $composableBuilder(
    column: $table.pricePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifespanDays => $composableBuilder(
    column: $table.lifespanDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastRestock => $composableBuilder(
    column: $table.lastRestock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupplyItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplyItemsTable> {
  $$SupplyItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePaise => $composableBuilder(
    column: $table.pricePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifespanDays => $composableBuilder(
    column: $table.lifespanDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastRestock => $composableBuilder(
    column: $table.lastRestock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupplyItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplyItemsTable> {
  $$SupplyItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get pricePaise => $composableBuilder(
    column: $table.pricePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lifespanDays => $composableBuilder(
    column: $table.lifespanDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastRestock => $composableBuilder(
    column: $table.lastRestock,
    builder: (column) => column,
  );
}

class $$SupplyItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplyItemsTable,
          SupplyItemRow,
          $$SupplyItemsTableFilterComposer,
          $$SupplyItemsTableOrderingComposer,
          $$SupplyItemsTableAnnotationComposer,
          $$SupplyItemsTableCreateCompanionBuilder,
          $$SupplyItemsTableUpdateCompanionBuilder,
          (
            SupplyItemRow,
            BaseReferences<_$AppDatabase, $SupplyItemsTable, SupplyItemRow>,
          ),
          SupplyItemRow,
          PrefetchHooks Function()
        > {
  $$SupplyItemsTableTableManager(_$AppDatabase db, $SupplyItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplyItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplyItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplyItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> pricePaise = const Value.absent(),
                Value<int> lifespanDays = const Value.absent(),
                Value<String> lastRestock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplyItemsCompanion(
                id: id,
                name: name,
                pricePaise: pricePaise,
                lifespanDays: lifespanDays,
                lastRestock: lastRestock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int pricePaise,
                required int lifespanDays,
                required String lastRestock,
                Value<int> rowid = const Value.absent(),
              }) => SupplyItemsCompanion.insert(
                id: id,
                name: name,
                pricePaise: pricePaise,
                lifespanDays: lifespanDays,
                lastRestock: lastRestock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplyItemsTable, SupplyItemRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SupplyItemsTable,
                    SupplyItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupplyItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplyItemsTable,
      SupplyItemRow,
      $$SupplyItemsTableFilterComposer,
      $$SupplyItemsTableOrderingComposer,
      $$SupplyItemsTableAnnotationComposer,
      $$SupplyItemsTableCreateCompanionBuilder,
      $$SupplyItemsTableUpdateCompanionBuilder,
      (
        SupplyItemRow,
        BaseReferences<_$AppDatabase, $SupplyItemsTable, SupplyItemRow>,
      ),
      SupplyItemRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringCostsTableCreateCompanionBuilder =
    RecurringCostsCompanion Function({
      required String id,
      required String name,
      required int amountPaise,
      required int everyMonths,
      Value<int> rowid,
    });
typedef $$RecurringCostsTableUpdateCompanionBuilder =
    RecurringCostsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> amountPaise,
      Value<int> everyMonths,
      Value<int> rowid,
    });

class $$RecurringCostsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringCostsTable> {
  $$RecurringCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get everyMonths => $composableBuilder(
    column: $table.everyMonths,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringCostsTable> {
  $$RecurringCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get everyMonths => $composableBuilder(
    column: $table.everyMonths,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringCostsTable> {
  $$RecurringCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get everyMonths => $composableBuilder(
    column: $table.everyMonths,
    builder: (column) => column,
  );
}

class $$RecurringCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringCostsTable,
          RecurringCostRow,
          $$RecurringCostsTableFilterComposer,
          $$RecurringCostsTableOrderingComposer,
          $$RecurringCostsTableAnnotationComposer,
          $$RecurringCostsTableCreateCompanionBuilder,
          $$RecurringCostsTableUpdateCompanionBuilder,
          (
            RecurringCostRow,
            BaseReferences<
              _$AppDatabase,
              $RecurringCostsTable,
              RecurringCostRow
            >,
          ),
          RecurringCostRow,
          PrefetchHooks Function()
        > {
  $$RecurringCostsTableTableManager(
    _$AppDatabase db,
    $RecurringCostsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> everyMonths = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringCostsCompanion(
                id: id,
                name: name,
                amountPaise: amountPaise,
                everyMonths: everyMonths,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int amountPaise,
                required int everyMonths,
                Value<int> rowid = const Value.absent(),
              }) => RecurringCostsCompanion.insert(
                id: id,
                name: name,
                amountPaise: amountPaise,
                everyMonths: everyMonths,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringCostsTable, RecurringCostRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecurringCostsTable,
                    RecurringCostRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringCostsTable,
      RecurringCostRow,
      $$RecurringCostsTableFilterComposer,
      $$RecurringCostsTableOrderingComposer,
      $$RecurringCostsTableAnnotationComposer,
      $$RecurringCostsTableCreateCompanionBuilder,
      $$RecurringCostsTableUpdateCompanionBuilder,
      (
        RecurringCostRow,
        BaseReferences<_$AppDatabase, $RecurringCostsTable, RecurringCostRow>,
      ),
      RecurringCostRow,
      PrefetchHooks Function()
    >;
typedef $$BalanceAnchorsTableCreateCompanionBuilder =
    BalanceAnchorsCompanion Function({
      Value<int> id,
      required int at,
      required int bankPaise,
      required int cashPaise,
      required int excludedPaise,
    });
typedef $$BalanceAnchorsTableUpdateCompanionBuilder =
    BalanceAnchorsCompanion Function({
      Value<int> id,
      Value<int> at,
      Value<int> bankPaise,
      Value<int> cashPaise,
      Value<int> excludedPaise,
    });

class $$BalanceAnchorsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bankPaise => $composableBuilder(
    column: $table.bankPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashPaise => $composableBuilder(
    column: $table.cashPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get excludedPaise => $composableBuilder(
    column: $table.excludedPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BalanceAnchorsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bankPaise => $composableBuilder(
    column: $table.bankPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashPaise => $composableBuilder(
    column: $table.cashPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get excludedPaise => $composableBuilder(
    column: $table.excludedPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BalanceAnchorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get bankPaise =>
      $composableBuilder(column: $table.bankPaise, builder: (column) => column);

  GeneratedColumn<int> get cashPaise =>
      $composableBuilder(column: $table.cashPaise, builder: (column) => column);

  GeneratedColumn<int> get excludedPaise => $composableBuilder(
    column: $table.excludedPaise,
    builder: (column) => column,
  );
}

class $$BalanceAnchorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceAnchorsTable,
          BalanceAnchorRow,
          $$BalanceAnchorsTableFilterComposer,
          $$BalanceAnchorsTableOrderingComposer,
          $$BalanceAnchorsTableAnnotationComposer,
          $$BalanceAnchorsTableCreateCompanionBuilder,
          $$BalanceAnchorsTableUpdateCompanionBuilder,
          (
            BalanceAnchorRow,
            BaseReferences<
              _$AppDatabase,
              $BalanceAnchorsTable,
              BalanceAnchorRow
            >,
          ),
          BalanceAnchorRow,
          PrefetchHooks Function()
        > {
  $$BalanceAnchorsTableTableManager(
    _$AppDatabase db,
    $BalanceAnchorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceAnchorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceAnchorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceAnchorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> bankPaise = const Value.absent(),
                Value<int> cashPaise = const Value.absent(),
                Value<int> excludedPaise = const Value.absent(),
              }) => BalanceAnchorsCompanion(
                id: id,
                at: at,
                bankPaise: bankPaise,
                cashPaise: cashPaise,
                excludedPaise: excludedPaise,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int at,
                required int bankPaise,
                required int cashPaise,
                required int excludedPaise,
              }) => BalanceAnchorsCompanion.insert(
                id: id,
                at: at,
                bankPaise: bankPaise,
                cashPaise: cashPaise,
                excludedPaise: excludedPaise,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BalanceAnchorsTable, BalanceAnchorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BalanceAnchorsTable,
                    BalanceAnchorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BalanceAnchorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceAnchorsTable,
      BalanceAnchorRow,
      $$BalanceAnchorsTableFilterComposer,
      $$BalanceAnchorsTableOrderingComposer,
      $$BalanceAnchorsTableAnnotationComposer,
      $$BalanceAnchorsTableCreateCompanionBuilder,
      $$BalanceAnchorsTableUpdateCompanionBuilder,
      (
        BalanceAnchorRow,
        BaseReferences<_$AppDatabase, $BalanceAnchorsTable, BalanceAnchorRow>,
      ),
      BalanceAnchorRow,
      PrefetchHooks Function()
    >;
typedef $$KeywordMappingsTableCreateCompanionBuilder =
    KeywordMappingsCompanion Function({
      required String keyword,
      required String category,
      Value<int> rowid,
    });
typedef $$KeywordMappingsTableUpdateCompanionBuilder =
    KeywordMappingsCompanion Function({
      Value<String> keyword,
      Value<String> category,
      Value<int> rowid,
    });

class $$KeywordMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $KeywordMappingsTable> {
  $$KeywordMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeywordMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KeywordMappingsTable> {
  $$KeywordMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeywordMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeywordMappingsTable> {
  $$KeywordMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$KeywordMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeywordMappingsTable,
          KeywordMappingRow,
          $$KeywordMappingsTableFilterComposer,
          $$KeywordMappingsTableOrderingComposer,
          $$KeywordMappingsTableAnnotationComposer,
          $$KeywordMappingsTableCreateCompanionBuilder,
          $$KeywordMappingsTableUpdateCompanionBuilder,
          (
            KeywordMappingRow,
            BaseReferences<
              _$AppDatabase,
              $KeywordMappingsTable,
              KeywordMappingRow
            >,
          ),
          KeywordMappingRow,
          PrefetchHooks Function()
        > {
  $$KeywordMappingsTableTableManager(
    _$AppDatabase db,
    $KeywordMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeywordMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeywordMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeywordMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> keyword = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeywordMappingsCompanion(
                keyword: keyword,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String keyword,
                required String category,
                Value<int> rowid = const Value.absent(),
              }) => KeywordMappingsCompanion.insert(
                keyword: keyword,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeywordMappingsTable, KeywordMappingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $KeywordMappingsTable,
                    KeywordMappingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeywordMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeywordMappingsTable,
      KeywordMappingRow,
      $$KeywordMappingsTableFilterComposer,
      $$KeywordMappingsTableOrderingComposer,
      $$KeywordMappingsTableAnnotationComposer,
      $$KeywordMappingsTableCreateCompanionBuilder,
      $$KeywordMappingsTableUpdateCompanionBuilder,
      (
        KeywordMappingRow,
        BaseReferences<_$AppDatabase, $KeywordMappingsTable, KeywordMappingRow>,
      ),
      KeywordMappingRow,
      PrefetchHooks Function()
    >;
typedef $$StreakDaysTableCreateCompanionBuilder = StreakDaysCompanion Function({
  required String date,
  required bool noSpend,
  Value<int> rowid,
});
typedef $$StreakDaysTableUpdateCompanionBuilder = StreakDaysCompanion Function({
  Value<String> date,
  Value<bool> noSpend,
  Value<int> rowid,
});

class $$StreakDaysTableFilterComposer
    extends Composer<_$AppDatabase, $StreakDaysTable> {
  $$StreakDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noSpend => $composableBuilder(
    column: $table.noSpend,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakDaysTable> {
  $$StreakDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noSpend => $composableBuilder(
    column: $table.noSpend,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakDaysTable> {
  $$StreakDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get noSpend =>
      $composableBuilder(column: $table.noSpend, builder: (column) => column);
}

class $$StreakDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakDaysTable,
          StreakDayRow,
          $$StreakDaysTableFilterComposer,
          $$StreakDaysTableOrderingComposer,
          $$StreakDaysTableAnnotationComposer,
          $$StreakDaysTableCreateCompanionBuilder,
          $$StreakDaysTableUpdateCompanionBuilder,
          (
            StreakDayRow,
            BaseReferences<_$AppDatabase, $StreakDaysTable, StreakDayRow>,
          ),
          StreakDayRow,
          PrefetchHooks Function()
        > {
  $$StreakDaysTableTableManager(_$AppDatabase db, $StreakDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> date = const Value.absent(),
            Value<bool> noSpend = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StreakDaysCompanion(date: date, noSpend: noSpend, rowid: rowid),
          createCompanionCallback:
              ({
                required String date,
                required bool noSpend,
                Value<int> rowid = const Value.absent(),
              }) => StreakDaysCompanion.insert(
                date: date,
                noSpend: noSpend,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreakDaysTable, StreakDayRow>(table),
                  BaseReferences<_$AppDatabase, $StreakDaysTable, StreakDayRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakDaysTable,
      StreakDayRow,
      $$StreakDaysTableFilterComposer,
      $$StreakDaysTableOrderingComposer,
      $$StreakDaysTableAnnotationComposer,
      $$StreakDaysTableCreateCompanionBuilder,
      $$StreakDaysTableUpdateCompanionBuilder,
      (
        StreakDayRow,
        BaseReferences<_$AppDatabase, $StreakDaysTable, StreakDayRow>,
      ),
      StreakDayRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$CyclesTableTableManager get cycles =>
      $$CyclesTableTableManager(_db, _db.cycles);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db, _db.allocations);
  $$DepositsTableTableManager get deposits =>
      $$DepositsTableTableManager(_db, _db.deposits);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AdjustmentsTableTableManager get adjustments =>
      $$AdjustmentsTableTableManager(_db, _db.adjustments);
  $$HoldsTableTableManager get holds =>
      $$HoldsTableTableManager(_db, _db.holds);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$SupplyItemsTableTableManager get supplyItems =>
      $$SupplyItemsTableTableManager(_db, _db.supplyItems);
  $$RecurringCostsTableTableManager get recurringCosts =>
      $$RecurringCostsTableTableManager(_db, _db.recurringCosts);
  $$BalanceAnchorsTableTableManager get balanceAnchors =>
      $$BalanceAnchorsTableTableManager(_db, _db.balanceAnchors);
  $$KeywordMappingsTableTableManager get keywordMappings =>
      $$KeywordMappingsTableTableManager(_db, _db.keywordMappings);
  $$StreakDaysTableTableManager get streakDays =>
      $$StreakDaysTableTableManager(_db, _db.streakDays);
}
