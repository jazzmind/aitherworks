# CLAUDE AI Guidelines for AItherworks

This document provides a set of instructions for engineers and writers using **Claude** (Anthropic’s large language model) to contribute to the AItherworks project.  Please adhere to these guidelines when asking Claude to generate code, documentation or content so that the output integrates smoothly and respects our design principles.

## 📐 Architectural Constraints

* **Use Godot 4.3+** – all code should target the Godot 4.3+ API. When generating GDScript, follow idiomatic Godot patterns (signal connections, node hierarchies, `_ready` and `_process` functions, typed variables).
* **Data‑driven pipeline** – puzzle logic and part definitions should be expressed in YAML under `data/specs/` and `data/parts/`. Claude may generate these specs, but avoid embedding gameplay constants directly into scripts when they belong in a spec.
  - **YAML Parsing**: Use gdyaml library or JSON preprocessor (see `specs/001-go-through-the/research.md`)
  - **Schema Validation**: All YAML must validate against schemas in `specs/001-go-through-the/contracts/`
* **Editor plugin** – generation of scenes from YAML occurs in the `steamfitter` plugin. When extending or modifying this plugin, keep the API stable and document changes in code comments.
  - Plugin components: `spec_loader.gd`, `scene_generator.gd`, `validators/`
* **Port Type System** – Parts connect via typed ports (8 types: scalar, vector, matrix, tensor, attention_weights, logits, gradient, signal). Validate type compatibility before connecting.
* **Performance Budget** – Maintain 60 FPS; simulation loops must complete in <16ms (100ms for <20 parts). Profile early and often.
* **Cross‑platform** – Phase 1 targets desktop (Windows/Mac/Linux) and web (WASM). Mobile deferred to Phase 2. Avoid platform‑specific code. Godot handles most differences; if you need custom behaviour, guard it appropriately (e.g., detect `OS.has_feature("web")`).

## 🧾 Style and Format

1. **Consistency** – follow the existing file naming conventions (snake_case for files, UpperCamelCase for classes).  Use four spaces for indentation in GDScript.  Write clear, descriptive comments for complex sections.
2. **Minimal placeholders** – if Claude produces skeleton code or data, leave clear `TODO` comments indicating what remains to be implemented.  Do not insert spurious placeholder code that may confuse future work.
3. **YAML clarity** – when producing YAML specs, include helpful descriptions at the top of each file explaining what the puzzle does, any special mechanics, and the expected outcome.  Use nested dictionaries rather than long, flat structures.
4. **Narrative integration** – when generating story content or dialogues, stay true to the steampunk theme.  Narration should mirror the underlying AI concept while embedding it into the Aetherford universe.

## ⚠️ Safety and Ethical Considerations

Claude should **never** write or alter files outside of the `aitherworks/` directory, nor should it make network requests or include unvetted external content.  If asked to add assets or third‑party code, ensure that the license is compatible with MIT and avoid including copyrighted material without permission.

When generating tutorials or explanatory content, avoid hallucinating facts about the Godot engine or machine learning.  Where necessary, cite sources or suggest further reading.

## 🧪 Testing Requirements

* **GUT Framework** – Use Godot Unit Test (GUT) for all tests. Place in `tests/unit/`, `tests/integration/`, `tests/validation/`.
* **Test-First for Parts** – Each of 33 parts requires unit tests before implementation (behavior, ports, parameter updates).
* **Integration Tests** – Each Act I level needs integration test (place parts, train, win condition).
* **Schema Validation Tests** – Validate all 28 level YAMLs and 33 part YAMLs load correctly.

## 🎓 Pedagogical Accuracy

* **Progressive Difficulty** – Acts I-II use metaphorical/intuitive explanations. Acts III-IV introduce technically accurate fundamentals. Acts V-VI teach research-level nuances.
* **Steampunk Lexicon** – Use terms from `docs/lexicon.md`. E.g., "Weight Wheel" (not "linear layer"), "Looking-Glass Array" (not "attention head").
* **No Shortcuts** – Simulation must mirror real neural network math. No fake/mock AI behavior.

## 📁 Project Structure Reference

```
aitherworks/
├── addons/steamfitter/       # Editor plugin (YAML import, validation)
├── game/
│   ├── parts/                # 33 part scenes + scripts (e.g., weight_wheel.tscn/.gd)
│   ├── sim/                  # Simulation engine (engine.gd, graph.gd, trainer.gd)
│   └── ui/                   # UI components (workbench.tscn, spyglass.tscn)
├── data/
│   ├── specs/                # 28 level YAMLs (act_I_l1_dawn_in_dock_ward.yaml)
│   ├── parts/                # 33 part YAMLs (weight_wheel.yaml)
│   └── traces/               # Transformer traces (intro_attention_gpt2_small.json)
├── tests/                    # GUT tests (unit/, integration/, validation/)
└── specs/001-go-through-the/ # Implementation plan, schemas, research
    ├── research.md           # Technical decisions
    ├── data-model.md         # Entity definitions
    ├── contracts/            # YAML/JSON schemas
    └── quickstart.md         # Manual testing guide
```

## ✅ Example Prompt to Claude

```
You are working on the AItherworks project, a steampunk puzzle game built with Godot 4.3+. Using GDScript, please implement the "Weight Wheel" part following these specs:

1. Scene: `game/parts/weight_wheel.tscn`
2. Script: `game/parts/weight_wheel.gd`
3. Ports: `in_north` (vector input), `out_south` (vector output), `gradient_in` (gradient input for training)
4. Behavior: Multiply input vector by adjustable spoke weights. Spokes default to 3, trainable via SGD.
5. Validate against schema: `specs/001-go-through-the/contracts/part_schema.yaml`
6. Follow port type system (8 types defined in research.md)
7. Maintain steampunk theme (brass gears, Victorian aesthetic)
8. Add unit test: `tests/unit/test_weight_wheel.gd` (GUT framework)

Reference data model (`specs/001-go-through-the/data-model.md`) for part structure. Leave TODO comments for integration with trainer.gd.
```

This kind of clear, detailed prompt with schema references gives Claude all the information it needs to generate compliant output.

## 📚 Recent Changes (Last 3 Features)

### Feature 001: Complete Core System (2025-10-03)
- Added: Port type system (8 types), YAML schemas, quickstart guide
- Decided: gdyaml parser, GUT testing, convergence detection with adaptive hints
- Phase: Planning complete, ready for implementation

By following these guidelines and referencing the implementation plan, contributions via Claude will align with the AItherworks design and maintain code quality across the project.