# Godot Assets Not Loading in Web Build

## The Problem

When the Godot game runs in the browser:
- Background images don't show
- Emoji/Unicode characters show as blocks (□)
- Icons missing from UI

This is **NOT** a Next.js issue - the Godot game itself isn't loading its assets correctly in the web build.

## Common Causes

### 1. Assets Not Imported

**Check**: Look for `.import` files next to your assets
```bash
ls assets/icons/*.import
```

If missing:
1. Open project in Godot Editor
2. Let it reimport assets
3. Check Project → Project Settings → Import Defaults

### 2. Font Doesn't Support Emoji

Web builds use a different text rendering system. System emoji fonts aren't available.

**Solution**: Use image-based icons or web-compatible fonts

### 3. Resource Paths

Godot uses `res://` protocol which works in editor but might have issues in web builds.

## Solutions

### Fix 1: Verify Assets in Export

1. Open Godot Editor
2. Project → Export
3. Click "Web" preset
4. Check "Resources" tab
5. Ensure all assets are listed

### Fix 2: Test Export Locally

```bash
# Export the game
./scripts/export_web.sh

# Start a simple HTTP server
cd web/public/godot
python3 -m http.server 8000

# Open in browser
open http://localhost:8000/index.html
```

Check browser console (F12) for errors like:
- `Failed to load resource`
- `404 Not Found`
- Font warnings

### Fix 3: Replace Emoji with Images

Instead of unicode emoji in labels/text:

**Before** (in Godot scene):
```
Label.text = "⚙️ Settings"
```

**After**:
```
HBoxContainer:
  - TextureRect (gear icon)
  - Label.text = "Settings"
```

### Fix 4: Embed Font with Emoji Support

1. Download a font with emoji support (e.g., Noto Color Emoji)
2. Add to Godot project
3. In theme, use this font for labels

**Or use SVG icons instead**:
```gdscript
# Load icon dynamically
var icon = load("res://assets/icons/gear.svg")
$IconTexture.texture = icon
```

### Fix 5: Check Console Output

When game runs in browser:

1. Open DevTools (F12)
2. Check Console tab for errors
3. Look for missing resource messages

Common errors:
```
ERROR: Failed to open PCK file
ERROR: Cannot open file 'res://assets/...'
ERROR: Failed to load resource
```

## Debugging Steps

### 1. Verify PCK Contents

The `.pck` file should contain all game assets. Check size:

```bash
ls -lh web/public/godot/aitherworks.pck
# Should be several MB if assets are included
```

If size is very small (<1MB), assets weren't packed.

### 2. Check Export Filter

In `export_presets.cfg`:

```ini
export_filter="all_resources"  # ✓ Include everything
# NOT: export_filter="resources"  # ✗ Only referenced resources
```

### 3. Force Reimport

In Godot Editor:
1. Select `assets` folder in FileSystem
2. Right-click → Reimport
3. Wait for reimport to complete
4. Export again

### 4. Check for Missing Dependencies

Some assets might reference other assets:
- Scenes reference textures
- Materials reference shaders
- Fonts reference font files

Ensure all dependencies are in the project.

## Web-Specific Limitations

### Fonts

**Issue**: System fonts aren't available in web builds

**Solution**:
- Embed custom fonts in project
- Use DynamicFont with `.ttf`/`.otf` files
- Avoid relying on system emoji fonts

### Large Textures

**Issue**: WebGL has texture size limits (usually 4096x4096)

**Solution**:
- Compress textures for web
- Enable `vram_texture_compression/for_desktop=true`
- Use smaller texture sizes

### Audio Formats

**Issue**: Some audio formats aren't supported in browsers

**Solution**:
- Use OGG Vorbis for music
- Use WAV for short sound effects
- Avoid MP3 (patent/licensing issues)

## Quick Fixes

### For Missing Icons

Replace emoji text with SVG icons loaded as textures:

```gdscript
# In your UI script
@onready var icon = $IconTexture

func _ready():
    # Load SVG as texture
    icon.texture = load("res://assets/icons/gear.svg")
```

### For Missing Backgrounds

Ensure background textures are set in scene:

```gdscript
@onready var bg = $Background

func _ready():
    # Explicitly load background
    var texture = load("res://assets/backrounds/1/orig.png")
    bg.texture = texture
```

### For Missing Fonts

Create a fallback font:

```gdscript
func _ready():
    if not $Label.get_theme_font("font"):
        # Load embedded font
        var font = load("res://assets/fonts/your_font.ttf")
        $Label.add_theme_font_override("font", font)
```

## Testing Checklist

After making changes:

- [ ] Re-export: `./scripts/export_web.sh`
- [ ] Check PCK size (should include assets)
- [ ] Test in browser: `npm run dev`
- [ ] Check browser console for errors
- [ ] Verify backgrounds load
- [ ] Verify icons/emoji display
- [ ] Test on different browsers

## Common Export Issues

### "Failed to open PCK file"

**Cause**: PCK file path is wrong or file is corrupted

**Fix**:
```bash
# Clean and re-export
rm web/public/godot/*
./scripts/export_web.sh
```

### "Cannot open file 'res://...'"

**Cause**: Asset path is wrong or asset not included in export

**Fix**:
1. Check asset exists in FileSystem dock
2. Verify path spelling (case-sensitive!)
3. Re-export with `all_resources` filter

### "WebGL: INVALID_VALUE"

**Cause**: Texture too large or invalid format

**Fix**:
- Enable texture compression in export preset
- Resize large textures to ≤2048x2048
- Use PNG/WebP instead of exotic formats

## Pro Tips

### 1. Use Web-Safe Assets

- SVG for icons (scalable, small file size)
- PNG for backgrounds (widely supported)
- OGG for audio (best browser support)

### 2. Test Early, Test Often

Export to web frequently during development to catch issues early.

### 3. Use Built-in Icons

Godot has built-in editor icons that work well in web builds:

```gdscript
# Use Godot's built-in icons
get_theme_icon("Folder", "EditorIcons")
```

### 4. Optimize for Web

- Compress textures
- Reduce asset sizes
- Use streaming for large resources

## Still Having Issues?

1. **Check the browser console** - errors will show there
2. **Test with a minimal scene** - create a simple test scene with one background
3. **Compare working vs broken** - see what's different
4. **Ask in Godot forums** - web export issues are common

## Next Steps

1. Open browser DevTools (F12)
2. Go to Console tab
3. Reload the game
4. Copy any error messages
5. Check the Network tab to see which resources fail to load

Share the console errors for more specific help!

