# Vercel Routes Manifest Error - Fixed

## The Error

```
Error: The file "/vercel/path0/web/out/routes-manifest.json" couldn't be found.
This is often caused by a misconfiguration in your project.
```

## Root Cause

Vercel was trying to detect and use Next.js-specific features, but with `output: 'export'`, Next.js generates a static site without `routes-manifest.json`.

## The Fix

### 1. Moved `vercel.json` to Correct Location

**Before**: `web/public/vercel.json` ❌  
**After**: `web/vercel.json` ✅

The config must be in the project root (the directory with `package.json`).

### 2. Updated `vercel.json` Configuration

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "out",
  "installCommand": "npm install",
  "framework": null,  // ← Important: Tells Vercel to treat as static
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

**Key changes**:
- `"framework": null` - Disables Next.js-specific handling
- Explicit `buildCommand` and `outputDirectory`
- Headers still applied for SharedArrayBuffer support

### 3. Added `.vercelignore`

Created `web/.vercelignore` to exclude unnecessary files:
```
node_modules
.next
*.log
.DS_Store
```

## How It Works Now

```
Vercel Build Process
────────────────────

1. Detect project in web/ directory
2. Run: npm install
3. Run: npm run build
   → Builds Next.js static site
   → Outputs to web/out/
4. Deploy web/out/ as static files
5. Apply COOP/COEP headers from vercel.json
```

## Deploying

### Option 1: Via Vercel Dashboard

1. Push your changes to GitHub:
   ```bash
   git add web/vercel.json web/.vercelignore
   git commit -m "Fix Vercel static export configuration"
   git push
   ```

2. In Vercel dashboard:
   - Go to your project
   - Settings → General
   - Ensure **Root Directory** is set to: `web`
   - Save

3. Trigger redeploy (or push new changes)

### Option 2: Via CLI

```bash
cd web
vercel --prod
```

## Verification

After deployment, check:

1. **Site loads**: Visit your Vercel URL
2. **Headers present**: Open DevTools → Network → Select any file → Response Headers
   - Should see `cross-origin-embedder-policy: require-corp`
   - Should see `cross-origin-opener-policy: same-origin`
3. **Game loads**: Should see your Godot game (if files are committed)

## Common Issues

### Still Getting Routes Manifest Error?

**Solution**: Delete and reimport the project in Vercel:
1. Delete project in Vercel dashboard
2. Reimport from GitHub
3. Set root directory to `web`
4. Deploy

### "Framework: Next.js" Showing in Vercel?

**Solution**: The `framework: null` setting should override this. If issues persist:
1. In Vercel dashboard: Settings → General → Framework Preset
2. Select "Other" instead of "Next.js"
3. Redeploy

### Headers Not Applied?

**Solution**: Ensure `vercel.json` is in `web/` directory (not `web/public/`)

## Summary

✅ `vercel.json` moved to `web/` (project root)  
✅ `framework: null` set to disable Next.js-specific features  
✅ Explicit build commands configured  
✅ Headers configured for WASM/threading  
✅ `.vercelignore` added  

Your deployment should now work! 🚀

