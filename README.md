# Fintrack

Personal Android budget planner and expense tracker. See `BUILD_BRIEF.md` for the product brief, `DECISIONS.md` for agreed decisions and open questions, `FLAWS.md` for the flaw log, and `IDEAS.md` for proposals outside the brief.

## Commands

- App tests: `flutter test`
- Engine tests: `cd packages/budget_engine && dart test`
- Debug APK: `flutter build apk --debug`
- Regenerate Drift code: `dart run build_runner build --force-jit`

## Installing on the phone without losing data

Release builds are signed with `~/.fintrack/keys/fintrack-release.jks` (see D36). Back up that file and `~/.fintrack/keys/key.properties.backup` somewhere safe. Without them, the next update cannot be installed without uninstalling, which erases all data.

```
flutter build apk --release --target-platform android-arm64
~/Library/Android/sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Never use `flutter run` or `flutter install` against the phone with the release build installed. A debug build has a different signature, and `flutter install` uninstalls first.
