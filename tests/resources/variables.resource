*** Settings ***
Documentation    Shared variables for TRAVEO II LED-toggle test suite.
...              Hardware: CYTVII-B-E-1M-SK  MCU: CYT2B75XX
...
...              GPIO register map
...              ─────────────────
...              GPIO_BASE          = 0x40310000
...              GPIO_PORT_STRIDE   = 0x80 (128 bytes per port)
...              PRT_DR  offset     = 0x00  (output data register)
...              PRT_PS  offset     = 0x04  (pin state – input read)
...              PRT_PC  offset     = 0x08  (drive mode configuration)


*** Variables ***
# ── OpenOCD connection ──────────────────────────────────────────────────────
${OPENOCD_HOST}         localhost
${OPENOCD_PORT}         4444
${OPENOCD_TIMEOUT}      5

# OpenOCD interface / target config files (relative to the OpenOCD scripts dir)
${OPENOCD_INTERFACE}    interface/cmsis-dap.cfg
${OPENOCD_TARGET}       target/traveo2_1m_a0.cfg

# Firmware binary built by CMake
${ELF_PATH}             ${CURDIR}${/}..${/}..${/}build${/}traveo2_starter.elf

# ── GPIO base addresses ──────────────────────────────────────────────────────
${GPIO_BASE}            ${0x40310000}
${GPIO_PORT_STRIDE}     ${0x80}

# Port 7  – SW1 on P7.0
${PORT7_BASE}           ${0x40310380}    # 0x40310000 + 7*0x80
${P7_PRT_DR}            ${0x40310380}
${P7_PRT_PS}            ${0x40310384}
${P7_PRT_PC}            ${0x40310388}

# Port 19 – LED1 on P19.0
${PORT19_BASE}          ${0x40310980}    # 0x40310000 + 19*0x80
${P19_PRT_DR}           ${0x40310980}
${P19_PRT_PS}           ${0x40310984}
${P19_PRT_PC}           ${0x40310988}

# ── Drive-mode constants (PRT_PC bits[2:0]) ─────────────────────────────────
${PORT_DM_PULLUP}       ${0x2}    # Pull-up  – expected for SW1  (P7.0)
${PORT_DM_STRONG}       ${0x6}    # Strong   – expected for LED1 (P19.0)

# ── AUTOSAR / IoHwAb constants ───────────────────────────────────────────────
${STD_LOW}              ${0}
${STD_HIGH}             ${1}
${IOHWAB_SIG_INACTIVE}  ${0}
${IOHWAB_SIG_ACTIVE}    ${1}

# ── Timing ───────────────────────────────────────────────────────────────────
${BUTTON_HOLD_SECONDS}      3
${POWER_CYCLE_WAIT_S}       2
${DEBOUNCE_PERIOD_MS}       10

# ── Source-code paths (for static / inspection tests) ────────────────────────
${SRC_ROOT}             ${CURDIR}${/}..${/}..${/}src
${SWC_LED_TOGGLE_C}     ${SRC_ROOT}${/}App${/}SwcLedToggle${/}SwcLedToggle.c
${IOHWAB_C}             ${SRC_ROOT}${/}EcuAb${/}IoHwAb${/}IoHwAb.c
${DIO_C}                ${SRC_ROOT}${/}Mcal${/}Dio${/}Dio.c
${MAIN_C}               ${SRC_ROOT}${/}main.c
