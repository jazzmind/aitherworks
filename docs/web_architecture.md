# Web Deployment Architecture

This document visualizes the architecture of AItherworks web deployment.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        User's Browser                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     Next.js App                            │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  HTML + CSS + JavaScript                            │  │  │
│  │  │  - Loading Screen                                   │  │  │
│  │  │  - Progress Bar                                     │  │  │
│  │  │  - Canvas Element                                   │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                         ↓                                  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Godot Engine Loader (aitherworks.js)              │  │  │
│  │  │  - Initialize WASM                                  │  │  │
│  │  │  - Load game resources                             │  │  │
│  │  │  - Setup canvas                                     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                         ↓                                  │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  WebAssembly Runtime                                │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │  Godot Engine (aitherworks.wasm)              │  │  │  │
│  │  │  │  - Rendering Engine (WebGL)                   │  │  │  │
│  │  │  │  - Physics Engine                              │  │  │  │
│  │  │  │  - Audio Engine                                │  │  │  │
│  │  │  │  - GDScript VM                                 │  │  │  │
│  │  │  └───────────────────────────────────────────────┘  │  │  │
│  │  │                      ↓                               │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │  Your Game (aitherworks.pck)                  │  │  │  │
│  │  │  │  - Scenes (.tscn)                             │  │  │  │
│  │  │  │  - Scripts (.gd → bytecode)                   │  │  │  │
│  │  │  │  - Assets (images, audio, etc.)               │  │  │  │
│  │  │  └───────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                ↑
                    Network (HTTPS + CDN)
                                ↑
┌─────────────────────────────────────────────────────────────────┐
│                      Vercel Platform                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Edge Network (Global CDN)                                │  │
│  │  - Serves static files                                    │  │
│  │  - Adds CORS headers (COOP/COEP)                          │  │
│  │  - Compresses files (Brotli/Gzip)                         │  │
│  │  - SSL/HTTPS                                              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                               ↑                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Static Files (web/out/)                                  │  │
│  │  ├── index.html (Next.js wrapper)                         │  │
│  │  ├── _next/ (Next.js assets)                              │  │
│  │  └── godot/ (Game files)                                  │  │
│  │      ├── aitherworks.wasm                                 │  │
│  │      ├── aitherworks.pck                                  │  │
│  │      └── aitherworks.js                                   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                ↑
                      Automatic Deployment
                                ↑
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Repository                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Source Code                                              │  │
│  │  - Godot project                                          │  │
│  │  - Next.js app                                            │  │
│  │  - Build scripts                                          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Build Pipeline

```
Developer Workflow
─────────────────

┌──────────────────┐
│ Edit Game in     │
│ Godot Editor     │
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│ ./scripts/       │
│ export_web.sh    │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────────────────────┐
│ Export to WASM                            │
│ - Godot CLI exports project              │
│ - Creates WASM + PCK files                │
│ - Output: web/public/godot/               │
└────────┬─────────────────────────────────┘
         │
         ↓
┌──────────────────┐
│ cd web           │
│ npm run build    │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────────────────────┐
│ Next.js Build                             │
│ - Compiles TypeScript → JavaScript        │
│ - Processes Tailwind CSS                  │
│ - Generates static HTML                   │
│ - Copies public/ files                    │
│ - Output: web/out/                        │
└────────┬─────────────────────────────────┘
         │
         ↓
┌──────────────────┐
│ git push         │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────────────────────┐
│ Vercel Deployment                         │
│ - Detects changes on GitHub               │
│ - Runs npm run build                      │
│ - Deploys to edge network                 │
│ - Generates unique URL                    │
└────────┬─────────────────────────────────┘
         │
         ↓
┌──────────────────┐
│ Live Game! 🎮    │
│ https://         │
│ your-game.vercel │
│ .app             │
└──────────────────┘
```

## File Flow

```
Source Files                   Build Output              Deployed Files
────────────                   ────────────              ──────────────

game/                          web/public/godot/         vercel.app/godot/
├── parts/*.tscn      ────→    ├── aitherworks.wasm  ──→ aitherworks.wasm
├── sim/*.gd                   ├── aitherworks.pck       aitherworks.pck
├── ui/*.tscn                  └── aitherworks.js        aitherworks.js
└── assets/

web/app/                       web/out/                  vercel.app/
├── layout.tsx        ────→    ├── index.html        ──→ index.html
├── page.tsx                   └── _next/                _next/
└── globals.css                    └── static/            └── static/

export_presets.cfg
project.godot
    │
    └─────────────────────────→ Controls export process
```

## Runtime Data Flow

```
User Interaction Flow
─────────────────────

User Action (Click, Key Press)
         ↓
Browser Event (MouseEvent, KeyboardEvent)
         ↓
JavaScript Event Handler (Next.js page)
         ↓
Godot Engine Loader (aitherworks.js)
         ↓
WASM Function Call
         ↓
Godot Input System (C++ → WASM)
         ↓
GDScript _input() Function
         ↓
Your Game Logic
         ↓
Scene Updates
         ↓
Render to Canvas
         ↓
WebGL Draw Calls
         ↓
GPU Rendering
         ↓
User Sees Result
```

## Loading Sequence

```
Timeline of Game Load
─────────────────────

  0ms ├─ User navigates to site
      │
 50ms ├─ HTML downloaded and parsed
      │  Next.js page starts loading
      │
200ms ├─ CSS loaded, loading screen visible
      │  Progress bar shows "Initializing..."
      │
500ms ├─ aitherworks.js downloaded
      │  Engine loader starts
      │
 1.5s ├─ aitherworks.wasm downloaded (largest file)
      │  Progress bar at 50%
      │  Browser compiles WASM to native code
      │
 2.5s ├─ WASM compilation complete
      │  Godot runtime initializes
      │  Progress bar at 75%
      │
 3.0s ├─ aitherworks.pck downloaded
      │  Game resources loaded into virtual FS
      │  Progress bar at 90%
      │
 3.5s ├─ Game starts
      │  Main scene loads
      │  Progress bar at 100%
      │
 4.0s ├─ Loading screen fades out
      │  Game is playable! 🎮
```

