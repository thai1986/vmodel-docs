# Step-by-Step: CYTVII-B-E-1M-SK (Compile + Flash)

## 1) Prerequisites (Windows)

Install these tools and ensure they are in `PATH`:

1. CMake
2. Ninja
3. GNU Arm Embedded Toolchain (`arm-none-eabi-gcc`)
4. OpenOCD (with KitProg3 support)

Quick check:

```powershell
Get-Command cmake,ninja,arm-none-eabi-gcc,openocd
```

## 2) Project structure
# Step-by-Step: CYTVII-B-E-1M-SK (Compile + Flash)

## 1) Prerequisites (Windows)

Install these tools and ensure they are in PATH:

1. CMake
2. Ninja
3. GNU Arm Embedded Toolchain (arm-none-eabi-gcc)
4. OpenOCD

Quick check:

```powershell
Get-Command cmake,ninja,arm-none-eabi-gcc,openocd
```

Current status on this machine:

- Installed: CMake, Ninja, GNU Arm Embedded Toolchain, OpenOCD xPack
- Build: verified working
- Flash tooling: script auto-prefers Infineon OpenOCD at C:\Infineon\Tools\ModusToolboxProgtools-1.7\openocd\bin\openocd.exe

## 2) Project structure

This starter repo contains:

- CMakeLists.txt
- cmake/toolchain-arm-none-eabi.cmake
- src/main.c
- linker/traveo2_1m.ld
- scripts/build_traveo2.ps1
- scripts/check_kitprog.ps1
- scripts/flash_traveo2.ps1

## 3) Compile

From repository root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./scripts/build_traveo2.ps1 -BuildType Debug
```

Expected output file:

- build/traveo2_starter.elf

## 4) Pre-flash health check

Connect board via USB, then run:

```powershell
./scripts/check_kitprog.ps1
```

If this fails with "Can't find a KitProg device", reconnect cable/board and close apps that may be using KitProg.

## 5) Flash to CYTVII-B-E-1M-SK

Run:

```powershell
./scripts/flash_traveo2.ps1 -ElfPath "build\traveo2_starter.elf" -InterfaceCfg "interface/kitprog.cfg" -TargetCfg "target/traveo2_1m_a0.cfg"
```

If your board revision uses a different TRAVEO II target cfg, change TargetCfg accordingly.

## 6) Troubleshooting

### Missing tools

If a script reports a missing tool, reopen terminal after install and rerun.

### Linker or startup issues

This repo uses a minimal placeholder linker script for bring-up.
For production firmware, replace with official Infineon startup/linker files for your exact device variant.

### List OpenOCD target configs

```powershell
$openocd = (Get-Command openocd).Source
$scripts = Join-Path (Split-Path -Parent (Split-Path -Parent $openocd)) "openocd\scripts"
Get-ChildItem (Join-Path $scripts "target") -Filter *.cfg | Select-Object -ExpandProperty Name
```

