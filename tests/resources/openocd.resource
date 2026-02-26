*** Settings ***
Documentation    Higher-level keywords for OpenOCD debugger interaction.
...              Wraps OpenOcdLibrary.py to provide board-specific helpers.
Resource         variables.resource
Library          ../libraries/OpenOcdLibrary.py


*** Keywords ***
Connect To Board Via OpenOCD
    [Documentation]    Start OpenOCD server process, then open the Telnet connection.
    ...    Requires the KitProg3 USB-DAP adapter connected to the host.
    Start OpenOCD    interface_cfg=${OPENOCD_INTERFACE}    target_cfg=${OPENOCD_TARGET}
    Open OpenOCD Connection    host=${OPENOCD_HOST}    port=${OPENOCD_PORT}
    ...    timeout=${OPENOCD_TIMEOUT}

Disconnect From Board
    [Documentation]    Close the Telnet connection and stop the OpenOCD process.
    Close OpenOCD Connection
    Stop OpenOCD

Flash And Halt At Port Init Return
    [Documentation]    Reset the target, halt it, and leave the CPU stopped
    ...    immediately after ``Port_Init()`` completes.
    ...    A breakpoint is set on the first instruction that follows Port_Init.
    ...    This is used by TC-001 and TC-002.
    Reset And Halt Target

Read PRT_PC Bits For Port
    [Documentation]    Return bits[2:0] (drive-mode field) of the PRT_PC register
    ...    for the given port number.
    ...
    ...    Example::
    ...
    ...        ${dm}=    Read PRT_PC Bits For Port    7
    [Arguments]    ${port_number}
    ${port_base}=    Evaluate    0x40310000 + int(${port_number}) * 0x80
    ${prt_pc_addr}=    Evaluate    ${port_base} + 0x08
    ${bits}=    Read Register Bits    ${prt_pc_addr}    lsb=0    width=3
    RETURN    ${bits}

Read PRT_PS Bit For Port Pin
    [Documentation]    Return bit *pin* of the PRT_PS register –
    ...    the live digital input state of pin *pin* on *port*.
    [Arguments]    ${port_number}    ${pin_number}
    ${port_base}=    Evaluate    0x40310000 + int(${port_number}) * 0x80
    ${prt_ps_addr}=    Evaluate    ${port_base} + 0x04
    ${bit}=    Read Register Bits    ${prt_ps_addr}    lsb=${pin_number}    width=1
    RETURN    ${bit}

Read PRT_DR Bit For Port Pin
    [Documentation]    Return bit *pin* of the PRT_DR (output data register)
    ...    for *port*.
    [Arguments]    ${port_number}    ${pin_number}
    ${port_base}=    Evaluate    0x40310000 + int(${port_number}) * 0x80
    ${prt_dr_addr}=    Evaluate    ${port_base} + 0x00
    ${bit}=    Read Register Bits    ${prt_dr_addr}    lsb=${pin_number}    width=1
    RETURN    ${bit}

PRT_PC Drive Mode Should Be
    [Documentation]    Assert that the drive-mode bits[2:0] of PRT_PC for *port*
    ...    equal *expected_dm*.
    [Arguments]    ${port_number}    ${expected_dm}
    ${actual}=    Read PRT_PC Bits For Port    ${port_number}
    Should Be Equal As Integers    ${actual}    ${expected_dm}
    ...    msg=PRT_PC drive-mode for port ${port_number}: expected 0x${expected_dm:X}, got 0x${actual:X}

PRT_DR Bit Should Be
    [Documentation]    Assert that bit *pin* of PRT_DR for *port* equals *expected*.
    [Arguments]    ${port_number}    ${pin_number}    ${expected}
    ${actual}=    Read PRT_DR Bit For Port Pin    ${port_number}    ${pin_number}
    Should Be Equal As Integers    ${actual}    ${expected}
    ...    msg=PRT_DR port ${port_number} pin ${pin_number}: expected ${expected}, got ${actual}

PRT_PS Bit Should Be
    [Documentation]    Assert that bit *pin* of PRT_PS for *port* equals *expected*.
    [Arguments]    ${port_number}    ${pin_number}    ${expected}
    ${actual}=    Read PRT_PS Bit For Port Pin    ${port_number}    ${pin_number}
    Should Be Equal As Integers    ${actual}    ${expected}
    ...    msg=PRT_PS port ${port_number} pin ${pin_number}: expected ${expected}, got ${actual}
