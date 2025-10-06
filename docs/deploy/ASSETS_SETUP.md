# Assets Setup for Web Deployment

## The Problem

The Next.js loading screen was missing the steampunk aesthetic - no background images, custom fonts, or icons from the Godot project.

## The Solution

Assets are copied from the Godot `assets/` directory to `web/public/assets/` and used in the loading screen.

## What Changed

### 1. Assets Copied

```
assets/ (Godot)           →  web/public/assets/ (Next.js)
├── backrounds/1/orig.png →  backgrounds/loading-bg.png
├── blueprint_bg.svg      →  blueprint-bg.svg
├── icons/*.svg           →  icons/*.svg
└── characters/*.svg      →  characters/*.svg
```

### 2. Updated Styling (`web/app/globals.css`)

**Background:**
- Blueprint pattern background
- Golden grid overlay
- Steampunk color scheme (#d4af37 gold, #2a2420 dark brown)

**Typography:**
- Georgia/Times New Roman serif fonts
- Golden text with glow effects
- Larger, more dramatic title

**Progress Bar:**
- Brass/bronze styling
- Gradient fill with glow
- Inset shadows for depth

**Loading Icon:**
- Animated rotating gear
- Golden glow effect

### 3. Updated Component (`web/app/page.tsx`)

Added:
- Title: "AItherworks"
- Animated gear icon
- Better visual hierarchy

## Usage

### Sync Assets After Changes

When you update assets in the Godot project:

```bash
./scripts/sync_assets.sh
git add web/public/assets/
git commit -m "Update web assets"
```

### Manual Copy

Or copy specific files:

```bash
cp assets/icons/gear.svg web/public/assets/icons/
```

## Asset Inventory

### Backgrounds

- `loading-bg.png` - Main loading screen background
- `alt-bg-1.png` - Alternative background (set 2)
- `alt-bg-2.png` - Alternative background (set 3)
- `blueprint-bg.svg` - Blueprint pattern overlay

### Icons

- `gear.svg` - Loading spinner (rotating)
- `manifold.svg` - For future use
- `pressure_gauge.svg` - For future use
- `steam_pipe.svg` - For future use
- `weight_dial.svg` - For future use
- `ui_continue.svg` - For future use
- `ui_new.svg` - For future use
- `ui_quit.svg` - For future use
- `ui_settings.svg` - For future use
- `ui_skip.svg` - For future use

### Characters

- `aether_sage.svg` - For future narrative scenes
- `apprentice_player.svg` - For future narrative scenes
- `master_cogwright.svg` - For future narrative scenes

## Steampunk Color Palette

```css
--brass: #d4af37;         /* Primary gold */
--brass-light: #f4e4c1;   /* Light gold */
--brass-dark: #b8941f;    /* Dark gold */
--bronze: #8b7355;        /* Bronze accents */
--leather: #2a2420;       /* Dark brown */
--parchment: #e8d4a0;     /* Text color */
--shadow: rgba(0,0,0,0.8);
```

## Customization

### Change Loading Icon

Edit `web/app/page.tsx`:

```tsx
<img 
  src="/assets/icons/your-icon.svg"  // ← Change this
  alt="Loading" 
  id="status-icon"
/>
```

### Change Background

Edit `web/app/globals.css`:

```css
body {
  background-image: url('/assets/backgrounds/alt-bg-1.png');
}
```

### Change Title

Edit `web/app/page.tsx`:

```tsx
<div id="status-title">Your Title Here</div>
```

### Add Loading Tips

Edit `web/app/page.tsx`:

```tsx
const tips = [
  "Building aetheric circuits...",
  "Calibrating pressure valves...",
  "Charging brass capacitors..."
]
const [tip, setTip] = useState(tips[0])

// In the UI:
<div id="status-notice">{status}</div>
<div style={{ fontSize: '14px', fontStyle: 'italic' }}>{tip}</div>
```

## Performance

Asset sizes:
- Icons (SVG): ~1-5 KB each
- Blueprint SVG: ~10 KB
- Background PNG: ~500 KB

Total: ~600 KB (acceptable for web)

Consider:
- WebP format for backgrounds (smaller)
- SVG optimization with SVGO
- Lazy loading for unused assets

## Git Handling

Assets are **committed to git**:
- `.gitignore` has `!/public/assets` to force inclusion
- Assets are deployed with the Next.js app
- No need to sync during Vercel build

## Future Enhancements

### Narrative Scenes

Use character SVGs for story moments:

```tsx
<img 
  src="/assets/characters/master_cogwright.svg"
  alt="Master Cogwright"
  style={{ width: '200px' }}
/>
<p>"Welcome to the workshop, apprentice..."</p>
```

### Dynamic Backgrounds

Rotate backgrounds based on game progress:

```tsx
const backgrounds = [
  '/assets/backgrounds/loading-bg.png',
  '/assets/backgrounds/alt-bg-1.png',
  '/assets/backgrounds/alt-bg-2.png'
]
const bgIndex = Math.floor(progress / 33)
```

### Loading Animation

Animate multiple gears:

```css
.gear-small {
  animation: spin 1.5s linear infinite;
}
.gear-large {
  animation: spin 3s linear infinite reverse;
}
```

## Troubleshooting

### Assets Not Loading

1. **Check file exists:**
   ```bash
   ls web/public/assets/icons/gear.svg
   ```

2. **Check path in code:**
   - Use `/assets/...` not `./assets/...`
   - Must start with `/` for Next.js public folder

3. **Clear browser cache:**
   - Hard refresh: Ctrl+Shift+R (Chrome)
   - Or: DevTools → Application → Clear Storage

### SVG Not Displaying

1. **Check SVG is valid:**
   - Open in browser directly
   - Check for XML errors

2. **Check SVG size:**
   - Ensure width/height or viewBox is set
   - Add explicit dimensions in CSS if needed

### Background Not Showing

1. **Check image path:**
   ```css
   background-image: url('/assets/blueprint-bg.svg');
   ```

2. **Check image loaded:**
   - Network tab in DevTools
   - Should see 200 status

## Summary

✅ Assets copied to `web/public/assets/`  
✅ Steampunk styling applied  
✅ Animated loading screen  
✅ Assets committed to git  
✅ Sync script available: `./scripts/sync_assets.sh`  

Your loading screen now has the full steampunk aesthetic! 🎩⚙️

