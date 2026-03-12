Software Requirements
=====================

This page defines the software requirements for the **TRAVEO II Entry Family Starter Kit**
LED toggle feature. Each requirement is assigned a unique ID used for traceability
between specification and implementation.

.. contents:: Requirements
   :local:
   :depth: 1

----

System Requirements
-------------------

.. _REQ-SYS-001:

**REQ-SYS-001** – Target Hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SYS-001
:Type:        System
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-001`, :ref:`TC-002`

The software shall execute on the **CYTVII-B-E-1M-SK** evaluation board
equipped with the **CYT2B75XX** microcontroller (32-bit Arm Cortex-M4F,
QFP 100-pin, 0.5 mm pitch).

----

.. _REQ-SYS-002:

**REQ-SYS-002** – Software Architecture
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SYS-002
:Type:        System
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-012`

The software shall follow the **AUTOSAR Classic layered architecture**:

- **MCAL** – Port Driver, DIO Driver
- **ECU Abstraction** – I/O Hardware Abstraction (IoHwAb)
- **Application** – Software Component (SWC)

----

Hardware Requirements
---------------------

.. _REQ-HW-001:

**REQ-HW-001** – USER Switch Input
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-HW-001
:Type:        Hardware
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-001`, :ref:`TC-007`, :ref:`TC-009`

The USER Switch **SW1** shall be connected to MCU port pin **P7.0** (QFP pin 29),
configured as a resistive pull-up digital input. The switch is **active-LOW**:
logic LOW on the pin indicates a pressed state.

----

.. _REQ-HW-002:

**REQ-HW-002** – USER LED Output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-HW-002
:Type:        Hardware
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-002`, :ref:`TC-008`, :ref:`TC-010`

The USER LED **LED1** (blue) shall be connected to MCU port pin **P19.0** (QFP pin 77),
configured as a strong-drive digital output. The LED is **active-LOW**:
driving the pin LOW illuminates the LED.

----

Functional Requirements
-----------------------

.. _REQ-FUNC-001:

**REQ-FUNC-001** – LED Toggle on Button Press
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-FUNC-001
:Type:        Functional
:Priority:    Mandatory
:Status:      Approved
:Implements:  :ref:`REQ-HW-001`, :ref:`REQ-HW-002`
:Test Cases:  :ref:`TC-004`, :ref:`TC-005`

Pressing SW1 once shall turn LED1 **ON**.
Pressing SW1 again shall turn LED1 **OFF**.
Each confirmed press event shall toggle the LED state exactly once.

----

.. _REQ-FUNC-002:

**REQ-FUNC-002** – Falling-Edge Detection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-FUNC-002
:Type:        Functional
:Priority:    Mandatory
:Status:      Approved
:Implements:  :ref:`REQ-FUNC-001`
:Test Cases:  :ref:`TC-004`, :ref:`TC-005`, :ref:`TC-006`

The software shall act on a **single rising edge** of the logical SW1 signal
(INACTIVE to ACTIVE transition) per button press. Holding the button pressed
shall not repeatedly toggle the LED.

----

.. _REQ-FUNC-003:

