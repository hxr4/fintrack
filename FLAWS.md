# FLAWS

Review of BUILD_BRIEF.md before any feature code. Each entry gives the problem, why it matters, the proposed fix, and whether a decision is needed from Hari. Entries marked **Decision: yes** are mirrored as questions in DECISIONS.md under "Open questions".

Status values: `open` (waiting on a decision), `planned` (fix agreed or needs no decision, scheduled for the named phase), `fixed`.

---

## A. Known risks from section 13: confirmation

| # | Risk | How it is handled | Phase |
|---|------|-------------------|-------|
| 1 | Silent money movement | Every move is an Adjustment row with `auto` and `undone` flags. Moves made in one engine pass are grouped under one batch id so the UI shows one summary per batch. Undo replays the inverse and is tested for exact state restoration. See also F08 for what auto-adjust refills to. | 1, 2 |
| 2 | Carry-forward splurge | Soft cap at 1.5x base daily, excess shown as "banked" with a one-tap move to Buffer or a Goal. "Base daily" is not defined in the brief; see F05. | 1, 2 |
| 3 | Cold start | Default weights for cycles 1 and 2, 70/30 blending from the third completed cycle. Blending has its own flaw; see F06. | 1 |
| 4 | Uncertain cycle start | Cycle starts on the confirmed arrival date, with an awaiting-deposit state. Two gaps remain; see F01 and F02. | 1 |
| 5 | Vendor battery managers | Guided vivo onboarding step (exact alarms, autostart, unrestricted battery), boot rescheduling, a local log of scheduled vs fired reminders, and a settings warning when fires go missing. See F17 for the exact-alarm permission choice. | 7 |
| 6 | Local data loss | Backup export and restore, uninstall warning, Android Auto Backup. Auto Backup conflicts with encryption; see F19. | 6 |
| 7 | Web product images | Official pages or press images only, one image per item, source URL in assets/gear/SOURCES.md, placeholder plus a request for a photo when no image can be fetched. | 4 |
| 8 | Visual effects vs readability and battery | One animated layer, paused when backgrounded, static in calm mode, flat opaque cards, a contrast test across every palette. Daily accent variation must stay inside the tested set; see F22. | 8 |
| 9 | Type-to-log misclassification | Parser never saves without the confirm chip. Corrections are stored as keyword-to-category mappings and win over built-in keywords next time. | 2 |
| 10 | Food floor and food language | Food floor is a hard engine invariant checked by property tests. Copy goes through a reviewed string list. Streaks and "clean weeks" must not reward eating less; see F21. Health colours on the Food card; see F23. | 1, 8 |
| 11 | Scope | Every phase ends with an installable debug APK and passing tests. | all |

---

## B. New flaws

### F01. Leftover money at cycle end has no destination
- **Status:** fixed in phase 1 (`CycleCloser`, night food top-up in `AllocationPlanner`).
- **Problem:** The brief describes how a deposit is split but not what happens to money left in categories when the next cycle starts (including after an early deposit). The acceptance criterion "allocations always sum to the deposit" also ignores leftover.
- **Why it matters:** Leftover is real money in the bank. If it silently disappears from the plan, the balance check will always show a difference. If it silently flows into spendable categories, it becomes the splurge that risk 2 is trying to prevent.
- **Proposed fix:** At cycle close, each category's remainder is swept by rule: Night food stock and Essentials stock keep their balance (they are stock funds); bike service fund and recurring set-asides keep theirs; everything else goes to Buffer. The invariant becomes "allocations sum to deposit plus carried-in amount", tested exactly. The recap shows the sweep.

### F02. Expected next start conflicts with "on or before the 5th"
- **Status:** fixed in phase 1 (`CycleCalendar.expectedNextStart`).
- **Problem:** 5.1 says the next start defaults to the same day of next month as this start. If one deposit arrives late on the 9th, the next cycle is planned to end on the 9th, but family usually sends by the 5th. The plan then over-stretches money by four days, and a deposit on the 3rd ends the cycle early.
- **Why it matters:** Cycle length drives the daily allowance. A wrong end date makes every day's number wrong for the whole cycle.
- **Proposed fix:** Store an anchor day (default 5, from onboarding). Expected next start is the anchor day of the next month, clamped to month length, and never less than 14 days away (otherwise the month after). A late deposit produces a shorter cycle, not a shifted one. The "start on the 31st" acceptance test then means anchor day 31, clamped to 28, 29 or 30 per month without drifting.

