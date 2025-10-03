
# Implementation Plan: Complete AItherworks Core System

**Branch**: `001-go-through-the` | **Date**: 2025-10-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-go-through-the/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code, or `AGENTS.md` for all other agents).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary

This implementation plan addresses the complete AItherworks core system: a steampunk puzzle game teaching AI/ML concepts through hands-on machine building. The system comprises 7 major components:

1. **Campaign Mode**: 28 levels across 6 Acts (vectors → transformers → alignment)
2. **Steamfitter Plugin**: YAML-driven editor tooling for content authoring
3. **Part Library**: 33 machine parts mapping to neural network components
4. **Simulation Engine**: Deterministic forward/backward pass with gradient visualization
5. **Transformer Visualization**: Pre-generated trace loading with attention analysis
6. **Sandbox Mode**: Unrestricted experimentation with blueprint export
7. **Narrative System**: Story-driven progression with steampunk worldbuilding

**Primary Requirement**: Enable players to learn AI/ML concepts by building and training neural network equivalents using steampunk machine parts, progressing from basic vectors (Act I) to research-level techniques (Act VI) with pedagogical accuracy appropriate to each Act's difficulty tier.

**Technical Approach**: Godot 4.x game engine with data-driven YAML specifications, GDScript simulation layer, scene-based part architecture, and deterministic training mechanics that mirror real neural network behavior.

## Technical Context
**Language/Version**: GDScript (Godot 4.x native scripting language), targeting Godot 4.3+  
**Primary Dependencies**: Godot 4.x engine, YAML parser for GDScript (requires research/selection), JSON for transformer traces  
**Storage**: Local file system for YAML specs (`data/specs/`, `data/parts/`), local save files for player progress  
**Testing**: Godot's GUT (Godot Unit Test) framework, manual playtesting validation  
**Target Platform**: Desktop (Windows/Mac/Linux) and Web (WASM) in Phase 1; Mobile (iOS/Android) deferred to Phase 2  
**Project Type**: Single project (game) - Godot project structure with `addons/`, `game/`, `data/` top-level directories  
**Performance Goals**: 60 FPS during gameplay/simulation, <100ms forward/backward pass for typical machines (<20 parts), <3s level load times  
**Constraints**: <500 MB total project size for web deployment, deterministic simulation (reproducible training), cross-platform (no platform-specific code except OS.has_feature checks)  
**Scale/Scope**: 28 campaign levels, 33 machine parts, 6 acts, ~10-20 hours campaign playtime, sandbox mode for unlimited experimentation

**Target Hardware Specification** (for performance testing):
- **Desktop (Mid-Range)**:
  - CPU: Intel Core i5-8250U or AMD Ryzen 5 3500U (4 cores, 1.6-3.4 GHz)
  - RAM: 8 GB DDR4
  - GPU: Integrated Intel UHD 620 or AMD Vega 8
  - OS: Windows 10/11, macOS 12+, Ubuntu 20.04+
- **Web Deployment Target**:
  - Browser: Chrome 90+, Firefox 88+, Safari 14+
  - Connection: 4G (10 Mbps minimum for initial 500 MB load)
  - Device: Desktop/laptop with 16 GB RAM (web export uses more memory than native)
  - Max Bundle Size: 500 MB compressed (requires asset optimization, texture compression)

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify compliance with `/memory/constitution.md` principles:

