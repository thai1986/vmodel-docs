Test Specification
==================

This page defines the test cases for the **TRAVEO II Entry Family Starter Kit**
LED toggle feature. Each test case is linked to one or more requirements
in the :doc:`requirements` page.

.. contents:: Test Cases
   :local:
   :depth: 1

----

Overview
--------

.. list-table::
   :widths: 15 40 20 15 10
   :header-rows: 1

   * - Test ID
     - Summary
     - Covers
     - Method
     - Status
   * - :ref:`TC-001`
     - Port initialisation – SW1 pin drive mode
     - :ref:`REQ-SW-001`, :ref:`REQ-HW-001`
     - Inspection / Debug
     - Draft
   * - :ref:`TC-002`
     - Port initialisation – LED1 pin drive mode
     - :ref:`REQ-SW-001`, :ref:`REQ-HW-002`
     - Inspection / Debug
     - Draft
   * - :ref:`TC-003`
     - LED1 OFF at power-on reset
     - :ref:`REQ-FUNC-003`
     - Board Test
     - Draft
   * - :ref:`TC-004`
     - LED1 turns ON on first SW1 press
     - :ref:`REQ-FUNC-001`, :ref:`REQ-FUNC-002`
     - Board Test
     - Draft
   * - :ref:`TC-005`
     - LED1 turns OFF on second SW1 press
     - :ref:`REQ-FUNC-001`, :ref:`REQ-FUNC-002`
     - Board Test
     - Draft
   * - :ref:`TC-006`
     - No repeated toggle while holding SW1
     - :ref:`REQ-FUNC-002`
     - Board Test
     - Draft
   * - :ref:`TC-007`
     - Dio_ReadChannel returns STD_LOW when SW1 pressed
     - :ref:`REQ-SW-002`, :ref:`REQ-HW-001`
     - Unit Test
     - Draft
   * - :ref:`TC-008`
     - Dio_WriteChannel drives LED1 active-LOW correctly
     - :ref:`REQ-SW-003`, :ref:`REQ-HW-002`
     - Unit Test
     - Draft
   * - :ref:`TC-009`
     - IoHwAb polarity inversion – SW1
     - :ref:`REQ-SW-004`
     - Unit Test
     - Draft
   * - :ref:`TC-010`
     - IoHwAb polarity inversion – LED1
     - :ref:`REQ-SW-004`
     - Unit Test
     - Draft
   * - :ref:`TC-011`
     - SWC runnable called at 10 ms period
     - :ref:`REQ-SW-005`
     - Inspection
     - Draft
   * - :ref:`TC-012`
     - No direct register access in SwcLedToggle
     - :ref:`REQ-SW-006`
     - Code Review
     - Draft

----

Test Cases
----------

.. _TC-001:

TC-001 – SW1 Pin Drive Mode After Port_Init
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-001
:Covers:          :ref:`REQ-SW-001`, :ref:`REQ-HW-001`
:Test Method:     Inspection / Debugger register read
:Robot File:      :download:`TC001_TC002_port_init.robot <../tests/suites/TC001_TC002_port_init.robot>`
:Precondition:    Board powered, firmware loaded, debugger connected.
:Expected Result: ``PRT_PC`` for port 7, pin 0 = ``0x02`` (pull-up drive mode).

**Steps**

1. Flash firmware to board.
2. Halt CPU immediately after ``Port_Init()`` returns (breakpoint).
3. Read register ``0x40310000 + (7 * 0x80) + 0x08`` (GPIO port 7, PRT_PC).
4. Verify bits [2:0] equal ``0x2`` (``PORT_DM_PULLUP``).

**Pass Criteria**

Bits [2:0] of PRT_PC for P7 == ``0x2``.

----

.. _TC-002:

TC-002 – LED1 Pin Drive Mode After Port_Init
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-002
:Covers:          :ref:`REQ-SW-001`, :ref:`REQ-HW-002`
:Test Method:     Inspection / Debugger register read
:Robot File:      :download:`TC001_TC002_port_init.robot <../tests/suites/TC001_TC002_port_init.robot>`
:Precondition:    Board powered, firmware loaded, debugger connected.
:Expected Result: ``PRT_PC`` for port 19, pin 0 = ``0x06`` (strong drive mode).

