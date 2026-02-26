*** Settings ***
Documentation    Functional / Board-level Tests
...
...    TC-003   LED1 is OFF at power-on reset
...    TC-004   LED1 turns ON after first SW1 press
...    TC-005   LED1 turns OFF after second SW1 press
...    TC-006   No repeated toggling while SW1 is held
...
...    Requirements covered: REQ-FUNC-001, REQ-FUNC-002, REQ-FUNC-003
...    Test method: Debugger register read for LED state; manual SW1
...                 interaction confirmed by the PRT_DR register value.
...
...    Preconditions
...    -------------
...    - Board powered and KitProg3 USB-DAP connected.
...    - Firmware flashed and running.
...    - OpenOCD connected (Suite Setup opens the connection).
...
...    NOTE: TC-004, TC-005, TC-006 require the tester to PHYSICALLY
...          press the SW1 button on the board when prompted.  The test
...          waits for the operator and then reads the LED register.

Resource         ../resources/variables.resource
Resource         ../resources/openocd.resource
Library          ../libraries/OpenOcdLibrary.py
Library          Collections
Suite Setup      Functional Suite Setup
Suite Teardown   Functional Suite Teardown


*** Test Cases ***

# ── TC-003 ──────────────────────────────────────────────────────────────────

TC-003 - LED1 Is OFF At Power-On Reset
    [Documentation]    Verify that LED1 (P19.0, active-LOW) is not illuminated
    ...    immediately after power-on reset.
    ...
    ...    Active-LOW LED:  PRT_DR bit 0 == 1 ( STD_HIGH ) → LED off.
    ...
    ...    Covers: REQ-FUNC-003
    [Tags]    TC-003    power-on    functional    REQ-FUNC-003

    # Perform a full reset so the MCU enters its startup sequence
    # Use reset run so CM0+ boot ROM can start CM4 before we halt.
    Reset And Run Target
    Sleep    0.5s    # 500 ms – enough for CM0+ boot + Port_Init + first scheduler tick
    Halt Target

    # Read PRT_DR bit 0 for P19 (LED1)
    ${led_dr_bit}=    Read PRT_DR Bit For Port Pin    19    0

    # Active-LOW: STD_HIGH (1) on the pin means LED is OFF
    Should Be Equal As Integers    ${led_dr_bit}    ${STD_HIGH}
    ...    msg=TC-003 FAIL: LED1 PRT_DR bit should be 1 (LED off) after reset, got ${led_dr_bit}

    Log    TC-003 PASS: LED1 PRT_DR bit = ${led_dr_bit} (STD_HIGH → LED off) after power-on reset.


# ── TC-004 ──────────────────────────────────────────────────────────────────

TC-004 - LED1 Turns ON After First SW1 Press
    [Documentation]    Verify that pressing SW1 once turns LED1 ON.
    ...
    ...    Starting state: LED1 OFF (PRT_DR bit 0 == 1).
    ...    After one press + release: LED1 ON  (PRT_DR bit 0 == 0).
    ...
    ...    Active-LOW LED:  PRT_DR bit 0 == 0 ( STD_LOW ) → LED on.
    ...
    ...    OPERATOR ACTION REQUIRED: Press and release SW1 when prompted.
    ...
    ...    Covers: REQ-FUNC-001, REQ-FUNC-002
    [Tags]    TC-004    functional    button    REQ-FUNC-001    REQ-FUNC-002

    # Precondition: TC-003 passed – LED must be OFF
    Verify LED1 Is Off    precondition=TC-003

    # Let firmware run so it can detect the button event
    Resume Target

    # Pause to allow the operator to press and release the button
    Log    ACTION REQUIRED: Press and release SW1 (USER button) on the board now.
    Sleep    5s    # Operator window: 5 seconds to press the button

    # Halt to read the stable post-press register state
    Halt Target

    # Active-LOW: STD_LOW (0) means LED is ON
    ${led_dr_bit}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${led_dr_bit}    ${STD_LOW}
    ...    msg=TC-004 FAIL: LED1 should be ON (PRT_DR bit = 0) after first SW1 press, got ${led_dr_bit}

    Log    TC-004 PASS: LED1 PRT_DR bit = ${led_dr_bit} (STD_LOW → LED on) after first SW1 press.


# ── TC-005 ──────────────────────────────────────────────────────────────────

