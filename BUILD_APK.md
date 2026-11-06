# How to obtain the Android APK

This source ZIP is **not an APK**. An APK must be compiled by Flutter with the Android SDK. The included GitHub Actions workflow does this in the cloud, so no Flutter installation is required on your computer.

## Option 1: GitHub Actions (no Android Studio needed)

1. Unzip `aurora_finance_flutter_mvp_with_build.zip` so you have the `aurora_finance_flutter` project folder.
2. Create a **private** empty GitHub repository at https://github.com/new (avoid checking "Initialize this repository with README").
3. Upload/push the **contents** of the `aurora_finance_flutter` folder to the repository, **including the hidden `.github` folder**. You can use GitHub Desktop or Git. With Git installed, open a terminal inside the project folder and run:

   ```bash
   git init
   git add .
   git commit -m "Initial Aurora Finance Android app"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
   git push -u origin main
   ```

   Replace the URL with your new repository URL. Log in to GitHub when prompted.
4. In your GitHub repository, open **Actions → Build Android APK**. The first push to `main` should start the build. You can also select **Run workflow** manually.
5. When the build completes with a green check mark, open its run page. Under **Artifacts**, download **aurora-finance-android-apk**.
6. Extract that artifact ZIP to obtain `app-release.apk`. Transfer it to your Android phone and open it to install. Android may ask you to allow installation from that source.

**Important:** This APK is intended for personal testing. It uses the default Flutter-generated release signing configuration when available, not a configured personal publishing key. It is not ready for distribution through Google Play. Data is locally stored without encryption or backups.

## Option 2: Build on Windows

Install Flutter and the Android SDK from https://docs.flutter.dev/platform-integration/android/setup, then run `build-apk-windows.ps1` in PowerShell from this project folder. The output should appear at `build/app/outputs/flutter-apk/app-release.apk` if build succeeds.

## Build status

These scripts have been prepared and structurally checked, but the authoring environment has no Flutter/Android SDK or external package-download access. **No APK was compiled or verified in this environment.** Errors in GitHub Actions should be treated as build failures, not proof that an APK is available.
