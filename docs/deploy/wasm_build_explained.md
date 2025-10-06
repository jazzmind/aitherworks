# Understanding Godot → WASM Build Process

This document explains how Godot games are compiled to WebAssembly and what happens under the hood.

## Overview

When you export a Godot game to "Web", you're actually:

1. Compiling the **entire Godot engine** to WebAssembly
2. Packaging your **game resources** (scenes, scripts, assets) into a PCK file
3. Generating **JavaScript glue code** to load and run the WASM module
4. Creating **worker threads** for multithreading support

## The Build Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│ Godot Project (GDScript, Scenes, Assets)                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Export Process (Godot Editor or CLI)                        │
│ - Collects all resources                                    │
│ - Compiles scripts                                          │
│ - Packages into PCK file                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Export Templates (Pre-compiled Godot Engine)                │
│ - WASM binary of Godot engine                               │
│ - JavaScript loader                                         │
│ - Web workers                                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Output Files                                                 │
│ ├── aitherworks.html      (Entry point)                     │
│ ├── aitherworks.js        (Engine loader)                   │
│ ├── aitherworks.wasm      (Godot engine ~30MB)              │
│ ├── aitherworks.pck       (Your game data)                  │
│ ├── aitherworks.worker.js (Web Worker)                      │
│ └── aitherworks.audio.worklet.js (Audio)                    │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. WASM Module (`aitherworks.wasm`)

This is the **entire Godot engine** compiled to WebAssembly using Emscripten:

- **Size**: ~25-40 MB (varies by Godot version and enabled features)
- **Contains**:
  - Rendering engine (Vulkan → WebGL/WebGPU)
  - Physics engine (Godot Physics or Jolt)
  - Audio engine
  - Scene system
  - GDScript VM
  - All core Godot systems

The WASM module is **stateless** and loads your game from the PCK file.

### 2. PCK File (`aitherworks.pck`)

The **packed game resources**:

- **Format**: Godot's proprietary archive format
- **Contains**:
  - All `.tscn` scene files (compiled to binary)
  - All `.gd` script files (bytecode compiled)
  - All assets (images, audio, fonts, etc.)
  - Resource import metadata

Think of it as a ZIP file optimized for Godot.

### 3. JavaScript Loader (`aitherworks.js`)

The **glue code** between browser and WASM:

```javascript
// Simplified version of what it does:
class Engine {
  constructor(config) {
    this.canvas = config.canvas
    this.onProgress = config.onProgress
  }
  
  async startGame({ executable, mainPack }) {
    // 1. Load WASM module
    const module = await loadWASM(executable + '.wasm')
    
    // 2. Initialize Godot runtime
    await this.initializeRuntime(module)
    
    // 3. Mount virtual filesystem
    await this.mountPCK(mainPack)
    
    // 4. Start main loop
    this.startMainLoop()
  }
}
```

Key responsibilities:
- Load and instantiate WASM
- Set up canvas and WebGL context
- Create virtual filesystem (Emscripten FS)
- Handle browser events (resize, input, etc.)
- Manage audio context
- Run the game loop

### 4. Web Workers (`aitherworks.worker.js`)

Enable **multithreading** via SharedArrayBuffer:

- Godot can use multiple threads for physics, rendering prep, etc.
- Requires `Cross-Origin-Embedder-Policy: require-corp` header
- Requires `Cross-Origin-Opener-Policy: same-origin` header
- Falls back to single-threaded if headers missing

## The Compilation Process

### What Godot Does

When you run `godot --export-release "Web" output.html`:

1. **Read project.godot**: Determines game settings, entry scene, etc.
2. **Read export_presets.cfg**: Gets web-specific export options
3. **Collect resources**: Scans `res://` for all used files
4. **Compile scripts**: GDScript → bytecode
5. **Pack resources**: Creates the PCK file
6. **Copy templates**: Uses pre-compiled WASM engine
7. **Generate HTML**: Creates entry point with correct paths

### What You Don't Need to Do

❌ You **don't** compile Godot engine yourself  
❌ You **don't** need Emscripten installed  
❌ You **don't** need a C++ compiler  
❌ You **don't** modify WASM files  

✅ You **only** export using Godot's built-in exporter  
✅ Godot uses **pre-compiled templates** (downloaded separately)

## Export Templates Explained

### What Are They?

Export templates are **pre-compiled versions** of the Godot engine for each platform.

For Web, they include:
- `webassembly_release.zip` - Optimized WASM build
- `webassembly_debug.zip` - Debug WASM build (with symbols)

### Where They Come From

Built by the Godot team using:
- Emscripten compiler
- Godot engine source code
- Optimized build flags

### Where They're Stored

**On macOS**:
```
~/Library/Application Support/Godot/export_templates/4.x.stable/
```

**On Linux**:
```
~/.local/share/godot/export_templates/4.x.stable/
```

**On Windows**:
```
%APPDATA%\Godot\export_templates\4.x.stable\
```