**Steps**

1. Flash firmware to board.
2. Halt CPU immediately after ``Port_Init()`` returns (breakpoint).
3. Read register ``0x40310000 + (19 * 0x80) + 0x08`` (GPIO port 19, PRT_PC).
4. Verify bits [2:0] equal ``0x6`` (``PORT_DM_STRONG``).

**Pass Criteria**

Bits [2:0] of PRT_PC for P19 == ``0x6``.

----

.. _TC-003:

TC-003 – LED1 OFF at Power-On Reset
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-003
:Covers:          :ref:`REQ-FUNC-003`
:Test Method:     Board Test (visual observation)
:Robot File:      :download:`TC003_TC006_functional.robot <../tests/suites/TC003_TC006_functional.robot>`
:Precondition:    Board powered via USB. No button pressed.

**Steps**

1. Power-cycle the board (unplug and reconnect USB).
2. Observe LED1 immediately after power-on.

**Pass Criteria**

LED1 is **not illuminated** after power-on reset.

----

.. _TC-004:

TC-004 – LED1 ON After First SW1 Press
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-004
:Covers:          :ref:`REQ-FUNC-001`, :ref:`REQ-FUNC-002`
:Test Method:     Board Test (visual observation)
:Robot File:      :download:`TC003_TC006_functional.robot <../tests/suites/TC003_TC006_functional.robot>`
:Precondition:    TC-003 passed (LED1 is OFF).

**Steps**

1. Press SW1 once and release.
2. Observe LED1.

**Pass Criteria**

LED1 is **illuminated** (blue) after releasing SW1.

----

.. _TC-005:

TC-005 – LED1 OFF After Second SW1 Press
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-005
:Covers:          :ref:`REQ-FUNC-001`, :ref:`REQ-FUNC-002`
:Test Method:     Board Test (visual observation)
:Robot File:      :download:`TC003_TC006_functional.robot <../tests/suites/TC003_TC006_functional.robot>`
:Precondition:    TC-004 passed (LED1 is ON).

**Steps**

1. Press SW1 once and release.
2. Observe LED1.

**Pass Criteria**

LED1 is **not illuminated** after releasing SW1.

----

.. _TC-006:

TC-006 – No Repeated Toggle While Holding SW1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-006
:Covers:          :ref:`REQ-FUNC-002`
:Test Method:     Board Test (visual observation)
:Robot File:      :download:`TC003_TC006_functional.robot <../tests/suites/TC003_TC006_functional.robot>`
:Precondition:    LED1 is in any stable state.

**Steps**

1. Press and **hold** SW1 for 3 seconds without releasing.
2. Observe LED1 during the hold period.
3. Release SW1.

**Pass Criteria**

LED1 changes state **exactly once** at the moment of press.
It does not toggle repeatedly while the button is held.

----

.. _TC-007:

TC-007 – Dio_ReadChannel Returns STD_LOW When SW1 Pressed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-007
:Covers:          :ref:`REQ-SW-002`, :ref:`REQ-HW-001`
:Test Method:     Unit Test (debugger watch / printf trace)
:Robot File:      :download:`TC007_TC010_unit.robot <../tests/suites/TC007_TC010_unit.robot>`
:Precondition:    Debugger connected. Breakpoint inside ``SwcLedToggle_Run10ms``.

**Steps**

1. Set a breakpoint at the ``IoHwAb_Read_Sw1()`` call in ``SwcLedToggle_Run10ms``.
2. Press and hold SW1.
3. Step into ``IoHwAb_Read_Sw1`` → ``Dio_ReadChannel(DIO_CHANNEL_SW1)``.
4. Inspect return value.

**Pass Criteria**

``Dio_ReadChannel(DIO_CHANNEL_SW1)`` returns ``STD_LOW`` (0x00) while SW1 is held pressed.

----

.. _TC-008:

TC-008 – Dio_WriteChannel Drives LED1 Active-LOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-008
:Covers:          :ref:`REQ-SW-003`, :ref:`REQ-HW-002`
:Test Method:     Unit Test (debugger register read)
:Robot File:      :download:`TC007_TC010_unit.robot <../tests/suites/TC007_TC010_unit.robot>`
:Precondition:    Debugger connected.

