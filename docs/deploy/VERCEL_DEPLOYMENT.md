# Deploying to Vercel

## The Problem

Vercel's build environment doesn't have Godot installed, so it can't export your game during the build process.

## The Solution

Export the game **locally** before deploying, and commit the exported files to git.

## Step-by-Step Deployment

### 1. Export Game Locally

From the project root:

```bash
./scripts/export_web.sh
```

This creates files in `web/public/godot/`:
- `aitherworks.wasm`
- `aitherworks.pck`
- `aitherworks.js`
- etc.

### 2. Commit the Exported Files

The `.gitignore` has been updated to **allow** committing these files:

```bash
git add web/public/godot/
git add web/package.json .gitignore
git commit -m "Add exported game files for Vercel deployment"
git push
```

### 3. Deploy to Vercel

#### Option A: Automatic (GitHub Integration)

1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repository
3. Configure:
   - **Root Directory**: `web`
   - **Framework**: Next.js (auto-detected)
   - **Build Command**: `npm run build` (default)
   - **Output Directory**: `out` (default)
4. Click "Deploy"

Vercel will now:
- ✅ Skip the Godot export (already done locally)
- ✅ Build Next.js with the committed game files
- ✅ Deploy successfully

#### Option B: Vercel CLI

```bash
cd web
vercel --prod
```

## Workflow

```
┌─────────────────────────────────────┐
│ 1. Make changes in Godot            │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 2. Export locally                   │
│    ./scripts/export_web.sh          │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 3. Commit exported files            │
│    git add web/public/godot/        │
│    git commit -m "Update game"      │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 4. Push to GitHub                   │
│    git push                          │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 5. Vercel auto-deploys              │
│    Uses committed files             │
└─────────────────────────────────────┘
```

## Package.json Scripts

The scripts have been updated:

```json
{
  "scripts": {
    "dev": "node server.mjs",           // Dev server with COOP/COEP headers
    "build": "next build",              // Vercel uses this (no Godot export)
    "build:full": "npm run build:godot && npm run build",  // Local: export + build
    "build:godot": "sh ../scripts/export_web.sh"  // Export Godot game only
  }
}
```

**For local development:**
```bash
npm run build:full  # Export game + build Next.js
```

**Vercel uses:**
```bash
npm run build  # Just build Next.js (expects game files committed)
```

## File Sizes

The exported game files are large (20-40MB typically):

```
web/public/godot/
├── aitherworks.wasm      ~30MB
├── aitherworks.pck       ~5-20MB (depends on assets)
├── aitherworks.js        ~1MB
└── other files           ~1MB
```

**Total**: ~40-50MB

This is acceptable for git, but consider:
- Using Git LFS for files >50MB
- Optimizing assets (compress textures, audio)

## Vercel Configuration

Your `web/vercel.json` is already configured:

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

This enables SharedArrayBuffer for threading.

## Troubleshooting

### Vercel Build Fails: "Godot not found"

**Cause**: The `build` script is trying to export the game

**Fix**: Update `web/package.json`:
```json
"build": "next build"  // Remove Godot export from build
```

### Vercel Build Fails: "No Next.js version detected"

**Cause**: Vercel root directory is wrong

**Fix**: Set root directory to `web` in Vercel dashboard:
- Project Settings → General → Root Directory: `web`

### Game Doesn't Load on Vercel

**Cause**: Game files not committed

**Fix**: 
```bash
git add web/public/godot/
git commit -m "Add game files"
git push
```

### "Too Large" Error in Git

**Cause**: Files exceed GitHub's 100MB limit

**Fix**: Use Git LFS:
```bash
cd web/public/godot
git lfs track "*.wasm"
git lfs track "*.pck"
git add .gitattributes
git add *.wasm *.pck
git commit -m "Add large files with LFS"
```

## Alternative: GitHub Actions (Advanced)

For automatic builds, you can set up GitHub Actions to:
1. Install Godot in CI
2. Export the game
3. Commit to a `deploy` branch
4. Vercel deploys from that branch

See `docs/deploy/GITHUB_ACTIONS.md` (to be created if needed).

## Best Practices

### 1. Version Control

Tag releases when deploying:
```bash
git tag v0.1.0
git push --tags
```

### 2. Test Locally First

Before pushing:
```bash
cd web
npm run build:full
npm run start
# Test at http://localhost:3000
```

### 3. Use Preview Deployments

Push to a feature branch for preview:
```bash
git checkout -b feature/new-level
# Make changes, export, commit
git push origin feature/new-level
# Vercel creates preview URL
```

### 4. Optimize Before Deploy

```bash
# In Godot, enable texture compression
# In export_presets.cfg:
vram_texture_compression/for_desktop=true

# Use compressed audio formats (OGG, not WAV)
```

## Summary

✅ Export game locally  
✅ Commit `web/public/godot/` files  
✅ Push to GitHub  
✅ Vercel deploys automatically  

The key: **Separate Godot export from Vercel build**

---

Need help? Check:
- `docs/deploy/web_deployment.md` - Full deployment guide
- `docs/deploy/FIRST_RUN.md` - First time setup
- `docs/deploy/FIXES_APPLIED.md` - Common issues and fixes

