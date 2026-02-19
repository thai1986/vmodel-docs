param(
    [string]$ElfPath = "build\traveo2_starter.elf",
    [string]$InterfaceCfg = "interface/cmsis-dap.cfg",
    [string]$TargetCfg = "target/traveo2_1m_a0.cfg",
    [string]$OpenOcdScriptsDir = "",
    [string]$OpenOcdExe = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ElfPath)) {
    throw "ELF file not found: $ElfPath"
}

$elfPathResolved = (Resolve-Path $ElfPath).Path -replace '\\','/'

$candidateOpenOcdExe = @()
if ($OpenOcdExe -ne "") {
    $candidateOpenOcdExe += $OpenOcdExe
}

$candidateOpenOcdExe += "C:\Infineon\Tools\ModusToolboxProgtools-1.7\openocd\bin\openocd.exe"

$pathOpenOcd = Get-Command openocd -ErrorAction SilentlyContinue
if ($pathOpenOcd) {
    $candidateOpenOcdExe += $pathOpenOcd.Source
}

$openocdExe = $null
foreach ($candidateExe in $candidateOpenOcdExe) {
    if (Test-Path $candidateExe) {
        $openocdExe = $candidateExe
        break
    }
}

if (-not $openocdExe) {
    throw "Missing required tool: openocd"
}

$candidateScriptDirs = @()

if ($OpenOcdScriptsDir -ne "") {
    $candidateScriptDirs += $OpenOcdScriptsDir
}

$openocdBinDir = Split-Path -Parent $openocdExe
$exeRelativeScripts = Join-Path $openocdBinDir "..\scripts"
$candidateScriptDirs += $exeRelativeScripts

$candidateScriptDirs += "C:\Infineon\Tools\ModusToolboxProgtools-1.7\openocd\scripts"
$openocdRoot = Split-Path -Parent (Split-Path -Parent $openocdExe)
$candidateScriptDirs += (Join-Path $openocdRoot "openocd\scripts")

$openocdScripts = $null
foreach ($candidate in $candidateScriptDirs) {
    if (Test-Path $candidate) {
        $openocdScripts = $candidate
        break
    }
}

if (-not $openocdScripts) {
    throw "OpenOCD scripts directory not found. Checked: $($candidateScriptDirs -join '; ')"
}

$interfacePath = Join-Path $openocdScripts $InterfaceCfg
if (-not (Test-Path $interfacePath)) {
    throw "OpenOCD interface config not found: $interfacePath"
}

$targetPath = Join-Path $openocdScripts $TargetCfg
if (-not (Test-Path $targetPath)) {
    throw "OpenOCD target config not found: $targetPath. Set -OpenOcdScriptsDir and -TargetCfg to your installed TRAVEO II script path."
}

$openOcdCommand = 'transport select swd; program "' + $elfPathResolved + '" verify reset exit'
& $openocdExe -s $openocdScripts -f $InterfaceCfg -f $TargetCfg -c $openOcdCommand
if ($LASTEXITCODE -ne 0) {
    throw "OpenOCD flash failed with exit code $LASTEXITCODE"
}

Write-Host "Flash complete: $elfPathResolved"
