# Exporting Data Files (YAML/JSON) to Web

## The Problem

Your game loads data files (YAML specs, JSON traces) at runtime using `FileAccess`:

```gdscript
var file_path := "res://data/specs/%s.yaml" % level_id
var file := FileAccess.open(file_path, FileAccess.READ)
```

**Godot only exports files it recognizes as "resources"** (`.tscn`, `.gd`, images, etc.). Plain text files like `.yaml` and `.json` are ignored by default.

## The Solution

Add these file types to the **include filter** in your export preset.

### Fixed in `export_presets.cfg`

```ini
[preset.0]
name="Web"
platform="Web"
export_filter="all_resources"
include_filter="*.yaml,*.json"  # ← Added this
exclude_filter=""
```

This tells Godot: "Export all resources AND also include any `.yaml` and `.json` files you find."

## How to Verify It Worked

### 1. Check PCK Size

After re-exporting:

```bash
ls -lh web/public/godot/aitherworks.pck
```

If YAML files are included, size should increase slightly (YAML files are small, so maybe only +100-500KB).

### 2. Test in Browser

```bash
cd web
npm run dev
```

Open the game and check console (F12) for errors like:
- `Cannot open file 'res://data/specs/...'` ❌ (means files missing)
- No errors ✅ (means files are loaded)

### 3. Manual PCK Inspection (Advanced)

If you have `godotpcktool` installed:

```bash
# List contents of PCK
godotpcktool -l web/public/godot/aitherworks.pck | grep yaml
```

Should see your YAML files listed.

## What Files Need to Be Exported

### Your Data Structure

```
data/
├── parts/           # 34 YAML files (part definitions)
├── specs/           # 19 YAML files (level specs)
└── traces/          # JSON files (ML traces)
```

All of these need to be in the PCK for the game to work.

## Common Issues

### Issue: "Cannot open file" Errors

**Cause**: Files not included in export

**Fix**:
1. Add to `include_filter` in `export_presets.cfg`
2. Re-export: `./scripts/export_web.sh`

### Issue: Files Load in Editor but Not in Web Build

**Cause**: Different file access methods

**Solution**: Always use `res://` paths:
```gdscript
# ✅ Good - works everywhere
FileAccess.open("res://data/specs/level.yaml", FileAccess.READ)

# ❌ Bad - won't work in exports
FileAccess.open("data/specs/level.yaml", FileAccess.READ)
```

### Issue: Large PCK File Size

**Cause**: Including too many files

**Solution**: Use `exclude_filter` to skip unnecessary files:
```ini
exclude_filter="*.md,*.txt,test_*"  # Exclude docs and test files
```

## File Types to Include

Common non-resource files that need explicit inclusion:

```ini
include_filter="*.yaml,*.json,*.csv,*.txt,*.xml,*.toml,*.ini,*.cfg"
```

Pick only what you need.

## Alternative: Convert to Resources

Instead of using `FileAccess`, you can import data files as Godot resources:

### Method 1: Custom Resource Importer

Create a resource importer plugin that converts YAML → GDScript Resource at import time. Then use:

```gdscript
var level_data = load("res://data/specs/level.yaml")  # Becomes a Resource
```

**Pros**:
- Guaranteed to be exported
- Faster loading (binary format)
- Type-safe

**Cons**:
- More complex setup
- Requires editor plugin

### Method 2: Embedded in Script

For small datasets, embed directly:

```gdscript
const LEVELS = {
    "level1": {
        "title": "First Steps",
        "allowed_parts": ["weight_wheel", "matrix_frame"]
    }
}
```

**Pros**:
- Always works
- Fast

**Cons**:
- Not data-driven
- Harder to edit

### Method 3: JSON as Resource

Godot can load JSON at runtime:

```gdscript
var json = JSON.new()
var file = FileAccess.open("res://data/level.json", FileAccess.READ)
var result = json.parse(file.get_as_text())
var data = json.data
```

Still needs `include_filter="*.json"`.

## Best Practice for Web Export

### Export Preset Structure

```ini
[preset.0]
name="Web"
platform="Web"

# Export all scenes, scripts, images, etc.
export_filter="all_resources"

# ALSO include these file types
include_filter="*.yaml,*.json"

# But skip these
exclude_filter="*.md,*.txt,test_*,example_*"

# Output
export_path="web/public/godot/aitherworks.html"
```

### File Organization

```
data/
├── specs/
│   ├── level_*.yaml          # ✅ Include
│   ├── example_*.yaml        # ⚠️ Maybe exclude (examples)
│   └── README.md             # ❌ Exclude (docs)
└── parts/
    ├── *.yaml                # ✅ Include
    └── template.yaml         # ⚠️ Maybe exclude (template)
```

## Debugging

### Check What's in Your PCK

```bash
# Install godotpcktool (if available)
# brew install godotpcktool  # or from GitHub

# List all files
godotpcktool -l web/public/godot/aitherworks.pck

# Filter for data files
godotpcktool -l web/public/godot/aitherworks.pck | grep -E '\.(yaml|json)'
```

### Test File Access

Create a test scene that tries to load each data file:

```gdscript
func _ready():
    test_file_access()

func test_file_access():
    var test_files = [
        "res://data/specs/example_puzzle.yaml",
        "res://data/parts/weight_wheel.yaml",
        "res://data/traces/intro_attention_gpt2_small.json"
    ]
    
    for path in test_files:
        if FileAccess.file_exists(path):
            print("✅ Found: ", path)
        else:
            print("❌ Missing: ", path)
```

Run in browser and check console.

## Summary

1. ✅ **Updated** `export_presets.cfg` to include `*.yaml,*.json`
2. ✅ **Re-export** the game: `./scripts/export_web.sh`
3. ✅ **Test** in browser to verify files load
4. ✅ **Check console** for "Cannot open file" errors

Your data files should now be included in the web export! 🎉

## Next Steps

After fixing this, you should also check:
- [ ] Font/emoji rendering (separate issue)
- [ ] Background images loading
- [ ] All asset paths are `res://` format
- [ ] No hardcoded local file paths

See `docs/deploy/GODOT_ASSETS_WEB.md` for asset loading issues.

