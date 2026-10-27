# DECISIONS

Decisions are numbered and never renumbered. When a decision changes, the old entry is marked superseded and a new one is added.

## Made in Phase 0

### D01. Toolchain
Flutter 3.47.8 stable, Dart 3.13.7, Android Gradle Plugin 9.1.0, Kotlin 2.4.0, Gradle 9.3.1, Java 17 bytecode. Android only. `minSdk 26`, `compileSdk` and `targetSdk` follow the Flutter defaults.

### D02. Package layout
- `packages/budget_engine`: pure Dart package for section 5. It has no Flutter dependency in its pubspec, so a Flutter import cannot compile, and a test also checks this. Run with `dart test` from that folder.
- `lib/`: the Flutter app, depending on the engine by path. Planned folders: `app` (router, theme, shell), `data` (Drift database, repositories), `features/<screen>` (UI and Riverpod providers per screen), `platform` (lock, notifications, widget, files).
- `assets/gear`: product images with `SOURCES.md` (phase 4).

### D03. Application id
`com.hari.fintrack`, display name "Fintrack". Changing the id after real data exists means a fresh install, so confirm or rename now (question Q12).

### D04. Money
All amounts are `int` paise. The engine wraps them in a `Money` value type with no `double` constructor. Splits use largest remainder, ties broken by fixed category order. Weights are integer basis points summing to 10,000 (FLAWS F26).

### D05. Time
Asia/Kolkata has no daylight saving, a fixed UTC+05:30. The engine works on civil dates (year, month, day) and IST instants passed in by the caller, so it needs no timezone database and is deterministic for a given input and "now". The app converts device time to IST with the `timezone` package and never reads the device locale or zone for cycle maths. A `Clock` abstraction is injected everywhere for fake-clock tests.

### D06. Dependencies
riverpod 3 (`flutter_riverpod`), `go_router`, `drift` with `drift_flutter`, `local_auth`, `flutter_local_notifications`, `timezone`, `home_widget`, `excel`, `pdf`, `flutter_animate`, `image_picker`, `path_provider`, `path`. Additionally `share_plus` for sharing exports and the family summary (section 10 asks for "shareable"). Dev: `build_runner`, `drift_dev`, `flutter_lints`. Core library desugaring is enabled, which `flutter_local_notifications` requires. `MainActivity` extends `FlutterFragmentActivity`, which `local_auth` requires.

### D07. SQLite binary
`sqlite3` 3.x bundles its own SQLite through a Dart build hook. It downloads a prebuilt, hash-verified binary at build time only; the app makes no network calls at runtime. Encryption is a one-line switch in `pubspec.yaml` (see Q1).

### D08. Code style
No comments in code files, including generated template files that were cleaned up. Strict analyzer modes (`strict-casts`, `strict-inference`, `strict-raw-types`) in both packages.

### D09. Mileage
Full-to-full method that sums partial fills in between (FLAWS F15). This reads "between consecutive full-tank fills" as the measuring points, not as a reason to drop intervals that contain partial fills.

### D10. Gradle networking and build warnings
`org.gradle.jvmargs` forces IPv4 (`-Djava.net.preferIPv4Stack=true`) because the JVM failed to resolve `dl.google.com` through the Tailscale DNS resolvers while macOS resolved it fine. Flutter warns that `home_widget` 0.10.0 still applies the Kotlin Gradle Plugin, which future Flutter versions will reject; check for an updated release before phase 7.

## Decided after the Phase 0 review

D10 was already taken by the Gradle note above, so Hari's answers start at D11.

