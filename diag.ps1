# Diagnostic script - run from fit_her-main folder
$log = Join-Path $PSScriptRoot "diag_log.txt"
"=== ADB DIAGNOSTIC $(Get-Date) ===" | Out-File $log

"--- adb devices ---" | Out-File $log -Append
adb devices 2>&1 | Out-File $log -Append

"--- device info ---" | Out-File $log -Append
adb shell getprop ro.product.model 2>&1 | Out-File $log -Append
adb shell getprop ro.miui.ui.version.name 2>&1 | Out-File $log -Append
adb shell getprop ro.build.version.release 2>&1 | Out-File $log -Append

"--- secure install settings ---" | Out-File $log -Append
adb shell settings get global verifier_verify_adb_installs 2>&1 | Out-File $log -Append
adb shell settings get secure install_non_market_apps 2>&1 | Out-File $log -Append

"--- push apk ---" | Out-File $log -Append
adb push build\app\outputs\flutter-apk\app-debug.apk /data/local/tmp/app.apk 2>&1 | Out-File $log -Append

"--- pm install ---" | Out-File $log -Append
adb shell pm install -r /data/local/tmp/app.apk 2>&1 | Out-File $log -Append

"--- adb install (fallback) ---" | Out-File $log -Append
adb install -r build\app\outputs\flutter-apk\app-debug.apk 2>&1 | Out-File $log -Append

"=== DONE ===" | Out-File $log -Append
Write-Host "Done. Log saved to diag_log.txt"
