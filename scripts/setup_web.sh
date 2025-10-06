#!/bin/zsh

# One-time setup script for web deployment
# Run this after cloning the repository

set -e

echo "🎮 Setting up AItherworks for web deployment..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check Node.js
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found${NC}"
    echo "Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION}${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm not found${NC}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "${GREEN}✓ npm ${NPM_VERSION}${NC}"

# Check Godot
if ! command -v godot &> /dev/null && ! command -v godot4 &> /dev/null; then
    echo -e "${YELLOW}⚠ Godot not found in PATH${NC}"
    echo "You'll need to install Godot 4.x to export the game."
    echo ""
    echo "Install options:"
    echo "  macOS: brew install godot"
    echo "  Linux: snap install godot-4"
    echo "  Windows: Download from https://godotengine.org/download"
    echo ""
    read -p "Continue setup anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    GODOT_CMD="godot"
    if command -v godot4 &> /dev/null; then
        GODOT_CMD="godot4"
    fi
    GODOT_VERSION=$($GODOT_CMD --version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Godot ${GODOT_VERSION}${NC}"
fi

# Install Node dependencies
echo ""
echo -e "${BLUE}Installing Next.js dependencies...${NC}"
cd web
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

cd ..

# Create necessary directories
echo ""
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p web/public/godot
echo -e "${GREEN}✓ Directories created${NC}"

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo ""
echo -e "${YELLOW}1. Export the game:${NC}"
echo "   ./scripts/export_web.sh"
echo ""
echo -e "${YELLOW}2. Start development server:${NC}"
echo "   cd web && npm run dev"
echo ""
echo -e "${YELLOW}3. Deploy to Vercel:${NC}"
echo "   cd web && vercel"
echo ""
echo "For detailed instructions, see docs/web_deployment.md"
echo ""