## Network Architecture

```
                    User
                     │
                     ↓
          ┌──────────────────┐
          │ DNS Resolution   │
          │ your-game.       │
          │ vercel.app       │
          └────────┬─────────┘
                   │
                   ↓
    ┌──────────────────────────────┐
    │ Vercel Edge Network          │
    │ (Nearest Geographic Location)│
    └────────┬─────────────────────┘
             │
             ├─→ Serve HTML (cached)
             ├─→ Serve JS (cached, compressed)
             ├─→ Serve WASM (cached, compressed)
             └─→ Serve PCK (cached)
                 │
                 ↓ Add Headers
                 - Cross-Origin-Embedder-Policy
                 - Cross-Origin-Opener-Policy
                 - Content-Encoding: br/gzip
                 │
                 ↓
             User's Browser
```

## Memory Layout (Browser)

```
Browser Process Memory
──────────────────────

┌─────────────────────────────────┐
│ Renderer Process (Tab)          │
│                                  │
│ ┌─────────────────────────────┐ │
│ │ JavaScript Heap             │ │
│ │ - React components          │ │
│ │ - Next.js runtime           │ │
│ │ - DOM                       │ │
│ │ Size: ~50-100 MB            │ │
│ └─────────────────────────────┘ │
│                                  │
│ ┌─────────────────────────────┐ │
│ │ WebAssembly Heap            │ │
│ │ - Godot engine memory       │ │
│ │ - Game objects              │ │
│ │ - Scene nodes               │ │
│ │ Size: 100-500 MB (grows)    │ │
│ └─────────────────────────────┘ │
│                                  │
│ ┌─────────────────────────────┐ │
│ │ GPU Memory (WebGL)          │ │
│ │ - Textures                  │ │
│ │ - Vertex buffers            │ │
│ │ - Shaders                   │ │
│ │ Size: 100-300 MB            │ │
│ └─────────────────────────────┘ │
│                                  │
│ ┌─────────────────────────────┐ │
│ │ SharedArrayBuffer           │ │
│ │ - Multi-threading data      │ │
│ │ - Worker communication      │ │
│ │ Size: 10-50 MB (if enabled) │ │
│ └─────────────────────────────┘ │
│                                  │
│ Total: ~250-950 MB              │
└─────────────────────────────────┘
```

## Component Responsibilities

```
┌──────────────────┐
│ Next.js App      │
├──────────────────┤
│ - Page routing   │
│ - SEO/meta tags  │
│ - Loading UI     │
│ - Error handling │
│ - Canvas setup   │
└────────┬─────────┘
         │ owns
         ↓
┌──────────────────┐
│ Godot Loader     │
├──────────────────┤
│ - WASM init      │
│ - File loading   │
│ - Event bridge   │
│ - Main loop      │
│ - Audio context  │
└────────┬─────────┘
         │ calls
         ↓
┌──────────────────┐
│ Godot Engine     │
├──────────────────┤
│ - Rendering      │
│ - Physics        │
│ - Audio          │
│ - Input          │
│ - Scene system   │
└────────┬─────────┘
         │ runs
         ↓
┌──────────────────┐
│ Your Game        │
├──────────────────┤
│ - Scenes         │
│ - Scripts        │
│ - Assets         │
│ - Game logic     │
└──────────────────┘
```

## Security Model

```
Browser Security Boundaries
────────────────────────────

┌─────────────────────────────────────┐
│ Same-Origin Policy                   │
│ https://your-game.vercel.app        │
│                                      │
│ ┌─────────────────────────────────┐ │
│ │ Main Thread                     │ │
│ │ - Next.js app                   │ │
│ │ - DOM manipulation              │ │
│ │ - Godot loader                  │ │
│ └─────────────────────────────────┘ │
│                                      │
│ ┌─────────────────────────────────┐ │
│ │ Web Worker                      │ │
│ │ - Physics calculations          │ │
│ │ - Can access SharedArrayBuffer │ │
│ │ - No DOM access                 │ │
│ └─────────────────────────────────┘ │
│            ↕ (postMessage)           │
│ ┌─────────────────────────────────┐ │
│ │ WASM Sandbox                    │ │
│ │ - Isolated memory space         │ │
│ │ - No direct system access       │ │
│ │ - All I/O via Emscripten        │ │
│ └─────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘

Headers Required:
- Cross-Origin-Embedder-Policy: require-corp
  → Isolates origin from others
  
- Cross-Origin-Opener-Policy: same-origin
  → Prevents popup attacks
  
Together: Enable SharedArrayBuffer
```

## Development vs Production

```
Development (localhost:3000)
─────────────────────────────
- Next.js dev server with HMR
- Uncompressed files
- Source maps enabled
- Detailed error messages
- COOP/COEP may be missing
- No CDN caching

         vs

Production (vercel.app)
───────────────────────
- Static files pre-built
- Brotli/Gzip compression
- Source maps optional
- Production optimizations
- COOP/COEP headers set
- Global CDN caching
- Edge network routing
```

## Summary

This architecture provides:

✅ **Performance**: WASM near-native speed  
✅ **Security**: Browser sandbox + CORS isolation  
✅ **Scalability**: Vercel CDN global distribution  
✅ **Developer Experience**: Automated builds and deploys  
✅ **User Experience**: Fast loading, smooth gameplay  

All while keeping your Godot development workflow unchanged!

