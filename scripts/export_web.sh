#!/bin/bash

# Export Godot game to WebAssembly
# Can be run from project root or web/ directory

set -e

# Determine project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# If called from web/ directory via npm, go to project root
if [ -f "package.json" ] && [ -d "../game" ]; then
    cd ..
elif [ ! -f "project.godot" ]; then
    # Try to find project root
    cd "$PROJECT_ROOT"
fi

# Verify we're in the project root
if [ ! -f "project.godot" ]; then
    echo "Error: Cannot find project.godot. Please run from project root."
    exit 1
fi

echo "🎮 Exporting AItherworks to WebAssembly..."
echo "Working directory: $(pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Find Godot executable
GODOT_CMD=""

# Check common locations
if command -v godot &> /dev/null; then
    GODOT_CMD="godot"
elif command -v godot4 &> /dev/null; then
    GODOT_CMD="godot4"
elif [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="/Applications/Godot.app/Contents/MacOS/Godot"
elif [ -f "/Applications/Godot_mono.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="/Applications/Godot_mono.app/Contents/MacOS/Godot"
elif [ -f "$HOME/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_CMD="$HOME/Applications/Godot.app/Contents/MacOS/Godot"
fi

# If still not found, error out
if [ -z "$GODOT_CMD" ]; then
    echo -e "${RED}Error: Godot not found${NC}"
    echo ""
    echo "Searched locations:"
    echo "  - PATH (godot or godot4 command)"
    echo "  - /Applications/Godot.app"
    echo "  - /Applications/Godot_mono.app"
    echo "  - ~/Applications/Godot.app"
    echo ""
    echo "Solutions:"
    echo "1. Install via Homebrew: brew install godot"
    echo "2. Add Godot to PATH in ~/.zshrc:"
    echo "   export PATH=\"/Applications/Godot.app/Contents/MacOS:\$PATH\""
    echo "3. Download from: https://godotengine.org/download"
    exit 1
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

