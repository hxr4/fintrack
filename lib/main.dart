import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/state.dart';
import 'data/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.open();
  runApp(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(database)],
    child: const FintrackApp(),
  ));
}
