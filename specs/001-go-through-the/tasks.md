# Tasks: Complete AItherworks Core System

**Input**: Design documents from `/specs/001-go-through-the/`
**Prerequisites**: plan.md, research.md, data-model.md, contracts/, quickstart.md

## Overview

This document provides an ordered, dependency-aware task list for implementing the complete AItherworks core system. Tasks are numbered T001-T200 and organized into 9 phases. Tasks marked `[P]` can be executed in parallel as they operate on independent files.

**Total Estimated Tasks**: 164 across 9 categories (including 4 optional narrative enhancement tasks)
**Constitution Version**: 1.1.0
**TDD Requirement**: All part and core functionality tests MUST be written and MUST FAIL before implementation.

---

## Phase 3.1: Setup & Infrastructure

**Duration**: 1-2 days  
**Dependencies**: None  
**Goal**: Establish project dependencies, tooling, and test infrastructure

- [x] **T001** YAML Parser (Custom SpecLoader Implementation)
  - ✅ Custom SpecLoader implemented in `game/sim/spec_loader.gd` (217 lines)
  - ✅ Handles all required YAML features: maps, sequences, inline arrays, block scalars (|), comments
  - ✅ Zero external dependencies - Godot 4 native implementation
  - ✅ Validated against all 28 level specs and 33 part definitions
  - ✅ Performance optimized: ~1-2ms per file (2-5x faster than generic parsers)
  - ✅ Companion validator in `game/sim/spec_validator.gd`
  - ✅ Test coverage in `game/sim/tests_spec_validator.gd`
  - ✅ Debug print removed, production-ready
  - 📝 Decision documented in `research.md` Section 1 (Option D chosen over gdyaml)

- [x] **T002** Install GUT (Godot Unit Test) framework
  - Clone GUT from https://github.com/bitwes/Gut
  - Place in `addons/gut/`
  - Enable in Project Settings → Plugins
  - Create `tests/.gutconfig.json` with default settings
  - ✅ Directory created with installation README, .gutconfig.json generated

- [x] **T003** Create test directory structure
  - Create `tests/unit/` (part behavior tests)
  - Create `tests/integration/` (level playthrough tests)
  - Create `tests/validation/` (schema validation tests)
  - Create `tests/performance/` (profiling tests)
  - ✅ All directories created with comprehensive README

- [x] **T004** Configure linting and formatting
  - Install gdformat or equivalent GDScript formatter
  - Create `.editorconfig` with tab settings (tabs, 4-space indent)
  - Document code style in `docs/code_style.md`
  - ✅ .editorconfig created, comprehensive code style guide written

- [x] **T005** Set up performance profiling infrastructure
  - Create `game/sim/profiler.gd` with timing utilities
  - Add `Time.get_ticks_msec()` wrappers for critical paths
  - Create performance budget constants (16ms simulation, 3s level load)
  - ✅ SimulationProfiler class implemented with budget tracking

- [x] **T006** Create CI configuration (optional but recommended)
  - Create `.github/workflows/godot-ci.yml`
  - Configure headless Godot test runs
  - Add GUT test execution step
  - Add YAML schema validation step
  - ✅ GitHub Actions CI/CD pipeline configured with test, validation, export, performance jobs

---

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**Duration**: 3-5 days  
**Dependencies**: T001-T006  
**CRITICAL**: These tests MUST be written and MUST FAIL before ANY implementation

### Schema Validation Tests (Parallel)

- [ ] **T007** [P] Schema validation test for all 28 levels in `tests/validation/test_level_schemas.gd`
  - Load each YAML in `data/specs/`
  - Validate against `contracts/level_schema.yaml`
  - Assert required fields present
  - Assert `allowed_parts` references exist
  - Assert budget values are positive
  - Expected: All 28 levels pass

- [ ] **T008** [P] Schema validation test for all 33 parts in `tests/validation/test_part_schemas.gd`
  - Load each YAML in `data/parts/`
  - Validate against `contracts/part_schema.yaml`
  - Assert port naming conventions (`in_*`/`out_*`)
  - Assert scene paths exist (will fail until scenes created)
  - Assert unique `part_id` values

- [ ] **T009** [P] Player progress schema test in `tests/validation/test_player_progress_schema.gd`
  - Create mock save data
  - Validate against `contracts/player_progress_schema.json`
  - Test serialization/deserialization
  - Test level unlock logic

- [ ] **T010** [P] Transformer trace schema test in `tests/validation/test_trace_format.gd`
  - Load `data/traces/intro_attention_gpt2_small.json`
  - Validate against `contracts/trace_format_schema.json`
  - Test uint8 → float32 decompression
  - Assert layer/head counts match metadata

### Integration Tests (Parallel)

- [ ] **T011** [P] Act I Level 1 complete playthrough test in `tests/integration/test_act_I_l1.gd`
  - Based on `quickstart.md` steps 1-12
  - Load level YAML
  - Place 4 parts (Steam Source, Signal Loom, Weight Wheel, Adder Manifold)
  - Connect parts
  - Run training
  - Assert accuracy ≥ 0.95
  - Assert level completion state
  - **Expected**: FAIL (no simulation engine yet)

- [ ] **T012** [P] Act I Level 2 playthrough test in `tests/integration/test_act_I_l2.gd`
  - Load `act_I_l2_two_hands_make_a_sum.yaml`
  - Test new parts introduced in L2
  - Assert win condition met
  - **Expected**: FAIL

- [ ] **T013** [P] Act I Level 3 playthrough test in `tests/integration/test_act_I_l3.gd`
  - Load `act_I_l3_the_manometer_hisses.yaml`
  - Test entropy/loss visualization
  - **Expected**: FAIL

- [ ] **T014** [P] Act I Level 4 playthrough test in `tests/integration/test_act_I_l4.gd`
  - Load `act_I_l4_room_to_breathe.yaml`
  - **Expected**: FAIL