### F03. Awaiting-deposit state has no day count
- **Status:** fixed in phase 1 (`CycleCalendar.awaitingPlanDays`).
- **Problem:** When the deposit is late, the allowance is "computed from leftover money", but divided over how many days is unspecified.
- **Proposed fix:** Divide the leftover pool by days until anchor day plus a 3-day grace, recomputed daily, with a minimum of 3 days. The banner states the assumption ("planning for 3 more days"). Food floor still applies and the shortfall is shown if leftover cannot cover it.

### F04. Floors and weights are not reconciled
- **Status:** fixed in phase 1 (`AllocationPlanner`).
- **Problem:** Weights are applied to the remainder, and floors are "never violated", but the brief does not say what happens when a weighted share lands below a floor (small deposit, long cycle, large reserves).
- **Proposed fix:** Weighted split first. Any category below its floor is raised to the floor, and the difference is taken from other categories in the negative-delta absorption order (5.3). If that runs out, the shortfall path in 5.2.5 triggers. Petrol floor is per cycle, so it is prorated by cycle length against a 30-day reference.

### F05. "Base daily amount" for the soft cap is undefined
- **Status:** fixed in phase 1 (`CyclePlan.baseDaily`).
- **Proposed fix:** Base daily = spendable pool at cycle start divided by cycle length. It is recomputed only on events that change the plan (mid-cycle extra income, balance-check replan, auto-adjust into Food), never on ordinary carry-forward.

### F06. Blending with actual spend erodes Buffer and rewards overspending
- **Status:** fixed in phase 1 (`WeightBlender`).
- **Problem:** From cycle 3, weights become 70 percent past spend shares. Buffer is rarely spent, so its weight falls from 10 to about 3 percent and keeps falling. Any category that overspent (and was topped up by auto-adjust) gets a bigger weight next time, which rewards the overspend. UPI under-logging also distorts the shares.
- **Why it matters:** The safety net shrinks exactly when history shows it is needed, and the plan drifts towards the user's worst month.
- **Proposed fix:** Exclude Buffer from blending (fixed at its default weight). Blend only Food, Petrol, Outings, Try something new and Misc, using a trimmed median of the last three cycles. Cap each weight's change at 3 percentage points per cycle. Floors still apply.

### F07. Goals are not a category, but generosity and banked money flow into them
- **Status:** fixed in phase 1 (`BudgetCategory.goals`).
- **Problem:** 5.3 sends 10 percent of positive delta to Goals and absorbs negative delta from Goals; 5.4 moves banked money to a Goal; 5.8 saves towards goals. None of the eight categories holds that money, and Goal in the data model has no balance.
- **Why it matters:** Without a home, goal money stays in the spendable pool and gets spent, or vanishes from the plan and breaks the balance check.
- **Proposed fix:** Add a ninth, non-spendable category "Goals" with a new tier `savings`. Each Goal tracks its own share through Adjustments into and out of the Goals category. Goal balances carry across cycles and are excluded from the F01 sweep.

### F08. Auto-adjust refills to zero, which still starves Food
- **Status:** fixed in phase 1, then changed by D23: Food now gets one week moved and the rest held (F35).
- **Problem:** Auto-adjust triggers when an essential category "reaches zero". Spending usually overshoots (50 left, 200 spent), and refilling to zero leaves Food empty with days still to go, which breaks the per-day food floor the brief says is never violated.
- **Proposed fix:** Refill target for Food is floor per day times days left including today. For Petrol it is the prorated remaining Petrol floor. For Night food stock it is zero, since it is a stock fund. The trigger condition stays "reached zero or below", so no money moves on projections alone.