TC-005 - LED1 Turns OFF After Second SW1 Press
    [Documentation]    Verify that pressing SW1 a second time turns LED1 OFF.
    ...
    ...    Starting state: LED1 ON (PRT_DR bit 0 == 0, from TC-004).
    ...    After one press + release: LED1 OFF (PRT_DR bit 0 == 1).
    ...
    ...    OPERATOR ACTION REQUIRED: Press and release SW1 when prompted.
    ...
    ...    Covers: REQ-FUNC-001, REQ-FUNC-002
    [Tags]    TC-005    functional    button    REQ-FUNC-001    REQ-FUNC-002

    # Precondition: TC-004 passed – LED must be ON
    Verify LED1 Is On    precondition=TC-004

    # Resume so the firmware can catch the button event
    Resume Target

    Log    ACTION REQUIRED: Press and release SW1 (USER button) on the board now.
    Sleep    5s

    Halt Target

    # Active-LOW: STD_HIGH (1) means LED is OFF
    ${led_dr_bit}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${led_dr_bit}    ${STD_HIGH}
    ...    msg=TC-005 FAIL: LED1 should be OFF (PRT_DR bit = 1) after second SW1 press, got ${led_dr_bit}

    Log    TC-005 PASS: LED1 PRT_DR bit = ${led_dr_bit} (STD_HIGH → LED off) after second SW1 press.


# ── TC-006 ──────────────────────────────────────────────────────────────────

TC-006 - No Repeated Toggle While SW1 Is Held For 3 Seconds
    [Documentation]    Verify that holding SW1 pressed for 3 seconds causes the
    ...    LED to change state exactly once; it must not toggle repeatedly.
    ...
    ...    Method: Record LED state before press, record again at 1 s intervals
    ...    while the button is held, verify LED state is stable throughout.
    ...
    ...    OPERATOR ACTION REQUIRED: Hold SW1 pressed when prompted.
    ...
    ...    Covers: REQ-FUNC-002
    [Tags]    TC-006    functional    button    debounce    REQ-FUNC-002

    # ------------------------------------------------------------------
    # 1. Capture the LED state before the button is pressed
    # ------------------------------------------------------------------
    Halt Target
    ${initial_led}=    Read PRT_DR Bit For Port Pin    19    0
    Resume Target

    Log    TC-006: LED1 initial state = ${initial_led}. ACTION REQUIRED: Press and HOLD SW1 now.
    Sleep    1s    # Short pause before hold starts

    # ------------------------------------------------------------------
    # 2. Sample LED at 1 s intervals while button is held
    # ------------------------------------------------------------------
    @{led_samples}=    Create List

    FOR    ${i}    IN RANGE    ${BUTTON_HOLD_SECONDS}
        Sleep    1s
        Halt Target
        ${sample}=    Read PRT_DR Bit For Port Pin    19    0
        Append To List    ${led_samples}    ${sample}
        Resume Target
        Log    TC-006: sample ${i+1}/${BUTTON_HOLD_SECONDS}: LED PRT_DR bit = ${sample}
    END

    Log    ACTION REQUIRED: Release SW1 now.
    Sleep    0.5s

    # ------------------------------------------------------------------
    # 3. The expected final state is the toggle of the initial state
    # ------------------------------------------------------------------
    ${expected_toggled}=    Evaluate    1 - int(${initial_led})

    # All samples must equal the toggled state (changed once, stayed stable)
    FOR    ${sample}    IN    @{led_samples}
        Should Be Equal As Integers    ${sample}    ${expected_toggled}
        ...    msg=TC-006 FAIL: LED toggled more than once during SW1 hold. Sample=${sample}, expected=${expected_toggled}
    END

    Log    TC-006 PASS: LED changed state exactly once during the ${BUTTON_HOLD_SECONDS} s SW1 hold.


*** Keywords ***

Functional Suite Setup
    [Documentation]    Connect to board and reset to a clean state, waiting
    ...    for CM0+ boot ROM to start CM4 and the scheduler loop to be running.
    Connect To Board Via OpenOCD
    # reset run lets CM0+ boot ROM complete and start CM4.
    Reset And Run Target
    Sleep    0.5s    # Let the firmware reach the main scheduler loop
    Halt Target

Functional Suite Teardown
    Resume Target
    Disconnect From Board

Verify LED1 Is Off
    [Documentation]    Assert that LED1 is currently off (PRT_DR bit 0 == STD_HIGH).
    [Arguments]    ${precondition}=none
    Halt Target
    ${bit}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${bit}    ${STD_HIGH}
    ...    msg=Precondition (${precondition}) not met: LED1 must be OFF before this test (PRT_DR bit = ${bit})
    Resume Target

Verify LED1 Is On
    [Documentation]    Assert that LED1 is currently on (PRT_DR bit 0 == STD_LOW).
    [Arguments]    ${precondition}=none
    Halt Target
    ${bit}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${bit}    ${STD_LOW}
    ...    msg=Precondition (${precondition}) not met: LED1 must be ON before this test (PRT_DR bit = ${bit})
    Resume Target