### D11. Recommended defaults accepted
- Q1: no database encryption. The database is included in Android Auto Backup, and manual backups are encrypted with a passphrase.
- Q2: default weights Food 60, Petrol 14, Outings 9, Try something new 4, Misc 3, Buffer 10, confirmed again in onboarding.
- Q4: expected next start is the anchor day of a following month, clamped to month length and at least 14 days after the start (F02).
- Q5: a ninth, non-spendable Goals category, tier `savings` (F07).
- Q6: Buffer is fixed; the other five weights blend from the median of the last three cycles, moving at most 3 percentage points per cycle (F06).
- Q7: auto-adjust refills Food to floor times days left and Petrol to its prorated remaining floor (F08). The Food part is superseded by D23.
- Q8: allowance day boundary 04:00 IST; late-night mode from 00:00 to 04:00 (F10).
- Q9: a fifth notification type, "Upcoming due" (F16).
- Q10: USE_EXACT_ALARM while the app is sideloaded (F17).
- Q11: amounts visible in widget and notifications with a hide setting; FLAG_SECURE on with a toggle (F18).
- Q13: a clean day is a day that was fully logged or marked "no spend"; spending amount plays no part (F21).
- Q14: the Food card never turns red (F23).

### D12. Leftover at cycle end (Q3, F01, changed by Hari)
At cycle close:
- Night food stock and Essentials stock keep their balance up to their target. The new cycle tops them up to target instead of adding the full target, so a stock fund never exceeds its target. Anything above target goes to Buffer.
- Bike fund, Recurring fund and Goals keep their balance.
- Leftover Food, Petrol, Outings, Try something new, Misc and Unlogged go to Buffer.
- Buffer carries over, capped at two times the closing cycle's Buffer allocation. The excess joins the next cycle's allocation pool and is split by the weights with the new deposit. It is not part of the generosity delta.
- Negative leftovers (real overspending) reduce Buffer first, then the next cycle's pool.

The invariant is now: a cycle's allocations sum to its installments plus the carry into the pool, and opening balances plus allocations equal all the money carried in plus the installments.

### D13. Name and id (Q12)
"Fintrack", `com.hari.fintrack`.

### D14. Card payments (Q15, F27)
`PaymentMethod` is `cash`, `upi`, `card`, plus an internal `unrecorded` used only by balance-check corrections (D21). Reports include card. The add sheet shows cash and UPI only, unless "Card payments" is enabled in Settings.

### D15. Engine values come from settings (Q16)
The engine has no built-in amounts. `BudgetSettings` carries the food floor per day, petrol floor per cycle, night food stock target, anchor day, day boundary hour and default weights, filled from onboarding and settings. App-side defaults for onboarding: food floor ₹150 per day, petrol floor ₹1,200 per cycle, night food stock ₹750 per cycle, anchor day 5, boundary 04:00. For now: one monthly transfer, rent outside the budget with an excluded amount of 0, no recurring costs. Hari enters real values in onboarding.

Rules that come from the brief itself (generosity shares, the 70/30 blend, the 1.5x soft cap and so on) live in `BudgetPolicy` with the brief's values as defaults.

### D16. Deposits are a list (new requirement, F28)
Each `Deposit` is an `installment` or an `extra`. The planner uses only the cycle's installment total, generosity compares installment totals per cycle, and only extras get the positive-delta split. Phase 1 implements the single monthly installment; the schema and types never assume one deposit per cycle.

### D17. Phase 9: payment notification capture (I01 approved)
Runs after phase 8. Constraints:
- The notification listener handles only an allowlist of payment-app and bank-app packages. Every other notification is discarded immediately, without reading its content.
- Raw notification text is never stored, only the parsed amount, merchant string and timestamp.
- It always creates a suggestion card to confirm, never a transaction.
- The vivo setup steps are documented.
- A notification listener is preferred over SMS read permission.
- Android's restricted-settings block for sideloaded apps is handled first (F29).

## Engine design decisions (Phase 1)

### D18. Categories are a fixed enum
`BudgetCategory` lists the launch categories plus Goals (`savings`), Bike fund and Recurring fund (`reserve`, F30), and Unlogged (`correction`). The database stores the enum name. Display names, icons and colours belong to the app.

### D19. Ordered rules
- Allocation, after floors are raised (the final cuts are superseded by D26): Try something new, Outings, Buffer, this cycle's Goals allocation, supply items not due this cycle (least urgent first). If still short: Misc, Recurring fund, Bike fund, supply items due this cycle, Night food stock top-up, Petrol, then Food (F31, F34).
- Auto-adjust donors: Buffer, Try something new, Outings, Essentials stock above what is reserved for items due this cycle. Held money is never a donor (D23).
- Unlogged balance-check spending is covered from: Try something new, Outings, Misc, Buffer, spare Essentials stock, Petrol down to its remaining floor, Food down to its remaining floor. Goals savings are never touched automatically.