### F09. "No negative balances" cannot be guaranteed for real spending
- **Status:** fixed in phase 1. Engine moves never take a donor below zero or a floor; tested by property tests.
- **Problem:** The user can always spend money the plan does not have. If donors are exhausted, a category balance is negative in fact.
- **Proposed fix:** The invariant applies to engine-produced allocations and adjustments: the engine never moves a balance below zero or below a floor. A category that is negative because of user spending is shown as a cycle shortfall with the runway, as 5.5 already describes, and is tested as such.

### F10. Late-night food counts against the next day
- **Status:** fixed in phase 1 (maths) and phase 2 (late-night mode from 00:00 to 04:00: dimmed home, Night food stock card, gentle line, Night food predicted for quick add).
- **Problem:** All maths uses calendar dates in IST. A snack at 1:30 am belongs to tomorrow's allowance, while the user experiences it as part of tonight.
- **Why it matters:** It makes tomorrow look tight first thing in the morning and makes the late-night pattern (a known problem) invisible in today's view.
- **Proposed fix:** An allowance day boundary at 04:00 IST for allowance, pace and runway only. Transactions keep their real timestamp, and cycle dates stay calendar dates. Late-night mode runs from 00:00 to 04:00 to match.

### F11. Runway formula divides by zero and is noisy early
- **Status:** fixed in phase 1 (`RunwayCalculator`).
- **Problem:** Trailing seven-day average spend is zero after a quiet week, and has fewer than seven days of data at cycle start. A single outing also swings it a lot.
- **Proposed fix:** Average over pool categories only. Use the available days when fewer than seven, and fall back to base daily on day 1. When the average is zero, show "comfortable to cycle end" instead of a date.

### F12. Balance check has no opening balance and mixes in other money
- **Status:** fixed in phase 3 (D42). Opening balance recorded at onboarding, balance check screen with three neutral resolutions, auto-adjust after corrections.
- **Problem:** Expected balance needs a starting bank balance and cash in hand, which the app never records. Rent is paid separately, possibly from the same account. Moving money from bank to cash (ATM, a friend paying cash for UPI) is not a spend, but there is no transfer type.
- **Why it matters:** Without these, every balance check reports a false difference and the replan uses wrong numbers. That is the opposite of the neutral, trustworthy check the brief wants.
- **Proposed fix:** Record an opening balance (bank plus cash) at onboarding and after each balance check. Compare totals (bank plus cash), not each account separately, so cash withdrawals need no logging. Let the user mark money in the account that is outside the budget (rent, savings) as an excluded amount. The Unlogged adjustment is a transaction in a hidden "Unlogged" category, so category totals stay honest.

### F13. Purchase planner savings are not actually set aside
- **Status:** planned (phase 5, depends on F07). **Decision: no.**
- **Problem:** Scenarios describe daily savings, but nothing moves money, so the savings remain spendable.
- **Proposed fix:** Choosing a scenario creates a plan that reduces flexible allocations for the remaining days and moves the saved amount into the Goals category at each day's rollover, through Adjustments. "2 outings and 3 treats" uses the median transaction size in Outings and Try something new from history, or defaults of 400 and 150 rupees until there is history.

### F14. Supply set-asides do not catch up for items due soon
- **Status:** fixed in phase 3 (D39).
- **Problem:** Set-aside equals price divided by lifespan times cycle length. An item that is due in 10 days, with nothing saved for it yet, still only gets a third of its price this cycle.
- **Proposed fix:** Each supply item keeps an accumulated balance. Set-aside for the cycle is the larger of the steady rate and what is needed to reach the full price by the expected restock date, capped at the price. Learned lifespan uses an exponential moving average and ignores the first restock after onboarding if the onboarding last-restock date was a guess.

### F15. Mileage discards data when there are partial fills
- **Status:** fixed in phase 3 (D40).
- **Problem:** "Computed only between consecutive full-tank fills" can be read as ignoring any interval that contains a partial fill.
- **Proposed fix:** Standard full-to-full method. Distance is odometer difference between two full fills. Fuel is the sum of litres for every fill after the first full fill up to and including the second. Litres are stored as integer millilitres. Logging a fill also creates the Petrol transaction for the amount paid, so it is never logged twice.

