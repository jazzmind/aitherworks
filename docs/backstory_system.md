# Enhanced Backstory System

The AItherworks backstory system has been enhanced with parallax backgrounds and Zelda-style JRPG text presentation, making it reusable for every story chapter.

## Features

- **Parallax Backgrounds**: Multiple background layers move at different speeds for depth
- **Chapter-Specific Content**: Each chapter can have its own background and story content
- **Zelda-Style Presentation**: Large, centered text in a semi-transparent card
- **Reusable**: Same scene can be used for all chapters by setting the chapter number
- **Typewriter Effect**: Text appears gradually with a classic RPG feel

## Background Structure

Backgrounds are organized in the `assets/backrounds/` directory:

```
assets/backrounds/
├── 1/          # Chapter 1 backgrounds
│   ├── 1.png   # Foreground layer (fastest parallax)
│   ├── 2.png   # Mid-ground layer (medium parallax)
│   ├── 3.png   # Background layer (slow parallax)
│   ├── 4.png   # Sky/atmosphere layer (slowest parallax)
│   ├── orig.png      # Fallback single background
│   └── origbig.png   # High-resolution version
├── 2/          # Chapter 2 backgrounds
│   ├── 1.png
│   ├── 2.png
│   ├── 3.png
│   ├── 4.png
│   └── orig.png
└── ...
```

## Usage

### Basic Chapter Display

```gdscript
# Show backstory for a specific chapter
func show_chapter(chapter_number: int):
    get_tree().change_scene_to_file("res://game/ui/backstory_scene.tscn")
    
    # Wait for scene to be ready
    await get_tree().process_frame
    
    # Set the chapter (this loads backgrounds and content)
    var backstory_scene = get_tree().current_scene
    if backstory_scene.has_method("set_chapter"):
        backstory_scene.set_chapter(chapter_number)
```

### Using the Helper Script

```gdscript
# Load the helper
var backstory_helper = preload("res://game/ui/backstory_transition.gd").new()

# Show specific acts
backstory_helper.show_act_2_backstory()
backstory_helper.show_act_3_backstory()
backstory_helper.show_chapter_backstory(4)
```

### Content Loading

The system automatically tries to load content in this order:

1. **Chapter-specific content**: `docs/act-I.md`, `docs/act-II.md`, etc.
2. **Fallback content**: `docs/backstory.md`
3. **Generated content**: If no files exist, generates a chapter-specific story

## Customization

### Adding New Chapters

1. Create background images in `assets/backrounds/[chapter_number]/`
2. Add story content in `docs/act-[RomanNumeral].md`
3. Use `set_chapter(chapter_number)` to display

### Modifying Parallax Speeds

Edit the `parallax_speeds` array in `backstory_scene.gd`:

```gdscript
var parallax_speeds := [0.1, 0.05, 0.02, 0.01]  # Different speeds for each layer
```

### Styling the Story Card

The story card appearance is controlled by the `StyleBoxFlat` resource in the scene file. Modify:
- Background color and transparency
- Border thickness and color
- Corner radius
- Shadow effects

## Technical Details

### Background Loading

- Automatically detects available background layers (1.png, 2.png, 3.png, 4.png)
- Falls back to orig.png if no numbered layers exist
- Creates TextureRect nodes dynamically for each layer

### Parallax Effect

- Runs at 60 FPS for smooth movement
- Each layer moves at a different speed
- Loops every 100 pixels for seamless scrolling
- Uses `fmod()` for efficient looping

### Text Rendering

- BBCode enabled for rich formatting
- Typewriter effect reveals text gradually
- Auto-scrolls to keep text visible
- Supports markdown conversion with steampunk styling

## Example Integration

```gdscript
# In your level completion script
func on_level_complete():
    # Show next chapter's backstory
    var next_chapter = current_chapter + 1
    show_chapter_backstory(next_chapter)

# In your main menu
func on_story_button_pressed():
    show_chapter_backstory(1)  # Show intro story
```

## File Dependencies

- **Main Scene**: `game/ui/backstory_scene.tscn`
- **Script**: `game/ui/backstory_scene.gd`
- **Helper**: `game/ui/backstory_transition.gd`
- **Backgrounds**: `assets/backrounds/[chapter]/[layer].png`
- **Content**: `docs/act-[I-VI].md`

This system provides a cinematic, engaging way to present story content while maintaining the steampunk aesthetic of AItherworks.
