# Run with PowerShell in the project folder after installing Flutter + Android SDK.
# Produces build\app\outputs\flutter-apk\app-release.apk
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error 'Flutter was not found. Install Flutter + Android Studio first: https://docs.flutter.dev/platform-integration/android/setup'
  exit 1
}
function Run-Flutter([string[]]$Arguments) {
  & flutter @Arguments
  if ($LASTEXITCODE -ne 0) { throw "Flutter failed: $($Arguments -join ' ')" }
}
Run-Flutter -Arguments @('create', '.', '--platforms=android', '--project-name', 'aurora_finance', '--org', 'com.aurorafinance')
Run-Flutter -Arguments @('pub', 'get')
Run-Flutter -Arguments @('test', 'test/ledger_math_test.dart')
Run-Flutter -Arguments @('build', 'apk', '--release')
$apk = Join-Path $PSScriptRoot 'build\app\outputs\flutter-apk\app-release.apk'
if (-not (Test-Path $apk)) { throw 'Flutter finished but APK was not found.' }
Write-Host "APK ready: $apk" -ForegroundColor Green
