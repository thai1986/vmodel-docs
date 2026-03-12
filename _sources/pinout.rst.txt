Pinout – Board Headers
======================

The **CYTVII-B-E-1M-SK** board (MCU: **CYT2B75XX**) provides **7 Arduino-compatible pin headers** (2.54 mm pitch)
for accessing MCU signals.

.. contents:: Header List
   :local:
   :depth: 1

----

J1 – Arduino Pin Header 1 (8×1)
---------------------------------

Power and GND pins.

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu
   * - 1
     - NC
   * - 2
     - 5 V
   * - 3
     - NC
   * - 4
     - NC
   * - 5
     - 5 V
   * - 6
     - GND
   * - 7
     - GND
   * - 8
     - 5 V

----

J2 – Arduino Pin Header 2 (8×1) – Analog Inputs
-------------------------------------------------

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
   * - 1
     - A0 (P7\_5)
   * - 2
     - A1 (P7\_4)
   * - 3
     - A2 (P7\_3)
   * - 4
     - A3 (P6\_5)
   * - 5
     - A4 (P6\_4)
   * - 6
     - A5 (P13\_2)
   * - 7
     - A6 (P12\_1)
   * - 8
     - A7

----

J7 – Arduino Pin Header 3 (8×1) – Extended Analog
--------------------------------------------------

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
   * - 1
     - A8 (P7\_0)
   * - 2
     - A9 (P18\_6)
   * - 3
     - A10 (P18\_7)
   * - 4
     - NC
   * - 5
     - NC
   * - 6
     - NC
   * - 7
     - NC
   * - 8
     - NC

----

J9 – Arduino Pin Header 4 (8×1) – Digital 14–21
-------------------------------------------------

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
   * - 1
     - 14 (P18\_1)
   * - 2
     - 15 (P18\_0)
   * - 3
     - 16 (P17\_2)
   * - 4
     - 17 (P17\_1)
   * - 5
     - 18 (P14\_1)
   * - 6
     - 19 (P14\_0)
   * - 7
     - 20 (P0\_3) – CAN RX
   * - 8
     - 21 (P0\_2) – CAN TX

----

J10 – Arduino Pin Header 5 (8×1) – Digital 0–7
-----------------------------------------------

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
   * - 1
     - 0
   * - 2
     - 1
   * - 3
     - 2 (P19\_1)
   * - 4
     - 3 (P19\_2)
   * - 5
     - 4 (P21\_0)
   * - 6
     - 5 (P21\_1)
   * - 7
     - 6 (P13\_3)
   * - 8
     - 7 (P13\_5)

----

J11 – Arduino Pin Header 6 (10×1) – I2C + Digital 8–13
-------------------------------------------------------

.. list-table::
   :widths: 15 85
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
   * - 1
     - SCL
   * - 2
     - SDA
   * - 3
     - 5 V
   * - 4
     - GND
   * - 5
     - 13 (P22\_2)
   * - 6
     - 12 (P22\_0)
   * - 7
     - 11 (P22\_1)
   * - 8
     - 10 (P22\_3)
   * - 9
     - 9 (P23\_3)
   * - 10
     - 8 (P21\_5)

----

J13 – Arduino Pin Header 7 (18×2) – Extended Digital 22–53
-----------------------------------------------------------

.. list-table::
   :widths: 10 45 10 45
   :header-rows: 1

   * - Pin
     - Tín hiệu (MCU port)
     - Pin
     - Tín hiệu (MCU port)
   * - 1
     - 5 V
     - 2
     - 5 V
   * - 3
     - 22 (P11\_2)
     - 4
     - 23 (P11\_1)
   * - 5
     - 24 (P11\_0)
     - 6
     - 25 (P8\_2)
   * - 7
     - 26 (P8\_1)
     - 8
     - 27 (P18\_2)
   * - 9
     - 28 (P17\_0)
     - 10
     - 29 (P14\_3)
   * - 11
     - 30 (P14\_2)
     - 12
     - 31 (P13\_7)
   * - 13
     - 32 (P13\_6)
     - 14
     - 33 (P13\_4)
   * - 15
     - 34 (P8\_0)
     - 16
     - 35 (P3\_0)
   * - 17
     - 36 (P2\_3)
     - 18
     - 37 (P12\_4)
   * - 19
     - 38 (P12\_3)
     - 20
     - 39 (P12\_2)
   * - 21
     - 40 (P19\_0) – USER LED
     - 22
     - 41 (P3\_1)
   * - 23
     - 42 (P5\_3)
     - 24
     - 43 (P2\_0)
   * - 25
     - 44 (P5\_0)
     - 26
     - 45 (P5\_1)
   * - 27
     - 46 (P5\_2)
     - 28
     - 47 (P18\_3)
   * - 29
     - 48 (P18\_4)
     - 30
     - 49 (P18\_5)
   * - 31
     - 50 (P6\_0) – ADC[0]\_0
     - 32
     - 51 (P6\_1)
   * - 33
     - 52 (P6\_2)
     - 34
     - 53 (P6\_3)
   * - 35
     - GND
     - 36
     - GND

----

Key Port Summary
----------------

.. list-table::
   :widths: 20 20 60
   :header-rows: 1

   * - MCU Port
     - Board Location
     - Function
   * - P0.2
     - J9 pin 8
     - CAN0\_1 TX
   * - P0.3
     - J9 pin 7
     - CAN0\_1 RX
   * - P6.0
     - J13 pin 31
     - ADC[0]\_0 (potentiometer VR1)
   * - P7.0
     - J7 pin 1 / SW1
     - A8 / User Switch
   * - P12.2
     - J13 pin 20
     - USER LED4 (Blue), QFP pin 47
   * - P19.0
     - J13 pin 21
     - USER LED1 (Blue), QFP pin 77
