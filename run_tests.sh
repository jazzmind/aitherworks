#!/bin/bash
# Test Runner for AItherworks
# Runs GUT tests with timeout protection to catch hanging tests

set -e

# Configuration
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="."
TEST_TIMEOUT=30  # seconds
DEFAULT_TEST_DIR="tests/unit"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
TEST_DIR="${1:-$DEFAULT_TEST_DIR}"
SPECIFIC_TEST="${2:-}"

echo -e "${GREEN}=== AItherworks Test Runner ===${NC}"
echo "Test directory: $TEST_DIR"
if [ -n "$SPECIFIC_TEST" ]; then
    echo "Specific test: $SPECIFIC_TEST"
fi
echo "Timeout: ${TEST_TIMEOUT}s"
echo ""

# Build GUT command
GUT_CMD="$GODOT_PATH --headless --path $PROJECT_PATH -s addons/gut/gut_cmdln.gd -gdir=$TEST_DIR -gexit"
if [ -n "$SPECIFIC_TEST" ]; then
    GUT_CMD="$GUT_CMD -gtest=$SPECIFIC_TEST"
fi

# Run with timeout protection
echo -e "${YELLOW}Running tests...${NC}"
echo ""

# Start godot in background and capture PID
$GUT_CMD 2>&1 &
GODOT_PID=$!

# Monitor with timeout
SECONDS_ELAPSED=0
while kill -0 $GODOT_PID 2>/dev/null; do
    sleep 1
    SECONDS_ELAPSED=$((SECONDS_ELAPSED + 1))
    
    if [ $SECONDS_ELAPSED -ge $TEST_TIMEOUT ]; then
        echo ""
        echo -e "${RED}ERROR: Tests timed out after ${TEST_TIMEOUT}s${NC}"
        echo "Killing Godot process (PID: $GODOT_PID)..."
        kill -9 $GODOT_PID 2>/dev/null
        echo ""
        echo -e "${YELLOW}Possible causes:${NC}"
        echo "  - Infinite loop in test code"
        echo "  - Deadlock in tested code"
        echo "  - Test waiting for user input"
        echo "  - Godot hanging on scene load"
        exit 1
    fi
done

# Wait for process to finish and capture exit code
wait $GODOT_PID
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Tests completed successfully${NC}"
else
    echo -e "${RED}❌ Tests failed with exit code: $EXIT_CODE${NC}"
fi

exit $EXIT_CODE

