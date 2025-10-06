#!/bin/bash

# Export Godot game to WebAssembly
# This script should be run from the project root

set -e

echo "🎮 Exporting AItherworks to WebAssembly..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Godot is installed
if ! command -v godot &> /dev/null && ! command -v godot4 &> /dev/null; then
    echo -e "${RED}Error: Godot not found in PATH${NC}"
    echo "Please install Godot 4.x or add it to your PATH"
    echo ""
    echo "On macOS with Homebrew:"
    echo "  brew install godot"
    echo ""
    echo "Or download from: https://godotengine.org/download"
    exit 1
fi

# Determine which Godot command to use
GODOT_CMD="godot"
if command -v godot4 &> /dev/null; then
    GODOT_CMD="godot4"
fi

# Check Godot version
GODOT_VERSION=$($GODOT_CMD --version 2>&1 | head -n 1)
echo -e "${GREEN}Found Godot:${NC} $GODOT_VERSION"

# Create output directory
OUTPUT_DIR="web/public/godot"
mkdir -p "$OUTPUT_DIR"

# Clean previous build
echo -e "${YELLOW}Cleaning previous build...${NC}"
rm -f "$OUTPUT_DIR"/*

# Export the game
echo -e "${YELLOW}Exporting game...${NC}"
$GODOT_CMD --headless --export-release "Web" "$OUTPUT_DIR/aitherworks.html" 2>&1 | grep -v "^Godot Engine" || true

# Check if export was successful
if [ ! -f "$OUTPUT_DIR/aitherworks.html" ]; then
    echo -e "${RED}Error: Export failed!${NC}"
    echo ""
    echo "Common issues:"
    echo "1. Export templates not installed"
    echo "   - Open Godot Editor -> Editor -> Manage Export Templates"
    echo "   - Download templates for your Godot version"
    echo ""
    echo "2. Export preset not configured"
    echo "   - The export_presets.cfg should be in the project root"
    echo ""
    exit 1
fi

# Rename files for Next.js public folder
echo -e "${YELLOW}Renaming exported files...${NC}"
if [ -f "$OUTPUT_DIR/aitherworks.html" ]; then
    # The HTML file contains the engine loader, we'll extract it
    mv "$OUTPUT_DIR/aitherworks.html" "$OUTPUT_DIR/index.html"
fi

# Create a simple loader script for Next.js
cat > "$OUTPUT_DIR/../engine.js" << 'EOF'
// This file will be loaded by the Next.js page
// It initializes the Godot engine

if (typeof window !== 'undefined') {
  window.Engine = (function() {
    // Engine code will be injected here by Godot export
    // For now, this is a placeholder
    return null;
  })();
}
EOF

echo -e "${GREEN}✅ Export complete!${NC}"
echo -e "Output directory: ${YELLOW}$OUTPUT_DIR${NC}"
echo ""
echo "Files exported:"
ls -lh "$OUTPUT_DIR"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. cd web"
echo "2. npm install"
echo "3. npm run dev"
echo ""
echo "For production deployment:"
echo "1. npm run build"
echo "2. Deploy the 'out' directory to Vercel"

