*** Settings ***
Documentation    Port Initialisation Tests
...
...    TC-001   SW1 pin (P7.0) drive mode after Port_Init
...    TC-002   LED1 pin (P19.0) drive mode after Port_Init
...
...    Requirements covered: REQ-SW-001, REQ-HW-001, REQ-HW-002
...    Test method: Debugger register read via OpenOCD
...
...    Preconditions
...    -------------
...    - Board powered and KitProg3 USB-DAP connected to the host.
...    - OpenOCD running (or the Suite Setup will start it).
...    - Firmware ELF flashed to the target.
...
...    Pass criteria
...    -------------
...    TC-001:  bits[2:0] of PRT_PC(P7)  == 0x2  (PORT_DM_PULLUP)
...    TC-002:  bits[2:0] of PRT_PC(P19) == 0x6  (PORT_DM_STRONG)

Resource         ../resources/variables.resource
Resource         ../resources/openocd.resource
Library          ../libraries/OpenOcdLibrary.py
Suite Setup      Port Init Suite Setup
Suite Teardown   Port Init Suite Teardown


*** Test Cases ***

# ── TC-001 ──────────────────────────────────────────────────────────────────

TC-001 - SW1 Pin P7.0 Drive Mode Is Pull-Up After Port Init
    [Documentation]    Verify that the PORT driver configures P7.0 (SW1) with
    ...    pull-up drive mode (PORT_DM_PULLUP = 0x2) immediately after
    ...    Port_Init() returns.
    ...
    ...    Covers: REQ-SW-001, REQ-HW-001
    ...    Requirement reference: PRT_PC for GPIO port 7 bits[2:0] == 0x2
    [Tags]    TC-001    port-init    hw-register    REQ-SW-001    REQ-HW-001

    # Halt the target so the register values are stable
    Halt Target

    # Read bits[2:0] of PRT_PC for port 7 (SW1)
    ${drive_mode}=    Read PRT_PC Bits For Port    7

    # Verify the drive-mode is pull-up (0x2 = PORT_DM_PULLUP)
    Should Be Equal As Integers    ${drive_mode}    ${PORT_DM_PULLUP}
    ...    msg=TC-001 FAIL: P7.0 (SW1) PRT_PC drive-mode expected ${PORT_DM_PULLUP} (pull-up) but got ${drive_mode}

    Log    TC-001 PASS: P7.0 drive-mode = ${drive_mode} (PORT_DM_PULLUP)


# ── TC-002 ──────────────────────────────────────────────────────────────────

TC-002 - LED1 Pin P19.0 Drive Mode Is Strong After Port Init
    [Documentation]    Verify that the PORT driver configures P19.0 (LED1) with
    ...    strong drive mode (PORT_DM_STRONG = 0x6) immediately after
    ...    Port_Init() returns.
    ...
    ...    Covers: REQ-SW-001, REQ-HW-002
    ...    Requirement reference: PRT_PC for GPIO port 19 bits[2:0] == 0x6
    [Tags]    TC-002    port-init    hw-register    REQ-SW-001    REQ-HW-002

    # Halt the target so the register values are stable
    Halt Target

    # Read bits[2:0] of PRT_PC for port 19 (LED1)
    ${drive_mode}=    Read PRT_PC Bits For Port    19

    # Verify the drive-mode is strong (0x6 = PORT_DM_STRONG)
    Should Be Equal As Integers    ${drive_mode}    ${PORT_DM_STRONG}
    ...    msg=TC-002 FAIL: P19.0 (LED1) PRT_PC drive-mode expected ${PORT_DM_STRONG} (strong) but got ${drive_mode}

    Log    TC-002 PASS: P19.0 drive-mode = ${drive_mode} (PORT_DM_STRONG)


*** Keywords ***

Port Init Suite Setup
    [Documentation]    Connect to the board via OpenOCD and reset the target,
    ...    waiting for the CM0+ boot ROM to start CM4 and Port_Init() to complete.
    Connect To Board Via OpenOCD
    # Use reset run so CM0+ boot ROM can initialise and start CM4.
    # reset halt would stop CM0+ before it can start CM4, leaving Port_Init() uncalled.
    Reset And Run Target
    Sleep    0.5s    # 500 ms – enough for CM0+ boot + CM4 startup + Port_Init
    Halt Target
    Log    Board halted. PRT_PC registers should reflect post-Port_Init state.

Port Init Suite Teardown
    [Documentation]    Resume the target and close the OpenOCD connection.
    Resume Target
    Disconnect From Board
