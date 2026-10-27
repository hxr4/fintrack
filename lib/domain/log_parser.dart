import 'package:budget_engine/budget_engine.dart';

import 'rupees.dart';

final class ParsedEntry {
  const ParsedEntry({required this.amount, required this.category, required this.note, required this.keyword});

  final Money amount;
  final BudgetCategory? category;
  final String note;
  final String? keyword;
}

abstract final class LogParser {
  static const builtInKeywords = <String, BudgetCategory>{
    'breakfast': BudgetCategory.food,
    'lunch': BudgetCategory.food,
    'dinner': BudgetCategory.food,
    'food': BudgetCategory.food,
    'meal': BudgetCategory.food,
    'mess': BudgetCategory.food,
    'canteen': BudgetCategory.food,
    'tea': BudgetCategory.food,
    'chai': BudgetCategory.food,
    'coffee': BudgetCategory.food,
    'juice': BudgetCategory.food,
    'snack': BudgetCategory.food,
    'snacks': BudgetCategory.food,
    'swiggy': BudgetCategory.food,
    'zomato': BudgetCategory.food,
    'petrol': BudgetCategory.petrol,
    'fuel': BudgetCategory.petrol,
    'bunk': BudgetCategory.petrol,
    'maggi': BudgetCategory.nightFoodStock,
    'noodles': BudgetCategory.nightFoodStock,
    'biscuits': BudgetCategory.nightFoodStock,
    'soap': BudgetCategory.essentialsStock,
    'shampoo': BudgetCategory.essentialsStock,
    'toothpaste': BudgetCategory.essentialsStock,
    'detergent': BudgetCategory.essentialsStock,
    'movie': BudgetCategory.outings,
    'outing': BudgetCategory.outings,
    'trip': BudgetCategory.outings,
    'cafe': BudgetCategory.outings,
    'party': BudgetCategory.outings,
    'treat': BudgetCategory.trySomethingNew,
    'new': BudgetCategory.trySomethingNew,
    'data': BudgetCategory.misc,
    'pack': BudgetCategory.misc,
    'print': BudgetCategory.misc,
    'xerox': BudgetCategory.misc,
  };

  static ParsedEntry? parse(String input, {Map<String, BudgetCategory> learned = const {}}) {
    final tokens = input.trim().toLowerCase().split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
    Money? amount;
    final words = <String>[];
    for (final token in tokens) {
      final value = amount == null ? Rupees.parse(token.replaceAll('rs', '')) : null;
      if (value != null && value.isPositive) {
        amount = value;
      } else {
        words.add(token);
      }
    }
    if (amount == null) {
      return null;
    }
    BudgetCategory? category;
    String? keyword;
    for (final word in words) {
      final match = learned[word] ?? builtInKeywords[word];
      if (match != null) {
        category = match;
        keyword = word;
        break;
      }
    }
    return ParsedEntry(
      amount: amount,
      category: category,
      note: words.join(' '),
      keyword: keyword ?? (words.isEmpty ? null : words.first),
    );
  }
}
