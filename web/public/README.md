# Public Directory

This directory contains static assets served by Next.js.

## Structure

```
public/
├── godot/              # Exported Godot game files (auto-generated)
│   ├── aitherworks.wasm
│   ├── aitherworks.pck
│   ├── aitherworks.js
│   └── *.worker.js
└── vercel.json         # Vercel configuration
```

## Godot Export Files

The `godot/` directory is populated by running:

```bash
npm run build:godot
```

Or directly:

```bash
../scripts/export_web.sh
```

**Important**: These files are auto-generated and should not be committed to git. They are listed in `.gitignore`.

## Vercel Configuration

`vercel.json` configures headers required for WebAssembly with threading support:

- `Cross-Origin-Embedder-Policy: require-corp`
- `Cross-Origin-Opener-Policy: same-origin`

These headers enable `SharedArrayBuffer` which Godot uses for multithreading.

## Adding Static Assets

To add static assets (images, fonts, etc.) for the Next.js app:

1. Add files to this directory
2. Reference them from your components:
   ```tsx
   <img src="/my-image.png" alt="..." />
   ```

Note: Godot game assets should be in the Godot project, not here.

