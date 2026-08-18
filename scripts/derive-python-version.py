#!/usr/bin/env python
"""Derive the devcontainer Python version from InvenTree's MIN_PYTHON_VERSION.

Reads reference/inventree-source/src/backend/InvenTree/InvenTree/version.py
and emits the required Python version (e.g. "3.12"). This lets the devcontainer
build track the InvenTree stable branch instead of hard-coding a version that
can fall behind and cause INVE-E15 / "Python version not supported".
"""

import argparse
import pathlib
import re
import sys


def derive_python_version(version_file: pathlib.Path) -> str:
    """Return the required Python version from InvenTree's version.py."""
    text = version_file.read_text(encoding="utf-8")
    match = re.search(
        r"MIN_PYTHON_VERSION\s*=\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)",
        text,
    )
    if not match:
        raise ValueError(f"Could not parse MIN_PYTHON_VERSION from {version_file}")

    return f"{match.group(1)}.{match.group(2)}"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Derive the Python version required by the InvenTree submodule."
    )
    parser.add_argument(
        "--version-file",
        type=pathlib.Path,
        default=pathlib.Path(
            "reference/inventree-source/src/backend/InvenTree/InvenTree/version.py"
        ),
        help="Path to InvenTree version.py",
    )
    parser.add_argument(
        "--default",
        default="3.12",
        help="Fallback Python version if version.py is missing",
    )
    args = parser.parse_args()

    try:
        version = (
            derive_python_version(args.version_file)
            if args.version_file.exists()
            else args.default
        )
        # Write raw bytes to avoid Windows newline translation on the host.
        sys.stdout.buffer.write(version.encode("utf-8"))
        sys.stdout.buffer.flush()
    except Exception as exc:
        sys.stderr.buffer.write(f"ERROR: {exc}".encode("utf-8"))
        sys.stderr.buffer.flush()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
