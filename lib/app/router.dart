import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/category/category_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lock/lock_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/report/report_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'state.dart';
import 'strings.dart';

final class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(budgetProvider.select((value) => value.value?.ready ?? false), (_, _) => notifyListeners());
    ref.listen(lockProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final app = ref.read(budgetProvider).value;
      if (app == null) {
        return null;
      }
      final path = state.matchedLocation;
      if (!app.ready) {
        return path == '/onboarding' ? null : '/onboarding';
      }
      if (ref.read(lockProvider)) {
        return path == '/lock' ? null : '/lock';
      }
      if (path == '/lock' || path == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
      GoRoute(
        path: '/category/:name',
        builder: (context, state) =>
            CategoryScreen(category: BudgetCategory.values.byName(state.pathParameters['name']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/plan', builder: (context, state) => const PlanScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/report', builder: (context, state) => const ReportScreen())]),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: S.navHome),
          NavigationDestination(icon: Icon(Icons.timeline_outlined), selectedIcon: Icon(Icons.timeline), label: S.navPlan),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: S.navGoals),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: S.navReport),
        ],
      ),
    );
  }
}
