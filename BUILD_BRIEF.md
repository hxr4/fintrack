# Budget app build brief for Claude Code

## 1. Role and working rules

You are the lead engineer and product critic on a personal Android budget app for one user (Hari). Build it in phases, stop at the end of each phase, and wait for the instruction "next".

Rules that apply throughout:
- Flutter (stable) with Dart, Android only, minSdk 26. Target device is a current flagship phone, but the app must still run smoothly on a mid-range phone with calm mode on.
- Write no comments inside code files. Names and structure must carry the meaning.
- Store all money as integer paise. Never use floating point for money. Allocate with the largest-remainder method so parts always sum exactly to the whole.
- All dates and times use the Asia/Kolkata zone. Never rely on device locale for cycle maths.
- Offline first. No accounts, no analytics, no network calls at runtime. Product images are bundled as assets.
- Do not add features that are not in this brief. Put proposals in IDEAS.md and ask.
- Before changing any behaviour described here, ask. Flaws you find are handled through the protocol in section 13.

## 2. Product summary

A budget planner and expense tracker that turns a monthly deposit into a daily allowance, adapts when categories run out, plans purchases, and is pleasant enough to open daily.

The user is a student who receives about 12,000 to 13,000 rupees a month from family. Rent is paid separately. The money covers food, petrol, supplies and fun. Known problems: UPI hides spending, food costs spike when he eats out or gets hungry late at night, and money runs out before the end of the month. The app must make the remaining money visible before each spend and must never starve the food budget.

## 3. Tech stack

- State: Riverpod. Routing: go_router.
- Database: Drift on SQLite. Ask the user whether to enable SQLCipher encryption at rest and explain the build cost.
- Biometric lock: local_auth with device credential fallback, lock after 30 seconds in background, FLAG_SECURE so the recent-apps preview is blank.
- Notifications: flutter_local_notifications with timezone, exact alarms, boot rescheduling, and action buttons handled in a background isolate.
- Home-screen widget: home_widget.
- Spreadsheet export: excel package. One-page summary: pdf package.
- Animation: flutter_animate plus custom painters. Background: a fragment shader with an animated blurred-gradient fallback.
- Image picking: image_picker. Haptics: HapticFeedback.

## 4. Data model

Cycle, Category, Allocation (per cycle per category), Transaction, Adjustment, SupplyItem, Goal, GearItem, GearEvent, FuelFill, RecurringCost, Profile, Settings, StreakDay.

Transaction fields: amountPaise, categoryId, method (cash or upi), occurredAt, note, source (manual, quickadd, typed, notification).

Adjustment fields: fromCategoryId, toCategoryId, amountPaise, reason, createdAt, auto, undone.

Categories at launch: Food, Petrol, Night food stock, Essentials stock, Outings, Try something new, Misc and data packs, Buffer. Each has a tier: essential (Food, Petrol, Night food stock), stock (Essentials stock), flexible (Outings, Try something new, Misc), buffer.

Laundry and mobile recharge are excluded by design. Data packs go under Misc.

## 5. Budget engine

The engine is pure Dart with no Flutter imports and full unit tests. Build it first.

### 5.1 Cycle
- The cycle starts on the day the deposit actually arrives, confirmed by the user. Default expectation is on or before the 5th. If the cycle start passes with no deposit, enter an awaiting-deposit state: compute the allowance from leftover money and show a banner. When the deposit is logged, start the cycle on that date.
- Cycle length is the number of days from this start to the expected next start, which defaults to the same day of the next month, clamped to that month's length. This handles 28, 29, 30 and 31 day months and leap years.

### 5.2 Allocation
1. Reserve first: Night food stock (user-set amount), Essentials stock set-asides, bike service fund, recurring-cost set-asides.
2. Remaining money is split across Food, Petrol, Outings, Try something new, Misc and Buffer using weights. Default weights are Food 60 percent, Petrol 14, Outings 9, Try something new 4, Misc 3, Buffer 10, applied to the remainder after reserves. They must sum to 100 and the engine must assert this. Ask the user to confirm these defaults in onboarding.
3. From the third completed cycle, blend 70 percent actual past spend shares with 30 percent defaults. Floors still apply.
4. Floors that are never violated by any automatic rule: Food minimum per day (default 150 rupees, user-editable), Petrol minimum per cycle, fixed set-asides already due.
5. If the deposit cannot cover all floors, do not hide it. Show the shortfall amount and offer to generate the family summary.

### 5.3 Generosity
- Baseline is the median of the last three deposits. In the first cycle the baseline equals the deposit, so there is no delta.
- Positive delta is shared: Food 50 percent, Outings 20, Try something new 10, Buffer 10, Goals 10.
- Negative delta is absorbed in this order and never below floors: Try something new, Outings, Buffer, Goals, deferral of the least urgent supply items, Petrol down to floor, Food down to floor.
- Extra income mid-cycle follows the same positive-delta rule over the remaining days.

