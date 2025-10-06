# Web Deployment Quick Start

This is a condensed guide to get your game running on the web in 5 minutes.

## Prerequisites Checklist

- [ ] Godot 4.x installed and in PATH
- [ ] Godot Web export templates installed
- [ ] Node.js 18+ installed
- [ ] Git repository (for Vercel deployment)

## Step-by-Step

### 1. Install Export Templates (First Time Only)

Open Godot Editor:
```
Editor → Manage Export Templates → Download and Install
```

Or verify from command line:
```bash
godot --version
```

### 2. Start the Dev Server First (Optional)

You can start Next.js before exporting to see the helpful error message:

```bash
cd web
npm install  # if you haven't already
npm run dev
```

Open http://localhost:3000 - you'll see instructions to export the game.

### 3. Export Game to WASM

From project root (in a new terminal):
```bash
./scripts/export_web.sh
```

Expected output:
```
🎮 Exporting AItherworks to WebAssembly...
Found Godot: 4.x.x
Cleaning previous build...
Exporting game...
✅ Export complete!
```

**Files created:**
- `web/public/godot/aitherworks.wasm` (Godot engine)
- `web/public/godot/aitherworks.pck` (Your game)
- `web/public/godot/aitherworks.js` (Loader)

### 4. Refresh Browser

Go back to http://localhost:3000 and refresh.

You should see:
1. "Loading game engine..."
2. Progress bar: "Loading... XX%"
3. Game canvas appears
4. Your Godot game running in the browser! 🎮

### 5. Deploy to Vercel

#### Option A: GitHub (Recommended)

```bash
# From project root
git add .
git commit -m "Add web deployment"
git push
```

Then:
1. Go to https://vercel.com
2. Click "New Project"
3. Import your GitHub repository
4. Settings:
   - Root Directory: `web`
   - Framework: Next.js (auto-detected)
   - Build Command: `npm run build` (default)
5. Click "Deploy"

#### Option B: Vercel CLI

```bash
cd web
npm install -g vercel
vercel login
vercel
```

Follow the prompts. Your game will be live in ~2 minutes!

## Troubleshooting

### "Godot not found in PATH"
```bash
# macOS
brew install godot

# Or add to PATH
export PATH="/Applications/Godot.app/Contents/MacOS:$PATH"
```

### "Export templates not installed"
Open Godot Editor → Editor → Manage Export Templates → Download

### "SharedArrayBuffer not available"
This is normal in development. Deploy to Vercel which sets the correct headers.

### Game doesn't load in browser
1. Check browser console (F12)
2. Verify files exist: `web/public/godot/aitherworks.wasm`
3. Try re-exporting: `./scripts/export_web.sh`

## What Gets Deployed?

```
web/out/                    ← This gets deployed
├── index.html              ← Next.js wrapper
├── _next/                  ← Next.js assets
└── godot/                  ← Your game
    ├── aitherworks.wasm    (Game engine ~30MB)
    ├── aitherworks.pck     (Your game data)
    ├── aitherworks.js      (Loader)
    └── *.worker.js         (Threading support)
```

## Next Steps

- Customize loading screen in `web/app/page.tsx`
- Add analytics in `web/app/layout.tsx`
- Set up custom domain in Vercel dashboard
- Enable CI/CD with GitHub Actions

## Need More Info?

See the full guide: [web_deployment.md](./web_deployment.md)

