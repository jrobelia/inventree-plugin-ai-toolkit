#!/bin/bash
set -e

echo "=========================================="
echo "Running All Tests for {{PLUGIN_NAME}}"
echo "=========================================="

# Preflight: Code quality checks
echo ""
echo "Step 1: Running code quality checks..."
echo "----------------------------------------"

# Python linting and formatting
ruff check {{MODULE_NAME}}
ruff format --check {{MODULE_NAME}}

# Frontend linting
cd frontend
npm run lint
cd ..

echo "✓ Code quality checks passed"

# Unit tests
echo ""
echo "Step 2: Running Python unit tests..."
echo "----------------------------------------"
python -m pytest {{MODULE_NAME}}/tests/unit -v
echo "✓ Unit tests passed"

# Integration tests
echo ""
echo "Step 3: Running Python integration tests..."
echo "----------------------------------------"
python -m pytest {{MODULE_NAME}}/tests/integration -v
echo "✓ Integration tests passed"

# Frontend unit tests
echo ""
echo "Step 4: Running frontend unit tests..."
echo "----------------------------------------"
cd frontend
npm run test
cd ..
echo "✓ Frontend unit tests passed"

# E2E tests (only if InvenTree server is running)
echo ""
echo "Step 5: Running E2E tests with Playwright..."
echo "----------------------------------------"
echo "Note: Ensure InvenTree server is running on http://localhost:8001"
cd frontend
npm run test:e2e
cd ..
echo "✓ E2E tests passed"

echo ""
echo "=========================================="
echo "All tests passed successfully!"
echo "=========================================="
