import 'category.dart';

enum ScenarioPace { fast, balanced, slow }

final class ScenarioRule {
  const ScenarioRule({
    required this.pace,
    required this.flexiblePercent,
    required this.bufferPercent,
    required this.usesBanked,
  });

  final ScenarioPace pace;
  final int flexiblePercent;
  final int bufferPercent;
  final bool usesBanked;
}

final class BudgetPolicy {
  const BudgetPolicy({
    this.minimumCycleDays = 14,
    this.awaitingGraceDays = 3,
    this.awaitingMinimumDays = 3,
    this.petrolFloorReferenceDays = 30,
    this.baselineCycles = 3,
    this.blendingStartsAfterCompletedCycles = 3,
    this.blendingWindowCycles = 3,
    this.blendActualPercent = 70,
    this.maxWeightChangeBasisPoints = 300,
    this.generosityShares = const {
      BudgetCategory.food: 5000,
      BudgetCategory.outings: 2000,
      BudgetCategory.trySomethingNew: 1000,
      BudgetCategory.buffer: 1000,
      BudgetCategory.goals: 1000,
    },
    this.softCapNumerator = 3,
    this.softCapDenominator = 2,
    this.runwayWindowDays = 7,
    this.bufferCarryCycles = 2,
    this.foodRefillDays = 7,
    this.replanPromptBeforeDay = 10,
    this.scenarios = const [
      ScenarioRule(pace: ScenarioPace.fast, flexiblePercent: 75, bufferPercent: 50, usesBanked: true),
      ScenarioRule(pace: ScenarioPace.balanced, flexiblePercent: 50, bufferPercent: 0, usesBanked: true),
      ScenarioRule(pace: ScenarioPace.slow, flexiblePercent: 25, bufferPercent: 0, usesBanked: false),
    ],
  });

  final int minimumCycleDays;
  final int awaitingGraceDays;
  final int awaitingMinimumDays;
  final int petrolFloorReferenceDays;
  final int baselineCycles;
  final int blendingStartsAfterCompletedCycles;
  final int blendingWindowCycles;
  final int blendActualPercent;
  final int maxWeightChangeBasisPoints;
  final Map<BudgetCategory, int> generosityShares;
  final int softCapNumerator;
  final int softCapDenominator;
  final int runwayWindowDays;
  final int bufferCarryCycles;
  final int foodRefillDays;
  final int replanPromptBeforeDay;
  final List<ScenarioRule> scenarios;
}
