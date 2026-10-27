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

## Open questions

Each question has a recommended default in bold. Answering "defaults" accepts all of them.

**Q1. Encrypt the database with SQLCipher?**
The build cost is small with the current `sqlite3` package: one pubspec setting and a prebuilt binary, adding a few MB per CPU architecture because the Android build links OpenSSL, plus `flutter_secure_storage` to keep the key in Android Keystore. The real costs are elsewhere. Losing the key (a factory reset of the Keystore, some vivo restore paths) makes the data unreadable. Android Auto Backup becomes useless for the database (F19). Debugging means you can't open the database file with a normal SQLite viewer. The app lock and Android's file-based encryption already protect data on a locked phone.
**Default: no encryption now, passphrase-encrypted manual backups.** Can be switched on later with a one-time migration.

**Q2. Default weights** Food 60, Petrol 14, Outings 9, Try something new 4, Misc 3, Buffer 10: **keep as is.**

**Q3. Leftover at cycle end (F01):** **stock funds and set-asides keep their balance, everything else goes to Buffer.** Alternative: leftover adds to next cycle's deposit before allocation.

**Q4. Expected next start (F02):** **anchor day, default 5th, clamped per month.** Alternative: same day as this cycle's actual arrival, as the brief says.

**Q5. Goals category (F07):** **add a ninth, non-spendable "Goals" category.**

**Q6. Blending (F06):** **Buffer fixed, trimmed median of last three cycles, at most 3 points of change per cycle.**

**Q7. Auto-adjust refill target (F08):** **Food to floor times days left, Petrol to prorated floor.**

**Q8. Day boundary for allowance (F10):** **04:00 IST**, with late-night mode from 00:00 to 04:00.

**Q9. Notifications (F16):** **add a fifth type, "Upcoming due",** for bike documents, service and supply restocks.

**Q10. Exact alarms (F17):** **USE_EXACT_ALARM**, valid while the app is not on Play.

**Q11. Privacy (F18):** **amounts visible in widget and notifications with a setting to hide them, FLAG_SECURE on with a toggle.**

**Q12. Name and id:** **"Fintrack", `com.hari.fintrack`.**

**Q13. Clean week (F21):** **seven consecutive days where every day was logged or marked "no spend".** Amount spent plays no part.

**Q14. Food card colour (F23):** **never red; amber with a neutral line.**

**Q15. Payment methods (F27):** **cash and UPI only, as the brief says.** Alternative: add card.

**Q16. Numbers I need for the engine defaults** (all editable later in onboarding):
- Food floor per day: brief says ₹150. Confirm.
- Petrol floor per cycle: no default given. **Suggest ₹1,200** (about 11 litres) until the fuel log has data.
- Night food stock amount per cycle: no default given. **Suggest ₹600.**
- Usual deposit day: **5th**, and does the amount arrive in one transfer?
- Is rent paid from the same bank account this money lands in? If yes, roughly how much stays in the account outside the budget?
- Recurring costs to set aside for (subscriptions, college fees, anything else)? Data packs stay under Misc.
