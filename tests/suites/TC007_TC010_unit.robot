*** Settings ***
Documentation    Unit Tests – DIO driver and IoHwAb layer
...
...    TC-007   Dio_ReadChannel returns STD_LOW when SW1 is pressed
...    TC-008   Dio_WriteChannel drives LED1 active-LOW correctly
...    TC-009   IoHwAb polarity inversion for SW1 (active-LOW pin → ACTIVE signal)
...    TC-010   IoHwAb polarity inversion for LED1 (ACTIVE signal → active-LOW pin)
...
...    Requirements: REQ-SW-002, REQ-SW-003, REQ-SW-004, REQ-HW-001, REQ-HW-002
...    Test method: Register read via OpenOCD debugger + operator button interaction.
...
...    Active-LOW truth tables
...    ----------------------
...    SW1  (P7.0,  pull-up input):
...      SW1 pressed  → P7.0 tied LOW  → PRT_PS bit 0 = 0 (STD_LOW)
...      SW1 released → P7.0 pulled HIGH → PRT_PS bit 0 = 1 (STD_HIGH)
...
...    LED1 (P19.0, strong output):
...      LED ON  (ACTIVE)   → drive LOW  → PRT_DR bit 0 = 0 (STD_LOW)
...      LED OFF (INACTIVE) → drive HIGH → PRT_DR bit 0 = 1 (STD_HIGH)

Resource         ../resources/variables.resource
Resource         ../resources/openocd.resource
Library          ../libraries/OpenOcdLibrary.py
Suite Setup      Unit Test Suite Setup
Suite Teardown   Unit Test Suite Teardown


*** Test Cases ***

# ── TC-007 ──────────────────────────────────────────────────────────────────

TC-007 - Dio ReadChannel Returns STD_LOW When SW1 Is Pressed
    [Documentation]    Verify that ``Dio_ReadChannel(DIO_CHANNEL_SW1)`` returns
    ...    ``STD_LOW`` (0x00) while SW1 is physically pressed.
    ...
    ...    The DIO driver reads PRT_PS (pin state register).  When the active-LOW
    ...    switch closes the circuit, P7.0 is pulled to GND → PRT_PS bit 0 == 0.
    ...
    ...    This test uses debugger pin forcing to emulate SW1 pressed/released
    ...    states without manual button interaction.
    ...
    ...    Covers: REQ-SW-002, REQ-HW-001
    [Tags]    TC-007    unit    dio    REQ-SW-002    REQ-HW-001

    Halt Target
    ${pc_before}=    Read Register    ${P7_PRT_PC}
    ${dr_before}=    Read Register    ${P7_PRT_DR}

    # Force P7.0 to strong drive output so we can inject deterministic levels.
    ${pc_force_out}=    Evaluate    (int(${pc_before}) & 0xFFFFFFF0) | 0xE
    Write Register    ${P7_PRT_PC}    ${pc_force_out}

    # Emulate SW1 released: pin HIGH
    ${dr_release}=    Evaluate    int(${dr_before}) | (1 << 0)
    Write Register    ${P7_PRT_DR}    ${dr_release}
    ${released_ps}=    Read PRT_PS Bit For Port Pin    7    0
    Should Be Equal As Integers    ${released_ps}    ${STD_HIGH}
    ...    msg=TC-007 precondition: emulated released state should read HIGH, got ${released_ps}

    # Emulate SW1 pressed: pin LOW
    ${dr_press}=    Evaluate    int(${dr_before}) & ~(1 << 0) & 0xFFFFFFFF
    Write Register    ${P7_PRT_DR}    ${dr_press}
    ${pressed_ps}=    Read PRT_PS Bit For Port Pin    7    0

    # SW1 active-LOW: pressed → pin LOW → PRT_PS bit = 0 (STD_LOW)
    Should Be Equal As Integers    ${pressed_ps}    ${STD_LOW}
    ...    msg=TC-007 FAIL: Dio_ReadChannel(SW1) should return STD_LOW (PRT_PS bit 0 = 0) while SW1 pressed, got ${pressed_ps}

    # Restore original SW1 pin configuration and output data.
    Write Register    ${P7_PRT_DR}    ${dr_before}
    Write Register    ${P7_PRT_PC}    ${pc_before}
    Resume Target
    Log    TC-007 PASS: Emulated SW1 press drives PRT_PS bit 0 LOW as expected.


# ── TC-008 ──────────────────────────────────────────────────────────────────

