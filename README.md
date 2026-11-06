# Aurora Finance — Flutter Android MVP 0.2

A real, offline-first **manual** personal finance application. Version 0.2 closely follows the supplied HTML prototype: compact dark surfaces, a large multicolor balance card, a clean analytics grid, and the gradient amount editor. The layered aurora motion follows a **52-second loop**; the surrounding header has a subtler **64-second glow**.

## Included features

- Dark dashboard with a layered, slow-moving gradient balance card and softly animated top-of-screen glow
- Visual design aligned with the HTML reference: compact action tiles, floating bottom navigation, transaction rows, segmented analytics, and dark form fields
- Rebuilt transaction editor: gradient amount panel, expense/income selector, category/date/description fields, bottom cancel/clear-or-delete/save actions
- Add income and expenses; edit and delete entries
- Persistent local SQLite storage (survives application restarts)
- Opening balance; calculated ledger balance
- Weekly and monthly analytics (actual amounts by category and period)
- Transaction history with income/expense filters
- USD, EUR, AMD ledger currency; switching is disabled when the ledger contains money, preventing accidental relabeling
- Empty ledger on first install. An **optional Preview design** button shows clearly labeled, in-memory example amounts; those samples are never saved to the ledger and disappear when adding a real transaction
- Local-data reset with a destructive-action confirmation
- No login, internet permission, backend, or external service used by the app itself

**Important:** This is a manual budget tracker, **not a banking app**. The expense/income buttons record transactions; they do not send, receive, or transfer actual money. Current SQLite storage is **not encrypted** and there is **no backup, authentication, cloud synchronization, or multi-device recovery**. Do not treat the MVP as production-ready for sensitive financial records.

## Setup on Windows (Android)

1. Install the latest supported Flutter SDK, Android Studio and Android SDK. See: https://docs.flutter.dev/platform-integration/android/setup
2. Extract this ZIP folder, open a terminal in `aurora_finance_flutter` (the folder containing `pubspec.yaml`).
3. Generate Android platform scaffolding (not included in this ZIP):

   ```powershell
   flutter create . --platforms=android --project-name aurora_finance --org com.example
   ```

4. Resolve dependencies and check the project:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   ```

5. Connect an Android device with USB debugging enabled, or open an emulator:

   ```powershell
   flutter devices
   flutter run
   ```

6. Build an installable Android APK:

   ```powershell
   flutter build apk --release
   ```

   The build will normally be at `build/app/outputs/flutter-apk/app-release.apk`.

**Before publishing:** Change the `--org com.example` organization to your own domain/ID and set your own app name/icon, package ID, signing key, privacy policy and Play Console configuration. A personal APK can be tested without publishing to Google Play.

## Project structure

- `lib/main.dart` — app bootstrap, theme, finance controller
- `lib/data/ledger.dart` — SQLite persistence, data model, currency math
- `lib/ui/aurora_card.dart` — separately animated, multicolor card canvas and subtle header ambient glow
- `lib/ui/demo_preview.dart` — explicit visual-only sample data, never inserted into SQLite
- `lib/ui/screens.dart` — home, analytics, transaction history, settings, entry editor
- `test/ledger_math_test.dart` — ledger arithmetic tests
- `test/demo_preview_test.dart` — preview data checks
- `test/aurora_card_test.dart` — animated card child stability test

## Design fidelity notes

The **HTML prototype is the visual reference**, not a production bank statement. This Flutter version uses similar spacing and proportions while adapting to Android safe areas, screen sizes and keyboard interactions. `lib/ui/aurora_card.dart` contains the color composition; the animation affects only the painted background, not labels. The app honors the operating system’s reduced-animation setting on startup.

The design preview is off by default. For filled example screens without mixing fake records into your data, open Home → **Preview design**. The sample balance and transactions are explicitly marked; analytics derive from the same in-memory examples. Exit preview or start entering real transactions to return to the real ledger.

## MVP constraints and suggested next steps

1. **Data resilience:** Add encrypted local storage, app lock, encrypted export/import and backup; test restore before storing important records.
2. **Onboarding:** Create a first-launch flow for currency and opening balance, category customization, and dashboard preferences.
3. **Finance features:** Budget limits, recurring transactions, charts by month, search, CSV export, and optional account balances.
4. **QA:** Android emulator/device tests, performance profiling, accessibility, responsive layout, input edge cases, and release signing.
5. **Only if needed later:** bank connection via an authorized Open Banking provider. Never connect to live bank accounts by scraping credentials.

## Build verification status

This source bundle was prepared without the Flutter SDK installed in the authoring environment. It **has not** been compiled or run on Android in that environment. Execute `flutter analyze`, `flutter test`, and `flutter run` as above to identify any SDK-version-specific issues before distributing.

## Build APK without installing Flutter locally

The project includes an automated GitHub Actions workflow at `.github/workflows/build-android-apk.yml`, and a Windows PowerShell script `build-apk-windows.ps1`. Follow **[BUILD_APK.md](BUILD_APK.md)** to generate and download an installable APK. The workflow uses the stable Flutter channel and should be regarded as an unverified build recipe until GitHub Actions runs it successfully.

## Visual reference included

`design_reference/aurora_banking_prototype.html` contains the interactive HTML
prototype used as the design comparison target. Open it in a browser to compare
spacing, composition and gradient motion against a device build.
