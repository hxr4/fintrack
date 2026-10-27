import 'package:budget_engine/budget_engine.dart';

import '../domain/health.dart';

abstract final class S {
  static const appName = 'Fintrack';

  static String categoryName(BudgetCategory category) => switch (category) {
        BudgetCategory.food => 'Food',
        BudgetCategory.petrol => 'Petrol',
        BudgetCategory.nightFoodStock => 'Night food stock',
        BudgetCategory.essentialsStock => 'Essentials stock',
        BudgetCategory.outings => 'Outings',
        BudgetCategory.trySomethingNew => 'Try something new',
        BudgetCategory.misc => 'Misc and data packs',
        BudgetCategory.buffer => 'Buffer',
        BudgetCategory.bikeFund => 'Bike fund',
        BudgetCategory.recurringFund => 'Recurring fund',
        BudgetCategory.goals => 'Goals',
        BudgetCategory.unlogged => 'Unlogged',
      };

  static String shortCategoryName(BudgetCategory category) => switch (category) {
        BudgetCategory.nightFoodStock => 'Night food',
        BudgetCategory.essentialsStock => 'Essentials',
        BudgetCategory.trySomethingNew => 'Try new',
        BudgetCategory.misc => 'Misc',
        _ => categoryName(category),
      };

  static String methodName(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.upi => 'UPI',
        PaymentMethod.card => 'Card',
        PaymentMethod.unrecorded => 'Unrecorded',
      };

  static String healthLabel(HealthState state) => switch (state) {
        HealthState.comfortable => 'On track',
        HealthState.tight => 'Running tight',
        HealthState.limit => 'At the limit',
        HealthState.neutral => 'Saved',
      };

  static const foodCoveredByFloor = 'Food is covered by the floor';
  static const notSpendable = 'Not for daily spending';

  static String greeting(int hour) {
    if (hour >= 4 && hour < 12) {
      return 'Good morning';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    }
    if (hour >= 17 && hour < 22) {
      return 'Good evening';
    }
    return 'Hello, night owl';
  }

  static String cycleLine(int day, int length, int left) => 'Day $day of $length, $left left';
  static String awaitingLine(int days) => 'Waiting for money to arrive. Planning for $days more days';
  static const awaitingBannerTitle = 'Money has not arrived yet';
  static const awaitingBannerBody =
      'Today\'s amount is worked out from what is left. Log the deposit from Plan when it lands.';

  static const leftToday = 'left today';
  static const overToday = 'over today\'s amount';
  static const pool = 'Pool';
  static const banked = 'Banked';
  static const bankedHint = 'Extra above your usual daily pace. Still spendable.';
  static const moveBanked = 'Move banked money';
  static const moveToBuffer = 'Move to Buffer';
  static const moveToGoals = 'Move to Goals';
  static String bankedMoved(String amount, String target) => 'Moved $amount to $target';

  static String runwaySpare(String date, int days) =>
      days == 0 ? 'At this pace, money lasts until $date' : 'At this pace, money lasts until $date, $days days spare';
  static String runwayShort(String date, int days) => 'At this pace, money lasts until $date, $days days short';
  static const runwayComfortable = 'Comfortable to the end of the cycle';

  static const custom = 'Custom';
  static String quickChip(String amount, BudgetCategory category) => '+$amount ${shortCategoryName(category)}';
  static const typeToLogHint = 'Type to log, like 40 lunch';
  static const typeToLogNotUnderstood = 'Add an amount, like 40 lunch';
  static const confirm = 'Save';
  static const cancel = 'Cancel';
  static const change = 'Change';

  static String logged(String amount, BudgetCategory category) => 'Logged $amount in ${categoryName(category)}';
  static const undo = 'Undo';
  static const deleted = 'Entry removed';

  static const addTitle = 'Add spend';
  static const note = 'Note';
  static const noteHint = 'Optional';
  static const save = 'Save';
  static const enterAmount = 'Enter an amount';

  static String summaryMoved(String moved, List<BudgetCategory> targets) =>
      'Moved $moved into ${targets.map(categoryName).join(' and ')}';
  static String summaryHolding(String held) => 'Holding $held for the coming weeks';
  static String summaryShortfall(String amount) =>
      'The flexible categories could not cover $amount. It is shown as a shortfall in Plan.';
  static const summaryExplain =
      'Food has a floor, so it was topped up from Buffer and the flexible categories. Held money stays where it is and moves into Food a week at a time.';
  static const gotIt = 'Got it';
  static const replanTitle = 'Food ran out early this cycle';
  static const replanBody =
      'That happens. A balance check or a family summary can help reset the plan for the rest of the month.';
  static const balanceCheck = 'Balance check';
  static const familySummary = 'Family summary';
  static const comingLater = 'This arrives in a later update';

  static const lateNightTitle = 'Late night';
  static String lateNightStock(String amount) => 'Night food stock has $amount left';
  static const lateNightLines = [
    'Hungry is fine. Eat something and get some rest.',
    'Night food stock is there for exactly this.',
    'A warm snack and some sleep sounds good.',
  ];

  static const todaysIdea = 'Today\'s idea';
  static const ideas = [
    'Try a new dish at the mess or canteen this week.',
    'A short evening ride somewhere new costs very little.',
    'Check what is left in the night food stock and top it up while it is cheap.',
    'Cook or make something simple with a friend.',
    'Look for a free event or club meeting on campus.',
    'Write down one thing you enjoyed buying this week.',
    'Fill the tank when you are already near a pump.',
    'Try a fruit you have not had in a while.',
    'Plan one outing for the weekend and give it a budget.',
    'Carry a water bottle on long rides.',
  ];

  static const navHome = 'Home';
  static const navPlan = 'Plan';
  static const navGoals = 'Goals';
  static const navReport = 'Report';

