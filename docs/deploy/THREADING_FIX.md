# SharedArrayBuffer / Threading Fix

## The Error

```
Runtime DataCloneError
Worker.postMessage: The WebAssembly.Memory object cannot be serialized.
The Cross-Origin-Opener-Policy and Cross-Origin-Embedder-Policy HTTP headers can be used to enable this.
```

## Root Cause

Godot uses **threading** via SharedArrayBuffer, which requires special HTTP headers:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

Next.js dev server (`next dev`) doesn't set these headers by default.

## Solution: Custom Dev Server ✅

I've created a custom server that sets the required headers.

### Files Created

**`web/server.mjs`** - Custom Node.js server that wraps Next.js with proper headers

### Updated Scripts

**`web/package.json`**:
```json
{
  "scripts": {
    "dev": "node server.mjs",        // ← New: Uses custom server
    "dev:next": "next dev",           // ← Old: Standard Next.js (no headers)
    "build": "npm run build:godot && next build",
    "start": "next start"
  }
}
```

## How to Use

### Option 1: Use Custom Server (Recommended)

**Stop the current dev server** (Ctrl+C) and restart:

```bash
cd web
npm run dev
```

This now uses the custom server with COOP/COEP headers enabled.

### Option 2: Disable Threading in Godot

If you don't need threading, you can disable it:

**Edit `export_presets.cfg`**:
```ini
[preset.0.options]
variant/thread_support=false    # Change from true to false
```

Then re-export:
```bash
./scripts/export_web.sh
```

**Pros**: Works with standard `next dev`  
**Cons**: Slightly slower performance (single-threaded)

## Verification

After restarting with the custom server, check browser console:

```javascript
// In browser console:
typeof SharedArrayBuffer
// Should output: "function" (not "undefined")
```

If it's still "undefined", the headers aren't being set correctly.

## Production

In production (Vercel), headers are set via `vercel.json`:

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

This works automatically when deployed to Vercel.

## Troubleshooting

### Still getting the error?

1. **Hard refresh**: Ctrl+Shift+R (Chrome) or Cmd+Shift+R (Mac)
2. **Clear cache**: Open DevTools → Application → Clear Storage
3. **Check headers**: Network tab → Select any file → Headers → Response Headers

You should see:
```
cross-origin-embedder-policy: require-corp
cross-origin-opener-policy: same-origin
```

### Can't use custom server?

Use Option 2 (disable threading in Godot). Performance difference is minimal for most 2D games.

## Technical Details

### Why These Headers?

**SharedArrayBuffer** allows multiple threads to share memory efficiently. For security reasons (Spectre/Meltdown), browsers require:

1. **COEP: require-corp**
   - "Cross-Origin Embedder Policy"
   - Ensures all resources are explicitly allowed to be embedded

2. **COOP: same-origin**
   - "Cross-Origin Opener Policy"  
   - Isolates the page from other origins

Together, they create a "cross-origin isolated" context where SharedArrayBuffer is allowed.

### What Godot Uses Threading For

- Physics calculations
- Audio processing
- Resource loading
- Rendering preparation

For simple games, single-threaded is often sufficient.

## References

- [SharedArrayBuffer on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer)
- [COOP/COEP Explainer](https://web.dev/coop-coep/)
- [Godot Web Export Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)

---

**Current Status**: ✅ Custom server configured with proper headers

