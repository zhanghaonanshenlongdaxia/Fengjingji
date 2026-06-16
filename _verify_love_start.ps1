# Verify LÖVE can launch the fengjingji project
$ErrorActionPreference = "Stop"

$love    = "d:\godotProject\tools\love\love-11.5-win64\love.exe"
$proj    = "d:\godotProject\风景集"
$logFile = Join-Path $env:TEMP "love_fengjingji_stdout.log"
$errFile = Join-Path $env:TEMP "love_fengjingji_stderr.log"

if (Test-Path $logFile) { Remove-Item $logFile -Force }
if (Test-Path $errFile) { Remove-Item $errFile -Force }

Write-Host "=== Step 1: Kill old love.exe ==="
Get-Process -Name love -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host ("Killing PID=" + $_.Id)
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 1

Write-Host "=== Step 2: Start LOEVE for fengjingji ==="
$proc = Start-Process -FilePath $love `
                      -ArgumentList ('"' + $proj + '"') `
                      -RedirectStandardOutput $logFile `
                      -RedirectStandardError  $errFile `
                      -PassThru -WindowStyle Normal
Write-Host ("Started PID=" + $proc.Id + ", waiting 5s ...")
Start-Sleep -Seconds 5

$check = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
if ($check) {
    Write-Host ("=== OK: Process alive, PID=" + $check.Id + " Title=" + $check.MainWindowTitle + " ===")
} else {
    Write-Host "=== FAIL: Process exited within 5s ==="
}

Write-Host "=== Step 3: STDOUT ==="
if (Test-Path $logFile) {
    $out = Get-Content $logFile -ErrorAction SilentlyContinue
    if ($out) { $out | ForEach-Object { Write-Host ("  OUT> " + $_) } }
    else { Write-Host "  (stdout empty)" }
} else {
    Write-Host "  (no stdout log)"
}

Write-Host "=== Step 4: STDERR ==="
if (Test-Path $errFile) {
    $errs = Get-Content $errFile -ErrorAction SilentlyContinue
    if ($errs) { $errs | ForEach-Object { Write-Host ("  ERR> " + $_) } }
    else { Write-Host "  (stderr empty)" }
} else {
    Write-Host "  (no stderr log)"
}

Write-Host "=== Step 5: Keep it running for manual check ==="