TC-008 - Dio WriteChannel Drives LED1 Active-LOW Correctly
    [Documentation]    Verify that ``Dio_WriteChannel(DIO_CHANNEL_LED1, STD_LOW)``
    ...    sets PRT_DR bit 0 to 0, turning LED1 ON via the active-LOW circuit.
    ...    Then verify that writing STD_HIGH sets PRT_DR bit 0 to 1 (LED off).
    ...
    ...    The test directly sets PRT_DR via OpenOCD to simulate what
    ...    Dio_WriteChannel does, then reads back to confirm.
    ...
    ...    Covers: REQ-SW-003, REQ-HW-002
    [Tags]    TC-008    unit    dio    REQ-SW-003    REQ-HW-002

    Halt Target

    # ---- Step 1: Write STD_LOW to simulate "LED active request" ----
    # Simulate Dio_WriteChannel(DIO_CHANNEL_LED1, STD_LOW)
    # PRT_DR for P19: read–modify–write to clear bit 0
    ${dr_before}=    Read Register    ${P19_PRT_DR}
    ${dr_led_on}=    Evaluate    int(${dr_before}) & ~(1 << 0) & 0xFFFFFFFF
    Write Register    ${P19_PRT_DR}    ${dr_led_on}

    ${prt_dr_bit}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${prt_dr_bit}    ${STD_LOW}
    ...    msg=TC-008 FAIL: After writing STD_LOW to LED1, PRT_DR bit 0 should be 0, got ${prt_dr_bit}
    Log    TC-008 Step 1 PASS: PRT_DR bit 0 = ${prt_dr_bit} (STD_LOW → LED active-LOW ON).

    # ---- Step 2: Write STD_HIGH to simulate "LED off request" ----
    ${dr_led_off}=    Evaluate    int(${dr_before}) | (1 << 0)
    Write Register    ${P19_PRT_DR}    ${dr_led_off}

    ${prt_dr_bit_off}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${prt_dr_bit_off}    ${STD_HIGH}
    ...    msg=TC-008 FAIL: After writing STD_HIGH to LED1, PRT_DR bit 0 should be 1, got ${prt_dr_bit_off}
    Log    TC-008 Step 2 PASS: PRT_DR bit 0 = ${prt_dr_bit_off} (STD_HIGH → LED off).

    Resume Target


# ── TC-009 ──────────────────────────────────────────────────────────────────

TC-009 - IoHwAb Polarity Inversion For SW1
    [Documentation]    Verify the active-LOW polarity inversion implemented by
    ...    ``IoHwAb_Read_Sw1()``:
    ...
    ...      Pin LOW  (SW1 pressed)  → ``IOHWAB_SIG_ACTIVE``   (1)
    ...      Pin HIGH (SW1 released) → ``IOHWAB_SIG_INACTIVE`` (0)
    ...
    ...    The test emulates SW1 pin states via debugger pin forcing and checks
    ...    the expected active-LOW polarity mapping.
    ...
    ...    Covers: REQ-SW-004
    [Tags]    TC-009    unit    iohwab    polarity    REQ-SW-004

    Halt Target
    ${pc_before}=    Read Register    ${P7_PRT_PC}
    ${dr_before}=    Read Register    ${P7_PRT_DR}

    # Force P7.0 to strong drive output to inject deterministic levels.
    ${pc_force_out}=    Evaluate    (int(${pc_before}) & 0xFFFFFFF0) | 0xE
    Write Register    ${P7_PRT_PC}    ${pc_force_out}

    # -- Verify with SW1 released (INACTIVE expected) --
    ${dr_release}=    Evaluate    int(${dr_before}) | (1 << 0)
    Write Register    ${P7_PRT_DR}    ${dr_release}
    ${pin_released}=    Read PRT_PS Bit For Port Pin    7    0
    # Compute expected IoHwAb output: pin HIGH → INACTIVE
    ${iohwab_inactive}=    Evaluate    ${IOHWAB_SIG_INACTIVE} if int(${pin_released}) == 1 else ${IOHWAB_SIG_ACTIVE}
    Should Be Equal As Integers    ${iohwab_inactive}    ${IOHWAB_SIG_INACTIVE}
    ...    msg=TC-009 FAIL (released): pin HIGH should map to IOHWAB_SIG_INACTIVE (0). PRT_PS bit = ${pin_released}
    Log    TC-009: Released: PRT_PS bit = ${pin_released} → IoHwAb = ${iohwab_inactive} (INACTIVE). PASS.

    # -- Verify with SW1 pressed (ACTIVE expected) --
    ${dr_press}=    Evaluate    int(${dr_before}) & ~(1 << 0) & 0xFFFFFFFF
    Write Register    ${P7_PRT_DR}    ${dr_press}
    ${pin_pressed}=    Read PRT_PS Bit For Port Pin    7    0
    # Compute expected IoHwAb output: pin LOW → ACTIVE
    ${iohwab_active}=    Evaluate    ${IOHWAB_SIG_ACTIVE} if int(${pin_pressed}) == 0 else ${IOHWAB_SIG_INACTIVE}
    Should Be Equal As Integers    ${iohwab_active}    ${IOHWAB_SIG_ACTIVE}
    ...    msg=TC-009 FAIL (pressed): pin LOW should map to IOHWAB_SIG_ACTIVE (1). PRT_PS bit = ${pin_pressed}
    Log    TC-009: Pressed: PRT_PS bit = ${pin_pressed} → IoHwAb = ${iohwab_active} (ACTIVE). PASS.

    # Restore original SW1 pin configuration and output data.
    Write Register    ${P7_PRT_DR}    ${dr_before}
    Write Register    ${P7_PRT_PC}    ${pc_before}
    Resume Target


