# Project TODO

## Gameplay/Data Flow
- [ ] Add `Steam Source` to palettes and tutorial; ensure it connects to `Signal Loom`.
- [ ] Add `Spyglass` inspection window trigger from node context menu or double‑click.
- [ ] Persist inspection window position; allow multiple spyglasses.
- [ ] Forward pass: visualize wire activity (pulse/tint) along GraphEdit connections.
- [ ] Backprop pass: visualize gradient flow in reverse with red hues.

## YAML/Specs
- [x] Fix SpecLoader to handle `key:` followed by lists (sequences).
- [ ] Validate all part/level YAMLs on startup; log readable errors.
- [ ] Normalize port keys across parts (`north/south` or `in/out`) and document.

## Parts/Simulation
- [x] Implement `WeightWheel` with multi‑spoke weights and SGD apply.
- [x] Implement `SteamSource` and data patterns.
- [x] Implement `Spyglass` and `InspectionWindow`.
- [ ] Add `AdderManifold`, `ActivationGate` functional scripts (sum / ReLU).
- [ ] Connect engine training loop to graph topology (not just demo paths).

## Workbench UI
- [ ] Align Component Drawers strictly to `allowed_parts` ordering from spec.
- [ ] Replace generic sliders/checkboxes with steampunk toggles/knobs.
- [ ] Make Inspector context‑aware: show properties of selected `PartNode`.
- [ ] Add per‑part editors (e.g., WeightWheel spokes/weights list with knobs).
- [ ] Fix initial anchors/offsets so layout is centered without manual offsets.

## Tutorial/UX
- [x] Level selection placeholder and gating (must select Act I L1, then Load).
- [ ] Tutorial: highlight dropdown, then Load; validate exact selection.
- [ ] Tutorial steps for placing `Steam Source → Signal Loom → Weight Wheel → Spyglass`.
- [ ] Show story panel messages in BBCode with proper sizes once font setup is final.

## Theming
- [ ] Create steampunk toggle switch (2‑state) control.
- [ ] Create rotary knob control (TextureProgress‑based) for values.
- [ ] Update `steampunk_theme.tres` to style GraphEdit wires, buttons, panels.

## Title/Backstory
- [ ] Ensure backstory scene uses large readable font and inline illustrations.
- [ ] Title screen: fix overlapping animation and clickable Settings.

## Stability/Logging
- [ ] Add DEBUG on PartNode creation (id, ports, instance class) [in code].
- [ ] Guard against missing `story.title`/`description` with safe fallbacks.

---

## Today’s Plan
1. Replace TopBar/Inspector controls with themed switches/knobs and wire them up.
2. Make Inspector context‑aware (selected node) and expose WeightWheel spokes.
3. Ensure drawers reflect `allowed_parts` order and include Steam Source/Spyglass.
4. Add right‑click “Inspect with Spyglass” to open inspection window.


