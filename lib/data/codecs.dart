import 'package:budget_engine/budget_engine.dart';

abstract final class Codecs {
  static String weights(CategoryWeights weights) =>
      BudgetCategory.weighted.map((category) => '${category.name}:${weights[category]}').join(',');

  static CategoryWeights parseWeights(String text) => CategoryWeights({
        for (final part in text.split(','))
          BudgetCategory.values.byName(part.split(':')[0]): int.parse(part.split(':')[1]),
      });

  static int instant(DateTime value) => value.toUtc().millisecondsSinceEpoch;

  static DateTime parseInstant(int value) => DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  static BudgetCategory category(String name) => BudgetCategory.values.byName(name);
}