**Steps**

1. Set a breakpoint after ``IoHwAb_Write_Led1(IOHWAB_SIG_ACTIVE)`` call.
2. Read GPIO port 19 ``PRT_DR`` register (``0x40310000 + 19*0x80 + 0x00``).
3. Check bit 0.

**Pass Criteria**

Bit 0 of PRT_DR for port 19 == ``0`` (STD_LOW → LED active-LOW = ON).

----

.. _TC-009:

TC-009 – IoHwAb Polarity Inversion for SW1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-009
:Covers:          :ref:`REQ-SW-004`
:Test Method:     Unit Test (code inspection + debugger)
:Robot File:      :download:`TC007_TC010_unit.robot <../tests/suites/TC007_TC010_unit.robot>`
:Precondition:    Debugger connected.

**Steps**

1. With SW1 **pressed** (pin LOW), call ``IoHwAb_Read_Sw1()``.
2. Verify return value is ``IOHWAB_SIG_ACTIVE`` (1).
3. With SW1 **released** (pin HIGH), call ``IoHwAb_Read_Sw1()``.
4. Verify return value is ``IOHWAB_SIG_INACTIVE`` (0).

**Pass Criteria**

- Pin LOW  → ``IoHwAb_Read_Sw1()`` == ``IOHWAB_SIG_ACTIVE``
- Pin HIGH → ``IoHwAb_Read_Sw1()`` == ``IOHWAB_SIG_INACTIVE``

----

.. _TC-010:

TC-010 – IoHwAb Polarity Inversion for LED1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-010
:Covers:          :ref:`REQ-SW-004`
:Test Method:     Unit Test (code inspection + debugger)
:Robot File:      :download:`TC007_TC010_unit.robot <../tests/suites/TC007_TC010_unit.robot>`
:Precondition:    Debugger connected.

**Steps**

1. Call ``IoHwAb_Write_Led1(IOHWAB_SIG_ACTIVE)`` (LED on request).
2. Read PRT_DR bit 0 for port 19 → expect ``0`` (STD_LOW).
3. Call ``IoHwAb_Write_Led1(IOHWAB_SIG_INACTIVE)`` (LED off request).
4. Read PRT_DR bit 0 for port 19 → expect ``1`` (STD_HIGH).

**Pass Criteria**

- ``IOHWAB_SIG_ACTIVE``   writes STD_LOW  (0) to PRT_DR bit 0.
- ``IOHWAB_SIG_INACTIVE`` writes STD_HIGH (1) to PRT_DR bit 0.

----

.. _TC-011:

TC-011 – SWC Runnable Called at 10 ms Period
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-011
:Covers:          :ref:`REQ-SW-005`
:Test Method:     Code Inspection
:Robot File:      :download:`TC011_TC012_inspection.robot <../tests/suites/TC011_TC012_inspection.robot>`
:Precondition:    Source code available.

**Steps**

1. Review ``main.c`` scheduler loop.
2. Confirm ``Os_WaitTick10ms()`` is called before ``SwcLedToggle_Run10ms()``.
3. Review ``Os_WaitTick10ms()`` busy-wait count (480 000 iterations at ~48 MHz).

**Pass Criteria**

- ``SwcLedToggle_Run10ms()`` is called once per loop iteration.
- The loop delay is configured for approximately 10 ms.

----

.. _TC-012:

TC-012 – No Direct Register Access in SwcLedToggle
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:              TC-012
:Covers:          :ref:`REQ-SW-006`
:Test Method:     Code Review / Static Analysis
:Robot File:      :download:`TC011_TC012_inspection.robot <../tests/suites/TC011_TC012_inspection.robot>`
:Precondition:    Source code available.

**Steps**

1. Open ``src/App/SwcLedToggle/SwcLedToggle.c``.
2. Search for any direct memory-mapped register addresses (e.g. ``0x4031``).
3. Verify ``SwcLedToggle.c`` contains **no** ``REG32`` macro calls or raw address literals.
4. Verify all hardware access is via ``IoHwAb_Read_Sw1()`` and ``IoHwAb_Write_Led1()``.

**Pass Criteria**

``SwcLedToggle.c`` contains zero direct register accesses.
All I/O calls use the IoHwAb API exclusively.