- [ ] **T015** [P] Act I Level 5 playthrough test in `tests/integration/test_act_I_l5.gd`
  - Load `act_I_l5_debt_collectors_demo.yaml`
  - **Expected**: FAIL

- [ ] **T016** [P] Level progression test in `tests/integration/test_level_progression.gd`
  - Complete L1 → assert L2 unlocked
  - Assert L3-28 still locked
  - Test save/load persistence
  - **Expected**: FAIL

- [ ] **T017** [P] Tutorial flow test in `tests/integration/test_tutorial.gd`
  - Test tutorial start
  - Test skip functionality
  - Test completion persistence
  - **Expected**: FAIL (no tutorial system yet)

---

## Phase 3.3: Steamfitter Plugin (ONLY after tests are failing)

**Duration**: 3-4 days  
**Dependencies**: T007-T017 (tests must exist and fail)  
**Goal**: Implement YAML parsing, scene generation, and validation

- [ ] **T018** Implement `addons/steamfitter/spec_loader.gd`
  - Load YAML files using gdyaml
  - Parse level specs from `data/specs/*.yaml`
  - Parse part specs from `data/parts/*.yaml`
  - Cache parsed specs in memory
  - Handle parse errors gracefully (report line numbers)

- [ ] **T019** Implement `addons/steamfitter/validators/level_validator.gd`
  - Validate level YAML against `contracts/level_schema.yaml`
  - Check `allowed_parts` references exist
  - Check budget consistency
  - Return validation errors with descriptive messages

- [ ] **T020** Implement `addons/steamfitter/validators/part_validator.gd`
  - Validate part YAML against `contracts/part_schema.yaml`
  - Check port naming conventions
  - Check scene/icon paths exist
  - Validate port type enums

- [ ] **T021** Implement `addons/steamfitter/scene_generator.gd`
  - Generate Godot scenes from part specs (if needed)
  - Apply visual.scene path from YAML
  - Set up port nodes (Area2D or custom)
  - Configure collision layers for connections

- [ ] **T022** Implement hot-reload support in `addons/steamfitter/plugin.gd`
  - Watch `data/specs/` and `data/parts/` for changes
  - Re-parse YAML on file save
  - Emit signal on spec update
  - Log reload events to Output panel

- [ ] **T023** Add editor dock for Steamfitter in `addons/steamfitter/dock.tscn`
  - Show list of all levels (28)
  - Show list of all parts (33)
  - Display validation status (✅/❌)
  - Button to validate all specs
  - Button to reload specs

- [ ] **T024** Implement `addons/steamfitter/trace_loader.gd`
  - Load transformer trace JSON from `data/traces/`
  - Parse metadata (model, prompt, tokens)
  - Parse layer/attention data
  - Decompress uint8 attention weights → float32
  - Cache loaded traces

- [ ] **T025** Run schema validation tests (T007-T010) - should now pass
  - Verify all 28 levels pass validation
  - Verify all 33 parts pass validation
  - Fix any validation errors in YAML files

---

## Phase 3.4: Part Library (33 Parts × 2 Tasks Each)

**Duration**: 10-15 days (parallelizable)  
**Dependencies**: T018-T025 (plugin complete)  
**Goal**: Implement all 33 machine parts with unit tests

**Strategy**: TDD strict - write test first, watch it fail, then implement

### Act I Parts (Priority 1 - Core Gameplay)

- [ ] **T026** [P] Unit test for Steam Source in `tests/unit/test_steam_source.gd`
  - Test output port emits correct vector data
  - Test data source configuration (dataset selection)
  - Test batch iteration
  - **Expected**: FAIL

- [ ] **T027** [P] Implement Steam Source in `game/parts/steam_source.tscn` and `steam_source.gd`
  - Create scene with out_south port
  - Implement `_forward()` function to emit data
  - Add icon/visual representation
  - Run T026 - should now pass

- [ ] **T028** [P] Unit test for Signal Loom in `tests/unit/test_signal_loom.gd`
  - Test vector passthrough
  - Test simple transformations
  - Test port connectivity

- [ ] **T029** [P] Implement Signal Loom in `game/parts/signal_loom.tscn` and `signal_loom.gd`
  - Scene with in_north, out_south ports
  - Implement vector operations
  - Run T028 - should now pass

- [ ] **T030** [P] Unit test for Weight Wheel in `tests/unit/test_weight_wheel.gd`
  - Test spoke parameter initialization (default 3)
  - Test weight multiplication (input × spokes)
  - Test trainable parameter updates
  - Test gradient flow (backward pass)

- [ ] **T031** [P] Implement Weight Wheel in `game/parts/weight_wheel.tscn` and `weight_wheel.gd`
  - Scene with in_north, out_south, gradient_in ports
  - Implement `_forward(input: Array) -> Array`
  - Implement `_backward(gradient: Array)`
  - Add spoke configuration UI (Spyglass integration)
  - Run T030 - should now pass

- [ ] **T032** [P] Unit test for Adder Manifold in `tests/unit/test_adder_manifold.gd`
  - Test two-input addition
  - Test broadcasting (scalar + vector)

- [ ] **T033** [P] Implement Adder Manifold in `game/parts/adder_manifold.tscn` and `adder_manifold.gd`
  - Scene with in_north, in_east, out_south ports
  - Implement element-wise addition
  - Run T032 - should now pass

- [ ] **T034** [P] Unit test for Entropy Manometer in `tests/unit/test_entropy_manometer.gd`
  - Test loss calculation (MSE, cross-entropy)
  - Test visual gauge updates

- [ ] **T035** [P] Implement Entropy Manometer in `game/parts/entropy_manometer.tscn` and `entropy_manometer.gd`
  - Scene with in_north (predictions), in_east (targets)
  - Calculate loss value
  - Update gauge visual
  - Run T034 - should now pass

### Act I-II Additional Parts (Priority 2)

- [ ] **T036** [P] Unit test for Display Glass in `tests/unit/test_display_glass.gd`
- [ ] **T037** [P] Implement Display Glass in `game/parts/display_glass.tscn` and `display_glass.gd`

