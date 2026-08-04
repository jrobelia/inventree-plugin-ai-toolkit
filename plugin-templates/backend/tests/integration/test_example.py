"""Example integration test for an InvenTree plugin.

Integration tests may interact with the InvenTree database.
They require the InvenTree development environment to be set up.
"""
import pytest

# Mark integration tests so they can be skipped if InvenTree is not available
pytestmark = pytest.mark.django_db


def test_plugin_loads():
    """Example integration test that checks Django is configured."""
    # Replace with actual plugin functionality that requires the database
    try:
        from django.conf import settings

        assert settings.configured is True
    except ImportError:
        pytest.skip("Django/InvenTree not available")