- [x] **Data-Driven Design**: ✅ PASS - All 28 levels and 33 parts defined as YAML specs in `data/`. FR-055 through FR-059 mandate YAML as single source of truth. No hardcoded level content.
- [x] **Godot 4 Native**: ✅ PASS - GDScript for all game logic, targeting Godot 4.3+. Scene-based architecture with `.tscn` files. Signal-based event handling planned for part connections. Cross-platform by default (Phase 1: desktop/web).
- [x] **Plugin Integrity**: ✅ PASS - Steamfitter plugin (FR-011 to FR-017) maintains backward compatibility, validates schema, and reports clear errors. Hot-reload support for dev workflow. All `allowed_parts` references validated.
- [x] **Scene-Based Architecture**: ✅ PASS - Each of 33 parts is self-contained scene under `game/parts/` with matching `.gd` script (FR-018 to FR-025). Lowercase underscore naming enforced. Port-based connections between parts.
- [x] **Narrative Integration**: ✅ PASS - FR-036 explicitly mandates steampunk metaphors with progressive pedagogical accuracy (Acts I-II metaphorical → Acts V-VI research-level). All 6 Acts maintain Aetherford universe consistency. Lexicon-based terminology.
- [x] **Public Documentation**: ✅ PASS - This feature (complete core system) will generate Substack post documenting spec-driven development implementation. Constitution v1.1.0 Principle VI mandates weekly posts; this major feature qualifies for technical deep-dive post.

**Initial Constitution Check Result**: ✅ **PASS** - All 6 principles satisfied with no violations requiring justification.

## Project Structure

### Documentation (this feature)
```
specs/001-go-through-the/
├── spec.md              # Feature specification (input)
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── level_schema.yaml
│   ├── part_schema.yaml
│   ├── player_progress_schema.json
│   └── trace_format_schema.json
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
**Project Type**: Single Godot 4.x game project

```
aitherworks/
├── addons/
│   └── steamfitter/           # Editor plugin
│       ├── plugin.gd          # Main plugin entry (existing stub)
│       ├── plugin.cfg         # Plugin configuration (existing)
│       ├── spec_loader.gd     # YAML spec parser (to implement)
│       ├── scene_generator.gd # Scene generation from specs (to implement)
│       └── validators/        # Schema validation (to implement)
│
├── game/
│   ├── parts/                 # 33 reusable part scenes + scripts
│   │   ├── steam_source.tscn/.gd
│   │   ├── signal_loom.tscn/.gd
│   │   ├── weight_wheel.tscn/.gd
│   │   └── ... (30 more parts)
│   │
│   ├── sim/                   # Simulation engine
│   │   ├── engine.gd          # Main simulation loop
│   │   ├── graph.gd           # Connection graph
│   │   ├── trainer.gd         # Training orchestration
│   │   └── validators.gd      # Win condition evaluation
│   │
│   └── ui/                    # Game UI components
│       ├── workbench.tscn/.gd # Main workbench interface
│       ├── level_select.tscn/.gd
│       ├── spyglass.tscn/.gd  # Part inspection
│       └── sandbox.tscn/.gd   # Sandbox/Foundry mode
│
├── data/
│   ├── specs/                 # 28 level YAML specs (existing)
│   ├── parts/                 # 33 part YAML definitions (existing)
│   └── traces/                # Transformer trace JSONs (existing)
│
├── docs/                      # Design documentation (existing)
│
├── assets/                    # Art, audio, fonts (existing)
│
└── tests/                     # GUT test framework
    ├── integration/           # Level playthrough tests
    ├── unit/                  # Part behavior tests
    └── validation/            # YAML schema tests