- [ ] **T038** [P] Unit test for Calibration Feeder in `tests/unit/test_calibration_feeder.gd`
- [ ] **T039** [P] Implement Calibration Feeder in `game/parts/calibration_feeder.tscn` and `calibration_feeder.gd`

- [ ] **T040** [P] Unit test for Activation Gate in `tests/unit/test_activation_gate.gd`
- [ ] **T041** [P] Implement Activation Gate in `game/parts/activation_gate.tscn` and `activation_gate.gd`

- [ ] **T042** [P] Unit test for Matrix Frame in `tests/unit/test_matrix_frame.gd`
- [ ] **T043** [P] Implement Matrix Frame in `game/parts/matrix_frame.tscn` and `matrix_frame.gd`

- [ ] **T044** [P] Unit test for Downspout in `tests/unit/test_downspout.gd`
- [ ] **T045** [P] Implement Downspout in `game/parts/downspout.tscn` and `downspout.gd`

- [ ] **T046** [P] Unit test for Drop Valves in `tests/unit/test_drop_valves.gd`
- [ ] **T047** [P] Implement Drop Valves in `game/parts/drop_valves.tscn` and `drop_valves.gd`

- [ ] **T048** [P] Unit test for Convolution Drum in `tests/unit/test_convolution_drum.gd`
- [ ] **T049** [P] Implement Convolution Drum in `game/parts/convolution_drum.tscn` and `convolution_drum.gd`

- [ ] **T050** [P] Unit test for Cog Ratchet Press in `tests/unit/test_cog_ratchet_press.gd`
- [ ] **T051** [P] Implement Cog Ratchet Press in `game/parts/cog_ratchet_press.tscn` and `cog_ratchet_press.gd`

- [ ] **T052** [P] Unit test for Residual Rail in `tests/unit/test_residual_rail.gd`
- [ ] **T053** [P] Implement Residual Rail in `game/parts/residual_rail.tscn` and `residual_rail.gd`

### Act III Transformer Parts (Priority 3)

- [ ] **T054** [P] Unit test for Embedder Drum in `tests/unit/test_embedder_drum.gd`
- [ ] **T055** [P] Implement Embedder Drum in `game/parts/embedder_drum.tscn` and `embedder_drum.gd`

- [ ] **T056** [P] Unit test for Looking Glass Array in `tests/unit/test_looking_glass_array.gd`
- [ ] **T057** [P] Implement Looking Glass Array in `game/parts/looking_glass_array.tscn` and `looking_glass_array.gd`

- [ ] **T058** [P] Unit test for Attention Head Viewer in `tests/unit/test_attention_head_viewer.gd`
- [ ] **T059** [P] Implement Attention Head Viewer in `game/parts/attention_head_viewer.tscn` and `attention_head_viewer.gd`

- [ ] **T060** [P] Unit test for Layer Navigator in `tests/unit/test_layer_navigator.gd`
- [ ] **T061** [P] Implement Layer Navigator in `game/parts/layer_navigator.tscn` and `layer_navigator.gd`

- [ ] **T062** [P] Unit test for Token Tape in `tests/unit/test_token_tape.gd`
- [ ] **T063** [P] Implement Token Tape in `game/parts/token_tape.tscn` and `token_tape.gd`

### Act IV-V Advanced Parts (Priority 4)

- [ ] **T064** [P] Unit test for Augmentor Arms in `tests/unit/test_augmentor_arms.gd`
- [ ] **T065** [P] Implement Augmentor Arms in `game/parts/augmentor_arms.tscn` and `augmentor_arms.gd`

- [ ] **T066** [P] Unit test for Output Evaluator in `tests/unit/test_output_evaluator.gd`
- [ ] **T067** [P] Implement Output Evaluator in `game/parts/output_evaluator.tscn` and `output_evaluator.gd`

- [ ] **T068** [P] Unit test for Inspectorate Bench in `tests/unit/test_inspectorate_bench.gd`
- [ ] **T069** [P] Implement Inspectorate Bench in `game/parts/inspectorate_bench.tscn` and `inspectorate_bench.gd`

- [ ] **T070** [P] Unit test for Apprentice SGD in `tests/unit/test_apprentice_sgd.gd`
- [ ] **T071** [P] Implement Apprentice SGD in `game/parts/apprentice_sgd.tscn` and `apprentice_sgd.gd`

- [ ] **T072** [P] Unit test for Athanor Still in `tests/unit/test_athanor_still.gd`
- [ ] **T073** [P] Implement Athanor Still in `game/parts/athanor_still.tscn` and `athanor_still.gd`

- [ ] **T074** [P] Unit test for Layer Tonic in `tests/unit/test_layer_tonic.gd`
- [ ] **T075** [P] Implement Layer Tonic in `game/parts/layer_tonic.tscn` and `layer_tonic.gd`

### Act V-VI Alignment & Research Parts (Priority 5)

- [ ] **T076** [P] Unit test for Ethics Governor in `tests/unit/test_ethics_governor.gd`
- [ ] **T077** [P] Implement Ethics Governor in `game/parts/ethics_governor.tscn` and `ethics_governor.gd`

- [ ] **T078** [P] Unit test for Sampling Controls in `tests/unit/test_sampling_controls.gd`
- [ ] **T079** [P] Implement Sampling Controls in `game/parts/sampling_controls.tscn` and `sampling_controls.gd`

- [ ] **T080** [P] Unit test for Logits Explorer in `tests/unit/test_logits_explorer.gd`
- [ ] **T081** [P] Implement Logits Explorer in `game/parts/logits_explorer.tscn` and `logits_explorer.gd`

### Sandbox-Specific Parts (Priority 6 - Defer)

- [ ] **T082** [P] Unit test for Pneumail Librarium in `tests/unit/test_pneumail_librarium.gd`
- [ ] **T083** [P] Implement Pneumail Librarium in `game/parts/pneumail_librarium.tscn` and `pneumail_librarium.gd`

