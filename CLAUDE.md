# CLAUDE AI Guidelines for Signalworks

This document provides a set of instructions for engineers and writers using **Claude** (Anthropic’s large language model) to contribute to the Signalworks project.  Please adhere to these guidelines when asking Claude to generate code, documentation or content so that the output integrates smoothly and respects our design principles.

## 📐 Architectural Constraints

* **Use Godot 4** – all code should target the Godot 4.x API.  When generating GDScript, follow idiomatic Godot patterns (signal connections, node hierarchies, `_ready` and `_process` functions, etc.).
* **Data‑driven pipeline** – puzzle logic and part definitions should be expressed in YAML under `data/specs/` and `data/parts/`.  Claude may generate these specs, but avoid embedding gameplay constants directly into scripts when they belong in a spec.
* **Editor plugin** – generation of scenes from YAML occurs in the `steamfitter` plugin.  When extending or modifying this plugin, keep the API stable and document changes in code comments.
* **Cross‑platform** – avoid platform‑specific code.  Godot handles most differences for you; if you need custom behaviour, guard it appropriately (e.g., detect `OS.has_feature("web")`).

## 🧾 Style and Format

1. **Consistency** – follow the existing file naming conventions (snake_case for files, UpperCamelCase for classes).  Use four spaces for indentation in GDScript.  Write clear, descriptive comments for complex sections.
2. **Minimal placeholders** – if Claude produces skeleton code or data, leave clear `TODO` comments indicating what remains to be implemented.  Do not insert spurious placeholder code that may confuse future work.
3. **YAML clarity** – when producing YAML specs, include helpful descriptions at the top of each file explaining what the puzzle does, any special mechanics, and the expected outcome.  Use nested dictionaries rather than long, flat structures.
4. **Narrative integration** – when generating story content or dialogues, stay true to the steampunk theme.  Narration should mirror the underlying AI concept while embedding it into the Aetherford universe.

## ⚠️ Safety and Ethical Considerations

Claude should **never** write or alter files outside of the `signalworks/` directory, nor should it make network requests or include unvetted external content.  If asked to add assets or third‑party code, ensure that the license is compatible with MIT and avoid including copyrighted material without permission.

When generating tutorials or explanatory content, avoid hallucinating facts about the Godot engine or machine learning.  Where necessary, cite sources or suggest further reading.

## ✅ Example Prompt to Claude

```
You are working on the Signalworks project, a steampunk puzzle game built with Godot 4.  Using GDScript, please implement a new part called "GearSwitch".  It should have two states (on/off), emit a custom signal when toggled, and visually change its sprite frame accordingly.  Follow the repository naming conventions and file structure.  Place the scene and script into `game/parts/gear_switch.tscn` and `game/parts/gear_switch.gd` respectively.  Leave a TODO comment for integration into the simulation layer.
```

This kind of clear, concise prompt gives Claude all the information it needs to generate meaningful output without overstepping project boundaries.

By following these guidelines, contributions via Claude will align with the Signalworks design and maintain code quality across the project.