```

**Structure Decision**: Godot single-project structure with existing directories. The feature expands `addons/steamfitter/` plugin, implements all 33 parts under `game/parts/`, builds simulation engine in `game/sim/`, and creates UI components in `game/ui/`. YAML specs already exist in `data/` and will be validated/extended. No new top-level directories required.

## Phase 0: Outline & Research

✅ **COMPLETE** - See `research.md`

**Research Areas Addressed**:
1. YAML Parsing in GDScript → Decision: Third-party parser (gdyaml) with JSON fallback
2. Port Type System Design → Decision: 8 types (scalar, vector, matrix, tensor, attention_weights, logits, gradient, signal)
3. Training Convergence Detection → Decision: Max epochs + adaptive hints based on failure mode
4. Recurrent Connection Handling → Decision: Unroll with convergence check, configurable per level
5. Sandbox Dataset Formats → Decision: CSV, JSON, images, text with size limits
6. Challenge Seals Sharing → Decision: Local JSON export (Phase 1), web/cloud deferred (Phase 2)
7. Godot Unit Testing → Decision: GUT framework
8. Transformer Trace Validation → Decision: Validate existing format, uint8 compression
9. Performance Profiling → Decision: Profile early, <16ms simulation budget
10. Cross-Platform Strategy → Decision: Desktop+Web (Phase 1), Mobile (Phase 2)

**All NEEDS CLARIFICATION items from spec resolved.**

## Phase 1: Design & Contracts

✅ **COMPLETE** - All artifacts generated

**Artifacts Created**:
1. **data-model.md** - 7 core entities defined (Level, Part, PlayerProgress, MachineConfiguration, TrainingState, TransformerTrace, ChallengeSeal) with schemas, relationships, validation rules
2. **contracts/** - 4 schema files:
   - `level_schema.yaml` - Level YAML structure with 28 validation rules
   - `part_schema.yaml` - Part YAML structure with port type taxonomy
   - `player_progress_schema.json` - JSON Schema for save files
   - `trace_format_schema.json` - Transformer trace validation
3. **quickstart.md** - 12-step manual test for Act I Level 1 (first playable level validation)
4. **CLAUDE.md** - Updated with technical context:
   - Port type system (8 types)
   - Project structure reference
   - Testing requirements (GUT framework)
   - Pedagogical accuracy guidelines
   - Recent changes log

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
The `/tasks` command will load Phase 1 artifacts and generate a comprehensive task list covering all 7 major components of the AItherworks core system.

**Task Categories** (from data-model.md and quickstart.md):

1. **Setup & Infrastructure** (T001-T010):
   - Install/configure gdyaml YAML parser
   - Install GUT testing framework
   - Create test directory structure
   - Configure CI for automated testing
   - Set up performance profiling

2. **Steamfitter Plugin** (T011-T025):
   - Implement spec_loader.gd (YAML parsing)
   - Implement scene_generator.gd
   - Create validators/ directory with schema validators
   - Validate all 28 level YAMLs on startup
   - Validate all 33 part YAMLs on startup
   - Hot-reload support

3. **Part Library** (T026-T090 - 33 parts × 2 tasks each):
   - For each part: Create unit test (GUT) [P]
   - For each part: Implement scene + script [P]
   - Priority order: Steam Source, Signal Loom, Weight Wheel, Adder Manifold (Act I parts first)
   - Later: Transformer parts (Looking-Glass Array, Heat Lens, etc.)

4. **Simulation Engine** (T091-T110):
   - Implement game/sim/engine.gd (main loop)
   - Implement game/sim/graph.gd (connection graph, cycle detection)
   - Implement game/sim/trainer.gd (training orchestration)
   - Implement game/sim/validators.gd (win condition checks)
   - Add convergence detection with adaptive hints
   - Support recurrent connections (unroll logic)

5. **UI Components** (T111-T135):
   - Implement workbench.tscn/.gd (main interface)
   - Implement level_select.tscn/.gd (campaign menu)
   - Implement spyglass.tscn/.gd (part inspection)
   - Implement tutorial system (skippable)
   - Implement budget meters
   - Implement training UI (epoch counter, loss graph)

6. **Transformer Visualization** (T136-T150):
   - Implement trace loading (JSON → runtime)
   - Implement uint8 decompression for attention weights
   - Implement Layer Navigator
   - Implement Heat Lens visualization
   - Implement head ablation UI

7. **Sandbox Mode** (T151-T165):
   - Implement Pneumail Librarium (dataset loader)
   - Support CSV, JSON, image directories, text files
   - Implement blueprint export (Challenge Seals JSON)
   - Implement Lab Notebook (training curves)
   - Optional: PyTorch scaffold generation

8. **Integration Tests** (T166-T180):
   - Test Act I Level 1 complete playthrough (from quickstart.md)
   - Test each Act I level (L1-L5)
   - Test level progression (L1 unlocks L2, etc.)
   - Test player progress persistence
   - Test tutorial skip/complete flows

9. **Polish & Performance** (T181-T200):
   - Profile simulation loop (<16ms target)
   - Optimize YAML parsing (cache results)
   - Optimize Spyglass real-time updates
   - Web export size optimization (<500 MB)
   - Cross-platform testing (desktop, web)
   - Accessibility features (high-contrast, captions)

**Dependency Graph**:
```
Setup → Plugin → Parts (parallel) → Simulation → UI → Integration Tests
                       ↓
              Transformer Viz (parallel with UI)
                       ↓
                  Sandbox (after UI)
