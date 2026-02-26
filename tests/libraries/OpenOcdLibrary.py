"""
OpenOcdLibrary.py
=================
Robot Framework library for interacting with OpenOCD via its Telnet interface.

Provides keywords to:
  - Start / stop an OpenOCD server process
  - Connect / disconnect via Telnet (port 4444 by default)
  - Read / write 32-bit memory-mapped registers
  - Set / remove software breakpoints
  - Halt and resume the target CPU
  - Reset the target (with optional halt)

Requirements
------------
  pip install robotframework

OpenOCD must be available on PATH or its full path supplied to
`Start OpenOCD`.

Usage
-----
In a .robot file::

    Library    ../libraries/OpenOcdLibrary.py

    Open OpenOCD Connection    host=localhost    port=4444
    Halt Target
    ${val}=    Read Register    0x40310388
    Should Be Equal As Integers    ${val & 0x7}    0x2
    Resume Target
    Close OpenOCD Connection
"""

import socket
import subprocess
import time
import re
import logging
from typing import Optional


class _TelnetSocket:
    """Minimal Telnet-like socket wrapper (replaces the removed ``telnetlib``)."""

    def __init__(self, host: str, port: int, timeout: float = 5.0) -> None:
        self._sock = socket.create_connection((host, port), timeout=timeout)
        self._sock.settimeout(timeout)
        self._timeout = timeout
        self._buf = b""

    def read_until(self, expected: bytes, timeout: float = 5.0) -> bytes:
        """Read from the socket until *expected* appears or *timeout* expires."""
        deadline = time.monotonic() + timeout
        while expected not in self._buf:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                break
            self._sock.settimeout(max(remaining, 0.1))
            try:
                chunk = self._sock.recv(4096)
                if not chunk:
                    break
                self._buf += chunk
            except socket.timeout:
                break
        idx = self._buf.find(expected)
        if idx == -1:
            data, self._buf = self._buf, b""
        else:
            end = idx + len(expected)
            data, self._buf = self._buf[:end], self._buf[end:]
        return data

    def write(self, data: bytes) -> None:
        """Send *data* over the socket."""
        self._sock.sendall(data)

    def close(self) -> None:
        """Close the underlying socket."""
        try:
            self._sock.close()
        except Exception:
            pass

logger = logging.getLogger(__name__)


