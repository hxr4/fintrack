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
- **Status:** open. **Decision: yes.**
- **Problem:** The brief describes how a deposit is split but not what happens to money left in categories when the next cycle starts (including after an early deposit). The acceptance criterion "allocations always sum to the deposit" also ignores leftover.
- **Why it matters:** Leftover is real money in the bank. If it silently disappears from the plan, the balance check will always show a difference. If it silently flows into spendable categories, it becomes the splurge that risk 2 is trying to prevent.
- **Proposed fix:** At cycle close, each category's remainder is swept by rule: Night food stock and Essentials stock keep their balance (they are stock funds); bike service fund and recurring set-asides keep theirs; everything else goes to Buffer. The invariant becomes "allocations sum to deposit plus carried-in amount", tested exactly. The recap shows the sweep.

### F02. Expected next start conflicts with "on or before the 5th"
- **Status:** open. **Decision: yes.**
- **Problem:** 5.1 says the next start defaults to the same day of next month as this start. If one deposit arrives late on the 9th, the next cycle is planned to end on the 9th, but family usually sends by the 5th. The plan then over-stretches money by four days, and a deposit on the 3rd ends the cycle early.
- **Why it matters:** Cycle length drives the daily allowance. A wrong end date makes every day's number wrong for the whole cycle.
- **Proposed fix:** Store an anchor day (default 5, from onboarding). Expected next start is the anchor day of the next month, clamped to month length, and never less than 14 days away (otherwise the month after). A late deposit produces a shorter cycle, not a shifted one. The "start on the 31st" acceptance test then means anchor day 31, clamped to 28, 29 or 30 per month without drifting.

### F03. Awaiting-deposit state has no day count
- **Status:** planned (phase 1). **Decision: no**, unless you disagree.
- **Problem:** When the deposit is late, the allowance is "computed from leftover money", but divided over how many days is unspecified.
- **Proposed fix:** Divide the leftover pool by days until anchor day plus a 3-day grace, recomputed daily, with a minimum of 3 days. The banner states the assumption ("planning for 3 more days"). Food floor still applies and the shortfall is shown if leftover cannot cover it.

### F04. Floors and weights are not reconciled
- **Status:** planned (phase 1). **Decision: no.**
- **Problem:** Weights are applied to the remainder, and floors are "never violated", but the brief does not say what happens when a weighted share lands below a floor (small deposit, long cycle, large reserves).
- **Proposed fix:** Weighted split first. Any category below its floor is raised to the floor, and the difference is taken from other categories in the negative-delta absorption order (5.3). If that runs out, the shortfall path in 5.2.5 triggers. Petrol floor is per cycle, so it is prorated by cycle length against a 30-day reference.

### F05. "Base daily amount" for the soft cap is undefined
- **Status:** planned (phase 1). **Decision: no.**
- **Proposed fix:** Base daily = spendable pool at cycle start divided by cycle length. It is recomputed only on events that change the plan (mid-cycle extra income, balance-check replan, auto-adjust into Food), never on ordinary carry-forward.

### F06. Blending with actual spend erodes Buffer and rewards overspending
- **Status:** open. **Decision: yes.**
- **Problem:** From cycle 3, weights become 70 percent past spend shares. Buffer is rarely spent, so its weight falls from 10 to about 3 percent and keeps falling. Any category that overspent (and was topped up by auto-adjust) gets a bigger weight next time, which rewards the overspend. UPI under-logging also distorts the shares.
- **Why it matters:** The safety net shrinks exactly when history shows it is needed, and the plan drifts towards the user's worst month.
- **Proposed fix:** Exclude Buffer from blending (fixed at its default weight). Blend only Food, Petrol, Outings, Try something new and Misc, using a trimmed median of the last three cycles. Cap each weight's change at 3 percentage points per cycle. Floors still apply.

### F07. Goals are not a category, but generosity and banked money flow into them
- **Status:** open. **Decision: yes.**
- **Problem:** 5.3 sends 10 percent of positive delta to Goals and absorbs negative delta from Goals; 5.4 moves banked money to a Goal; 5.8 saves towards goals. None of the eight categories holds that money, and Goal in the data model has no balance.
- **Why it matters:** Without a home, goal money stays in the spendable pool and gets spent, or vanishes from the plan and breaks the balance check.
- **Proposed fix:** Add a ninth, non-spendable category "Goals" with a new tier `savings`. Each Goal tracks its own share through Adjustments into and out of the Goals category. Goal balances carry across cycles and are excluded from the F01 sweep.

