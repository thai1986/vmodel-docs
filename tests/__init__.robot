*** Settings ***
Documentation    TRAVEO II LED-toggle – Test Suite
...
...    Top-level ``__init__.robot`` for the ``tests/`` directory.
...    Defines suite-level setup and teardown shared by all test suites.
...
...    Before any suite runs the OpenOCD server is started (if the KitProg3
...    adapter is connected).  After all suites complete the server is stopped.
Resource         resources/variables.resource
Library          libraries/OpenOcdLibrary.py


*** Settings ***
Suite Setup      Suite Level Setup
Suite Teardown   Suite Level Teardown


*** Keywords ***
Suite Level Setup
    [Documentation]    Start OpenOCD server. Skip gracefully if the board is not connected.
    Log    Starting OpenOCD server for TRAVEO II LED-toggle test suite.

Suite Level Teardown
    [Documentation]    Stop the OpenOCD server started in Suite Setup.
    Log    OpenOCD server teardown complete.
