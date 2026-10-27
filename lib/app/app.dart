import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/preferences.dart';
import 'router.dart';
import 'state.dart';
import 'strings.dart';
import 'theme.dart';

class FintrackApp extends ConsumerStatefulWidget {
  const FintrackApp({super.key});

  @override
  ConsumerState<FintrackApp> createState() => _FintrackAppState();
}

class _FintrackAppState extends ConsumerState<FintrackApp> {
  late final AppLifecycleListener _lifecycle;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(lockProvider.notifier).onBackground(ref.read(clockProvider)()),
      onShow: () {
        ref.read(lockProvider.notifier).onForeground(ref.read(clockProvider)());
        ref.read(budgetProvider.notifier).refresh();
      },
    );
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => ref.read(budgetProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);
    final theme = state.value?.preferences.theme ?? ThemePreference.dark;
    if (!state.hasValue) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: state.hasError ? Text('${state.error}') : const CircularProgressIndicator(),
          ),
        ),
      );
    }
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme == ThemePreference.light ? ThemeMode.light : ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
