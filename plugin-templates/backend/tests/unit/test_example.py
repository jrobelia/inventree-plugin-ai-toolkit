"""Example unit test for an InvenTree plugin.

Unit tests should not require the InvenTree server or database.
They test pure functions and isolated plugin logic.
"""


def test_basic_math():
    """A simple placeholder unit test."""
    assert 1 + 1 == 2


def test_plugin_function():
    """Example test for a pure function in your plugin."""
    # Replace with an actual function from your plugin
    sample_input = {"name": "Resistor", "quantity": 10}
    assert sample_input["quantity"] > 0