### D20. Interpretations of the brief
- "From the third completed cycle" means blending starts once three cycles have completed, so the fourth plan is the first blended one. A median needs three data points.
- Petrol floor per cycle is prorated to the cycle's length against 30 days, rounded up.
- Base daily is the spendable pool at cycle start divided by cycle length (F05).
- Banked money is the total of the pool above base pace for the rest of the cycle: pool minus base daily times days left. Moving banked money takes from Try something new, then Outings, then Food down to floor times days left.
- Runway uses pool-category spending on completed days of this cycle in the last seven, base daily on day one, and reports "comfortable" when the average is zero (F11).
- Awaiting deposit: leftover pool divided by days until the expected start plus three, at least three days (F03).

### D21. Balance-check corrections
A shortfall becomes a transaction in Unlogged with method `unrecorded` and source `balanceCheck`. Adjustments then cover it from the D19 order, so the replan is visible in the ledger. A surplus becomes a negative correction transaction in Unlogged, moved to Buffer. Negative amounts are allowed only for balance-check corrections. "Distribute" writes correction transactions per category by this cycle's spending shares. "Ignore" changes nothing, so the next check shows the same difference.

### D22. Purchase planner scenarios
Savings come from Outings, Try something new and Misc at the current daily rate, plus lump sums. Fast uses 75 percent of the flexible daily rate, all banked money and half the Buffer. Balanced uses 50 percent and banked money. Slow uses 25 percent. Trade-offs are shown as skipped outings and treats, using the median transaction size in Outings and Try something new, or fallback costs passed in by the app (₹400 and ₹150 until there is history). If a target date can't be met even at 100 percent of the flexible rate plus all banked money and Buffer, the plan says so and gives the earliest possible date and the extra income needed.

## Decided after the Phase 1 review

### D23. Food refills move one week and hold the rest (F35, Hari's design)
When Food reaches zero:
1. Floor x min(days left, 7) is moved into Food from the donors (Buffer, Try something new, Outings, spare Essentials stock) as a normal ledger move. Any overshoot below zero is covered too.
2. A hold is placed on the donors, in the same order, for the rest of the commitment: floor x days left beyond 7, minus anything already held. Held money stays in its category but is not spendable. The spendable pool, allowance, banked money, balance-check cover and later refills all exclude it.
3. At each weekly rollover (7 allowance days after the commitment's last move or release), or when Food reaches zero again, up to 7 days of the hold are released into Food as normal ledger moves, oldest commitment first.
4. The summary shows "Moved X, holding Y" (`totalMoved`, `totalHeld`).
5. Holds are stored as `Hold` rows: positive to place, negative to release, each tagged with its commitment. Undo (`BatchUndo`) reverses a batch's moves and holds together, and cascades to later releases from that commitment, so the exact earlier state comes back.
6. Holds are dropped at cycle close. The held money is still in its category and is swept by the normal close rules (D12).
7. If the donors cannot cover the hold, the uncovered amount is reported at once as `holdShortfall`.
8. If Food reaches zero before day 10 of the cycle, `suggestReplan` is set, and the UI offers the balance check and family summary as well as the normal summary.
9. Weekly rollover releases at most one week per check, so a missed week releases on the next daily check. If Food still hits zero, the zero trigger releases more.

Petrol and Night food stock keep the plain refill (prorated floor and zero).

### D24. Bike fund and Recurring fund (F30 confirmed)
Both are non-spendable like Goals, get no card on the home screen, and appear under Supplies and Bike.

### D25. Misc stays out of the donor orders (F31 confirmed)

### D26. Shortfall cut order (F34, changed by Hari)
After the brief's absorption order is exhausted: Misc, Recurring fund, Bike fund, supply items already due (least urgent first), Petrol, Night food stock, and Food last.