  static const lockTitle = 'Fintrack is locked';
  static const unlock = 'Unlock';
  static const unlockReason = 'Unlock Fintrack';
  static const lockUnavailable =
      'This phone has no screen lock set up, so Fintrack cannot ask for a fingerprint or PIN. Set a screen lock in phone settings to protect it.';
  static const continueAnyway = 'Continue';
  static const lockNow = 'Lock now';
  static const unlockFailed = 'Not unlocked. Try again.';

  static const settings = 'Settings';
  static const settingCard = 'Card payments';
  static const settingCardHint = 'Show Card as a payment method when adding a spend';
  static const settingSecure = 'Hide screen in recent apps';
  static const settingSecureHint = 'Also blocks screenshots';
  static const settingLight = 'Light theme';
  static const budgetValues = 'Budget values';
  static const budgetValuesHint = 'Set during onboarding. Editing arrives with the Plan screen.';
  static const foodFloorLabel = 'Food floor per day';
  static const petrolFloorLabel = 'Petrol floor per cycle';
  static const nightFoodLabel = 'Night food stock per cycle';
  static const anchorDayLabel = 'Usual deposit day';

  static const onboardingWelcomeTitle = 'Welcome to Fintrack';
  static const onboardingWelcomeBody =
      'A few questions to set up this month. Everything stays on this phone, and every value can be changed later.';
  static const start = 'Start';
  static const next = 'Next';
  static const back = 'Back';
  static const finish = 'Finish setup';
  static const depositTitle = 'This month\'s money';
  static const depositAmount = 'Amount received';
  static const depositDate = 'Date it arrived';
  static const anchorDayHint = 'Day of the month it usually arrives';
  static const floorsTitle = 'Floors and stock';
  static const floorsBody = 'Floors are never cut by any automatic rule.';
  static const weightsTitle = 'How the rest is split';
  static String weightsTotal(int total) => 'Total $total of 100';
  static const weightsMustBe100 = 'The split must add up to 100';
  static const balancesTitle = 'Money right now';
  static const balancesBody =
      'Used later by the balance check. Include this month\'s deposit if it has arrived.';
  static const bankBalance = 'Bank balance';
  static const cashInHand = 'Cash in hand';
  static const excludedAmount = 'Money in the account that is not for this budget';
  static const excludedHint = 'For example rent or savings. Leave 0 if none.';
  static const recurringTitle = 'Recurring costs';
  static const recurringBody = 'Anything that repeats, like a subscription. Skip if none.';
  static const addRecurring = 'Add recurring cost';
  static const name = 'Name';
  static const amount = 'Amount';
  static const everyMonths = 'Every how many months';
  static const suppliesTitle = 'Supplies';
  static const suppliesBody = 'Things you restock, like soap or shampoo. Skip if you prefer to add them later.';
  static const addSupply = 'Add supply item';
  static const price = 'Price';
  static const lifespanDays = 'Lasts how many days';
  static const lastRestock = 'Last bought';
  static const paymentsTitle = 'Payments';
  static const paymentsBody = 'Cash and UPI are always available.';
  static const enableCard = 'I also pay by card';
  static const required = 'Required';
  static const invalidAmount = 'Enter a valid amount';
  static const invalidDay = 'Enter a day from 1 to 31';
  static const invalidNumber = 'Enter a whole number';
  static const add = 'Add';
  static String recurringLine(String amount, int months) =>
      months == 1 ? '$amount every month' : '$amount every $months months';
  static String supplyLine(String price, int days) => '$price, lasts $days days';
  static String parsedChip(String amount, BudgetCategory category) => '$amount · ${categoryName(category)}';
  static const remove = 'Remove';
  static String shortfallNote(String amount) =>
      'This month\'s money is $amount short of the floors. The plan shows exactly where, and a family summary can explain it.';

  static const planTitle = 'Plan';
  static const cycleDates = 'This cycle';
  static String cycleRange(String start, String end, int length) => '$start to $end, $length days';
  static const baseDaily = 'Usual daily amount';
  static const shortfall = 'Shortfall';
  static const moneyArrived = 'Money arrived';
  static const depositKindInstallment = 'Monthly money';
  static const depositKindExtra = 'Extra income';
  static const depositKindHint =
      'Monthly money starts a new cycle. Extra income is shared out across the rest of this cycle.';
  static const depositDateTooEarly = 'Pick a date after this cycle started';
  static const depositDateInFuture = 'Pick today or an earlier date';
  static const newCycleStarted = 'New cycle started';
  static const extraAdded = 'Extra income added';
  static const balanceCheckLater = 'Balance check arrives in the next update.';

  static const goalsTitle = 'Goals';
  static const goalsLater = 'The purchase planner arrives in a later update.';
  static String goalsSaved(String amount) => 'Saved for goals: $amount';

  static const reportTitle = 'Report';
  static const reportLater = 'Reports and exports arrive in a later update.';
  static const allTransactions = 'All entries this cycle';

  static const transactionsTitle = 'Entries this cycle';
  static const noTransactions = 'Nothing logged yet';
  static const spentThisCycle = 'Spent this cycle';
  static const leftLabel = 'Left';
  static String heldLine(String amount) => '$amount held for later weeks';
  static String paceLine(String spent, String expected) => 'Spent $spent so far. At an even pace it would be $expected';
  static const moves = 'Moves';
  static String moveIn(String amount, BudgetCategory from) => '$amount in from ${categoryName(from)}';
  static String moveOut(String amount, BudgetCategory to) => '$amount out to ${categoryName(to)}';
  static String holdPlaced(String amount) => '$amount held';
  static String holdReleased(String amount) => '$amount released';
  static const undone = 'Undone';
  static const today = 'Today';
  static const yesterday = 'Yesterday';
}