### F16. Section 9 says "four notification types only", but 5.10 needs reminders
- **Status:** planned (phase 7). **Decided (D11):** fifth type "Upcoming due".
- **Problem:** Bike service, insurance and PUC reminders (5.10) and supply restock "days left" are not among the four notification types.
- **Proposed fix:** Add a fifth type, "Upcoming due", covering service, insurance, PUC and supply restocks, at most one per day, combined into a single notification.

### F17. Exact alarm permission on Android 14 and later
- **Status:** planned (phase 7). **Decided (D11):** USE_EXACT_ALARM while sideloaded.
- **Problem:** SCHEDULE_EXACT_ALARM is denied by default on new installs from Android 14 and can be revoked. USE_EXACT_ALARM is granted automatically but Play policy allows it only for alarm and calendar apps.
- **Proposed fix:** Since the app is sideloaded for one user, declare USE_EXACT_ALARM, which removes one failure mode on a vivo phone. If the app is ever published, switch to SCHEDULE_EXACT_ALARM with the guided permission step.

### F18. Privacy leaks around the lock
- **Status:** lock and FLAG_SECURE fixed in phase 2; the lock ignores returning from the file picker, share sheet, camera and gallery since the backup step and phase 4 (D48, D52); widget and notification privacy planned for phase 7.
- **Problem:** The home-screen widget and notifications show amounts without unlocking, which bypasses the biometric lock. FLAG_SECURE also blocks screenshots, which Hari may want for sending numbers to family. Returning from the camera, gallery or share sheet would trigger the 30-second lock mid-task.
- **Proposed fix:** Widget and notification amounts visible by default, with a "hide amounts outside the app" setting. Notifications use private visibility on the lock screen. FLAG_SECURE on by default with a toggle in settings. The lock timer ignores time spent in intents the app itself launched.

### F19. Encryption and Android Auto Backup do not mix
- **Status:** fixed in the backup step (D47, D50).
- **Problem:** If the database is encrypted with a key held in Android Keystore, Auto Backup restores the database without the key, which is unreadable. Manual backup files in Downloads are readable by other apps if they are plain.
- **Proposed fix:** If encryption is on, exclude the database from Auto Backup and rely on the manual backup, which is encrypted with a passphrase you choose. If encryption is off, Auto Backup includes the database, and manual backups can still be passphrase-protected.

### F20. Interaction between reserves and negative delta is subtle
- **Status:** fixed in phase 1 (supply deferral in `AllocationPlanner`).
- **Problem:** 5.2 reserves supplies first, but 5.3 lets negative delta defer the least urgent supply items. That is fine, but it needs a defined urgency.
- **Proposed fix:** Urgency is days until the expected restock. Items not due inside this cycle are deferred first. Items already due ("reserves already due" in 5.5) are never deferred.

### F21. "Clean weeks" and streaks could reward eating less
- **Status:** data table added in phase 2; the "no spend" mark and streak counting are planned for phase 8, together with the clean-week confetti.
- **Problem:** StreakDay and "confetti for clean weeks" are in the brief, but "clean" is not defined. If it means "spent under the allowance", it rewards skipping meals, which conflicts with section 6 and risk 10.
- **Proposed fix:** A clean day means every day's spending was logged (or explicitly marked "no spend"). A clean week is seven clean days. Spending amount plays no part.

### F22. Daily accent variation vs the contrast test
- **Status:** planned (phase 8). **Decision: no.**
- **Proposed fix:** Daily accents are picked from a fixed list of variations, each checked by the contrast test in every palette and health state. No accent is generated at runtime from arbitrary hues.

### F23. Red health colour on Food can read as shaming
- **Status:** fixed in phase 2 (D31).
- **Problem:** Health colours go soft red at the limit for ring, bars and background. On the Food card, red reads as "stop eating".
- **Proposed fix:** Food never uses red. At the limit, the Food card shows amber plus the neutral line "Food is covered by the floor" when the floor is protecting it. Red is kept for flexible categories and the overall ring. Colour states are also always paired with a text label for colour-blind readability.

