param(
    [string]$InterfaceCfg = "interface/cmsis-dap.cfg",
    [string]$OpenOcdScriptsDir = "",
    [string]$OpenOcdExe = ""
)

$ErrorActionPreference = "Stop"

$candidateOpenOcdExe = @()
if ($OpenOcdExe -ne "") {
    $candidateOpenOcdExe += $OpenOcdExe
}

$candidateOpenOcdExe += "C:\Infineon\Tools\ModusToolboxProgtools-1.7\openocd\bin\openocd.exe"

$pathOpenOcd = Get-Command openocd -ErrorAction SilentlyContinue
if ($pathOpenOcd) {
    $candidateOpenOcdExe += $pathOpenOcd.Source
}

$openocdExeResolved = $null
foreach ($candidateExe in $candidateOpenOcdExe) {
    if (Test-Path $candidateExe) {
        $openocdExeResolved = $candidateExe
        break
    }
}

if (-not $openocdExeResolved) {
    throw "Missing required tool: openocd"
}

$candidateScriptDirs = @()
if ($OpenOcdScriptsDir -ne "") {
    $candidateScriptDirs += $OpenOcdScriptsDir
}

$openocdBinDir = Split-Path -Parent $openocdExeResolved
$candidateScriptDirs += (Join-Path $openocdBinDir "..\scripts")
$candidateScriptDirs += "C:\Infineon\Tools\ModusToolboxProgtools-1.7\openocd\scripts"

$openocdRoot = Split-Path -Parent (Split-Path -Parent $openocdExeResolved)
$candidateScriptDirs += (Join-Path $openocdRoot "openocd\scripts")

$openocdScripts = $null
foreach ($candidateDir in $candidateScriptDirs) {
    if (Test-Path $candidateDir) {
        $openocdScripts = $candidateDir
        break
    }
}

if (-not $openocdScripts) {
    throw "OpenOCD scripts directory not found."
}

$interfacePath = Join-Path $openocdScripts $InterfaceCfg
if (-not (Test-Path $interfacePath)) {
    throw "OpenOCD interface config not found: $interfacePath"
}

Write-Host "Using OpenOCD: $openocdExeResolved"
Write-Host "Using scripts : $openocdScripts"
Write-Host "Checking debug probe with $InterfaceCfg ..."

$previousErrorPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$output = & $openocdExeResolved -s $openocdScripts -f $InterfaceCfg -c "transport select swd; adapter speed 2000; init; shutdown" 2>&1
$ErrorActionPreference = $previousErrorPreference
$exitCode = $LASTEXITCODE

if ($output) {
    $output | ForEach-Object { Write-Host $_ }
}

if ($exitCode -eq 0) {
    Write-Host "Probe check PASSED."
    exit 0
}

if (($output -join "`n") -match "Can't find a KitProg device") {
    throw "Probe check FAILED: KitProg device not found. Reconnect board, use a data USB cable, and close any app using KitProg."
}

throw "Probe check FAILED with OpenOCD exit code $exitCode"
