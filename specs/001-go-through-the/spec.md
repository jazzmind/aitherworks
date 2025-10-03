# Feature Specification: Complete AItherworks Core System

**Feature Branch**: `001-go-through-the`  
**Created**: 2025-10-03  
**Status**: Draft  
**Input**: User description: "go through the docs and existing code as well as roadmap and create complete specs"

## Execution Flow (main)
```
1. Parse user description from Input
   → Request to analyze all documentation, code, and roadmap
   → Identify: completed features, gaps, planned but unimplemented features
2. Extract key concepts from description
   → Actors: Players, Mechanists (player character), Rivals, Inspectorate
   → Actions: Build machines, train models, solve puzzles, progress through campaign
   → Data: Level specs, part definitions, training traces, player progress
   → Constraints: Budgets (mass/pressure/brass), win conditions, constitutional principles
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION]
4. Fill User Scenarios & Testing section
   → Primary flow: Campaign progression from Act I through Act VI
   → Secondary flow: Sandbox mode for free experimentation
5. Generate Functional Requirements
   → Core gameplay loop, Steamfitter plugin, level system, parts library, sandbox mode
6. Identify Key Entities
   → Levels, Parts, Player Progress, Training State, Traces
7. Run Review Checklist
   → Focused on user experience and educational goals
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT players need and WHY (educational game teaching AI concepts)
- ❌ Avoid HOW to implement (no GDScript details, scene structure specifics)
- 👥 Written for game designers, educators, and stakeholders

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story

A player (Mechanist apprentice) launches AItherworks and experiences a structured campaign teaching AI concepts through steampunk puzzle-solving. They progress through 6 Acts, each introducing new machine parts (AI components) and concepts (neural network techniques). As they solve puzzles, they learn how to:
1. Build neural network equivalents using steampunk parts
2. Train models by adjusting weights and parameters
3. Validate solutions against hidden test sets
4. Optimize for multiple constraints (accuracy, efficiency, cost)
5. Handle modern AI challenges (bias, alignment, compression)

After completing the campaign, players unlock a Sandbox mode where they can freely experiment with all unlocked parts, import custom datasets, and share their creations.

### Acceptance Scenarios

1. **Given** a new player launches the game, **When** they select "Begin Campaign", **Then** they see the backstory scene introducing Aetherford and their foundry-barge.

2. **Given** a player is on Act I Level 1, **When** they place a Steam Source, Signal Loom, and Weight Wheel and connect them, **Then** they can run a forward pass and see aetheric marbles flow through the connections.

3. **Given** a player has built a simple machine, **When** they enable training mode and run the simulation, **Then** they see phlogiston dye flow backwards and weights adjust according to gradients.

4. **Given** a player's machine meets the win conditions, **When** the Inspectorate validates on hidden test data, **Then** the level is marked complete and the next level unlocks.

5. **Given** a player completes all 28 campaign levels, **When** they access the Foundry (Sandbox), **Then** they can use all 33 unlocked parts, load custom datasets, and export their machine designs as JSON blueprints.

6. **Given** a level has budget constraints (mass ≤ 6000 cogs, pressure ≤ Medium), **When** a player exceeds these limits, **Then** the system prevents them from placing additional parts and displays constraint violations.

7. **Given** a player double-clicks a part, **When** the Spyglass inspection window opens, **Then** they see real-time data flowing through that part (vectors, matrices, attention weights, logits).

8. **Given** a player is solving a transformer level, **When** they use the Layer Navigator, **Then** they can step through attention layers, see heat lens visualizations of attention weights, and ablate specific heads.

9. **Given** a player builds a quantization puzzle solution, **When** they use the Cog-Ratchet Press to compress weights to 4-bit, **Then** accuracy metrics update in real-time showing the precision/accuracy tradeoff.

10. **Given** a player creates a machine in Sandbox mode, **When** they export as a blueprint, **Then** the system generates a JSON graph with optional PyTorch scaffold showing the neural network equivalent.

### Edge Cases

- What happens when a player creates a machine with circular dependencies (feedback loops)? → System allows recurrent connections and runs simulation until convergence or max iterations (configurable per level)
- How does the system handle invalid part connections (mismatched port types)?
- What happens if a player's machine fails to converge during training (loss increases)? → System stops after max epochs (per level YAML) and provides adaptive hints (e.g., "Learning rate may be too high" or "Check Weight Wheel connections")
- How does the system handle extremely slow machines (performance degradation)?
- What happens when a player attempts to load a corrupted or invalid level spec?
- How does the system behave if required YAML files are missing or malformed?
- What happens when a player tries to place incompatible parts (e.g., convolution drum without input data)?
- How does the system handle edge cases in transformer trace loading (missing tokens, malformed attention matrices)?

## Requirements *(mandatory)*

### Functional Requirements

#### Core Gameplay Loop
- **FR-001**: System MUST allow players to select levels from a campaign menu showing 6 Acts with 28 total levels
- **FR-002**: System MUST enforce level gating (subsequent levels locked until prerequisites complete)
- **FR-003**: System MUST load level specifications from YAML files defining allowed parts, budgets, win conditions, and story
- **FR-004**: System MUST provide a workbench interface where players place parts on a workspace and connect them via ports (including recurrent connections/feedback loops)
- **FR-005**: System MUST validate part placements against level constraints (allowed parts list, budget limits)
- **FR-006**: System MUST support forward pass simulation showing data flow through connected parts
- **FR-007**: System MUST support training mode with backward pass showing gradient flow, stopping after max epochs with adaptive failure hints if convergence fails
- **FR-008**: System MUST evaluate player solutions against win conditions (accuracy thresholds, constraint limits)
- **FR-009**: System MUST validate solutions on hidden test data to prevent overfitting
- **FR-010**: System MUST persist player progress (completed levels, unlocked parts, sandbox access)

#### Steamfitter Editor Plugin
- **FR-011**: System MUST provide an editor plugin that imports YAML specifications during development
- **FR-012**: Plugin MUST parse level specs from `data/specs/` and validate schema compliance
- **FR-013**: Plugin MUST parse part definitions from `data/parts/` and validate schema compliance
- **FR-014**: Plugin MUST generate or validate Godot scene files corresponding to specifications
- **FR-015**: Plugin MUST report clear error messages for malformed YAML or schema violations
- **FR-016**: Plugin MUST support hot-reload of specifications during development (no editor restart required)
- **FR-017**: Plugin MUST validate that all `allowed_parts` references in level specs correspond to existing part definitions

#### Part Library & Simulation
- **FR-018**: System MUST implement 33 distinct machine parts corresponding to AI/ML components with behavior accuracy appropriate to campaign progression (simplified in early Acts, technically precise in later Acts)
- **FR-019**: Each part MUST expose clearly defined input/output ports with type constraints
- **FR-020**: Each part MUST display real-time state (values, gradients, activations) via Spyglass inspection
- **FR-021**: System MUST support basic parts: Steam Source (data input), Signal Loom (vectors), Weight Wheel (parameters), Adder Manifold (addition), Activation Gate (nonlinearity)
- **FR-022**: System MUST support convolution parts: Convolution Drum (filters), Augmentor Arms (data augmentation), Drop Valves (dropout)
- **FR-023**: System MUST support transformer parts: Looking-Glass Array (Q/K/V attention), Heat Lens (attention visualization), Residual Rail (skip connections), Layer Tonic (normalization)
- **FR-024**: System MUST support advanced parts: Cog-Ratchet Press (quantization), Athanor Still (distillation), Ethical Governor (alignment constraints)
- **FR-025**: System MUST support evaluation parts: Entropy Manometer (loss functions), Inspectorate Bench (validation), Output Evaluator (metrics)
- **FR-026**: System MUST execute deterministic simulation (same inputs → same outputs, reproducible training) with support for recurrent connections that run until convergence or max iterations
- **FR-027**: System MUST maintain 60 FPS during simulation on mid-range hardware

#### Transformer Visualization
- **FR-028**: System MUST load pre-generated transformer traces from JSON files
- **FR-029**: System MUST decode compressed attention matrices (uint8 → float32) on demand
- **FR-030**: System MUST provide Layer Navigator for stepping through transformer layers
- **FR-031**: System MUST visualize attention weights via Heat Lens showing focus distribution
- **FR-032**: System MUST support head ablation (disabling specific attention heads to observe effects)
- **FR-033**: System MUST display top-k logits with probability distributions
- **FR-034**: System MUST allow interactive sampling parameter adjustment (temperature, top-k, top-p)

#### Narrative & Story
- **FR-035**: System MUST display story scenes before/after levels showing steampunk narrative
- **FR-036**: Story scenes MUST use steampunk metaphors for AI concepts (consistent with lexicon) with progressive pedagogical accuracy: Acts I-II prioritize intuitive metaphors, Acts III-IV introduce technically accurate fundamentals, Acts V-VI teach standard CS concepts and research-level nuances
- **FR-037**: System MUST introduce rival characters (House Voltaic, Lady Kessington, Inspectorate) with distinct personalities
- **FR-038**: System MUST display narrative transitions via letterpress cards or pneumatic memos
- **FR-039**: System MUST tie level constraints to narrative stakes (debt collection, rival sabotage, citywide crisis)

#### Sandbox Mode
- **FR-040**: System MUST unlock Sandbox mode after campaign completion
- **FR-041**: Sandbox MUST provide access to all unlocked parts without budget constraints
- **FR-042**: Sandbox MUST allow custom dataset loading via Pneumail Librarium (images, tabular data, text)
- **FR-043**: Sandbox MUST support blueprint export as JSON graph representation
- **FR-044**: Sandbox SHOULD optionally generate PyTorch scaffold code mapping parts to torch.nn modules (Phase 1: time-permitting feature; defer to Phase 2 if schedule constrained)
- **FR-045**: Sandbox MUST display Lab Notebook with training curves (loss, gradients, metrics)
- **FR-046**: Sandbox MUST support Challenge Seals (shareable contraption configurations for competitive play)

#### UI/UX
- **FR-047**: System MUST provide optional tutorial guidance for first 3-5 levels (highlighted actions, tooltips) that is skippable but strongly recommended to new players with prominent UI highlighting
- **FR-048**: System MUST use steampunk-themed UI controls (rotary knobs, toggle switches, brass panels)
- **FR-049**: System MUST support multiple Spyglass windows simultaneously for comparing part states
- **FR-050**: System MUST display budget meters showing current vs. limit for mass/pressure/brass
- **FR-051**: System MUST show connection validity (green = valid type match, red = incompatible ports)
- **FR-052**: System MUST provide Component Drawers organized by part category (Input, Transformation, Training, Output)
- **FR-053**: System MUST display win conditions prominently with progress indicators
- **FR-054**: System MUST use accessibility features (high-contrast mode, captions for sound effects, math overlay toggles)

#### Data-Driven Design
- **FR-055**: All level content MUST be defined in YAML specs under `data/specs/`
- **FR-056**: All part definitions MUST be defined in YAML specs under `data/parts/`
- **FR-057**: YAML specs MUST be the single source of truth for game content (no hardcoded levels in scripts)
- **FR-058**: System MUST validate YAML specs on startup and report errors with file names and line numbers
- **FR-059**: System MUST support hot-reload of YAML specs in development builds

#### Performance & Quality
- **FR-060**: System MUST load level transitions in under 3 seconds on target hardware
- **FR-061**: System MUST complete forward/backward pass simulation within 100ms for typical machines (<20 parts)
- **FR-062**: System MUST support machines with up to 50 connected parts without performance degradation
- **FR-063**: System MUST maintain project size under 500 MB for web deployment
- **FR-064**: System MUST run on desktop (Windows/Mac/Linux) and web (WASM) in Phase 1; mobile (iOS/Android) support is Phase 2 stretch goal

### Key Entities *(include if feature involves data)*

- **Level**: Represents a single puzzle with id, name, description, story, budget constraints, allowed_parts list, win_conditions, and optional training parameters (including max_epochs for convergence failure detection). Stored as YAML in `data/specs/`.

- **Part**: Represents a machine component with part_id, display_name, category, description, ports (input/output with types), cost metrics (brass/mass/pressure), and behavior specification. Stored as YAML in `data/parts/`.

- **Player Progress**: Tracks completed levels, current act/level, unlocked parts, sandbox unlock status, tutorial completion/skip status, and achievement metrics. Persisted locally.

- **Machine Configuration**: The player's current part placement and connections for a level. Includes part positions, connection graph, and parameter values (e.g., Weight Wheel spoke values).

- **Training State**: Runtime state during training including current epoch, loss history, weight values, gradient flows, and validation metrics.

- **Transformer Trace**: Pre-generated transformer execution data including tokens (input/output), attention weights per layer/head (compressed), logits (top-k per position), and metadata (model name, prompt).

- **Budget**: Three-dimensional constraint on machines: mass (parameter count), pressure (energy/latency), brass (cost). Each part contributes to totals.

- **Win Condition**: Criteria for level completion including accuracy threshold, budget compliance, safety/fairness metrics (for alignment levels), and optional bonus objectives.

- **Rival**: NPC character with personality, motivation, and interference patterns. Affects narrative and occasionally introduces level modifiers (sabotage, resource limits).

- **Story Beat**: Narrative element displayed between levels including title, text, character quotes, and visual assets (comic panels, telegrams).

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs (educational game, AI teaching)
- [x] Written for non-technical stakeholders (game designers, educators)
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain — All resolved 2025-10-03 (see Clarifications Needed section)
- [x] Requirements are testable and unambiguous  
- [x] Success criteria are measurable (60 FPS, <3s load times, accuracy thresholds)
- [x] Scope is clearly bounded (28 levels, 33 parts, 6 acts)
- [x] Dependencies and assumptions identified

---

## Clarifications

### Session 2025-10-03
- Q: How should the system handle circular dependencies (feedback loops) in machine connections? → A: Allowed - run until convergence or max iterations
- Q: Should the tutorial system be mandatory for new players, or can they skip it? → A: Opt-in with strong recommendation - skippable but highlighted
- Q: What is the mobile platform (iOS/Android) prioritization relative to desktop/web? → A: Phase 1: Desktop/Web, Phase 2: Mobile (stretch goal)
- Q: What level of AI/ML pedagogical accuracy is required? → A: Progressive difficulty - Initial levels prioritize metaphorical intuition (Act I-II), progressing to conceptually correct fundamentals (Act III), standard undergraduate CS concepts (Act IV-V), and research-level nuances in final levels (Act VI)
- Q: If a player's machine fails to converge during training (loss diverges), how should the system respond? → A: Stop after max epochs and provide adaptive hints about the issue (e.g., learning rate too high, architecture problems)

---

## Clarifications Needed

**All clarifications resolved as of 2025-10-03. See research.md for decisions.**

### ✅ [RESOLVED #1: Port Type System]
**Question**: What are the exact port types supported (e.g., scalar, vector, matrix, attention_weights)? How are type mismatches handled (hard error vs. warning)?

**Resolution**: Defined 8 port types in `research.md` Section 2: scalar, vector, matrix, tensor, attention_weights, logits, gradient, signal. Type mismatches show red connection line + error tooltip, with runtime assertion checks. See `contracts/part_schema.yaml` for full taxonomy.

---

### ✅ [RESOLVED #4: Sandbox Dataset Format]
**Question**: What specific dataset formats does Pneumail Librarium support (CSV, JSON, image directories)? What are size limits?

**Resolution**: Supports 4 formats per `research.md` Section 5:
- CSV (max 10,000 rows, 50 columns)
- JSON (max 5 MB, array of objects)
- Images (PNG/JPG, max 512×512, 1,000 images, subdirs as labels)
- Text (max 10,000 lines, 500 chars/line)

---

### ✅ [RESOLVED #5: Challenge Seals Sharing Mechanism]
**Question**: How are Challenge Seals shared between players (local file export, Steam Workshop integration, web API)?

**Resolution**: Phase 1 uses local JSON file export (`*.aitherworks_seal`) per `research.md` Section 6. Players share manually (Discord, Reddit). Web API/Steam Workshop deferred to Phase 2. See `data-model.md` ChallengeSeal entity for JSON schema.

---




## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted (actors, actions, data, constraints)
- [x] Ambiguities marked (8 clarifications needed)
- [x] User scenarios defined (10 acceptance scenarios, edge cases identified)
- [x] Requirements generated (64 functional requirements across 9 categories)
- [x] Entities identified (10 key entities)
- [x] Review checklist passed (with clarifications noted)

---

## Summary

This specification defines the complete AItherworks core system: a steampunk puzzle game teaching AI/ML concepts through hands-on machine building. The system comprises:

1. **Campaign Mode**: 28 levels across 6 Acts teaching progressively advanced AI concepts (vectors → transformers → alignment)
2. **Steamfitter Plugin**: Editor tooling for YAML-driven content authoring and validation
3. **Part Library**: 33 machine parts mapping to neural network components with real-time visualization
4. **Simulation Engine**: Deterministic forward/backward pass with gradient visualization
5. **Transformer Visualization**: Pre-generated trace loading with attention analysis tools
6. **Sandbox Mode**: Unrestricted experimentation environment with blueprint export
7. **Narrative System**: Story-driven progression with rival characters and steampunk worldbuilding

**Success Criteria**:
- All 28 campaign levels playable with win condition validation
- All 33 parts implemented with AI/ML behavior accuracy appropriate to pedagogical progression (metaphorical → fundamental → standard → research-level)
- Steamfitter plugin generates valid scenes from YAML specs
- 60 FPS performance on mid-range hardware
- Educational accuracy verified by AI domain experts across difficulty tiers
- Player progression persistence working
- Sandbox export generating valid PyTorch scaffolds

**Out of Scope (Phase 1)**:
- Multiplayer or co-op modes
- Real-time competitive leaderboards (async Challenge Seals are in-scope)
- User-generated content marketplace (sharing mechanism TBD per Clarification #4)
- VR mode (future enhancement)
- Modding API beyond blueprint export
- Mobile platforms (iOS/Android) - deferred to Phase 2
- **Rival character system** (FR-037, FR-038, FR-039) - Narrative enhancement deferred to Phase 2; backstory scenes and level progression implemented in Phase 1

**Dependencies**:
- Godot 4.x engine (confirmed, already in use)
- ✅ YAML parsing: Custom SpecLoader implementation (zero external dependencies) - see `game/sim/spec_loader.gd`
- Pre-generated transformer traces (requires separate trace generation tooling)
- Steampunk art assets (backgrounds, part visuals, UI elements)
- Audio assets (piston thumps, valve hisses, chimes)
- AI/ML expert consultation for pedagogical validation across difficulty tiers (Acts I-II: intuitive, Acts III-IV: fundamentals, Acts V-VI: advanced/research)

---

This specification is ready for the `/plan` command to generate implementation plan and research phase.
