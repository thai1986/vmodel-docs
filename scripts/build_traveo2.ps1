param(
    [string]$BuildType = "Debug"
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required tool: $Name"
    }
}

Require-Command cmake
Require-Command ninja
Require-Command arm-none-eabi-gcc

$root = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $root "build"

$buildTypeArg = "CMAKE_BUILD_TYPE:STRING=$BuildType"
$toolchainArg = "CMAKE_TOOLCHAIN_FILE:FILEPATH=$root/cmake/toolchain-arm-none-eabi.cmake"

cmake -S $root -B $buildDir -G Ninja -D $buildTypeArg -D $toolchainArg
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed with exit code $LASTEXITCODE"
}

cmake --build $buildDir
if ($LASTEXITCODE -ne 0) {
    throw "CMake build failed with exit code $LASTEXITCODE"
}

Write-Host "Build complete: $buildDir"