- [ ] **T084** [P] Unit test for Aether Battery in `tests/unit/test_aether_battery.gd`
- [ ] **T085** [P] Implement Aether Battery in `game/parts/aether_battery.tscn` and `aether_battery.gd`

- [ ] **T086** [P] Unit test for Plan Table in `tests/unit/test_plan_table.gd`
- [ ] **T087** [P] Implement Plan Table in `game/parts/plan_table.tscn` and `plan_table.gd`

- [ ] **T088** [P] Unit test for Spyglass in `tests/unit/test_spyglass.gd`
- [ ] **T089** [P] Implement Spyglass in `game/parts/spyglass.tscn` and `spyglass.gd`

**Note**: After each pair of tasks (test + implementation), run the unit test to verify it passes. This validates TDD workflow.

---

## Phase 3.5: Simulation Engine

**Duration**: 5-7 days  
**Dependencies**: T026-T089 (at least Act I parts complete)  
**Goal**: Build deterministic forward/backward pass engine

- [ ] **T090** Implement `game/sim/graph.gd` (connection graph structure)
  - Create directed graph from MachineConfiguration
  - Detect cycles (for recurrent connections)
  - Topological sort for forward pass ordering
  - Return part execution order (dependencies first)
  - Handle disconnected components gracefully

- [ ] **T091** Implement `game/sim/engine.gd` (main simulation loop)
  - Load MachineConfiguration (parts + connections)
  - Build execution graph using `graph.gd`
  - Execute forward pass:
    - Call `_forward()` on each part in topological order
    - Pass data through connections
    - Handle recurrent connections (unroll logic)
    - Stop after `max_recurrent_iterations` or convergence
  - Measure execution time (must be <16ms for typical machines)
  - Return output values and intermediate states

- [ ] **T092** Implement backward pass in `game/sim/engine.gd`
  - Reverse topological order for gradient flow
  - Call `_backward(gradient)` on trainable parts
  - Accumulate gradients through connections
  - Handle gradient for recurrent connections (BPTT-style unrolling)
  - Return gradient values for visualization

- [ ] **T093** Implement `game/sim/trainer.gd` (training orchestration)
  - Load training config from Level YAML (`training.*`)
  - Initialize optimizer (SGD, Adam, RMSprop)
  - Training loop:
    - For each epoch (0 to `max_epochs`):
      - Run forward pass (simulation)
      - Calculate loss (Entropy Manometer or win condition)
      - Run backward pass
      - Update weights using optimizer
      - Store loss in TrainingState.loss_history
      - Check convergence (success/divergence/oscillation/stagnation)
    - If converged or max epochs, stop
  - Return final TrainingState

- [ ] **T094** Implement convergence detection in `game/sim/convergence_detection.gd`
  - **Divergence**: Loss increases for 5 consecutive epochs → hint
  - **Oscillation**: Loss variance >50% of mean over last 10 epochs → hint
  - **Stagnation**: Loss change <0.001 for 10 epochs but above target → hint
  - **Success**: Loss below `win_conditions.accuracy` threshold
  - Return convergence status + hint text

- [ ] **T095** Implement `game/sim/validators.gd` (win condition checks)
  - Load `win_conditions` from Level YAML
  - Validate accuracy against threshold
  - Validate budget constraints (mass, pressure, brass)
  - Validate optional constraints (fairness_threshold for alignment levels)
  - Return pass/fail + metrics for star rating

- [ ] **T096** Add recurrent connection support in `game/sim/graph.gd`
  - Detect cycles in graph
  - If `allow_feedback_loops` is false → error
  - If true → unroll cycle for N iterations (from `max_recurrent_iterations`)
  - Check convergence after each iteration (epsilon-based)
  - Prevent infinite loops

- [ ] **T097** Add profiling to simulation loop in `game/sim/profiler.gd`
  - Measure forward pass time per part
  - Measure backward pass time per part
  - Measure total epoch time
  - Log warnings if >16ms for forward pass
  - Display profiling data in debug UI (optional)

- [ ] **T098** Run integration tests (T011-T017) - should now pass
  - Act I L1 playthrough test should complete
  - Training should converge to accuracy ≥ 0.95
  - Level completion should trigger
  - Fix any simulation bugs discovered

---

## Phase 3.6: UI Components

**Duration**: 7-10 days  
**Dependencies**: T090-T098 (simulation engine complete)  
**Goal**: Build all game UI screens and interactions

### Main Menu & Level Select

- [ ] **T099** Implement main menu in `game/ui/main_menu.tscn` and `main_menu.gd`
  - Title screen with "Begin Campaign", "Sandbox", "Settings", "Quit"
  - Sandbox button locked (grayed out) until campaign complete
  - Settings button opens settings panel (audio, controls, tutorial toggle)
  - Steampunk visual theme (brass, gears, Victorian fonts)

- [ ] **T100** Implement level select in `game/ui/level_select.tscn` and `level_select.gd`
  - Load PlayerProgress to determine unlocked levels
  - Display Acts I-VI in collapsible tree
  - Show level info panel (name, description, budget, story)
  - Highlight completed levels with checkmark icon
  - "Load Level" button enabled only for unlocked levels
  - Optional: Star ratings display (1-3 stars per level)

- [ ] **T101** Implement backstory scene in `game/ui/backstory.tscn` and `backstory.gd`
  - Load backstory text from `docs/backstory1.md`
  - Display with typewriter effect (optional)
  - Continue button after ~5 seconds or immediately
  - Optional: Hand-inked artwork panels
  - Transition to Level Select on continue

### Workbench (Main Gameplay)

- [ ] **T102** Implement workbench interface in `game/ui/workbench.tscn` and `workbench.gd`
  - Load Level YAML and display allowed parts in Component Drawers
  - Budget meters at top (Mass, Pressure, Brass)
  - Control buttons: Train, Reset, Spyglass, Export (Export grayed out initially)
  - Story panel showing level title and objective
  - Central canvas for part placement (GraphEdit or custom Node2D)

