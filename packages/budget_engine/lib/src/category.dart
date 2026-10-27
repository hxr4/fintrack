enum CategoryTier { essential, stock, flexible, buffer, reserve, savings, correction }

enum BudgetCategory {
  food(CategoryTier.essential),
  petrol(CategoryTier.essential),
  nightFoodStock(CategoryTier.essential),
  essentialsStock(CategoryTier.stock),
  outings(CategoryTier.flexible),
  trySomethingNew(CategoryTier.flexible),
  misc(CategoryTier.flexible),
  buffer(CategoryTier.buffer),
  bikeFund(CategoryTier.reserve),
  recurringFund(CategoryTier.reserve),
  goals(CategoryTier.savings),
  unlogged(CategoryTier.correction);

  const BudgetCategory(this.tier);

  final CategoryTier tier;

  static const spendablePool = [food, outings, trySomethingNew];

  static const weighted = [food, petrol, outings, trySomethingNew, misc, buffer];

  static const blended = [food, petrol, outings, trySomethingNew, misc];

  static const essentials = [food, petrol, nightFoodStock];

  static const flexibleSavingsSources = [outings, trySomethingNew, misc];

  static const spendingCategories = [
    food,
    petrol,
    nightFoodStock,
    essentialsStock,
    outings,
    trySomethingNew,
    misc,
  ];

  bool get isEssential => tier == CategoryTier.essential;
  bool get isInSpendablePool => spendablePool.contains(this);

  static Map<BudgetCategory, T> filled<T>(T value) => {
        for (final category in BudgetCategory.values) category: value,
      };
}
