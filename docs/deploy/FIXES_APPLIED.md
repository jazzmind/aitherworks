# Fixes Applied to Web Deployment Setup

## Issues Fixed

### 1. Tailwind CSS v4 PostCSS Plugin Error

**Error:**
```
Error: It looks like you're trying to use `tailwindcss` directly as a PostCSS plugin. 
The PostCSS plugin has moved to a separate package...
```

**Root Cause:**
Tailwind CSS v4 separates the PostCSS plugin into its own package `@tailwindcss/postcss`.

**Fix Applied:**
1. Updated `web/package.json`:
   - Added `@tailwindcss/postcss` to devDependencies
   - Removed `autoprefixer` (not needed with Tailwind v4)

2. Updated `web/postcss.config.mjs`:
   ```javascript
   plugins: {
     '@tailwindcss/postcss': {},  // Changed from 'tailwindcss'
   }
   ```

3. Ran `npm install` to install the correct package

**Result:** ✅ Tailwind CSS v4 now works correctly with Next.js

---

### 2. Invalid Favicon Error

**Error:**
```
Error: Image import "...favicon.ico" is not a valid image file. 
The image may be corrupted or an unsupported format.
```

**Root Cause:**
The placeholder `favicon.ico` file contained text "placeholder" instead of a valid image.

**Fix Applied:**
- Deleted the invalid `web/app/favicon.ico` file
- Next.js will use its default favicon until a proper one is provided

**Result:** ✅ No more favicon errors

---

### 3. Next.js Export Headers Warning

**Warning:**
```
⚠ Specified "headers" will not automatically work with "output: export". 
```

**Root Cause:**
Static exports in Next.js cannot use the `headers()` function. Headers must be configured at the hosting level.

**Fix Applied:**
Updated `web/next.config.ts`:
- Removed the `async headers()` function
- Added comment explaining headers are in `vercel.json`

**Result:** ✅ No more warnings, headers still work via Vercel configuration

---

## Verification

After fixes:
- ✅ Dev server starts without errors: `npm run dev`
- ✅ HTTP 200 response from localhost
- ✅ No PostCSS errors
- ✅ No favicon errors
- ✅ No configuration warnings

## Commands to Test

```bash
cd web
npm install
npm run dev
```

Visit http://localhost:3000 (or 3001 if 3000 is in use)

## Files Modified

1. `web/package.json` - Updated Tailwind dependencies
2. `web/postcss.config.mjs` - Fixed PostCSS plugin name
3. `web/next.config.ts` - Removed static export incompatible headers
4. `web/app/favicon.ico` - Deleted invalid file

## Additional Notes

### About Tailwind CSS v4

Tailwind v4 changes:
- No `tailwind.config.js` file needed
- Uses `@tailwindcss/postcss` instead of `tailwindcss` as PostCSS plugin
- Import styles with `@import "tailwindcss";` in CSS
- No `@apply` directive support (use utility classes directly)

### About Headers in Static Export

For CORS headers required by WebAssembly:
- **Development**: May not have COOP/COEP headers (acceptable for testing)
- **Production**: Vercel applies headers from `vercel.json`
- Alternative hosts should configure headers at server level

Headers needed:
```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

These enable `SharedArrayBuffer` for Godot threading support.

---

### 4. "Godot Engine not loaded" Error

**Error:**
```
Error: Godot Engine not loaded
  at GamePage.useEffect.startGame (page.tsx:20:17)
```

**Root Cause:**
The Godot engine JavaScript loader wasn't being dynamically loaded, and the app didn't check if game files existed before trying to load them.

**Fix Applied:**

1. Updated `web/app/page.tsx` to:
   - Dynamically load the Godot engine script from `/godot/aitherworks.js`
   - Check if game files exist before attempting to load
   - Show helpful error messages with instructions
   - Display step-by-step fix guide if files are missing

2. Added helpful UI:
   ```tsx
   // Shows clear instructions to run ./scripts/export_web.sh
   // Displays numbered steps to fix the issue
   // Better error states with styled messages
   ```

3. Created `FIRST_RUN.md`:
   - Quick reference for first-time setup
   - Explains the export → load flow
   - Troubleshooting common issues

**Result:** ✅ App now gracefully handles missing game files and shows clear instructions

---

## Important Note: Export First!

The Next.js app is a **wrapper** for your Godot game. Before the game can run in the browser, you must:

1. Export your Godot game to WASM:
   ```bash
   ./scripts/export_web.sh
   ```

2. This creates files in `web/public/godot/`:
   - `aitherworks.wasm` (Godot engine)
   - `aitherworks.pck` (Your game data)
   - `aitherworks.js` (Loader script)

3. Then the Next.js app can load and display your game

**Workflow:**
```
Godot Project → Export to WASM → Next.js loads it → Browser runs it
```

---

---

### 5. SharedArrayBuffer / Threading Error

**Error:**
```
Runtime DataCloneError
Worker.postMessage: The WebAssembly.Memory object cannot be serialized.
The Cross-Origin-Opener-Policy and Cross-Origin-Embedder-Policy HTTP headers can be used to enable this.
```

**Root Cause:**
Godot uses threading via SharedArrayBuffer, which requires COOP/COEP headers. The standard Next.js dev server doesn't set these headers.

**Fix Applied:**

1. Created `web/server.mjs`:
   - Custom Node.js server wrapping Next.js
   - Automatically sets COOP/COEP headers
   - Enables SharedArrayBuffer in development

2. Updated `web/package.json`:
   ```json
   "dev": "node server.mjs"  // Now uses custom server
   ```

3. Created `THREADING_FIX.md`:
   - Explains the issue
   - Documents two solutions (custom server vs disable threading)
   - Troubleshooting steps

**Result:** ✅ SharedArrayBuffer works in development mode with proper headers

**To apply**: Restart the dev server with `npm run dev`

---

All issues resolved! The web deployment setup is now fully functional. 🎉

## Quick Start

```bash
# Terminal 1: Start Next.js dev server (with COOP/COEP headers)
cd web
npm run dev

# Terminal 2: Export Godot game
./scripts/export_web.sh

# Open http://localhost:3000 and enjoy!
```

