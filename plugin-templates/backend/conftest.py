"""Pytest configuration for InvenTree plugin tests.

Copy this file to your plugin's backend test root (e.g. my_plugin/tests/conftest.py).
"""
import os
import sys

# Add the plugin source directory to the path
import django


def pytest_configure():
    """Configure Django settings for tests."""
    # Try to locate the InvenTree source tree
    inventree_paths = [
        "/workspace/reference/inventree-source/src/backend",
        os.path.join(os.getcwd(), "..", "..", "inventree-source", "src", "backend"),
        os.environ.get("INVENTREE_SRC", ""),
    ]

    for path in inventree_paths:
        if path and os.path.isdir(path) and path not in sys.path:
            sys.path.insert(0, path)
            break

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "InvenTree.settings")

    try:
        django.setup()
    except Exception as exc:  # pragma: no cover
        # If InvenTree is not available, unit tests can still run without Django
        print(f"Warning: Could not configure Django: {exc}")
