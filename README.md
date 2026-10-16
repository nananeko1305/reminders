# Podsetnici (Flutter)

An Android reminder app: events that ring like an alarm, plus checklists for
shopping and packing. Everything is stored on the phone; there is no backend.
Serbian (Latin) by default, English in settings.

## Features

- **Events** — title, date (calendar picker), time (24h), optional note and
  repeat: none / daily / weekly / monthly.
- **Reminders** — at the event time the app always rings **as an alarm**: the
  alarm sound (it plays on the alarm volume, so silent mode does not mute it),
  repeating until dismissed, with the screen turned on over the lock screen.
  Optional earlier reminders are normal notifications: 7 days, 1 day, 1 h,
  30 min, 10 min before. Choices that make no sense for a repeat are locked
  (e.g. "1 day before" on a daily event).
- **Upcoming list** — events grouped by day (Danas, Sutra, "Subota, 18. okt")
  with a live countdown ("za 2 h 10 min"). Past one-time events go to a
  collapsed "Prošlo" section.
- **Checklists** — any number of named lists (Prodavnica, Za put…). Checked
  items are struck through. Quick add, swipe to delete with undo, "uncheck
  all" to reuse a list, "delete checked".
- **Settings** — language, theme, permission status with fix buttons, and a
  **test alarm** that rings in 10 seconds.

## How reminders are scheduled

`lib/scheduling/` keeps Android's alarm list in line with the events:

- `ReminderPlanner` (pure, unit-tested) turns events into notifications:
  - Daily and weekly events become **OS-repeating** notifications. They keep
    ringing even if the app is never opened again, and survive reboots.
  - One-time events, monthly events, and repeating events whose start is
    still in the future become one-shot notifications (12 months ahead for
    monthly). These are topped up whenever the app is opened.
  - Day offsets use calendar arithmetic, so "1 day before 09:00" stays 09:00
    across a DST change.
  - At most 400 notifications are scheduled (Android allows about 500 per app).
- `LocalNotificationScheduler` diffs that plan against what Android already
  has and only cancels or adds the difference. It syncs after every edit,
  on app start and on resume.
- The alarm uses `AndroidScheduleMode.alarmClock`, so Android also shows it as
  the phone's next alarm. Earlier reminders use exact alarms.
- `MainActivity.kt` lets the app show over the lock screen **only** while an
  alarm launched it. Dismissing the alarm ends that, so the rest of the app
  still needs unlocking.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

Install on a phone with USB debugging enabled:

```bash
flutter install --release
# or
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Local release builds are signed with the debug key unless
`android/key.properties` exists. The CI build is signed with the release key,
so switching between a local build and a GitHub one needs an uninstall.

## Icon

The logo (a bell with a check badge) lives in `assets/icon/` as SVG sources:

- `logo.svg`: the full rounded icon. Used for legacy launchers and the download page.
- `logo_background.svg` + `logo_foreground.svg`: the Android adaptive-icon layers. The foreground keeps the glyph inside the 66 dp safe zone, so no launcher mask clips it.

After editing an SVG, render the PNGs and regenerate the launcher icons:

```bash
for n in logo logo_background logo_foreground; do
  google-chrome --headless=new --hide-scrollbars --default-background-color=00000000 \
    --window-size=1024,1024 --screenshot="$PWD/assets/icon/$n.png" "file://$PWD/assets/icon/$n.svg"
done
dart run flutter_launcher_icons
```

## Release and update notifications

Same pipeline as car_expenses. Day-to-day work goes to `dev`; merging into
`main` ships. `.github/workflows/release-apk.yml` then runs:

1. analyze, test, and a signed release APK;
2. a GitHub Release `vX.Y.Z` with `reminders.apk`;
3. `version.json` on GitHub Pages
   (<https://nananeko1305.github.io/reminders/version.json>);
4. an FCM push to the `releases` topic (Firebase project `reminders-261016`).

Every install subscribes to that topic (`lib/updates/push_service.dart`). The
push text comes from `res/values*/strings.xml`, so each phone shows it in its
own language. On start, on a push and from Settings → "Proveri ažuriranja",
the app compares its version with `version.json` and offers to download the
new APK (`lib/updates/update_checker.dart`).

Versions are `major.minor.patch`, worked out from the commit messages since
the last tag: `feat` bumps the minor, anything else the patch, and a breaking
change the major. The version in `pubspec.yaml` is a floor. Android's version
code is the workflow run number.

Repository secrets:

- `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`: the release key. It lives in
  `~/.android-keys/reminders/`. Keep a backup: losing it means every phone has
  to uninstall to get new versions.
- `FCM_SERVICE_ACCOUNT`: a service-account key of the Firebase project
  (console → Project settings → Service accounts → Generate new private key).
  Without it the workflow skips only the push.

## Checking the alarm on a phone

1. On first launch, allow notifications (and on Android 12, exact alarms).
2. Settings → **Test alarm (za 10 s)**, then lock the phone. It should ring,
   turn the screen on and show the alarm screen; **Ugasi** stops it.
3. Create an event 12 minutes from now with "10 min pre" and check that both
   the reminder and the alarm arrive.
4. Optionally restart the phone with an alarm pending; it should still ring.

On Android 14+, if the alarm only shows as a notification while the phone is
locked, enable Settings → "Alarm preko celog ekrana". On Xiaomi, Samsung and
similar phones, turn off battery optimization for the app if alarms are late.