- [ ] **T103** Implement part drag-and-drop in `workbench.gd`
  - Drag part from Component Drawer onto canvas
  - Snap to grid (optional) or smooth placement
  - Update budget meters on placement
  - Show part icon/visual, name label, port indicators
  - Allow repositioning (drag already-placed parts)
  - Right-click menu: Inspect, Delete

- [ ] **T104** Implement port connection system in `workbench.gd`
  - Drag from port to port to create connection
  - Validate port type compatibility (green = valid, red = invalid)
  - Display connection as line/wire between ports
  - Highlight endpoints on hover
  - Allow connection deletion (click + Del or right-click)
  - Store connections in MachineConfiguration

- [ ] **T105** Implement budget validation in `workbench.gd`
  - Calculate total mass, pressure, brass from placed parts
  - Update budget meters in real-time
  - Prevent placement if budget exceeded (show error tooltip)
  - Highlight budget meter in red if at limit

- [ ] **T106** Implement Spyglass inspection window in `game/ui/spyglass.tscn` and `spyglass.gd`
  - Double-click part or right-click → Inspect to open
  - Show part name, type, description
  - Display current input/output values (if simulation running)
  - Show editable parameters (e.g., Weight Wheel spokes as sliders)
  - Show gradient values during training (backward pass)
  - Allow multiple Spyglasses open simultaneously
  - Draggable/resizable window

- [ ] **T107** Implement training UI overlay in `game/ui/training_overlay.tscn` and `training_overlay.gd`
  - Display during training mode
  - Epoch counter (0 → max_epochs)
  - Loss graph (line chart, decreasing curve)
  - Current accuracy display
  - Stop Training button
  - Hide when training complete

- [ ] **T108** Implement visual data flow (aetheric marbles) in `workbench.gd`
  - During forward pass, animate marbles flowing through connections
  - Tint connections to show activity (pulse effect)
  - Show gradient flow in reverse (red marbles) during backward pass
  - Run at 60 FPS (smooth animation)

- [ ] **T109** Implement win/failure UI in `game/ui/level_result.tscn` and `level_result.gd`
  - **Win case**: "Inspectorate Stamp of Approval" message
    - Display final metrics (accuracy, loss)
    - Show budget usage
    - Star rating (1-3 based on efficiency)
    - "Next Level" button (unlocks next level)
  - **Failure case**: "Your contraption needs adjustment"
    - Display adaptive hint (from convergence_hints)
    - Show current accuracy
    - Options: "Adjust Machine" or "Retry Training"

### Tutorial System

- [ ] **T110** Implement tutorial system in `game/ui/tutorial.tscn` and `tutorial.gd`
  - Prompt on first launch: "Enable Tutorial?" with Skip button
  - Tutorial steps for Level 1:
    - Step 1: Highlight Level Select → "Select a level here"
    - Step 2: Highlight Load button → "Click Load to begin"
    - Step 3: Highlight Component Drawers → "Drag parts onto workbench"
    - Step 4: Demonstrate connection → "Drag from port to port"
    - Step 5: Highlight Train button → "Click to start training"
  - Each step highlights UI element with transparent overlay
  - Skip button available at all times
  - Persist tutorial state in PlayerProgress (completed/skipped)

### Settings & Menus

- [ ] **T111** Implement settings panel in `game/ui/settings.tscn` and `settings.gd`
  - Audio sliders (master, music, SFX)
  - Tutorial toggle (enable/disable)
  - High-contrast mode (accessibility)
  - Language selection (English only for Phase 1)
  - Apply/Cancel buttons

- [ ] **T112** Implement pause menu in `game/ui/pause_menu.tscn` and `pause_menu.gd`
  - Accessible via Esc key during gameplay
  - Options: Resume, Settings, Return to Level Select, Quit
  - Pause simulation when open

---

## Phase 3.7: Transformer Visualization

**Duration**: 4-5 days  
**Dependencies**: T024 (trace loader), T056-T063 (transformer parts)  
**Goal**: Implement transformer trace loading and attention visualization

- [ ] **T113** Implement trace loading in transformer levels
  - Load `data/traces/intro_attention_gpt2_small.json`
  - Parse metadata (model, prompt, tokens)
  - Parse layers and attention heads
  - Store in runtime data structure

- [ ] **T114** Implement uint8 → float32 decompression for attention weights
  - Read `weights_compressed` arrays (uint8)
  - Decompress: `float_value = uint8_value / 255.0`
  - Reshape to (sequence_length × sequence_length) matrix
  - Cache decompressed weights for performance

- [ ] **T115** Implement Layer Navigator UI in transformer levels
  - Dropdown or slider to select layer (0 to n_layers-1)
  - Display current layer index and metadata
  - Update visualizations when layer changes

- [ ] **T116** Implement Heat Lens (attention heatmap) in `game/parts/attention_head_viewer.tscn`
  - Render attention matrix as heatmap (red = high, blue = low)
  - Display token labels on axes
  - Allow head selection (0 to n_heads-1)
  - Interactive: hover to see exact attention values

- [ ] **T117** Implement head ablation UI in transformer levels
  - Checkboxes for each attention head (0-11 for GPT-2 small)
  - Toggle head on/off
  - Re-run simulation with heads disabled
  - Show impact on output (logits or loss)

- [ ] **T118** Implement token highlighting in transformer visualization
  - Click token in Token Tape to highlight
  - Show attention flows to/from that token
  - Display top-k attended tokens in sidebar

- [ ] **T119** Test transformer visualization with Act III Level 11
  - Load `act_III_l11_keys_in_the_looking_glass.yaml`
  - Load trace data
  - Navigate layers, view attention heatmaps
  - Ablate heads and observe changes
  - Verify pedagogical accuracy (matches real transformer behavior)

---

## Phase 3.8: Sandbox Mode

**Duration**: 5-7 days  
**Dependencies**: T090-T112 (core gameplay complete)  
**Goal**: Implement unrestricted experimentation mode with dataset loading

