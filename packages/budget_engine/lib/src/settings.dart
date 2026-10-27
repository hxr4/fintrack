import 'money.dart';
import 'weights.dart';

final class BudgetSettings {
  BudgetSettings({
    required this.foodFloorPerDay,
    required this.petrolFloorPerCycle,
    required this.nightFoodStockTarget,
    required this.anchorDay,
    required this.dayBoundaryHour,
    required this.defaultWeights,
  }) {
    for (final (name, value) in [
      ('foodFloorPerDay', foodFloorPerDay),
      ('petrolFloorPerCycle', petrolFloorPerCycle),
      ('nightFoodStockTarget', nightFoodStockTarget),
    ]) {
      if (value.isNegative) {
        throw ArgumentError.value(value, name, 'must not be negative');
      }
    }
    if (anchorDay < 1 || anchorDay > 31) {
      throw ArgumentError.value(anchorDay, 'anchorDay', 'must be 1 to 31');
    }
    if (dayBoundaryHour < 0 || dayBoundaryHour > 23) {
      throw ArgumentError.value(dayBoundaryHour, 'dayBoundaryHour', 'must be 0 to 23');
    }
  }

  final Money foodFloorPerDay;
  final Money petrolFloorPerCycle;
  final Money nightFoodStockTarget;
  final int anchorDay;
  final int dayBoundaryHour;
  final CategoryWeights defaultWeights;

  BudgetSettings copyWith({
    Money? foodFloorPerDay,
    Money? petrolFloorPerCycle,
    Money? nightFoodStockTarget,
    int? anchorDay,
    int? dayBoundaryHour,
    CategoryWeights? defaultWeights,
  }) =>
      BudgetSettings(
        foodFloorPerDay: foodFloorPerDay ?? this.foodFloorPerDay,
        petrolFloorPerCycle: petrolFloorPerCycle ?? this.petrolFloorPerCycle,
        nightFoodStockTarget: nightFoodStockTarget ?? this.nightFoodStockTarget,
        anchorDay: anchorDay ?? this.anchorDay,
        dayBoundaryHour: dayBoundaryHour ?? this.dayBoundaryHour,
        defaultWeights: defaultWeights ?? this.defaultWeights,
      );
}