**REQ-FUNC-003** – Initial State
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-FUNC-003
:Type:        Functional
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-003`

After power-on reset, LED1 shall be in the **OFF** state.

----

Software Requirements
---------------------

.. _REQ-SW-001:

**REQ-SW-001** – Port Initialisation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-001
:Type:        Software
:Priority:    Mandatory
:Status:      Approved
:Allocated To: ``Port_Init()`` in ``src/Mcal/Port/Port.c``
:Test Cases:  :ref:`TC-001`, :ref:`TC-002`

The Port Driver shall initialise all configured pins before any application
runnable is called. The initialisation order shall be:

1. Set HSIOM to GPIO mode for each pin.
2. Write the initial output value.
3. Set the drive mode.

----

.. _REQ-SW-002:

**REQ-SW-002** – DIO Read Channel
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-002
:Type:        Software
:Priority:    Mandatory
:Status:      Approved
:Allocated To: ``Dio_ReadChannel()`` in ``src/Mcal/Dio/Dio.c``
:Test Cases:  :ref:`TC-007`

The DIO Driver shall read the current logical level of a channel from the
hardware **PRT_PS** (Pin State) register and return ``STD_HIGH`` or ``STD_LOW``.

----

.. _REQ-SW-003:

**REQ-SW-003** – DIO Write Channel
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-003
:Type:        Software
:Priority:    Mandatory
:Status:      Approved
:Allocated To: ``Dio_WriteChannel()`` in ``src/Mcal/Dio/Dio.c``
:Test Cases:  :ref:`TC-008`

The DIO Driver shall write the requested logical level to the hardware
**PRT_DR** (Data Register) of the specified channel.

----

.. _REQ-SW-004:

**REQ-SW-004** – IoHwAb Polarity Abstraction
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-004
:Type:        Software
:Priority:    Mandatory
:Status:      Approved
:Allocated To: ``IoHwAb.c`` in ``src/EcuAb/IoHwAb/``
:Test Cases:  :ref:`TC-009`, :ref:`TC-010`

The IoHwAb layer shall abstract the active-LOW hardware polarity of SW1 and
LED1. The application shall use only logical values
``IOHWAB_SIG_ACTIVE`` / ``IOHWAB_SIG_INACTIVE`` without knowledge of
physical pin polarity.

----

.. _REQ-SW-005:

**REQ-SW-005** – SWC Runnable Period
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-005
:Type:        Software
:Priority:    Mandatory
:Status:      Approved
:Allocated To: ``SwcLedToggle_Run10ms()`` in ``src/App/SwcLedToggle/SwcLedToggle.c``
:Test Cases:  :ref:`TC-011`

The ``SwcLedToggle_Run10ms`` runnable shall be called with a period of
**10 ms** by the scheduler. This period provides implicit software debounce
for the mechanical switch.

----

.. _REQ-SW-006:

**REQ-SW-006** – No Direct Register Access in Application Layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:ID:          REQ-SW-006
:Type:        Software / Architecture
:Priority:    Mandatory
:Status:      Approved
:Test Cases:  :ref:`TC-012`

Application-layer code (SWC) shall **not** access hardware registers directly.
All hardware interaction shall be routed through IoHwAb and MCAL.

----

Requirements Traceability Matrix
---------------------------------

.. list-table::
   :widths: 15 28 25 20 12
   :header-rows: 1

   * - Req ID
     - Summary
     - Implementation
     - Test Cases
     - Status
   * - REQ-SYS-001
     - Target: CYT2B75XX on CYTVII-B-E-1M-SK
     - ``CMakeLists.txt``, ``Port_Cfg.h``
     - :ref:`TC-001`, :ref:`TC-002`
     - Approved
   * - REQ-SYS-002
     - AUTOSAR layered architecture
     - All layers in ``src/``
     - :ref:`TC-012`
     - Approved
   * - REQ-HW-001
     - SW1 = P7.0, pull-up, active-LOW
     - ``Port_Cfg.h``, ``Dio_Cfg.h``
     - :ref:`TC-001`, :ref:`TC-007`, :ref:`TC-009`
     - Approved
   * - REQ-HW-002
     - LED1 = P19.0, strong output, active-LOW
     - ``Port_Cfg.h``, ``Dio_Cfg.h``
     - :ref:`TC-002`, :ref:`TC-008`, :ref:`TC-010`
     - Approved
   * - REQ-FUNC-001
     - SW1 press toggles LED1
     - ``SwcLedToggle.c``
     - :ref:`TC-004`, :ref:`TC-005`
     - Approved
   * - REQ-FUNC-002
     - Single rising-edge detection
     - ``SwcLedToggle.c`` (``prevSwState``)
     - :ref:`TC-004`, :ref:`TC-005`, :ref:`TC-006`
     - Approved
   * - REQ-FUNC-003
     - LED1 OFF at power-on
     - ``Port.c`` (``initValue = STD_HIGH``)
     - :ref:`TC-003`
     - Approved
   * - REQ-SW-001
     - Port_Init() before runnables
     - ``Port.c``, ``main.c``
     - :ref:`TC-001`, :ref:`TC-002`
     - Approved
   * - REQ-SW-002
     - Dio_ReadChannel via PRT_PS
     - ``Dio.c``
     - :ref:`TC-007`
     - Approved
   * - REQ-SW-003
     - Dio_WriteChannel via PRT_DR
     - ``Dio.c``
     - :ref:`TC-008`
     - Approved
   * - REQ-SW-004
     - IoHwAb polarity abstraction
     - ``IoHwAb.c``
     - :ref:`TC-009`, :ref:`TC-010`
     - Approved
   * - REQ-SW-005
     - SWC runnable period 10 ms
     - ``SwcLedToggle.c``, ``main.c``
     - :ref:`TC-011`
     - Approved
   * - REQ-SW-006
     - No HW register access in App layer
     - ``SwcLedToggle.c`` (IoHwAb only)
     - :ref:`TC-012`
     - Approved
