#!/bin/bash

# Deploy to Vercel workflow
# This script exports the game and prepares for deployment

set -e

echo "🚀 Preparing for Vercel deployment..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Export game
echo -e "${BLUE}Step 1: Exporting Godot game...${NC}"
./scripts/export_web.sh

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

echo ""

# 2. Check if files exist
if [ ! -f "web/public/godot/aitherworks.wasm" ]; then
    echo "❌ Error: Game files not found after export"
    exit 1
fi

echo -e "${GREEN}✓ Game exported successfully${NC}"
echo ""

# 3. Show file sizes
echo -e "${BLUE}Exported files:${NC}"
du -h web/public/godot/* | grep -v "index.html"
echo ""
TOTAL_SIZE=$(du -sh web/public/godot | awk '{print $1}')
echo -e "Total size: ${YELLOW}$TOTAL_SIZE${NC}"
echo ""

# 4. Git status
echo -e "${BLUE}Step 2: Checking git status...${NC}"
if [ -n "$(git status --porcelain web/public/godot)" ]; then
    echo -e "${YELLOW}Game files have changes${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review changes: git diff web/public/godot"
    echo "2. Add files: git add web/public/godot/"
    echo "3. Commit: git commit -m \"Update game for deployment\""
    echo "4. Push: git push"
    echo ""
    echo "Or run:"
    echo -e "${GREEN}git add web/public/godot/ && git commit -m \"Update game\" && git push${NC}"
else
    echo -e "${GREEN}✓ No changes to game files${NC}"
    echo ""
    echo "Game files are already committed."
    echo "Ready to deploy!"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Deployment preparation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "To deploy:"
echo "  • Via Vercel dashboard: Push to GitHub, auto-deploys"
echo "  • Via CLI: cd web && vercel --prod"
echo ""

