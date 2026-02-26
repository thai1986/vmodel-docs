"""
SourceInspectionLibrary.py
==========================
Robot Framework library for static source-code inspection tests (TC-011, TC-012).

Provides keywords to search C source files for patterns and assert
structural properties of the codebase.

Requirements
------------
  pip install robotframework

Usage
-----
In a .robot file::

    Library    ../libraries/SourceInspectionLibrary.py
"""

import re
import os
from pathlib import Path


class SourceInspectionLibrary:
    """Robot Framework library for C source-code static inspection."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_VERSION = "1.0.0"

    # ------------------------------------------------------------------ #
    #  File content helpers                                                #
    # ------------------------------------------------------------------ #

    def _read_source(self, file_path: str) -> str:
        path = Path(file_path)
        if not path.exists():
            raise FileNotFoundError(f"Source file not found: {file_path}")
        return path.read_text(encoding="utf-8")

    # ------------------------------------------------------------------ #
    #  Pattern search keywords                                             #
    # ------------------------------------------------------------------ #

    def file_should_contain_pattern(self, file_path: str, pattern: str) -> None:
        """Assert that ``file_path`` contains at least one line matching ``pattern``.

        ``pattern`` is treated as a regular expression.

        Example::

            File Should Contain Pattern
            ...    ${MAIN_C}
            ...    Os_WaitTick10ms\\(\\)
        """
        content = self._read_source(file_path)
        if not re.search(pattern, content):
            raise AssertionError(
                f"Pattern {pattern!r} NOT found in {file_path}"
            )

    def file_should_not_contain_pattern(self, file_path: str, pattern: str) -> None:
        """Assert that ``file_path`` does NOT contain any line matching ``pattern``.

        ``pattern`` is treated as a regular expression.

        Example::

            File Should Not Contain Pattern
            ...    ${SWC_LED_TOGGLE_C}
            ...    0x4031
        """
        content = self._read_source(file_path)
        match = re.search(pattern, content)
        if match:
            # Find the line number for a helpful error message
            lines = content.splitlines()
            lineno = content[: match.start()].count("\n") + 1
            raise AssertionError(
                f"Pattern {pattern!r} found in {file_path} at line {lineno}:\n"
                f"  {lines[lineno - 1].strip()}"
            )

    def file_should_contain_text(self, file_path: str, text: str) -> None:
        """Assert that ``file_path`` contains ``text`` as a plain substring (no regex).

        Use this instead of ``File Should Contain Pattern`` when ``text`` contains
        regex metacharacters such as ``(``, ``)``, ``[``, ``]``, ``+``, etc.

        Example::

            File Should Contain Text    ${SWC_LED_TOGGLE_C}    IoHwAb_Read_Sw1()
        """
        content = self._read_source(file_path)
        if text not in content:
            raise AssertionError(
                f"Text {text!r} NOT found in {file_path}"
            )

    def file_should_not_contain_text(self, file_path: str, text: str) -> None:
        """Assert that ``file_path`` does NOT contain ``text`` as a plain substring.

        Use this instead of ``File Should Not Contain Pattern`` when ``text``
        contains regex metacharacters.

        Example::

            File Should Not Contain Text    ${SWC_LED_TOGGLE_C}    (volatile
        """
        content = self._read_source(file_path)
        idx = content.find(text)
        if idx != -1:
            lineno = content[:idx].count("\n") + 1
            lines = content.splitlines()
            raise AssertionError(
                f"Text {text!r} found in {file_path} at line {lineno}:\n"
                f"  {lines[lineno - 1].strip()}"
            )

    def count_pattern_occurrences(self, file_path: str, pattern: str) -> int:
        """Return the number of non-overlapping occurrences of ``pattern`` in ``file_path``.

        Example::

            ${n}=    Count Pattern Occurrences    ${MAIN_C}    SwcLedToggle_Run10ms
            Should Be Equal As Integers    ${n}    1
        """
        content = self._read_source(file_path)
        return len(re.findall(pattern, content))

    def get_matching_lines(self, file_path: str, pattern: str):
        """Return a list of lines from ``file_path`` that match ``pattern``.

        Example::

            ${lines}=    Get Matching Lines    ${MAIN_C}    Os_WaitTick10ms
            Length Should Be    ${lines}    1
        """
        content = self._read_source(file_path)
        return [
            line.strip()
            for line in content.splitlines()
            if re.search(pattern, line)
        ]

    # ------------------------------------------------------------------ #
    #  Function-call order verification                                    #
    # ------------------------------------------------------------------ #

    def first_occurrence_should_precede_second(
        self,
        file_path: str,
        first_pattern: str,
        second_pattern: str,
    ) -> None:
        """Assert that the first match of ``first_pattern`` appears before the
        first match of ``second_pattern`` in ``file_path``.

        Example::

            First Occurrence Should Precede Second
            ...    ${MAIN_C}
            ...    Os_WaitTick10ms
            ...    SwcLedToggle_Run10ms
        """
        content = self._read_source(file_path)
        m1 = re.search(first_pattern, content)
        m2 = re.search(second_pattern, content)

        if not m1:
            raise AssertionError(
                f"First pattern {first_pattern!r} not found in {file_path}"
            )
        if not m2:
            raise AssertionError(
                f"Second pattern {second_pattern!r} not found in {file_path}"
            )
        if m1.start() >= m2.start():
            lines = content.splitlines()
            line1 = content[: m1.start()].count("\n") + 1
            line2 = content[: m2.start()].count("\n") + 1
            raise AssertionError(
                f"Expected {first_pattern!r} (line {line1}) to appear before "
                f"{second_pattern!r} (line {line2}) in {file_path}"
            )

    # ------------------------------------------------------------------ #
    #  Loop / scheduler structure verification                             #
    # ------------------------------------------------------------------ #

    def same_loop_block_should_contain(
        self,
        file_path: str,
        anchor_pattern: str,
        required_pattern: str,
    ) -> None:
        """Assert that ``required_pattern`` appears in the same loop block (between
        a ``while`` / ``for`` opening and closing brace) as ``anchor_pattern``.

        This is a heuristic check using brace matching starting from the last
        ``while`` before ``anchor_pattern``.

        Example::

            Same Loop Block Should Contain
            ...    ${MAIN_C}
            ...    Os_WaitTick10ms
            ...    SwcLedToggle_Run10ms
        """
        content = self._read_source(file_path)
        # Find the anchor
        m_anchor = re.search(anchor_pattern, content)
        if not m_anchor:
            raise AssertionError(
                f"Anchor pattern {anchor_pattern!r} not found in {file_path}"
            )
        anchor_pos = m_anchor.start()

        # Walk back to find the opening brace of the enclosing loop
        # Look for 'while' or 'for' before anchor_pos
        loop_match = None
        for m in re.finditer(r'\bwhile\b|\bfor\b', content[:anchor_pos]):
            loop_match = m  # keep the last one before anchor

        if loop_match is None:
            raise AssertionError(
                f"No enclosing loop ('while'/'for') found before anchor "
                f"{anchor_pattern!r} in {file_path}"
            )

        # Find the opening brace after the loop keyword
        open_brace_pos = content.index('{', loop_match.end())
        # Find the matching closing brace
        depth = 0
        close_brace_pos = None
        for i, ch in enumerate(content[open_brace_pos:], start=open_brace_pos):
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    close_brace_pos = i
                    break

        if close_brace_pos is None:
            raise AssertionError(f"Unmatched braces in {file_path}")

        loop_body = content[open_brace_pos:close_brace_pos + 1]

        if not re.search(required_pattern, loop_body):
            raise AssertionError(
                f"Pattern {required_pattern!r} not found in the same loop block "
                f"as {anchor_pattern!r} in {file_path}"
            )

    # ------------------------------------------------------------------ #
    #  Numeric constant inspection                                         #
    # ------------------------------------------------------------------ #

    def extract_integer_from_source(
        self, file_path: str, pattern: str, group: int = 1
    ) -> int:
        """Extract an integer value from the first regex match of ``pattern`` in
        ``file_path``. ``group`` selects the capture group (default: 1).

        Example::

            # Extract busy-wait count from  Os_WaitTick10ms busy loop
            ${count}=    Extract Integer From Source
            ...    ${MAIN_C}
            ...    for\\s*\\(.*?=\\s*0.*?<\\s*(\\d+)
        """
        content = self._read_source(file_path)
        m = re.search(pattern, content, re.DOTALL)
        if not m:
            raise AssertionError(
                f"Pattern {pattern!r} not found in {file_path}"
            )
        return int(m.group(int(group)))
