# Web Deployment - Complete Setup Summary

Your Godot game is now ready to be deployed to the web! Here's what was set up and how to use it.

## 📁 What Was Created

### Next.js Application (`web/`)
```
web/
├── app/
│   ├── layout.tsx          # Main app layout
│   ├── page.tsx            # Game page with Godot loader
│   └── globals.css         # Styling (Tailwind + game UI)
├── public/
│   ├── godot/              # Exported game files go here
│   └── vercel.json         # Headers configuration
├── package.json            # Dependencies and build scripts
├── next.config.ts          # Next.js configuration
└── tsconfig.json           # TypeScript configuration
```

### Build Scripts
- `scripts/export_web.sh` - Exports Godot game to WASM
- `scripts/setup_web.sh` - One-time setup for dependencies

### Documentation
- `docs/web_deployment.md` - Comprehensive deployment guide
- `docs/web_deployment_quickstart.md` - 5-minute quick start
- `docs/wasm_build_explained.md` - Technical deep dive

### Configuration Updates
- `export_presets.cfg` - Updated with web export settings
- `.gitignore` - Added build output directories
- `README.md` - Added web deployment section

## 🚀 Quick Start Commands

### First Time Setup
```bash
# Install dependencies
./scripts/setup_web.sh
```

### Development Workflow
```bash
# 1. Export game to WASM
./scripts/export_web.sh

# 2. Start dev server
cd web
npm run dev

# 3. Open browser
open http://localhost:3000
```

### Production Build
```bash
cd web
npm run build
# Output: web/out/ directory ready for deployment
```

## 🌐 Deployment Options

### Option 1: Vercel (Recommended)

**Via GitHub:**
1. Push code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Import repository
4. Set root directory: `web`
5. Deploy!

**Via CLI:**
```bash
cd web
npm install -g vercel
vercel login
vercel --prod
```

### Option 2: Other Hosts

The `web/out/` directory is a static site. Deploy to:
- Netlify
- Cloudflare Pages  
- GitHub Pages
- Any static host

**Important**: Ensure your host sends these headers:
```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

These are needed for multithreading (SharedArrayBuffer).

## 🎮 How It Works

```
┌─────────────────────────────────────────────────┐
│ Your Godot Game (GDScript)                      │
└─────────────────────────────────────────────────┘
                    ↓ export
┌─────────────────────────────────────────────────┐
│ WebAssembly Files                                │
│ - aitherworks.wasm (Godot engine)               │
│ - aitherworks.pck  (Your game data)             │
└─────────────────────────────────────────────────┘
                    ↓ embedded in
┌─────────────────────────────────────────────────┐
│ Next.js Static Site                              │
│ - Beautiful loading screen                       │
│ - Proper headers for WASM                        │
│ - Responsive canvas                              │
└─────────────────────────────────────────────────┘
                    ↓ deployed to
┌─────────────────────────────────────────────────┐
│ Vercel CDN                                       │
│ - Global distribution                            │
│ - Auto SSL/HTTPS                                 │
│ - Instant deployment                             │
└─────────────────────────────────────────────────┘
```

## 🔧 Key Technologies

- **Godot 4** - Game engine compiled to WebAssembly
- **Next.js 15** - React framework with App Router
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS v4** - Utility-first styling
- **Vercel** - Deployment and CDN hosting

## 📝 Build Configuration

### `export_presets.cfg`
Tells Godot how to export for web:
- Output: `web/public/godot/aitherworks.html`
- Threading: Enabled
- Compression: Enabled

### `next.config.ts`
Configures Next.js:
- Static export mode
- WASM-required headers (COOP/COEP)
- Image optimization disabled (for static export)

### `package.json` (in web/)
Build scripts:
- `npm run dev` - Development server
- `npm run build` - Full production build
- `npm run build:godot` - Export game only

## 🎨 Customization

### Loading Screen
Edit `web/app/page.tsx`:
```tsx
<div id="status-notice">{status}</div>
```

Add your branding, tips, or progress messages.

### Styling
Edit `web/app/globals.css`:
```css
#game-container {
  /* Change background, layout, etc. */
}
```

Uses Tailwind CSS v4 (imported via `@import "tailwindcss"`).

### Canvas Size
Edit `project.godot`:
```ini
[display]
window/size/viewport_width=1440
window/size/viewport_height=900
```

Or make it responsive in `export_presets.cfg`:
```ini
html/canvas_resize_policy=2
```

## 📊 Performance Tips

### Reduce Load Time
1. Use release build (not debug)
2. Enable texture compression
3. Compress audio files
4. Use Vercel CDN (automatic)

### Optimize Runtime
1. Enable threading in export preset
2. Profile with Chrome DevTools
3. Reduce draw calls
4. Use object pooling

### SEO and Meta Tags
Edit `web/app/layout.tsx`:
```tsx
export const metadata: Metadata = {
  title: 'AItherworks',
  description: 'Your game description',
  // Add OpenGraph, Twitter cards, etc.
}
```

## 🐛 Troubleshooting

### "Godot not found"
Install Godot 4.x and add to PATH:
```bash
# macOS
brew install godot
```

### "Export templates not installed"
Open Godot Editor → Editor → Manage Export Templates

### Game doesn't load
1. Check browser console (F12)
2. Verify files exist in `web/public/godot/`
3. Clear browser cache
4. Try in incognito mode

### "SharedArrayBuffer not available"
Deploy to Vercel (localhost may not have correct headers)

## 📖 Documentation

- **Quick Start**: `docs/web_deployment_quickstart.md`
- **Full Guide**: `docs/web_deployment.md`
- **WASM Explained**: `docs/wasm_build_explained.md`
- **Web README**: `web/README.md`

## 🔄 Typical Workflow

```bash
# 1. Make changes to Godot game
# Edit scenes, scripts, etc. in Godot Editor

# 2. Export to WASM
./scripts/export_web.sh

# 3. Test locally
cd web && npm run dev

# 4. Commit and push
git add .
git commit -m "Update game"
git push

# 5. Vercel auto-deploys
# Your changes go live in ~2 minutes
```

## 🎯 Next Steps

1. **Try it locally**: Run `./scripts/setup_web.sh` and `npm run dev`
2. **Deploy to Vercel**: Connect your GitHub repo
3. **Customize**: Edit loading screen and styling
4. **Share**: Send your game URL to players!

## 🆘 Getting Help

- **Godot Web Export**: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- **Next.js Docs**: https://nextjs.org/docs
- **Vercel Docs**: https://vercel.com/docs

---

**You're all set!** Your game can now run in any modern web browser. 🎮✨