### F08. Auto-adjust refills to zero, which still starves Food
- **Status:** open. **Decision: yes.**
- **Problem:** Auto-adjust triggers when an essential category "reaches zero". Spending usually overshoots (50 left, 200 spent), and refilling to zero leaves Food empty with days still to go, which breaks the per-day food floor the brief says is never violated.
- **Proposed fix:** Refill target for Food is floor per day times days left including today. For Petrol it is the prorated remaining Petrol floor. For Night food stock it is zero, since it is a stock fund. The trigger condition stays "reached zero or below", so no money moves on projections alone.

### F09. "No negative balances" cannot be guaranteed for real spending
- **Status:** planned (phase 1). **Decision: no.**
- **Problem:** The user can always spend money the plan does not have. If donors are exhausted, a category balance is negative in fact.
- **Proposed fix:** The invariant applies to engine-produced allocations and adjustments: the engine never moves a balance below zero or below a floor. A category that is negative because of user spending is shown as a cycle shortfall with the runway, as 5.5 already describes, and is tested as such.

### F10. Late-night food counts against the next day
- **Status:** open. **Decision: yes.**
- **Problem:** All maths uses calendar dates in IST. A snack at 1:30 am belongs to tomorrow's allowance, while the user experiences it as part of tonight.
- **Why it matters:** It makes tomorrow look tight first thing in the morning and makes the late-night pattern (a known problem) invisible in today's view.
- **Proposed fix:** An allowance day boundary at 04:00 IST for allowance, pace and runway only. Transactions keep their real timestamp, and cycle dates stay calendar dates. Late-night mode runs from 00:00 to 04:00 to match.

### F11. Runway formula divides by zero and is noisy early
- **Status:** planned (phase 1). **Decision: no.**
- **Problem:** Trailing seven-day average spend is zero after a quiet week, and has fewer than seven days of data at cycle start. A single outing also swings it a lot.
- **Proposed fix:** Average over pool categories only. Use the available days when fewer than seven, and fall back to base daily on day 1. When the average is zero, show "comfortable to cycle end" instead of a date.

### F12. Balance check has no opening balance and mixes in other money
- **Status:** open. **Decision: yes.**
- **Problem:** Expected balance needs a starting bank balance and cash in hand, which the app never records. Rent is paid separately, possibly from the same account. Moving money from bank to cash (ATM, a friend paying cash for UPI) is not a spend, but there is no transfer type.
- **Why it matters:** Without these, every balance check reports a false difference and the replan uses wrong numbers. That is the opposite of the neutral, trustworthy check the brief wants.
- **Proposed fix:** Record an opening balance (bank plus cash) at onboarding and after each balance check. Compare totals (bank plus cash), not each account separately, so cash withdrawals need no logging. Let the user mark money in the account that is outside the budget (rent, savings) as an excluded amount. The Unlogged adjustment is a transaction in a hidden "Unlogged" category, so category totals stay honest.

### F13. Purchase planner savings are not actually set aside
- **Status:** planned (phase 5, depends on F07). **Decision: no.**
- **Problem:** Scenarios describe daily savings, but nothing moves money, so the savings remain spendable.
- **Proposed fix:** Choosing a scenario creates a plan that reduces flexible allocations for the remaining days and moves the saved amount into the Goals category at each day's rollover, through Adjustments. "2 outings and 3 treats" uses the median transaction size in Outings and Try something new from history, or defaults of 400 and 150 rupees until there is history.

### F14. Supply set-asides do not catch up for items due soon
- **Status:** planned (phase 3). **Decision: no.**
- **Problem:** Set-aside equals price divided by lifespan times cycle length. An item that is due in 10 days, with nothing saved for it yet, still only gets a third of its price this cycle.
- **Proposed fix:** Each supply item keeps an accumulated balance. Set-aside for the cycle is the larger of the steady rate and what is needed to reach the full price by the expected restock date, capped at the price. Learned lifespan uses an exponential moving average and ignores the first restock after onboarding if the onboarding last-restock date was a guess.

### F15. Mileage discards data when there are partial fills
- **Status:** planned (phase 3). **Decision: no.**
- **Problem:** "Computed only between consecutive full-tank fills" can be read as ignoring any interval that contains a partial fill.
- **Proposed fix:** Standard full-to-full method. Distance is odometer difference between two full fills. Fuel is the sum of litres for every fill after the first full fill up to and including the second. Litres are stored as integer millilitres. Logging a fill also creates the Petrol transaction for the amount paid, so it is never logged twice.

### F16. Section 9 says "four notification types only", but 5.10 needs reminders
- **Status:** open. **Decision: yes.**
- **Problem:** Bike service, insurance and PUC reminders (5.10) and supply restock "days left" are not among the four notification types.
- **Proposed fix:** Add a fifth type, "Upcoming due", covering service, insurance, PUC and supply restocks, at most one per day, combined into a single notification.