### F24. Three-tap acceptance and quick-add chips need a category
- **Status:** fixed in phase 2 (D30).
- **Problem:** "+40" and "+100" chips do not say which category they log to.
- **Proposed fix:** Chips log to the category predicted from time of day and recent history (Food by default), shown on the chip ("+40 Food"). A long press opens the add sheet with that amount prefilled. One tap plus the undo snackbar meets the three-tap target.

### F25. Generosity baseline definition is ambiguous
- **Status:** fixed in phase 1 (`Generosity.baseline`).
- **Proposed fix:** Baseline is the median of the previous up to three deposits, excluding the current one. With two previous deposits the median is their mean, rounded down to whole paise. Mid-cycle extra income never enters the baseline. Example for 11,000, 12,000, 13,000: cycle 2 delta is +1,000; cycle 3 delta is 13,000 minus 11,500, which is +1,500.

### F26. Percentages with blending are not whole numbers
- **Status:** fixed in phase 1 (`CategoryWeights`, `LargestRemainder`).
- **Proposed fix:** Weights are integer basis points summing to exactly 10,000, themselves produced by largest remainder. Money is split from them by largest remainder in paise, with ties broken by category order so results are deterministic.

### F27. Debit card spending has no method
- **Status:** data model fixed in phase 1; Settings toggle and hidden-by-default add sheet fixed in phase 2; reports planned for phase 6.
- **Problem:** Method is cash or UPI only. Card payments (online orders, petrol pumps) would have to be logged as UPI, which skews the UPI versus cash report.
- **Proposed fix:** Either add "card" as a third method, or keep two and label UPI as "digital". Your call; adding it is cheap now and expensive after data exists.

