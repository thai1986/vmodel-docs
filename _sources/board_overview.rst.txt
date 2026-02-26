Board Overview
==============

Board Information
-----------------

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Parameter
     - Value
   * - Product Name
     - TRAVEO II Entry Family Starter Kit
   * - Board Part Number
     - CYTVII-B-E-1M-SK
   * - User Guide Document
     - 002-25314 Rev. \*B
   * - Manufacturer
     - Cypress Semiconductor (Infineon Technologies)
   * - Board Dimensions
     - 114 × 52 mm
   * - Operating Temperature
     - 0 to 40 °C

Microcontroller (MCU)
---------------------

The board mounts the following MCU:

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Part Number
     - Description
   * - **CYT2B75XX**
     - 32-bit Arm® Cortex®-M4F, Traveo™ II Family, QFP 100-pin (0.5 mm pitch)

Package: **QFP 100-pin, 0.5 mm pitch**, soldered at position **U1**.

.. note::
   OpenOCD target config: ``target/traveo2_1m_a0.cfg``.

Key Components
--------------

.. list-table::
   :widths: 20 20 60
   :header-rows: 1

   * - Reference
     - Part Number
     - Function
   * - U1
     - CYT2B75XX
     - Target MCU
   * - U2
     - CY8C5868LTI-LP039
     - KitProg3 (PSoC 5LP) – USB programming and debug bridge
   * - U3
     - TJA1057GT
     - CAN FD Transceiver
   * - X1
     - ABM10-16.000MHZ-D30-T3
     - Main crystal oscillator 16 MHz (optional, not mounted by default)
   * - VR1
     - 3313J-1-103E
     - Potentiometer 10 kΩ

Interfaces and Peripherals
--------------------------

.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - Name
     - Location
     - Notes
   * - USB Micro Connector
     - J8 (bottom side)
     - SWD over USB via KitProg3 (PSoC 5LP)
   * - CAN FD Screw Terminal
     - J5
     - CAN0\_1 – MCU P0.2 (TX) and P0.3 (RX). Not mounted by default.
   * - Debug MIPI-20 Connector
     - J3 (FTSH-110-01-L-DV-K)
     - Not mounted by default
   * - Current Measurement Jumper
     - J4 (replaces R24)
     - Remove R24 and mount J4 to measure U1 current
   * - Arduino-compatible Headers
     - J1, J2, J7, J9, J10, J11, J13
     - See :doc:`pinout`

LEDs and Switches
-----------------

.. list-table::
   :widths: 20 15 15 50
   :header-rows: 1

   * - Name
     - Reference
     - MCU Pin
     - Description
   * - USER LED (blue)
     - LED1
     - Pin 77 – P19.0
     - Connected to CYT2B75XX MCU
   * - USER LED (blue)
     - LED4
     - Pin 47 – P12.2
     - Connected to CYT2B75XX MCU
   * - POWER LED (green)
     - LED2
     - —
     - Power indicator
   * - STATUS LED (amber)
     - LED3
     - P1.4 (PSoC 5LP)
     - KitProg3 status
   * - USER Switch
     - SW1
     - Pin 29 – P7.0
     - User pushbutton → MCU
   * - RESET Switch
     - SW2
     - Pin 85 – XRES
     - System reset
   * - MODE Switch
     - SW3
     - PSoC 5LP
     - KitProg3 mode selection