### Version Matching

Templates **must match** your Godot version:
- Godot 4.2.1 → Templates 4.2.1
- Godot 4.3.0 → Templates 4.3.0

Mismatch = export fails or crashes.

## Build Optimizations

### Release vs Debug

**Debug Build**:
- Includes debug symbols
- Larger file size (~50MB)
- Slower execution
- Better error messages
- Useful for development

**Release Build**:
- Stripped symbols
- Smaller size (~30MB)
- Faster execution
- Minimal error info
- Use for production

### Compression

The WASM file can be compressed:

1. **Brotli** (best compression):
   ```
   aitherworks.wasm.br (15-20MB)
   ```
   
2. **Gzip**:
   ```
   aitherworks.wasm.gz (20-25MB)
   ```

Modern servers (like Vercel) handle this automatically.

### Texture Compression

Enable in export preset:
```ini
vram_texture_compression/for_desktop=true
```

Uses **WebGL compressed formats**:
- DXT1/DXT5 (desktop browsers)
- ASTC (mobile browsers)
- Fallback to PNG if unsupported

Reduces PCK size and GPU memory usage.

## How It Runs in the Browser

### 1. Page Load

```html
<script src="aitherworks.js"></script>
<canvas id="canvas"></canvas>
<script>
  const engine = new Engine({ canvas: document.getElementById('canvas') })
  engine.startGame({ executable: 'aitherworks', mainPack: 'aitherworks.pck' })
</script>
```

### 2. Engine Initialization

1. Browser downloads `aitherworks.js`
2. JavaScript loads `aitherworks.wasm`
3. Browser compiles WASM to native code
4. Emscripten runtime initializes
5. Virtual filesystem mounted
6. PCK file loaded into virtual FS

### 3. Game Loop

```
┌─────────────────────────────────────┐
│ Browser RequestAnimationFrame       │
│   ↓                                 │
│ JavaScript callback                 │
│   ↓                                 │
│ Call into WASM (Godot _process)     │
│   ↓                                 │
│ WASM executes game logic            │
│   ↓                                 │
│ WASM renders to WebGL               │
│   ↓                                 │
│ Browser composites to screen        │
│   ↓                                 │
│ Repeat at 60 FPS                    │
└─────────────────────────────────────┘
```

### 4. Input Handling

```
User clicks mouse
  ↓
Browser MouseEvent
  ↓
JavaScript event handler
  ↓
Pass to WASM via callback
  ↓
Godot InputEvent system
  ↓
Your GDScript _input() function
```

## Performance Characteristics

### Startup Time

- **WASM compilation**: 1-3 seconds (browser caches after first load)
- **PCK loading**: 0.5-2 seconds (depends on size)
- **Engine init**: 0.5-1 second
- **Total**: 2-6 seconds for first load

### Runtime Performance

Compared to native Godot:
- **Physics**: 70-90% of native speed
- **Rendering**: 80-95% (WebGL vs Vulkan overhead)
- **Script execution**: 60-80% (WASM vs native)
- **Memory**: 1.2-1.5x more (WASM overhead)

Good enough for most 2D games!

### Memory Usage

- **WASM heap**: Starts at 16MB, can grow to 2GB
- **GPU memory**: Similar to native
- **Browser overhead**: ~50-100MB

Total: Your game + 100-200MB overhead

## Debugging

### Browser Console

Use `console.log()` equivalent in Godot:
```gdscript
print("Debug message")  # Shows in browser console
```

### Source Maps

Debug builds include source maps for better stack traces.

### Performance Profiling

Use Chrome DevTools:
1. Open DevTools (F12)
2. Performance tab
3. Record while playing
4. Analyze WASM execution time

## Common Issues and Solutions

### "SharedArrayBuffer is not defined"

**Cause**: Missing COOP/COEP headers

**Solution**: Deploy to a server that sets:
```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

Vercel handles this automatically with our config.

### "Out of memory"

**Cause**: WASM heap exhausted

**Solution**: 
- Reduce texture sizes
- Use streaming for large assets
- Enable texture compression

### Slow loading

**Cause**: Large WASM/PCK files

**Solution**:
- Use release build, not debug
- Enable compression (Brotli/Gzip)
- Compress textures
- Use CDN (Vercel provides this)

## Advanced: Custom HTML Shell

You can customize the HTML wrapper:

1. Export with default shell
2. Copy `aitherworks.html` to `custom_shell.html`
3. Modify HTML/CSS/JS
4. Set in export preset:
   ```ini
   html/custom_html_shell="custom_shell.html"
   ```

We use Next.js instead for better control and modern tooling.

## Further Reading

- [Godot Web Export Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Emscripten Documentation](https://emscripten.org/)
- [WebAssembly Spec](https://webassembly.org/)
- [SharedArrayBuffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer)

---

This should give you a solid understanding of how Godot games are built for the web. The key takeaway: **you're compiling the engine, not writing WASM yourself**.

