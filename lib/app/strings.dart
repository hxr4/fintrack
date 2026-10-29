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
  static const leftoverLabel = 'Money already in hand';
  static const leftoverHint = 'Money you had before this deposit. It joins this month\'s plan.';
  static String balancesGapMessage(String total, String parts) =>
      'Bank plus cash, minus money not for this budget, comes to $total. This month\'s money plus money already in hand comes to $parts. They need to match.';
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

  static const planTools = 'Tools';
  static const balanceCheckHint = 'Compare what is in the bank and in your pocket with what the app expects';
  static const suppliesAndBike = 'Supplies and bike';
  static const suppliesAndBikeHint = 'Restocks, fuel log, service and documents';
  static const recurringCosts = 'Recurring costs';
  static const budgetValuesHint2 = 'Floors, night food stock, usual deposit day and the split';

  static const tabSupplies = 'Supplies';
  static const tabBike = 'Bike';
  static const tabRecurring = 'Recurring';
  static String fundLeft(String name, String amount) => '$name: $amount';
  static String savedOf(String saved, String price) => '$saved saved of $price';
  static String daysLeftLabel(int days) => days == 0 ? 'Due now' : (days == 1 ? '1 day left' : '$days days left');
  static String lifespanLine(int days) => 'Lasts about $days days';
  static const restocked = 'Restocked';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const amountPaid = 'Amount paid';
  static const noSupplies = 'No supply items yet';
  static const editSupply = 'Edit supply item';
  static String restockLogged(String name) => 'Restock of $name logged';
  static const newItemsNextCycle = 'Changes here are set aside for from the next cycle.';

  static const fuelSummary = 'Fuel';
  static String mileage(String kmPerLitre) => '$kmPerLitre km per litre';
  static String latestMileage(String kmPerLitre) => 'Last full tank: $kmPerLitre km per litre';
  static String costPerKm(String amount) => '$amount per km';
  static String kmPerDay(String km) => 'About $km km a day lately';
  static String petrolSuggestion(String suggested, String floor) =>
      'Recent riding suggests about $suggested per cycle. The petrol floor is $floor.';
  static const mileageNeedsTwoFull = 'Mileage shows after two full-tank fills.';
  static const logFuel = 'Log fuel';
  static const pricePerLitre = 'Price per litre';
  static const odometer = 'Odometer (km)';
  static const fullTank = 'Filled to full';
  static String litres(String value) => '$value L';
  static const recentFills = 'Recent fills';
  static String fillLine(String date, String litres, int odometer, bool full) =>
      '$date · $litres · $odometer km${full ? ' · full' : ''}';
  static const odometerTooLow = 'Odometer is lower than the last fill';
  static String fuelLogged(String amount) => 'Fuel of $amount logged in Petrol';

  static const service = 'Service';
  static const serviceNotSet = 'Add the service interval to see when it is due.';
  static String serviceDue(String when) => 'Next service: $when';
  static String serviceDueDays(int days) => days <= 0 ? 'due now' : 'in about $days days';
  static String serviceDueKm(int km) => km <= 0 ? 'due by distance' : '$km km to go';
  static const editService = 'Service details';
  static const serviceIntervalKm = 'Service every how many km';
  static const serviceIntervalMonths = 'Or every how many months';
  static const serviceCost = 'Usual service cost';
  static const lastServiceDate = 'Last service date';
  static const lastServiceKm = 'Odometer at last service (km)';
  static const recordService = 'Record a service';
  static const serviceLogged = 'Service logged';
  static const notSet = 'Not set';
  static const documents = 'Documents';
  static const insuranceExpiry = 'Insurance expires';
  static const pucExpiry = 'PUC expires';
  static String expiresIn(String date, int days) =>
      days < 0 ? '$date, expired' : (days == 0 ? '$date, today' : '$date, in $days days');
  static const optionalNumber = 'Leave empty if unknown';

  static const noRecurring = 'No recurring costs';
  static String perCycle(String amount) => '$amount set aside each cycle';
  static const paid = 'Paid';
  static const editRecurring = 'Edit recurring cost';
  static String recurringPaid(String name) => '$name payment logged';

  static const balanceCheckTitle = 'Balance check';
  static const balanceCheckIntro =
      'Enter what is in your bank account and in your pocket right now. The app compares it with what it expects from your entries.';
  static const balanceCheckHelp =
      'The amount compared is bank plus cash, minus money in the account that is not for this budget, such as rent. If this month\'s money has just arrived, log it from Money arrived first.';
  static const depositLookalikeTitle = 'This looks like this month\'s money. Log it first?';
  static String depositLookalikeBody(String amount) =>
      'The extra $amount is close to your usual monthly money. If it has arrived, log it as Monthly money and then compare again.';
  static const compare = 'Compare';
  static const expected = 'Expected';
  static const actual = 'Actual';
  static String lastChecked(String date) => 'Compared with the check on $date';
  static const balanceMatches = 'Everything matches.';
  static String balanceLower(String amount) =>
      'Your money is $amount lower than the app expected. That usually means a few spends were not logged.';
  static String balanceHigher(String amount) =>
      'Your money is $amount higher than the app expected. That can happen when something was logged twice or money came in.';
  static const resolveUnlogged = 'Log it as unlogged spending';
  static const resolveUnloggedHint = 'Taken from flexible categories and Buffer first. Floors stay protected.';
  static const resolveDistribute = 'Spread it across categories';
  static const resolveDistributeHint = 'Split by how you have spent this cycle.';
  static const resolveIgnore = 'Leave it as it is';
  static const resolveIgnoreHint = 'Nothing changes. The next check will show the same difference.';
  static const apply = 'Apply';
  static const balanceUpdated = 'Plan updated from your real balance';
  static String balanceUncovered(String amount) => '$amount could not be covered without touching floors. It shows as a shortfall.';

  static const budgetValuesTitle = 'Budget values';
  static const budgetValuesNote =
      'Floors apply straight away. The split and night food stock apply from the next cycle. A new deposit day moves this cycle\'s expected end if that date is still ahead.';
  static const budgetValuesSaved = 'Budget values saved';

  static const demoData = 'Load three demo months';
  static const demoDataHint = 'Debug builds only. Fills this empty install with simulated data.';

  static const backupTitle = 'Backup and restore';
  static const backupHint = 'Encrypted backup file, saved to Downloads';
  static const backupNotice =
      'Everything in Fintrack lives only on this phone. Uninstalling the app or resetting the phone erases it. Keep a recent backup somewhere other than this phone.';
  static String lastBackup(String when) => 'Last backup: $when';
  static const neverBackedUp = 'No backup yet';
  static const createBackup = 'Create backup';
  static const restoreBackup = 'Restore from a backup';
  static const passphrase = 'Passphrase';
  static const confirmPassphrase = 'Type the passphrase again';
  static const passphraseHint =
      'At least 8 characters. Without it the backup cannot be opened, so keep it in a password manager.';
  static const passphraseTooShort = 'Use at least 8 characters';
  static const passphraseMismatch = 'The two passphrases differ';
  static const creatingBackup = 'Creating backup';
  static const restoringBackup = 'Restoring';
  static String savedTo(String location) => 'Saved to $location';
  static const share = 'Share';
  static const notSaved = 'The backup was created but not saved. Use Share to keep it.';
  static String restoreConfirm(String date) =>
      'This replaces everything in Fintrack with the backup from $date. Anything logged since then is lost.';
  static const restore = 'Restore';
  static const restored = 'Backup restored';
  static const backupNotABackup = 'That file is not a Fintrack backup.';
  static const backupWrongPassphrase = 'The passphrase is wrong, or the file has been changed.';
  static const backupNewer = 'That backup was made by a newer version of Fintrack. Update the app first.';
  static const backupDamaged = 'That backup file is damaged.';
  static const restoreOnboardingHint = 'Already used Fintrack? Restore a backup instead of setting up again.';

  static const profile = 'Profile';
  static const yourName = 'Your name';
  static const aboutYou = 'About you';
  static const aboutYouHint = 'Course, college, city, anything you like';
  static const editProfile = 'Edit profile';
  static const changePhoto = 'Change photo';
  static const takePhoto = 'Take a photo';
  static const chooseFromGallery = 'Choose from gallery';
  static const gear = 'Gear';
  static const addGear = 'Add gear';
  static const gearName = 'Name';
  static const gearVariant = 'Variant, colour or configuration';
  static const specs = 'Specs';
  static const purchaseDate = 'Purchase date';
  static const pricePaid = 'Price paid';
  static const seller = 'Seller';
  static const warrantyEnds = 'Warranty ends';
  static const notes = 'Notes';
  static const billPhoto = 'Bill photo';
  static const addBillPhoto = 'Add bill photo';
  static const useMyPhoto = 'Use my own photo';
  static const deleteGear = 'Remove this item';
  static const gearSaved = 'Saved';
  static String costPerDay(String amount) => '$amount per day so far';
  static String ownedFor(int days) => days == 1 ? 'Owned for 1 day' : 'Owned for $days days';
  static String warrantyLeft(int days) =>
      days < 0 ? 'Warranty ended' : (days == 0 ? 'Warranty ends today' : 'Warranty: $days days left');
  static const missingDetails = 'Add the purchase date and price to see cost per day.';
  static const odometerLabel = 'Odometer';
  static String odometerValue(int km) => '$km km';
  static const bikeDetails = 'Service, fuel and documents';
  static const openBike = 'Open bike log';
  static const photoPlaceholder = 'No photo yet';
}