```

**Parallel Execution Opportunities**:
- All 33 part implementations can run in parallel (independent files)
- Part unit tests can run in parallel
- UI components largely independent (workbench, spyglass, level_select)
- Transformer visualization independent of campaign mode

**Ordering Strategy**:
- **TDD Strict**: Unit tests for parts BEFORE implementation
- **Dependency Order**: Plugin → Parts → Simulation → UI
- **Priority**: Act I parts and levels first (validate core loop early)
- **Defer**: Sandbox and advanced parts (Acts IV-VI) until core validated

**Estimated Output**: ~200 numbered, ordered tasks across 9 categories

**Test Coverage Requirements**:
- All 33 parts have unit tests (behavior, ports, parameters)
- All 28 levels have schema validation tests
- Act I levels (1-5) have integration tests
- Quickstart.md scenarios automated as integration tests

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Constitution Re-Check (Post-Design)

After Phase 1 design completion, re-evaluate constitutional compliance:

- [x] **Data-Driven Design**: ✅ PASS - data-model.md confirms all entities stored as YAML/JSON. Schemas validate structure. No violations introduced.
- [x] **Godot 4 Native**: ✅ PASS - All GDScript implementations planned. Port system uses Godot signals. No platform-specific code except OS.has_feature checks.
- [x] **Plugin Integrity**: ✅ PASS - Steamfitter plugin design maintains backward compatibility. Schema validators enforce consistency. Hot-reload supported.
- [x] **Scene-Based Architecture**: ✅ PASS - Each of 33 parts is self-contained scene. quickstart.md validates scene loading. No violations.
- [x] **Narrative Integration**: ✅ PASS - Pedagogical accuracy guidelines added to CLAUDE.md. Steampunk lexicon enforced. Progressive difficulty (Acts I→VI) maintained.
- [x] **Public Documentation**: ✅ PASS - This implementation plan will generate Substack post on spec-driven development. Post topics: YAML schemas, port type system, data modeling.

**Post-Design Constitution Check Result**: ✅ **PASS** - All 6 principles remain satisfied. No new violations introduced during design phase.

## Complexity Tracking

**No violations requiring justification.** All design decisions align with constitutional principles.


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) ✅
- [x] Phase 1: Design complete (/plan command) ✅
- [x] Phase 2: Task planning complete (/plan command - describe approach only) ✅
- [x] Phase 3: Tasks generated (/tasks command) ✅
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS ✅
- [x] Post-Design Constitution Check: PASS ✅
- [x] All NEEDS CLARIFICATION resolved ✅ (10 research decisions made)
- [x] Complexity deviations documented ✅ (None - all decisions constitutional)

**Artifacts Generated**:
- ✅ research.md (10 research decisions with rationale)
- ✅ data-model.md (7 entities, relationships, validation rules)
- ✅ contracts/ (4 schema files: level, part, player_progress, trace_format)
- ✅ quickstart.md (12-step manual test for Act I L1)
- ✅ CLAUDE.md updates (technical context, structure, testing guidelines)
- ✅ tasks.md (160 ordered, dependency-aware tasks across 9 phases)

**Task Generation Complete**: All 160 tasks created with TDD workflow, parallel execution markers, and constitutional compliance.

---
*Based on Constitution v1.1.0 - See `/memory/constitution.md`*

## Next Command

Run `/analyze` to perform cross-artifact consistency analysis across spec.md, plan.md, and tasks.md before implementation begins.
