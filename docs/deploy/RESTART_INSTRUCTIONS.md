# How to Restart the Dev Server

## All npm servers have been stopped ✅

Ports 3000 and 3001 are now free.

## Start the Dev Server (with COOP/COEP headers)

```bash
cd web
npm run dev
```

You should see:
```
> aitherworks-web@0.1.0 dev
> node server.mjs

> Ready on http://localhost:3000
✓ COOP/COEP headers enabled for WebAssembly threading
```

## Then Open Your Browser

http://localhost:3000

## What Should Happen

1. ✅ If game is exported: Game loads with threading support
2. ⚠️ If game not exported yet: You'll see instructions to run `./scripts/export_web.sh`

## If You Need to Export First

In a **new terminal** (keep dev server running):

```bash
# From project root
./scripts/export_web.sh
```

Then refresh your browser.

## Summary of Changes

- ✅ Custom server with COOP/COEP headers
- ✅ Fixes SharedArrayBuffer threading error
- ✅ Game will load properly

Ready to go! 🎮