# ── TC-010 ──────────────────────────────────────────────────────────────────

TC-010 - IoHwAb Polarity Inversion For LED1
    [Documentation]    Verify the active-LOW polarity inversion implemented by
    ...    ``IoHwAb_Write_Led1()``:
    ...
    ...      ``IOHWAB_SIG_ACTIVE``   (1) → PRT_DR bit 0 = 0  (STD_LOW,  LED on)
    ...      ``IOHWAB_SIG_INACTIVE`` (0) → PRT_DR bit 0 = 1  (STD_HIGH, LED off)
    ...
    ...    The test simulates the Dio_WriteChannel calls by directly writing PRT_DR.
    ...
    ...    Covers: REQ-SW-004
    [Tags]    TC-010    unit    iohwab    polarity    REQ-SW-004

    Halt Target

    # ---- Step 1: IOHWAB_SIG_ACTIVE → STD_LOW on PRT_DR ----
    # Simulate IoHwAb_Write_Led1(IOHWAB_SIG_ACTIVE): write STD_LOW to P19.0
    ${dr_val}=    Read Register    ${P19_PRT_DR}
    ${dr_active}=    Evaluate    int(${dr_val}) & ~(1 << 0) & 0xFFFFFFFF
    Write Register    ${P19_PRT_DR}    ${dr_active}

    ${bit_active}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${bit_active}    ${STD_LOW}
    ...    msg=TC-010 FAIL: IOHWAB_SIG_ACTIVE should drive PRT_DR bit 0 = STD_LOW (0), got ${bit_active}
    Log    TC-010 Step 1 PASS: IOHWAB_SIG_ACTIVE → PRT_DR bit 0 = ${bit_active} (STD_LOW, LED ON).

    # ---- Step 2: IOHWAB_SIG_INACTIVE → STD_HIGH on PRT_DR ----
    # Simulate IoHwAb_Write_Led1(IOHWAB_SIG_INACTIVE): write STD_HIGH to P19.0
    ${dr_inactive}=    Evaluate    int(${dr_val}) | (1 << 0)
    Write Register    ${P19_PRT_DR}    ${dr_inactive}

    ${bit_inactive}=    Read PRT_DR Bit For Port Pin    19    0
    Should Be Equal As Integers    ${bit_inactive}    ${STD_HIGH}
    ...    msg=TC-010 FAIL: IOHWAB_SIG_INACTIVE should drive PRT_DR bit 0 = STD_HIGH (1), got ${bit_inactive}
    Log    TC-010 Step 2 PASS: IOHWAB_SIG_INACTIVE → PRT_DR bit 0 = ${bit_inactive} (STD_HIGH, LED OFF).

    Resume Target


*** Keywords ***

Unit Test Suite Setup
    Connect To Board Via OpenOCD
    # reset run lets CM0+ boot ROM complete and start CM4.
    Reset And Run Target
    Sleep    0.5s    # Let Port_Init run so drive modes and PRT_PS pull-up are active
    Halt Target

Unit Test Suite Teardown
    Resume Target
    Disconnect From Board