class OpenOcdLibrary:
    """Robot Framework library for OpenOCD debugger control via Telnet."""

    ROBOT_LIBRARY_SCOPE = "SUITE"
    ROBOT_LIBRARY_VERSION = "1.0.0"

    def __init__(self) -> None:
        self._tn: Optional[_TelnetSocket] = None
        self._process: Optional[subprocess.Popen] = None

    # ------------------------------------------------------------------ #
    #  Process management                                                  #
    # ------------------------------------------------------------------ #

    def start_openocd(
        self,
        openocd_exe: str = "openocd",
        interface_cfg: str = "interface/cmsis-dap.cfg",
        target_cfg: str = "target/traveo2_1m_a0.cfg",
        scripts_dir: str = "",
        extra_args: str = "",
        startup_delay: float = 2.0,
    ) -> None:
        """Start an OpenOCD server process.

        Arguments:
        - ``openocd_exe``    – path to the openocd executable (default: ``openocd`` on PATH)
        - ``interface_cfg``  – interface config file (relative to scripts dir)
        - ``target_cfg``     – target config file (relative to scripts dir)
        - ``scripts_dir``    – OpenOCD scripts directory (optional)
        - ``extra_args``     – any additional OpenOCD arguments as a single string
        - ``startup_delay``  – seconds to wait for OpenOCD to start (default: 2.0)

        Example::

            Start OpenOCD    openocd_exe=C:/Infineon/Tools/openocd/bin/openocd.exe
            ...    interface_cfg=interface/cmsis-dap.cfg
            ...    target_cfg=target/traveo2_1m_a0.cfg
        """
        cmd = [openocd_exe]
        if scripts_dir:
            cmd += ["-s", scripts_dir]
        cmd += ["-f", interface_cfg, "-f", target_cfg]
        if extra_args:
            cmd += extra_args.split()

        logger.info("Starting OpenOCD: %s", " ".join(cmd))
        self._process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        time.sleep(float(startup_delay))
        if self._process.poll() is not None:
            out = self._process.stdout.read()
            raise RuntimeError(f"OpenOCD failed to start.\nOutput:\n{out}")

    def stop_openocd(self) -> None:
        """Terminate the OpenOCD process started by `Start OpenOCD`."""
        if self._process and self._process.poll() is None:
            self._process.terminate()
            try:
                self._process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self._process.kill()
        self._process = None

    # ------------------------------------------------------------------ #
    #  Connection management                                               #
    # ------------------------------------------------------------------ #

    def open_openocd_connection(
        self,
        host: str = "localhost",
        port: int = 4444,
        timeout: float = 5.0,
    ) -> None:
        """Open a Telnet connection to a running OpenOCD instance.

        Arguments:
        - ``host``    – OpenOCD Telnet host (default: ``localhost``)
        - ``port``    – OpenOCD Telnet port (default: ``4444``)
        - ``timeout`` – connection / read timeout in seconds (default: 5.0)

        Example::

            Open OpenOCD Connection    host=localhost    port=4444
        """
        self._tn = _TelnetSocket(host, int(port), float(timeout))
        # Consume the OpenOCD banner / prompt
        self._tn.read_until(b"> ", timeout=float(timeout))

    def close_openocd_connection(self) -> None:
        """Close the Telnet connection to OpenOCD."""
        if self._tn:
            try:
                self._send_command("exit")
            except Exception:
                pass
            self._tn.close()
            self._tn = None

    # ------------------------------------------------------------------ #
    #  Internal helpers                                                    #
    # ------------------------------------------------------------------ #

    def _send_command(self, cmd: str, timeout: float = 5.0) -> str:
        """Send a TCL command and return the response (stripped)."""
        if self._tn is None:
            raise RuntimeError(
                "Not connected to OpenOCD. Call 'Open OpenOCD Connection' first."
            )
        self._tn.write((cmd + "\n").encode("ascii"))
        response = self._tn.read_until(b"> ", timeout=timeout).decode(
            "ascii", errors="replace"
        )
        # Strip trailing prompt
        response = response.rstrip("> ").strip()
        return response

    # ------------------------------------------------------------------ #
    #  Target control                                                      #
    # ------------------------------------------------------------------ #

    def halt_target(self, timeout: float = 3.0) -> None:
        """Halt the target CPU.

        Example::

            Halt Target
        """
        self._send_command("halt", timeout=float(timeout))

    def resume_target(self) -> None:
        """Resume target CPU execution.

        Example::

            Resume Target
        """
        self._send_command("resume")

    def reset_and_halt_target(self) -> None:
        """Reset the target and leave it halted (equivalent to ``reset halt``).

        Example::

            Reset And Halt Target
        """
        self._send_command("reset halt", timeout=5.0)

    def reset_and_run_target(self) -> None:
        """Reset the target and let it run (equivalent to ``reset run``).

        Example::

            Reset And Run Target
        """
        self._send_command("reset run", timeout=5.0)

    # ------------------------------------------------------------------ #
    #  Register / memory access                                            #
    # ------------------------------------------------------------------ #

    def read_register(self, address) -> int:
        """Read a 32-bit value from a memory-mapped register.

        Returns an integer.

        Example::

            ${val}=    Read Register    0x40310388
            Log    PRT_PC = ${val}
        """
        addr = int(str(address), 0)
        response = self._send_command(f"mdw 0x{addr:08X}")
        # OpenOCD response: "0x40310388: 00000002 "
        match = re.search(r":\s+([0-9a-fA-F]{8})", response)
        if not match:
            raise ValueError(
                f"Unexpected OpenOCD response for mdw 0x{addr:08X}: {response!r}"
            )
        return int(match.group(1), 16)

    def write_register(self, address, value) -> None:
        """Write a 32-bit value to a memory-mapped register.

        Example::

            Write Register    0x40310980    0x00000001
        """
        addr = int(str(address), 0)
        val = int(str(value), 0)
        self._send_command(f"mww 0x{addr:08X} 0x{val:08X}")

    def read_register_bits(self, address, lsb: int, width: int = 1) -> int:
        """Read a bit-field from a 32-bit register.

        Arguments:
        - ``address`` – register address (integer or hex string)
        - ``lsb``     – index of the least-significant bit of the field
        - ``width``   – number of bits to extract (default: 1)

        Returns the extracted field value as an integer.

        Example::

            # Read bits [2:0] of PRT_PC for port 7
            ${dm}=    Read Register Bits    0x40310388    lsb=0    width=3
            Should Be Equal As Integers    ${dm}    2
        """
        raw = self.read_register(address)
        mask = (1 << int(width)) - 1
        return (raw >> int(lsb)) & mask

    # ------------------------------------------------------------------ #
    #  Breakpoints                                                         #
    # ------------------------------------------------------------------ #

    def set_breakpoint(self, address) -> None:
        """Set a software breakpoint at an address.

        Example::

            Set Breakpoint    0x08001234
        """
        addr = int(str(address), 0)
        self._send_command(f"bp 0x{addr:08X} 2 hw")

    def remove_breakpoint(self, address) -> None:
        """Remove a previously set breakpoint.

        Example::

            Remove Breakpoint    0x08001234
        """
        addr = int(str(address), 0)
        self._send_command(f"rbp 0x{addr:08X}")

    # ------------------------------------------------------------------ #
    #  Convenience assertions                                              #
    # ------------------------------------------------------------------ #

    def register_bits_should_equal(
        self, address, lsb: int, width: int, expected_value
    ) -> None:
        """Assert that a bit-field in a register equals an expected value.

        Raises ``AssertionError`` on mismatch.

        Example::

            Register Bits Should Equal    0x40310388    lsb=0    width=3    expected_value=2
        """
        actual = self.read_register_bits(address, lsb, width)
        expected = int(str(expected_value), 0)
        if actual != expected:
            raise AssertionError(
                f"Register 0x{int(str(address), 0):08X} bits[{int(lsb)+int(width)-1}:{lsb}]: "
                f"expected 0x{expected:X}, got 0x{actual:X}"
            )

    def send_raw_command(self, cmd: str) -> str:
        """Send a raw TCL/OpenOCD command and return the response string.

        Use this for advanced scenarios not covered by other keywords.

        Example::

            ${resp}=    Send Raw Command    reg pc
        """
        return self._send_command(cmd)