### 5.4 Daily allowance
- Spendable pool is the remaining amount in Food, Outings and Try something new.
- Allowance today equals pool at the start of the day divided by days left including today. Unspent money carries forward automatically because the pool is recomputed daily.
- Soft cap: if today's allowance exceeds 1.5 times the base daily amount, show the base amount in the ring and show the excess as "banked", with a one-tap option to move banked money to Buffer or a Goal. Banked money is still spendable.

### 5.5 Auto-adjust
- Trigger only when an essential category reaches zero. Do not move money on projections alone; use projections for notifications.
- Donor order: Buffer, Try something new, Outings, unspent future Essentials stock set-aside. Never take from floors or from reserves already due.
- Every move is written to the Adjustment ledger, shown to the user once as a single summary, and can be undone.
- If donors are exhausted, flag a cycle shortfall and show the runway.

### 5.6 Runway
Runway date is today plus pool divided by the trailing seven-day average spend. Compare it to the cycle end and show days short or spare.

### 5.7 Balance check
The user enters bank balance and cash in hand. Compute expected balance from logged data. Show the difference and offer three resolutions: log it as an Unlogged adjustment (default), distribute it across categories by recent share, or ignore. Then replan the remaining days from the true figure. Wording must be neutral, never accusatory.

### 5.8 Purchase planner
Input: item, price, optional target date. Output three scenarios named Fast, Balanced and Slow. Each shows days to reach the goal, daily saving needed, and the exact trade-offs per category (for example "2 outings and 3 treats"). Savings come only from flexible categories, Buffer and banked money, never from floors. If infeasible, say so plainly and show what date or extra income would make it work.

### 5.9 Supplies
SupplyItem has name, price, lifespan in days and last restock date. Monthly set-aside equals price divided by lifespan times cycle length. Show days left per item. Logging a restock creates a transaction in Essentials stock and updates the learned lifespan with a moving average.

### 5.10 Bike
Fuel fill log: date, litres, price per litre, odometer, full-tank flag. Mileage is computed only between consecutive full-tank fills. Show cost per km and a petrol allocation suggestion from recent riding. Track service due, insurance expiry and PUC expiry with reminders. A service fund set-aside is part of reserves.

## 6. Screens

1. Lock screen with biometric prompt.
2. Onboarding: deposit amount, cycle start, category defaults, floors, supply items, gear import.
3. Home: allowance ring, quick-add chips (+40, +100, custom), type-to-log bar ("40 lunch" parses amount and category with a confirm chip), category cards each with a plus button, runway line, daily idea card, greeting.
4. Add sheet: number pad, cash or UPI toggle, optional note, save. Target under three seconds.
5. Category detail: transactions, pace, adjustments.
6. Plan: cycle timeline, allowance curve, balance check button.
7. Goals: purchase planner with three scenarios.
8. Supplies and bike.
9. Reports: cycle summary, UPI versus cash split, heatmap calendar, spreadsheet export, family summary, backup and restore.
10. Profile: photo, personal details, gear cards, settings, calm mode.
11. Cycle recap in swipeable story format at month end.

Late-night mode after midnight: dim UI, show Night food stock and a gentle line. Messaging must never discourage eating or shame spending. Do not write copy that restricts food.

## 7. Visual system

- Dark by default with a light option.
- One accent colour, flat opaque cards over a moving background, readable first, pretty second.
- Background: blurred gradient blobs seeded from the date and hour, drifting slowly. Palette shifts by time of day. One animated layer only. Pause when the app is backgrounded. Calm mode switches it to a static gradient and reduces animation.
- Health colours follow the ratio of money remaining against time remaining: teal or green when comfortable, amber when tight, soft red at the limit. Ring, bars and background tint shift together.
- Contrast: text on cards must meet 4.5 to 1 in every palette. Add a test that computes this.
- Animations: ring fill on open, number count-up, bar easing on log, light haptic on save, confetti only for goals and clean weeks.
- Daily freshness: new accent variation, new idea card and a one-line insight each day, generated locally from a seeded list.

## 8. Gear and profile

Profile shows the user's photo and details, then a gear section with a card per item: image, name, specs, purchase date, price, cost per day of use, warranty countdown, notes, attached bill photo. The bike card adds odometer, service, insurance and PUC.