### F28. Deposits must not assume one transfer per cycle
- **Status:** type and engine fixed in phase 1; schema fixed in phase 2 (deposit rows linked to a cycle, each tagged installment or extra).
- **Problem:** The brief talks about "the deposit" as one amount per cycle. Family may switch to weekly transfers. If the engine treats each transfer as its own deposit, the second weekly transfer would look like extra income and get the generosity split (50 percent to Food and so on), and the baseline median would compare a weekly transfer to monthly ones.
- **Why it matters:** Weekly installments would inflate Food and flexible categories every week and make the baseline meaningless.
- **Plan:**
  1. `Deposit` has a kind: `installment` (part of the cycle's expected total) or `extra` (mid-cycle extra income). The schema stores deposits as rows linked to a cycle, never a single amount column on Cycle.
  2. The allocation planner reads only the sum of a cycle's installments. Extras are ignored by the planner.
  3. Generosity baseline and delta compare cycle installment totals, never individual transfers.
  4. Only `ExtraIncome.split` applies the positive-delta rule, and it refuses an installment. A test proves an installment can never reach it, and that adding extras never changes the baseline or delta.
  5. Phase 1 behaviour is the single monthly installment. For weekly transfers later: the cycle gets an expected installment total from settings; the plan is made against the expected total, and spendable money is limited to what has arrived (planned vs funded), so the ring never shows money that is still in transit. That needs its own decision when it is built.

### F29. Android restricted settings block the notification listener for sideloaded apps
- **Status:** planned (phase 9). **Decision: no.**
- **Problem:** Since Android 13, an app installed from an APK file outside an app store (for example from a file manager or browser) cannot be granted notification listener access until the user unlocks "Allow restricted settings" in the app's info screen. Android 15 extended the same block. On vivo the menu path differs from stock Android. Installs from Android Studio or `adb install` are generally not affected.
- **Why it matters:** I01 would silently never work and the user would see a greyed-out toggle with no explanation.
- **Proposed fix:** The phase 9 onboarding step checks whether listener access is granted. If not, it explains restricted settings, deep links to the app info screen, and shows the vivo menu path, documented step by step in `docs/vivo-setup.md`. Settings shows a warning while access is missing. The rest of the app never depends on the listener.

### F30. Bike service fund and recurring set-asides have no category
- **Status:** fixed in phase 1. **Decided (D24):** confirmed; no home card, shown under Supplies and Bike.
- **Problem:** 5.2 reserves money for a bike service fund and recurring costs, but none of the eight categories holds that money, which is the same gap as Goals (F07).
- **Why it matters:** Without a home, reserved money either sits in a spendable category or disappears from the plan.
- **Proposed fix:** Two non-spendable categories with a new tier `reserve`: "Bike fund" and "Recurring fund". Both keep their balance across cycles and are hidden in the UI while zero. Recurring fund stays at zero for now since there are no recurring costs.

### F31. Misc is missing from the absorption and donor orders
- **Status:** fixed in phase 1. **Decided (D25):** confirmed.
- **Problem:** The negative-delta order (5.3) and the auto-adjust donors (5.5) both leave out Misc and data packs. If Misc keeps its full share while Food is pushed below its floor, the food rule is broken.
- **Proposed fix:** Treat the omission as deliberate protection for data packs. Misc is never a donor in ordinary absorption or auto-adjust. It is cut only when money is truly short, before any floor or due reserve (see F34).

### F32. Undo followed by an immediate re-trigger
- **Status:** fixed (engine in phase 1, wired to the log action only in phase 2).
- **Problem:** If auto-adjust ran continuously, undoing a refill while Food is still at zero would make it fire again at once, and undo would look broken.
- **Proposed fix:** Auto-adjust runs only after a transaction is logged, never on a timer or on screen refresh. Undo marks the batch undone and leaves the state exactly as it was before the batch. The next logged transaction can trigger a new refill.

### F33. Negative delta and saved Goals money
- **Status:** fixed in phase 1.
- **Problem:** 5.3 absorbs a negative delta from "Goals". Taking money already saved towards a goal would silently undo the user's own saving.
- **Proposed fix:** Absorption takes only from this cycle's new Goals allocation, never from saved goal balances.

### F34. What gives first when floors cannot all be met
- **Status:** fixed in phase 1. **Decided (D26):** confirmed with Petrol cut before Night food stock.
- **Problem:** 5.2.5 says to show the shortfall, but allocations must still add up to the money that actually exists, so something has to go below its floor. The brief does not say what.
- **Fix:** After the brief's absorption order is exhausted, cuts happen in this order: Misc, Recurring fund, Bike fund, supply items already due (least urgent first), Petrol below its floor, Night food stock top-up, and Food below its floor last. The plan reports the exact shortfall amount, which feeds the family summary.

### F35. Early-cycle Food refill can empty every donor at once
- **Status:** fixed in phase 1. **Decided (D23):** move one week, hold the rest, release weekly or when Food hits zero again, undo together, drop holds at cycle close, replan prompt before day 10.
- **Problem:** Found while simulating cycles. Auto-adjust refills Food to floor times days left (F08, agreed). If Food runs out on day 6 of a 31-day cycle, the target is ₹150 x 26 = ₹3,900. That one refill usually takes all of Buffer, Try something new and Outings in a single batch, more than three weeks before the money is actually needed.
- **Why it matters:** The user loses every flexible rupee because of one bad week, and the Buffer that exists for emergencies is gone on day 6. The single summary will also show a large, alarming move.
- **Fix:** Hari's design (D23): move one week, hold the rest of the commitment on the donors, release up to a week at each weekly rollover or when Food hits zero again. The full food floor for the rest of the cycle stays protected, but money is not pulled out of Buffer and flexible categories weeks before it is needed.

### F36. Budget values cannot be edited after onboarding
- **Status:** fixed in phase 3 (D43).
- **Problem:** Food floor, petrol floor, night food stock, anchor day and weights are set in onboarding. Settings shows them but cannot change them yet, because a change mid-cycle has to replan the remaining days.
- **Proposed fix:** Edit them from the Plan screen in phase 3. A change applies to the remaining days through a replan that is written to the ledger, using the same path as the balance check.

### F37. Weekly hold releases only happen while the app is open
- **Status:** planned (phase 7). **Decision: no.**
- **Problem:** The weekly rollover is checked on start, on resume and every minute while the app is open. If the app is not opened for a week, the release happens on the next open. No money is lost, since held money stays in its category, but Food can look lower than planned until then.
- **Proposed fix:** Phase 7 adds a daily background check alongside the notifications. Until then, opening the app catches up immediately.

### F38. Seed-data tool for demos
- **Status:** fixed in phase 3 (D44).
- **Problem:** Section 12 asks for a tool that simulates three months for demos. The engine tests already simulate three months, but there is no way to load that into the app.
- **Proposed fix:** A debug-only menu item that fills a fresh install with three simulated months, using the acceptance-test spending model. It will never appear in release builds.

### F39. Onboarding deposit counted twice by the balance check
- **Status:** fixed in phase 3. **Decision: no.**
- **Problem:** Found by a test. The onboarding deposit was stamped at noon on its date, while the balance anchor was stamped at the moment onboarding finished. When onboarding happened before noon, the first balance check counted the deposit a second time and reported the balance as ₹12,000 too low.
- **Fix:** A deposit's recorded time is noon on its date, or now if that is earlier (D42). Covered by tests.

### F40. Schema migrations have no test against real old data
- **Status:** fixed in the backup step (D49).
- **Problem:** Phase 3 moves the database to version 2 (supply savings and fuel fills) with a migration. The phone was reinstalled fresh for this phase, so no version 1 database exists there, but later phases will need upgrades that keep data.
- **Proposed fix:** From phase 6, export the Drift schema for each version and add migration tests that open a database from every earlier version, alongside the backup and restore work.


### F41. A balance check before logging the new deposit treats the deposit as surplus
- **Status:** fixed (backup step, before phase 4). **Decision: no** (fix specified by Hari).
- **Confirmed in code:** `BalanceCheck.resolve` sends any positive difference to Buffer, through an Unlogged credit plus a move. If the month's money has landed but has not been logged, the difference is about one deposit. Resolving it puts that money in Buffer. When the deposit is then logged as Monthly money, it is planned a second time. The ledger then holds the money twice, and the next check shows a shortfall of about one deposit. "Spread it across categories" has the same problem, through credits to categories.
- **Fix:** When the difference is positive and within 20 percent of the last monthly deposit, the screen shows "This looks like this month's money. Log it first?" above the three options, with a Money arrived button that opens the deposit sheet. The screen also explains what to enter (bank plus cash, minus money not for this budget) and to log a new deposit first. The three options stay available, so a genuine surplus can still be resolved.

### F42. Money already in hand at setup never joins the plan
- **Status:** fixed (backup step, before phase 4). **Decision: no** (fix specified by Hari).
- **Confirmed in code, with one correction:** onboarding asks for bank balance, cash and excluded money, and records them only as the first balance anchor. The plan uses the deposit alone (no carry-in). Any leftover is real money the plan never sees. The claim needs one correction: the balance check does not catch this. It compares today's money with the anchor, and the anchor already includes the leftover, so every check says "matches" while the plan stays short by the leftover for good. The reverse is also possible: if bank plus cash is entered without the deposit, the plan holds more money than the anchor. The first check then reports the deposit as surplus, which is F41 again.
- **Fix:** Onboarding has a "Money already in hand" field on the balances step. It is prefilled with bank plus cash minus excluded money minus the deposit, and joins the first pool as a carry-in. Next is blocked unless deposit plus money already in hand equals bank plus cash minus excluded money, and the message shows the exact gap. That way the plan total, the anchor and the balance check start from the same number. Tests cover the first balance check right after onboarding, before and after noon, with and without leftover.

### F43. Photos make backups larger
- **Status:** accepted (phase 4). **Decision: no.**
- **Problem:** Photos are stored in the database (D52), so every photo makes each backup larger. A dozen bill photos at about 300 KB each add about 4 MB.
- **Why it is acceptable:** Backups are compressed and kept in Downloads or shared, and complete restores matter more than size. If backups ever pass about 25 MB, photos could be moved to a separate optional file.

