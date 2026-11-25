# ADDED: script parameters (lower $Scale / $BitRate for an even smaller file)
param(
    [string]$Target  = "patrol_test/app_test.dart",
    [string]$Device  = "emulator-5554",
    [string]$Package = "com.example.basic_modern_app",
    [double]$Scale   = 0.5,
    [int]$BitRate    = 1000000,
    [string]$OutDir  = "test_videos"
)

$ErrorActionPreference = "Stop"

# ADDED: locate adb (PATH first, then Android SDK)
$sdk = $env:ANDROID_HOME ?? $env:ANDROID_SDK_ROOT
$adb = (Get-Command adb -ErrorAction SilentlyContinue)?.Source ?? (Join-Path $sdk "platform-tools\adb.exe")

# ADDED: compute reduced recording size (multiples of 16 for encoder compatibility)
$wm   = [regex]::Matches((& $adb -s $Device shell wm size | Out-String), '(\d+)x(\d+)')
$last = $wm[$wm.Count - 1]
$w = [math]::Max(16, [math]::Floor([int]$last.Groups[1].Value * $Scale / 16) * 16)
$h = [math]::Max(16, [math]::Floor([int]$last.Groups[2].Value * $Scale / 16) * 16)

# ADDED: remove any leftover recording on the device
$remote = "/sdcard/patrol_test.mp4"
& $adb -s $Device shell rm -f $remote

# ADDED: start Patrol in the background (-d avoids the interactive device prompt)
$patrol = Start-Process patrol -ArgumentList "test", "-t", $Target, "-d", $Device -NoNewWindow -PassThru
$null = $patrol.Handle

# ADDED: wait until the app is in the foreground, then start recording
$recorder = $null
while (-not $patrol.HasExited) {
    $focus = & $adb -s $Device shell "dumpsys window | grep mCurrentFocus" 2>$null
    if ($focus -match [regex]::Escape($Package)) {
        $recorder = Start-Process $adb -ArgumentList "-s", $Device, "shell", "screenrecord",
            "--size", "$($w)x$($h)", "--bit-rate", "$BitRate", $remote -WindowStyle Hidden -PassThru
        Write-Host "`n[REC] App launched - recording started ($($w)x$($h), $BitRate bps)"
        break
    }
    Start-Sleep -Milliseconds 500
}

# ADDED: wait for the test run to finish
$patrol.WaitForExit()

# ADDED: stop recording gracefully (SIGINT finalizes the MP4), then pull the file
if ($recorder) {
    & $adb -s $Device shell pkill -2 screenrecord | Out-Null
    $null = $recorder.WaitForExit(10000)

    New-Item -ItemType Directory -Force $OutDir | Out-Null
    $local = Join-Path $OutDir ("patrol_test_{0:yyyyMMdd_HHmmss}.mp4" -f (Get-Date))
    & $adb -s $Device pull $remote $local | Out-Null
    & $adb -s $Device shell rm -f $remote

    $mb = "{0:N2}" -f ((Get-Item $local).Length / 1MB)
    Write-Host "[REC] Video saved: $local ($mb MB)"
}
else {
    Write-Warning "App never launched - no video recorded."
}

# ADDED: propagate Patrol's exit code
exit $patrol.ExitCode