### F17. Exact alarm permission on Android 14 and later
- **Status:** open. **Decision: yes.**
- **Problem:** SCHEDULE_EXACT_ALARM is denied by default on new installs from Android 14 and can be revoked. USE_EXACT_ALARM is granted automatically but Play policy allows it only for alarm and calendar apps.
- **Proposed fix:** Since the app is sideloaded for one user, declare USE_EXACT_ALARM, which removes one failure mode on a vivo phone. If the app is ever published, switch to SCHEDULE_EXACT_ALARM with the guided permission step.

### F18. Privacy leaks around the lock
- **Status:** open. **Decision: yes.**
- **Problem:** The home-screen widget and notifications show amounts without unlocking, which bypasses the biometric lock. FLAG_SECURE also blocks screenshots, which Hari may want for sending numbers to family. Returning from the camera, gallery or share sheet would trigger the 30-second lock mid-task.
- **Proposed fix:** Widget and notification amounts visible by default, with a "hide amounts outside the app" setting. Notifications use private visibility on the lock screen. FLAG_SECURE on by default with a toggle in settings. The lock timer ignores time spent in intents the app itself launched.

### F19. Encryption and Android Auto Backup do not mix
- **Status:** open. **Decision: yes** (part of the SQLCipher question).
- **Problem:** If the database is encrypted with a key held in Android Keystore, Auto Backup restores the database without the key, which is unreadable. Manual backup files in Downloads are readable by other apps if they are plain.
- **Proposed fix:** If encryption is on, exclude the database from Auto Backup and rely on the manual backup, which is encrypted with a passphrase you choose. If encryption is off, Auto Backup includes the database, and manual backups can still be passphrase-protected.

### F20. Interaction between reserves and negative delta is subtle
- **Status:** planned (phase 1). **Decision: no.**
- **Problem:** 5.2 reserves supplies first, but 5.3 lets negative delta defer the least urgent supply items. That is fine, but it needs a defined urgency.
- **Proposed fix:** Urgency is days until the expected restock. Items not due inside this cycle are deferred first. Items already due ("reserves already due" in 5.5) are never deferred.

### F21. "Clean weeks" and streaks could reward eating less
- **Status:** open. **Decision: yes.**
- **Problem:** StreakDay and "confetti for clean weeks" are in the brief, but "clean" is not defined. If it means "spent under the allowance", it rewards skipping meals, which conflicts with section 6 and risk 10.
- **Proposed fix:** A clean day means every day's spending was logged (or explicitly marked "no spend"). A clean week is seven clean days. Spending amount plays no part.

### F22. Daily accent variation vs the contrast test
- **Status:** planned (phase 8). **Decision: no.**
- **Proposed fix:** Daily accents are picked from a fixed list of variations, each checked by the contrast test in every palette and health state. No accent is generated at runtime from arbitrary hues.

### F23. Red health colour on Food can read as shaming
- **Status:** open. **Decision: yes.**
- **Problem:** Health colours go soft red at the limit for ring, bars and background. On the Food card, red reads as "stop eating".
- **Proposed fix:** Food never uses red. At the limit, the Food card shows amber plus the neutral line "Food is covered by the floor" when the floor is protecting it. Red is kept for flexible categories and the overall ring. Colour states are also always paired with a text label for colour-blind readability.

### F24. Three-tap acceptance and quick-add chips need a category
- **Status:** planned (phase 2). **Decision: no.**
- **Problem:** "+40" and "+100" chips do not say which category they log to.
- **Proposed fix:** Chips log to the category predicted from time of day and recent history (Food by default), shown on the chip ("+40 Food"). A long press opens the add sheet with that amount prefilled. One tap plus the undo snackbar meets the three-tap target.

### F25. Generosity baseline definition is ambiguous
- **Status:** planned (phase 1). **Decision: no.**
- **Proposed fix:** Baseline is the median of the previous up to three deposits, excluding the current one. With two previous deposits the median is their mean, rounded down to whole paise. Mid-cycle extra income never enters the baseline. Example for 11,000, 12,000, 13,000: cycle 2 delta is +1,000; cycle 3 delta is 13,000 minus 11,500, which is +1,500.

### F26. Percentages with blending are not whole numbers
- **Status:** planned (phase 1). **Decision: no.**
- **Proposed fix:** Weights are integer basis points summing to exactly 10,000, themselves produced by largest remainder. Money is split from them by largest remainder in paise, with ties broken by category order so results are deterministic.

### F27. Debit card spending has no method
- **Status:** open. **Decision: yes** (low priority).
- **Problem:** Method is cash or UPI only. Card payments (online orders, petrol pumps) would have to be logged as UPI, which skews the UPI versus cash report.
- **Proposed fix:** Either add "card" as a third method, or keep two and label UPI as "digital". Your call; adding it is cheap now and expensive after data exists.
