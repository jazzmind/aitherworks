#!/bin/bash

# Sync assets from Godot project to Next.js public folder
# Run this when you update assets in the Godot project

set -e

echo "🎨 Syncing assets to Next.js..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source and destination
SRC_ASSETS="assets"
DEST_ASSETS="web/public/assets"

# Create destination directories
mkdir -p "$DEST_ASSETS/backgrounds"
mkdir -p "$DEST_ASSETS/icons"
mkdir -p "$DEST_ASSETS/characters"

# Copy backgrounds (use one from each set)
echo -e "${BLUE}Copying backgrounds...${NC}"
cp "$SRC_ASSETS/backrounds/1/orig.png" "$DEST_ASSETS/backgrounds/loading-bg.png"
cp "$SRC_ASSETS/backrounds/2/orig.png" "$DEST_ASSETS/backgrounds/alt-bg-1.png"
cp "$SRC_ASSETS/backrounds/3/orig.png" "$DEST_ASSETS/backgrounds/alt-bg-2.png"
cp "$SRC_ASSETS/blueprint_bg.svg" "$DEST_ASSETS/blueprint-bg.svg"

# Copy icons (exclude .import files)
echo -e "${BLUE}Copying icons...${NC}"
find "$SRC_ASSETS/icons" -name "*.svg" ! -name "*.import" -exec cp {} "$DEST_ASSETS/icons/" \; 2>/dev/null || true

# Copy characters (exclude .import files)
echo -e "${BLUE}Copying characters...${NC}"
find "$SRC_ASSETS/characters" -name "*.svg" ! -name "*.import" -exec cp {} "$DEST_ASSETS/characters/" \; 2>/dev/null || true

# Clean up any .import files that got copied
echo -e "${BLUE}Cleaning up .import files...${NC}"
find "$DEST_ASSETS" -name "*.import" -delete 2>/dev/null || true

echo -e "${GREEN}✅ Assets synced!${NC}"
echo ""
echo "Copied to: $DEST_ASSETS"
echo ""
echo "Don't forget to commit:"
echo "  git add $DEST_ASSETS"
echo "  git commit -m \"Update web assets\""

