# Project TODO

## Gameplay/Data Flow
- [x] Add `Steam Source` to palettes and tutorial; ensure it connects to `Signal Loom`.
- [x] Add `Spyglass` inspection window trigger from node context menu or double‑click.
- [x] Persist inspection window position; allow multiple spyglasses.
- [x] Forward pass: visualize wire activity (pulse/tint) along GraphEdit connections.
- [x] Backprop pass: visualize gradient flow in reverse with red hues.

## YAML/Specs
- [x] Fix SpecLoader to handle `key:` followed by lists (sequences).
- [x] Validate all part/level YAMLs on startup; log readable errors.
- [ ] Normalize port keys across parts (`north/south` or `in/out`) and document.

## Parts/Simulation
- [x] Implement `WeightWheel` with multi‑spoke weights and SGD apply.
- [x] Implement `SteamSource` and data patterns.
- [x] Implement `Spyglass` and `InspectionWindow`.
- [x] Add `AdderManifold`, `ActivationGate` functional scripts (sum / ReLU).
- [x] Connect engine training loop to graph topology (not just demo paths).

## Workbench UI
- [x] Align Component Drawers strictly to `allowed_parts` ordering from spec.
- [ ] Replace generic sliders/checkboxes with steampunk toggles/knobs.
- [x] Make Inspector context‑aware: show properties of selected `PartNode`.
- [x] Add per‑part editors (e.g., WeightWheel spokes/weights list with knobs).
- [x] Fix initial anchors/offsets so layout is centered without manual offsets.

## Tutorial/UX
- [x] Level selection placeholder and gating (must select Act I L1, then Load).
- [ ] Tutorial: highlight dropdown, then Load; validate exact selection.
- [x] Tutorial steps for placing `Steam Source → Signal Loom → Weight Wheel → Spyglass`.
- [x] Show story panel messages in BBCode with proper sizes once font setup is final.

## Theming
- [x] Create steampunk toggle switch (2‑state) control.
- [x] Create rotary knob control (TextureProgress‑based) for values.
- [x] Update `steampunk_theme.tres` to style GraphEdit wires, buttons, panels.

## Title/Backstory
- [x] Ensure backstory scene uses large readable font and inline illustrations.
- [x] Title screen: fix overlapping animation and clickable Settings.

## Stability/Logging
- [x] Add DEBUG on PartNode creation (id, ports, instance class) [in code].
- [ ] Guard against missing `story.title`/`description` with safe fallbacks.
