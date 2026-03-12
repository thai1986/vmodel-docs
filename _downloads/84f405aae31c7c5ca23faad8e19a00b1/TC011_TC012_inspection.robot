*** Settings ***
Documentation    Static / Code Inspection Tests
...
...    TC-011   SwcLedToggle_Run10ms is called at 10 ms period (code review)
...    TC-012   No direct hardware register access in SwcLedToggle.c (static analysis)
...
...    Requirements: REQ-SW-005, REQ-SW-006
...    Test method: Source-code inspection using SourceInspectionLibrary.
...
...    These tests do NOT require connected hardware.  They run entirely
...    from source files in the ``src/`` tree.

Resource         ../resources/variables.resource
Library          ../libraries/SourceInspectionLibrary.py
Library          OperatingSystem


*** Test Cases ***

# ── TC-011 ──────────────────────────────────────────────────────────────────

TC-011 - SwcLedToggle Run10ms Is Called In The 10ms Scheduler Loop
    [Documentation]    Verify that the main scheduler loop in ``main.c`` calls
    ...    ``SwcLedToggle_Run10ms()`` exactly once per iteration and that
    ...    ``Os_WaitTick10ms()`` precedes it, providing the ~10 ms period
    ...    required by REQ-SW-005.
    ...
    ...    Pass criteria
    ...    -------------
    ...    1. ``Os_WaitTick10ms`` is defined in ``main.c``.
    ...    2. ``SwcLedToggle_Run10ms`` is called in ``main.c``.
    ...    3. A ``while`` infinite loop is present.
    ...    4. ``Os_WaitTick10ms`` precedes ``SwcLedToggle_Run10ms`` in the text.
    ...    5. Busy-wait count >= 400 000 (approx 8 ms at 48 MHz).
    ...    6. ``SwcLedToggle_Run10ms`` appears exactly once.
    ...
    ...    Covers: REQ-SW-005
    [Tags]    TC-011    inspection    scheduler    REQ-SW-005

    # ---- 1. Os_WaitTick10ms must exist ----
    File Should Contain Pattern    ${MAIN_C}    Os_WaitTick10ms
    Log    TC-011 CHECK 1 PASS: Os_WaitTick10ms found.

    # ---- 2. SwcLedToggle_Run10ms must be called ----
    File Should Contain Pattern    ${MAIN_C}    SwcLedToggle_Run10ms
    Log    TC-011 CHECK 2 PASS: SwcLedToggle_Run10ms found.

    # ---- 3. Scheduler while loop must exist ----
    File Should Contain Pattern    ${MAIN_C}    while
    Log    TC-011 CHECK 3 PASS: while loop found.

    # ---- 4. Os_WaitTick10ms precedes SwcLedToggle_Run10ms ----
    First Occurrence Should Precede Second    ${MAIN_C}    Os_WaitTick10ms    SwcLedToggle_Run10ms
    Log    TC-011 CHECK 4 PASS: Os_WaitTick10ms precedes SwcLedToggle_Run10ms.

    # ---- 5. Busy-wait count must be >= 400 000 ----
    ${count}=    Extract Integer From Source    ${MAIN_C}    volatile\\s+uint32\\s+n\\s*=\\s*(\\d+)
    Should Be True    ${count} >= 400000
    ...    msg=TC-011 FAIL: Os_WaitTick10ms busy-wait count = ${count} (< 400000)
    Log    TC-011 CHECK 5 PASS: Busy-wait count = ${count}.

    # ---- 6. SwcLedToggle_Run10ms appears exactly once ----
    ${call_count}=    Count Pattern Occurrences    ${MAIN_C}    SwcLedToggle_Run10ms
    Should Be Equal As Integers    ${call_count}    1
    ...    msg=TC-011 FAIL: SwcLedToggle_Run10ms appears ${call_count} times in main.c (expected 1)
    Log    TC-011 CHECK 6 PASS: SwcLedToggle_Run10ms appears exactly once.

    Log    TC-011 PASS: Scheduler loop structure valid. Busy-wait count = ${count}.


# ── TC-012 ──────────────────────────────────────────────────────────────────

TC-012 - SwcLedToggle Contains No Direct Hardware Register Access
    [Documentation]    Verify that ``SwcLedToggle.c`` contains **no** direct
    ...    memory-mapped register accesses.  All hardware interaction must be
    ...    routed through the ``IoHwAb`` API.
    ...
    ...    The following forbidden patterns are checked:
    ...    - Raw GPIO base address literals starting with ``0x4031``
    ...    - Use of the ``REG32`` macro
    ...    - Use of pointer casts to volatile hardware addresses (``(volatile``)
    ...    - Direct DIO API calls (``Dio_ReadChannel`` / ``Dio_WriteChannel``)
    ...      that bypass the IoHwAb layer
    ...
    ...    Permitted API calls verified to be present:
    ...    - ``IoHwAb_Read_Sw1``
    ...    - ``IoHwAb_Write_Led1``
    ...
    ...    Covers: REQ-SW-006
    [Tags]    TC-012    inspection    architecture    REQ-SW-006

    # ---- Forbidden: raw GPIO address literals ----
    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    0x4031
    Log    TC-012 CHECK 1 PASS: No raw GPIO address literals (0x4031...) found.

    # ---- Forbidden: REG32 macro ----
    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    REG32
    Log    TC-012 CHECK 2 PASS: No REG32 macro usage found.

    # ---- Forbidden: volatile pointer casts (direct register access pattern) ----
    File Should Not Contain Text    ${SWC_LED_TOGGLE_C}    (volatile
    Log    TC-012 CHECK 3 PASS: No volatile pointer casts found.

    # ---- Forbidden: direct MCAL DIO calls bypassing IoHwAb ----
    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    Dio_ReadChannel
    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    Dio_WriteChannel
    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    Dio_FlipChannel
    Log    TC-012 CHECK 4 PASS: No direct DIO driver calls found.

    # ---- Required: IoHwAb API calls are present ----
    File Should Contain Pattern    ${SWC_LED_TOGGLE_C}    IoHwAb_Read_Sw1
    Log    TC-012 CHECK 5 PASS: IoHwAb_Read_Sw1 call found.

    File Should Contain Pattern    ${SWC_LED_TOGGLE_C}    IoHwAb_Write_Led1
    Log    TC-012 CHECK 6 PASS: IoHwAb_Write_Led1 call found.

    # ---- Required: IoHwAb header included (not Dio.h directly) ----
    File Should Contain Pattern    ${SWC_LED_TOGGLE_C}    IoHwAb.h
    Log    TC-012 CHECK 7 PASS: IoHwAb.h is included.

    File Should Not Contain Pattern    ${SWC_LED_TOGGLE_C}    Dio.h
    Log    TC-012 CHECK 8 PASS: Dio.h is NOT directly included in SwcLedToggle.c.

    Log    TC-012 PASS: SwcLedToggle.c contains zero direct register accesses. All I/O via IoHwAb API.