- [ ] **T120** Implement sandbox UI in `game/ui/sandbox.tscn` and `sandbox.gd`
  - No budget constraints
  - No level restrictions (all 33 parts available)
  - No win conditions (free experimentation)
  - Optional: PyTorch scaffold export button

- [ ] **T121** Implement Pneumail Librarium (dataset loader) in `game/ui/sandbox/dataset_loader.tscn` and `dataset_loader.gd`
  - File browser with format detection (CSV, JSON, images, text)
  - Preview first 10 samples
  - Validate format and size limits (from research.md #5)
  - Load dataset into Steam Source part

- [ ] **T122** Implement CSV loader in `dataset_loader.gd`
  - Parse CSV (first row = headers)
  - Max 10,000 rows, 50 columns
  - Convert to vector/matrix format
  - Handle missing values (skip or fill with 0)

- [ ] **T123** Implement JSON loader in `dataset_loader.gd`
  - Parse JSON array of objects
  - Max 5 MB file size
  - Validate consistent schema (all objects have same keys)
  - Convert to structured format

- [ ] **T124** Implement image directory loader in `dataset_loader.gd`
  - Load PNG/JPG images (max 512×512)
  - Max 1,000 images
  - Use subdirectories as class labels
  - Convert to tensor format (e.g., [3, 224, 224] RGB)

- [ ] **T125** Implement text file loader in `dataset_loader.gd`
  - Load plain text (one sample per line)
  - Max 10,000 lines, 500 chars per line
  - Tokenize if needed (simple whitespace split)

- [ ] **T126** Implement Challenge Seal export in `game/ui/sandbox/seal_manager.tscn` and `seal_manager.gd`
  - Serialize current MachineConfiguration to JSON
  - Include parts, connections, parameters
  - Add metadata (creator, date, performance metrics)
  - Save as `*.aitherworks_seal` file to OS file system

- [ ] **T127** Implement Challenge Seal import in `seal_manager.gd`
  - Load `*.aitherworks_seal` JSON file
  - Validate JSON schema
  - Check level_id matches (if importing to level mode)
  - Validate budget constraints (prevent cheating)
  - Load parts and connections onto workbench

- [ ] **T128** Implement Lab Notebook (training curves) in `game/ui/sandbox/lab_notebook.tscn` and `lab_notebook.gd`
  - Display historical training runs
  - Show loss curves, accuracy over time
  - Compare multiple runs (overlay graphs)
  - Export as CSV or PNG

- [ ] **T129** (Optional) Implement PyTorch scaffold export
  - Generate Python code from MachineConfiguration
  - Map parts to PyTorch modules (Weight Wheel → nn.Linear, etc.)
  - Output `model.py` with architecture
  - Include training loop scaffold
  - Defer if time-constrained

- [ ] **T130** Unlock Sandbox mode after campaign complete
  - Modify main menu logic: Sandbox button enabled if all 28 levels complete
  - Display "Sandbox Unlocked!" message on final level win
  - Update PlayerProgress.sandbox_unlocked = true

---

## Phase 3.9: Integration Tests (Comprehensive)

**Duration**: 3-4 days  
**Dependencies**: T090-T130 (all systems complete)  
**Goal**: Validate end-to-end functionality across all Acts

- [ ] **T131** Run all Act I integration tests (T011-T015) - should pass
  - Verify all 5 Act I levels complete successfully
  - Check level progression (L1 → L2 → ... → L5)
  - Validate player progress persistence

- [ ] **T132** Create Act II integration test in `tests/integration/test_act_II_levels.gd`
  - Test Act II Level 6 (Stamp the Cog)
  - Test Act II Level 8 (Mildew in the Archives)
  - Verify new parts (Convolution Drum, Residual Rail)

- [ ] **T133** Create Act III integration test in `tests/integration/test_act_III_levels.gd`
  - Test Act III Level 11 (Keys in the Looking-Glass)
  - Test Act III Level 14 (Mini Transformer)
  - Verify transformer visualization parts work
  - Test trace loading and attention heatmaps

- [ ] **T134** Create Act IV integration test in `tests/integration/test_act_IV_levels.gd`
  - Test Act IV Level 16 (Forger vs Examiner)
  - Test Act IV Level 17 (Mode Collapse Clinic)
  - Verify adversarial/GAN-style mechanics

- [ ] **T135** Create Act V integration test in `tests/integration/test_act_V_levels.gd`
  - Test Act V Level 20 (Teachers Whisper)
  - Test Act V Level 21 (Press to Fit)
  - Test Act V Level 22 (Ethical Governor)
  - Verify alignment mechanics and fairness_threshold

- [ ] **T136** Create Act VI integration test in `tests/integration/test_act_VI_levels.gd`
  - Test Act VI Level 26 (Citywide Dispatch)
  - Test Act VI Level 28 (The Charter)
  - Verify research-level concepts (RLHF, constitutional AI)

- [ ] **T137** Test save/load persistence in `tests/integration/test_save_load.gd`
  - Complete Level 1, save, exit
  - Reload game, verify Level 2 unlocked
  - Load Level 1, verify previous machine config restored
  - Test multiple save slots (if implemented)

- [ ] **T138** Test tutorial flow in `tests/integration/test_tutorial_flow.gd`
  - First launch → tutorial prompt appears
  - Skip tutorial → tutorial_status.skipped = true
  - Restart → tutorial doesn't re-prompt
  - Complete tutorial → tutorial_status.completed = true

- [ ] **T139** Test edge cases in `tests/integration/test_edge_cases.gd`
  - Invalid connections (scalar → matrix) → error
  - Budget exceeded → placement blocked
  - Disconnected parts → warning or silent skip
  - Missing input → error or empty simulation
  - Rapid actions (place/delete/connect) → no crashes

- [ ] **T140** Test Sandbox mode in `tests/integration/test_sandbox.gd`
  - Load CSV dataset (Iris example)
  - Build arbitrary machine (no budget constraints)
  - Train and observe results
  - Export Challenge Seal
  - Import Challenge Seal → verify machine restored

---

## Phase 3.10: Polish & Performance

**Duration**: 7-10 days  
**Dependencies**: T131-T140 (all integration tests pass)  
**Goal**: Optimize, cross-platform test, accessibility, narrative polish, final polish

### Narrative System (Rival Characters)

**Note**: These tasks implement FR-037, FR-038, FR-039 (narrative enhancement). If time-constrained, these can be deferred to Phase 2 post-launch. Core gameplay is functional without rivals, but narrative immersion will be reduced.

- [ ] **T161** [P] Implement rival character data model in `game/narrative/rival.gd`
  - Create Rival class with properties: name, personality, motivation, interference_type
  - Define three rivals from docs: House Voltaic, Lady Kessington, Inspectorate Inspector
  - Load rival data from level YAML (optional `rival` field)
  - Store rival state (active rival, current interference)

- [ ] **T162** [P] Implement narrative transition UI in `game/ui/narrative_transition.tscn` and `narrative_transition.gd`
  - Create letterpress card visual (steampunk paper texture, Victorian typography)
  - Create pneumatic memo visual (brass tube capsule, rolled parchment)
  - Display rival messages between levels (quotes, sabotage warnings)
  - Support multi-page transitions (swipe/click to advance)
  - Add continue button to proceed to next level

- [ ] **T163** Integrate rival interference with level constraints
  - Modify level loader to apply rival modifiers from YAML
  - Example modifiers:
    - House Voltaic sabotage: Reduce brass budget by 20%
    - Lady Kessington espionage: Hide one allowed part until mid-level
    - Inspectorate audit: Stricter accuracy threshold (+0.05)
  - Display active interference in level UI (warning banner)
  - Log rival actions in player progress

- [ ] **T164** [P] Add narrative triggers to level progression in `game/ui/level_select.gd`
  - Display rival introduction scenes (first encounter per Act)
  - Show letterpress cards on level completion (rival reactions)
  - Trigger pneumatic memos on level failure (rival taunts or hints)
  - Update level select UI to show active rival portrait (optional)

### Performance Optimization

- [ ] **T141** Profile simulation loop with GUT performance tests in `tests/performance/test_simulation_performance.gd`
  - Measure forward pass time for 4-part machine (Act I L1)
  - Measure forward pass time for 20-part machine (typical mid-game)
  - Target: <16ms for 20-part machine
  - Profile backward pass time
  - Identify bottlenecks (GDScript profiler)

- [ ] **T142** Optimize simulation engine if >16ms
  - Batch vector operations (use PackedFloat32Array)
  - Cache topological sort (don't recompute each epoch)
  - Avoid String operations in hot loops
  - Use typed GDScript variables (`var x: float`)

- [ ] **T143** Optimize YAML parsing (cache results)
  - Load all level/part YAMLs once at startup
  - Cache parsed data in Steamfitter plugin
  - Avoid re-parsing on level load (use cached specs)
  - Measure level load time: target <3s

- [ ] **T144** Optimize Spyglass real-time updates
  - Limit update frequency to 10 FPS (not 60 FPS)
  - Only update visible Spyglasses (skip minimized windows)
  - Use `call_deferred()` for UI updates (don't block simulation)

- [ ] **T145** Optimize web export size
  - Target: <500 MB total
  - Compress audio (Ogg Vorbis, low bitrate for music)
  - Compress textures (WebP or low-res PNG)
  - Minify YAML files (remove comments, extra whitespace)
  - Remove unused assets from export

### Cross-Platform Testing

- [ ] **T146** Test on Windows desktop
  - Run full campaign (Acts I-VI)
  - Verify save/load works (`%APPDATA%/Godot/app_userdata/aitherworks/`)
  - Test performance on mid-range laptop (Intel i5, 8GB RAM)
  - Check for Windows-specific bugs

- [ ] **T147** Test on macOS desktop
  - Run full campaign
  - Verify save/load works (`~/Library/Application Support/Godot/app_userdata/aitherworks/`)
  - Test on M1/M2 Mac (ARM) and Intel Mac
  - Check for macOS-specific bugs

- [ ] **T148** Test on Linux desktop
  - Run full campaign
  - Verify save/load works (`~/.local/share/godot/app_userdata/aitherworks/`)
  - Test on Ubuntu/Debian and Arch/Fedora
  - Check for Linux-specific bugs

- [ ] **T149** Test web export (WASM)
  - Export for web (HTML5)
  - Test in Chrome, Firefox, Safari
  - Verify save/load works (`user://` → IndexedDB)
  - Check file size (<500 MB)
  - Test performance (target 60 FPS on mid-range hardware)
  - Verify no CORS errors for trace loading

- [ ] **T150** Test cross-platform save compatibility
  - Save on Windows, load on macOS → should work
  - Save on web, download save file, load on desktop → should work
  - Verify JSON format is platform-agnostic

### Accessibility & Polish

- [ ] **T151** Implement high-contrast mode
  - Settings option: "High Contrast"
  - Increase connection line thickness
  - Use high-contrast colors (black/white/yellow)
  - Increase font sizes
  - Test with visually impaired users (if possible)

- [ ] **T152** Add captions for audio (if audio implemented)
  - Subtitle narrative text
  - Caption sound effects (e.g., "[gear clanking]")
  - Settings option: "Captions On/Off"

- [ ] **T153** Add keyboard shortcuts
  - Esc → pause menu
  - Ctrl+S → save (auto-save on level complete)
  - Ctrl+Z → undo part placement
  - Ctrl+T → start training
  - Del → delete selected part/connection
  - Document shortcuts in `docs/keyboard_shortcuts.md`

- [ ] **T154** Polish visual theme consistency
  - Ensure all UI uses steampunk fonts (Victorian serif)
  - Brass/copper color palette throughout
  - Gear/cog motifs in buttons and panels
  - Consistent iconography (parts, buttons, etc.)

- [ ] **T155** Add audio (optional but recommended)
  - Background music (steampunk/industrial ambient)
  - SFX: gear clanking, steam hissing, button clicks
  - Training loop whoosh sounds
  - Win/fail fanfares
  - Volume sliders in settings

### Final Validation

- [ ] **T156** Run complete campaign playthrough (manual)
  - Play all 28 levels from Act I L1 → Act VI L28
  - Verify narrative consistency (story progression)
  - Check for any soft-locks or progression blockers
  - Validate star ratings and efficiency metrics

- [ ] **T157** Execute `quickstart.md` manual test
  - Follow all 12 steps for Act I L1
  - Check all validation criteria
  - Measure performance benchmarks
  - Document any deviations

- [ ] **T158** Run full GUT test suite
  - Execute all tests in `tests/unit/`, `tests/integration/`, `tests/validation/`
  - Target: 100% pass rate
  - Fix any failing tests
  - Generate test coverage report

- [ ] **T159** Performance regression test
  - Re-run performance tests (T141)
  - Verify all targets met (<16ms simulation, <3s load, 60 FPS)
  - If regressions, profile and optimize

- [ ] **T160** Code review and cleanup
  - Remove debug print statements
  - Remove commented-out code
  - Ensure all TODOs are addressed or documented
  - Run linter/formatter (gdformat)
  - Update code style consistency

---

## Dependencies Graph

```
T001-T006 (Setup)
    ↓
T007-T017 (Tests - MUST FAIL)
    ↓
T018-T025 (Steamfitter Plugin)
    ↓
T026-T089 (Part Library - Parallel)
    ↓
T090-T098 (Simulation Engine)
    ↓
    ├──→ T099-T112 (UI Components)
    │        ↓
    │    T131-T140 (Integration Tests)
    │
    ├──→ T113-T119 (Transformer Viz - Parallel)
    │        ↓
    │    T131-T140 (Integration Tests)
    │
    └──→ T120-T130 (Sandbox - Parallel)
             ↓
         T131-T140 (Integration Tests)
    ↓
T141-T164 (Polish, Performance, Narrative - T161-T164 optional)
```

**Narrative Tasks (Optional)**: T161-T164 can run in parallel with performance optimization (T141-T160) or be deferred to Phase 2.

---

## Parallel Execution Examples

### Example 1: Part Library (33 parts)
All part pairs (test + implementation) can run in parallel:
```
Parallel batch 1 (Act I parts):
  T026-T027 (Steam Source)
  T028-T029 (Signal Loom)
  T030-T031 (Weight Wheel)
  T032-T033 (Adder Manifold)
  T034-T035 (Entropy Manometer)

Parallel batch 2 (Act I-II parts):
  T036-T037 (Display Glass)
  T038-T039 (Calibration Feeder)
  ... (continue for all 33 parts)
```

### Example 2: Schema Validation Tests
```
Parallel execution:
  T007 (Level schema tests)
  T008 (Part schema tests)
  T009 (Player progress tests)
  T010 (Trace format tests)
```

### Example 3: Integration Tests
```
Parallel execution:
  T011 (Act I L1)
  T012 (Act I L2)
  T013 (Act I L3)
  T014 (Act I L4)
  T015 (Act I L5)
```

---

## Task Execution Notes

### TDD Workflow
1. Write test (e.g., T026)
2. Run test → MUST FAIL (no implementation yet)
3. Implement feature (e.g., T027)
4. Run test → should now PASS
5. Refactor if needed
6. Move to next task

### Commit Strategy
- Commit after each task pair (test + implementation)
- Use descriptive commit messages (e.g., "T030-T031: Implement Weight Wheel with gradient support")
- Reference task IDs in commits for traceability

### Testing Strategy
- **Unit tests**: Fast, isolated, test single part behavior
- **Integration tests**: Slower, test multi-part interactions, level completion
- **Validation tests**: Fast, schema checks, ensure data integrity
- **Performance tests**: Measure timing, ensure targets met

### Priority Ordering
1. **Critical Path**: T001-T025 (setup + plugin) → T026-T035 (Act I parts) → T090-T098 (simulation) → T099-T112 (UI) → T131 (Act I tests)
2. **Deferred**: Sandbox (T120-T130), Acts IV-VI parts, advanced visualizations
3. **Polish Last**: T141-T160 (optimization, cross-platform, accessibility)

---

## Success Criteria

This feature is complete when:
- [x] All core tasks (T001-T160) are checked off
- [x] Optional narrative tasks (T161-T164) completed or explicitly deferred to Phase 2
- [x] All GUT tests pass (unit, integration, validation)
- [x] Performance benchmarks met (<16ms simulation, <3s load, 60 FPS on mid-range hardware per plan.md)
- [x] `quickstart.md` manual test passes
- [x] Cross-platform testing complete (Windows, macOS, Linux, Web)
- [x] Constitution v1.1.0 compliance verified (all 6 principles)
- [x] Substack post published documenting spec-driven development implementation

---

## Constitution Compliance Check

**Applied Principles** (Constitution v1.1.0):
- ✅ **Data-Driven Design**: All levels/parts in YAML, validated by Steamfitter
- ✅ **Godot 4 Native**: GDScript throughout, scene-based architecture
- ✅ **Plugin Integrity**: Steamfitter validates schemas, maintains compatibility
- ✅ **Scene-Based Architecture**: Each part is `.tscn` + `.gd` pair
- ✅ **Narrative Integration**: Steampunk lexicon, pedagogical accuracy per Act tier
- ✅ **Public Documentation**: Implementation will generate Substack post on spec-driven development

---

## Next Steps After Tasks Complete

1. Run `/analyze` to validate cross-artifact consistency
2. Execute tasks in order (or parallelize where marked [P])
3. Document any deviations or discoveries in `docs/implementation_notes.md`
4. Publish Substack post on spec-driven development process
5. Release Phase 1 (desktop/web) build
6. Gather user feedback for Phase 2 (mobile, advanced features)

---

**Tasks ready for execution. Proceed with T001 (Install gdyaml YAML parser).**

