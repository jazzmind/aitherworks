# First Run Instructions

## You're seeing "Game files not found"?

This is expected! The Next.js app is ready, but you need to export your Godot game first.

## Quick Fix (3 steps)

### 1. Export Your Godot Game

From the project root, run:

```bash
./scripts/export_web.sh
```

**What this does:**
- Exports your Godot game to WebAssembly (WASM)
- Places the files in `web/public/godot/`
- Takes about 10-30 seconds

**Output you should see:**
```
🎮 Exporting AItherworks to WebAssembly...
Found Godot: 4.x.x
Cleaning previous build...
Exporting game...
✅ Export complete!
```

### 2. Refresh Your Browser

After the export completes, just refresh the page at http://localhost:3000

### 3. Your Game Should Load!

You'll see:
1. Loading screen with progress bar
2. "Loading... XX%"
3. Your Godot game running in the browser!

---

## Troubleshooting

### "Godot not found in PATH"

**Install Godot 4.x:**

**macOS:**
```bash
brew install godot
```

**Linux:**
```bash
snap install godot-4
```

**Windows:**
Download from https://godotengine.org/download

---

### "Export templates not installed"

1. Open Godot Editor
2. Go to: **Editor → Manage Export Templates**
3. Click **Download and Install**
4. Wait for download
5. Try exporting again

---

### Still Not Working?

Check the full guide: `docs/web_deployment_quickstart.md`

Or the comprehensive guide: `docs/web_deployment.md`

---

## Understanding the Flow

```
1. Godot Project (GDScript + Scenes)
        ↓
2. Export to WASM (./scripts/export_web.sh)
        ↓
3. Files created in web/public/godot/
        ↓
4. Next.js loads and displays them
        ↓
5. Game runs in browser!
```

The Next.js app is just a **wrapper** - it needs the exported game files to work.

---

## Files Created by Export

After running `./scripts/export_web.sh`, you'll see:

```
web/public/godot/
├── aitherworks.wasm      # Godot engine (~30MB)
├── aitherworks.pck       # Your game data
├── aitherworks.js        # Engine loader
├── aitherworks.worker.js # Web worker
└── aitherworks.audio.worklet.js
```

These are what the browser loads to run your game.

---

## Next Time

After the first export, whenever you make changes:

```bash
# 1. Make changes in Godot
# 2. Re-export
./scripts/export_web.sh

# 3. Refresh browser (Next.js will auto-reload)
```

That's it! 🎮✨