Gear list to import:
1. Phone: vivo X300 Pro, colour Dune Gold.
2. Laptop: MacBook Air M4, colour described by the user as Midnight Black (Apple's name is likely Midnight; verify).
3. Laptop: Lenovo LOQ 15IAX9.
4. Bike: Honda CB Hornet 160R, 2018.
5. In-ear monitors: KZ x HeadphoneZone Thunder, 1 dynamic driver plus 1 balanced armature.
6. Power bank: Portronics Aqua 65, 20,000 mAh.

Import workflow for each item:
1. Search the web for the official product page or press images. Do not scrape Google Images result pages. If you cannot download an image, use a placeholder and ask the user to supply a photo.
2. Download one good image into assets/gear and record the source URL in assets/gear/SOURCES.md. Images are for private personal use. If the app is ever published, replace them with the user's own photos.
3. Extract key specs from the manufacturer page.
4. Verify the exact product name and variant. If the name, colour or model does not match what you find, say so instead of guessing.
5. After research, ask the user one batched question set for missing fields: variant and configuration (RAM, storage, screen size), purchase date, price paid, seller, warranty end date, bill photo. For the bike also ask current odometer, last service date and kilometres, next service due, insurance expiry, PUC expiry, and ABS or CBS variant. For the power bank and IEM ask purchase date and price.

## 9. Notifications

Four types only, each with action buttons where useful: evening log nudge (skipped if already logged that day), category threshold alerts at 50, 80 and 100 percent, goal progress, money-arrived reminder around the 5th.

The phone is a vivo device with aggressive background management. Build an onboarding step that guides the user to grant exact alarm permission, enable autostart, and set battery use to unrestricted. Reschedule on boot. Record missed or suppressed reminders locally and surface a warning in settings if reminders appear to be failing.

## 10. Reports and backup

- Spreadsheet export with sheets: Summary, Transactions, Categories, Adjustments, Supplies, Bike. Saved in app storage and shareable or savable to Downloads.
- One-page family summary as PDF in a monotone style with no decorative boxes: category totals, what was cut, shortfall if any, requested amount.
- Backup file export and restore with a clear warning that uninstalling the app erases local data. Enable Android Auto Backup where compatible.

## 11. Phases and acceptance criteria

Stop after each phase, run all tests, report, and wait.

Phase 0, discovery: read this brief, create DECISIONS.md and FLAWS.md, scaffold the project, ask your batched questions. No feature code.
Phase 1, engine: sections 5.1 to 5.8 in pure Dart. Acceptance: tests pass for 28, 29, 30 and 31 day cycles, a leap-year cycle, a cycle starting on the 31st, a late deposit, deposits of 11,000, 12,000 and 13,000 in sequence, floors never violated, allocations always sum to the deposit, no negative balances, undo restores exact state.
Phase 2, core UI: lock, onboarding, home, add sheet, categories, transaction list. Acceptance: logging a transaction takes three taps or fewer, the ring and bars update instantly, state survives app restart.
Phase 3: supplies, bike log, recurring costs, balance check screen.
Phase 4: gear and profile with the import workflow.
Phase 5: purchase planner.
Phase 6: reports, spreadsheet, PDF summary, backup and restore. Acceptance: restore on a clean install reproduces identical balances.
Phase 7: notifications, widget, quick add from notifications.
Phase 8: visual polish, background, colour states, animations, cycle recap, calm mode. Acceptance: stays near 60 fps with calm mode off on a mid-range profile, contrast test passes in every palette.

## 12. Testing

- Unit and property tests for the engine: sums are exact, floors hold, no negatives, results are deterministic for a given input and date.
- Widget tests for the add flow and onboarding.
- Date tests with a fake clock across month ends, year end and leap day.
- A seed-data tool to simulate three months for demos.

## 13. Flaw and insight protocol

Before writing any feature code, review this brief critically and write FLAWS.md. For each flaw give: the problem, why it matters, the proposed fix, and whether you need a decision. Do not repeat the risks already listed below, but do confirm each is handled.

Known risks to address explicitly:
1. Silent money movement erodes trust. Mitigation in 5.5: ledger, single summary, undo.
2. Carry-forward can bank a surplus that becomes a splurge. Mitigation in 5.4: soft cap and banked display.
3. Cold start has no history. Mitigation in 5.2: defaults, then blending.
4. Cycle start date is uncertain. Mitigation in 5.1: cycle starts on actual arrival.
5. Reminders fail on aggressive vendor battery managers. Mitigation in section 9.
6. Local-only data can be lost. Mitigation in section 10.
7. Product images from the web have licence and reliability issues. Mitigation in section 8.
8. Visual effects can reduce readability and battery. Mitigation in section 7.
9. Type-to-log can misclassify. Always show a confirm chip and learn corrections.
10. The app must never reduce food below the floor or use language that restricts eating.
11. Scope is large. Every phase must produce a working app.

During the build, whenever you find a flaw in logic, UX, performance, data safety or money handling, add it to FLAWS.md, fix it if it is within scope, and ask if the fix changes agreed behaviour. At the end of every phase report: what was done, test results, flaws found and fixed, and one thing you would change next.

Begin with Phase 0.
