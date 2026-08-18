#!/usr/bin/env python
"""Regression test: the devcontainer Python version must satisfy InvenTree's minimum.

This catches the INVE-E15 / "Python version not supported" failure by comparing
PYTHON_VERSION (from the environment, the docker-compose build arg, or the
Dockerfile default) against MIN_PYTHON_VERSION from the InvenTree submodule.
"""

import argparse
import os
import pathlib
import re
import subprocess
import sys


VERSION_FILE = pathlib.Path(
    "reference/inventree-source/src/backend/InvenTree/InvenTree/version.py"
)
DOCKERFILE = pathlib.Path(".devcontainer/Dockerfile")
COMPOSE_FILE = pathlib.Path(".devcontainer/docker-compose.yml")
IMAGE_NAME = "devcontainer-toolkit:latest"


def parse_version(version: str):
    """Return (major, minor) for an X.Y[.Z] version string."""
    parts = version.split(".")
    return int(parts[0]), int(parts[1])


def read_min_python_version(version_file: pathlib.Path):
    text = version_file.read_text(encoding="utf-8")
    match = re.search(
        r"MIN_PYTHON_VERSION\s*=\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)",
        text,
    )
    if not match:
        raise ValueError(f"Could not parse MIN_PYTHON_VERSION from {version_file}")
    return f"{match.group(1)}.{match.group(2)}"


def read_dockerfile_python(dockerfile: pathlib.Path):
    text = dockerfile.read_text(encoding="utf-8")
    match = re.search(r"ARG\s+PYTHON_VERSION\s*=\s*([0-9.]+)", text)
    if not match:
        raise ValueError(f"Could not parse PYTHON_VERSION arg from {dockerfile}")
    return match.group(1)


def read_compose_python(compose_file: pathlib.Path):
    text = compose_file.read_text(encoding="utf-8")
    match = re.search(r"PYTHON_VERSION:\s*\"?\$?\{?PYTHON_VERSION:-?([0-9.]+)\}?\"?", text)
    if not match:
        raise ValueError(f"Could not parse PYTHON_VERSION arg from {compose_file}")
    return match.group(1)


def image_python_version(image_name: str):
    result = subprocess.run(
        ["docker", "run", "--rm", image_name, "python3", "--version"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Could not get python3 --version from {image_name}: {result.stderr}")
    # Output is "Python 3.12.x"
    match = re.search(r"Python\s+([0-9.]+)", result.stdout)
    if not match:
        raise RuntimeError(f"Unexpected python3 --version output: {result.stdout!r}")
    return match.group(1)


def assert_gte(actual: str, required: str, label: str):
    actual_tuple = parse_version(actual)
    required_tuple = parse_version(required)
    if actual_tuple < required_tuple:
        print(
            f"FAIL: {label} is {actual}, but InvenTree requires {required} or above",
            file=sys.stderr,
        )
        return False
    print(f"OK: {label} {actual} >= InvenTree minimum {required}")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Verify the devcontainer Python version satisfies InvenTree's minimum."
    )
    parser.add_argument(
        "--check-image",
        action="store_true",
        help="Also check the built devcontainer toolkit image",
    )
    parser.add_argument(
        "--python-version",
        help="Override the expected PYTHON_VERSION (defaults to env PYTHON_VERSION or Dockerfile/compose)",
    )
    args = parser.parse_args()

    if not VERSION_FILE.exists():
        print(f"ERROR: InvenTree version.py not found at {VERSION_FILE}", file=sys.stderr)
        return 1

    min_version = read_min_python_version(VERSION_FILE)
    print(f"InvenTree MIN_PYTHON_VERSION: {min_version}")

    ok = True

    # 1. Check the configured PYTHON_VERSION (env > explicit arg > docker-compose default)
    configured = args.python_version or os.environ.get("PYTHON_VERSION") or read_compose_python(COMPOSE_FILE)
    ok &= assert_gte(configured, min_version, "Configured PYTHON_VERSION")

    # 2. Check the Dockerfile default
    dockerfile_default = read_dockerfile_python(DOCKERFILE)
    ok &= assert_gte(dockerfile_default, min_version, "Dockerfile default PYTHON_VERSION")

    # 3. Optional: check the actual built image
    if args.check_image:
        try:
            image_version = image_python_version(IMAGE_NAME)
            ok &= assert_gte(image_version, min_version, f"Built image {IMAGE_NAME}")
        except Exception as exc:
            print(f"FAIL: {exc}", file=sys.stderr)
            ok = False

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
