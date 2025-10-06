# Web Deployment Guide

This guide explains how to build and deploy AItherworks to the web using Godot's WebAssembly export and Next.js hosting on Vercel.

## Overview

The deployment architecture consists of:

1. **Godot Game** (GDScript) → Exported to WebAssembly (WASM)
2. **Next.js Wrapper** (React/TypeScript) → Embeds the game with proper loading UI
3. **Vercel Hosting** → Serves the static Next.js site with correct headers for WASM

## Prerequisites

### 1. Install Godot 4.x

Download and install Godot 4.x from [godotengine.org](https://godotengine.org/download).

**On macOS:**
```bash
brew install godot
```

**On Linux:**
```bash
# Use your package manager or download from godotengine.org
sudo snap install godot-4
```

**On Windows:**
Download the installer from godotengine.org

### 2. Install Export Templates

Export templates are required to build for web:

1. Open the Godot Editor
2. Go to **Editor → Manage Export Templates**
3. Click **Download and Install**
4. Wait for the download to complete (templates match your Godot version)

Alternatively, download from the command line:
```bash
godot --headless --export-release "Web" dummy.html
# This will prompt you to install templates if missing
```

### 3. Install Node.js and npm

You need Node.js 18+ for Next.js:

**On macOS:**
```bash
brew install node
```

**On Linux:**
```bash
# Use nvm or your package manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
```

**On Windows:**
Download from [nodejs.org](https://nodejs.org/)

### 4. Install Vercel CLI (Optional)

For local testing and deployment:
```bash
npm install -g vercel
```

## Building for Web

### Step 1: Export Godot Game to WASM

From the project root, run:

```bash
./scripts/export_web.sh
```

This script will:
- Clean previous builds
- Export the game to `web/public/godot/`
- Generate the necessary files for Next.js integration

**What gets exported:**
- `aitherworks.wasm` - The compiled game engine
- `aitherworks.pck` - Game data package
- `aitherworks.js` - Engine loader
- `aitherworks.worker.js` - Web worker for threading
- `aitherworks.audio.worklet.js` - Audio processing

### Step 2: Build the Next.js App

```bash
cd web
npm install
npm run build
```

This will:
1. Run the Godot export script (via `build:godot`)
2. Build the Next.js static site
3. Output to `web/out/` directory

### Step 3: Test Locally

```bash
npm run start
# Or for development mode:
npm run dev
```

Open http://localhost:3000 to see your game.

## Understanding the Stack

### Godot → WASM Export

Godot 4 uses Emscripten to compile GDScript (and the engine) to WebAssembly:

- **WASM Module**: Contains the entire Godot engine compiled to WebAssembly
- **PCK File**: Packed game resources (scenes, scripts, assets)
- **JavaScript Loader**: Initializes the WASM module and handles browser APIs

### Next.js Wrapper

The Next.js app (`web/app/page.tsx`) provides:

- **Canvas Element**: Where Godot renders the game
- **Loading UI**: Progress bar and status messages
- **Error Handling**: Graceful fallbacks if the game fails to load
- **Proper Headers**: CORS and COOP/COEP headers for SharedArrayBuffer support

Key features:
- Static export (`output: 'export'` in `next.config.ts`)
- Custom headers for cross-origin isolation (required for threading)
- Steampunk-themed loading screen

### Web Architecture

```
User Browser
    ↓
Next.js Static Site (HTML/CSS/JS)
    ↓
Godot Engine Loader (JavaScript)
    ↓
WASM Runtime
    ↓
Your Game (GDScript → WASM)
```

## Deploying to Vercel

### Method 1: GitHub Integration (Recommended)

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Add web deployment setup"
   git push origin main
   ```

2. **Connect to Vercel:**
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Select your GitHub repository
   - Configure build settings:
     - **Framework Preset**: Next.js
     - **Root Directory**: `web`
     - **Build Command**: `npm run build`
     - **Output Directory**: `out`

3. **Deploy:**
   - Click "Deploy"
   - Vercel will automatically build and deploy your game
   - You'll get a URL like `aitherworks.vercel.app`

### Method 2: Vercel CLI

From the `web` directory:

```bash
vercel login
vercel
# Follow the prompts
```

For production deployment:
```bash
vercel --prod
```

### Method 3: Manual Upload

1. Build the site:
   ```bash
   cd web
   npm run build
   ```

2. Upload the `out/` directory to any static hosting service:
   - Vercel, Netlify, Cloudflare Pages, GitHub Pages, etc.
   - Ensure the server sends the correct CORS headers

## Configuration Files

### `export_presets.cfg` (Godot)

Defines how Godot exports to web:

```ini
[preset.0]
name="Web"
platform="Web"
export_path="web/public/godot/aitherworks.html"
variant/thread_support=true
```

Key settings:
- **thread_support=true**: Enables threading via SharedArrayBuffer (requires COOP/COEP headers)
- **canvas_resize_policy=2**: Allows canvas to adapt to container size
- **vram_texture_compression**: Optimizes texture loading

### `next.config.ts` (Next.js)

Configures Next.js for static export:

```typescript
{
  output: 'export',  // Static site generation
  images: { unoptimized: true },  // No image optimization for static export
  async headers() {
    // Required for SharedArrayBuffer (threading support)
    return [{
      source: '/:path*',
      headers: [
        { key: 'Cross-Origin-Embedder-Policy', value: 'require-corp' },
        { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
      ],
    }]
  }
}
```

### `vercel.json` (Optional)

If you need custom Vercel configuration, create `web/vercel.json`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Embedder-Policy", "value": "require-corp" },
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" }
      ]
    }
  ]
}
```

## Troubleshooting

### Game Doesn't Load

**Issue**: White screen or "Failed to load game"

**Solutions:**
1. Check browser console for errors
2. Verify all WASM files are present in `public/godot/`
3. Ensure export templates are installed
4. Try re-exporting: `./scripts/export_web.sh`

### SharedArrayBuffer Not Available

**Issue**: "SharedArrayBuffer is not defined"

**Solution:**
- Ensure COOP/COEP headers are set correctly
- Check `next.config.ts` has the headers configuration
- Verify headers are being sent (check Network tab in DevTools)

### Performance Issues

**Issue**: Game runs slowly in browser

**Solutions:**
1. Enable threading in export presets (`thread_support=true`)
2. Optimize textures (use compressed formats)
3. Reduce viewport size in `project.godot`
4. Profile with Chrome DevTools Performance tab
5. Consider using release export instead of debug

### Build Fails

**Issue**: `npm run build` fails

**Solutions:**
1. Check that Godot is in your PATH
2. Verify export templates are installed
3. Ensure `export_presets.cfg` is configured correctly
4. Try exporting manually from Godot Editor first

### Assets Not Loading

**Issue**: Missing textures or sounds

**Solutions:**
1. Check export filter in `export_presets.cfg` (should be "all_resources")
2. Verify assets are in the correct directories
3. Check for `.import` files next to assets
4. Reimport assets in Godot Editor

## Performance Optimization

### 1. Texture Compression

Enable VRAM compression in export presets:
```ini
vram_texture_compression/for_desktop=true
```

### 2. Code Optimization

- Use `@onready` for node references
- Avoid `_process()` when possible, use signals
- Pool frequently created objects
- Use `visibility_changed` signal to pause inactive nodes

### 3. Asset Optimization

- Compress PNG files with tools like `pngquant`
- Use WebP for textures where supported
- Reduce audio bitrates (32-44kHz is sufficient)
- Use streaming for background music

### 4. Loading Time

- Show loading screen early
- Load large resources asynchronously
- Consider splitting content into multiple PCK files
- Use progressive loading for levels

## Advanced Topics

### Custom Loading Screen

Modify `web/app/page.tsx` to customize the loading experience:

```tsx
// Add your own branding, animations, tips, etc.
<div id="status-notice">{status}</div>
```

### Multiple Environments

Use Vercel preview deployments for staging:

```bash
git checkout -b feature/new-level
# Make changes
git push origin feature/new-level
# Vercel automatically creates a preview deployment
```

### Analytics

Add analytics to track game usage:

```tsx
// In web/app/layout.tsx
import Analytics from '@vercel/analytics/react'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

### Custom Domain

In Vercel dashboard:
1. Go to your project settings
2. Click "Domains"
3. Add your custom domain (e.g., `play.aitherworks.com`)
4. Update DNS records as instructed

## CI/CD Pipeline

For automated deployments, add a GitHub Actions workflow:

`.github/workflows/deploy.yml`:
```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.3.0
          
      - name: Export Game
        run: ./scripts/export_web.sh
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./web
```

## Resources

- [Godot Web Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Next.js Static Export](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Vercel Documentation](https://vercel.com/docs)
- [SharedArrayBuffer and COOP/COEP](https://web.dev/coop-coep/)

## Support

If you encounter issues:

1. Check the [Godot Web Export FAQ](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#serving-the-files)
2. Review browser console for errors
3. Test in multiple browsers (Chrome, Firefox, Safari)
4. Open an issue on the GitHub repository

Happy deploying! 🎮✨

