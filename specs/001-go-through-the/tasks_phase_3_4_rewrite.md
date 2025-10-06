---

## Phase 3.4: Simulation Engine ⚠️ CRITICAL PATH

**Duration**: 5-7 days  
**Dependencies**: T200-T210 (retrofit tests complete), T007-T017 (integration tests defined)  
**Goal**: Build deterministic forward/backward pass engine to unblock 28 integration tests

**Note**: Originally Phase 3.5, moved up because simulation engine is blocking all integration tests.

- [ ] **T018** Implement `game/sim/graph.gd` (connection graph structure)
  - Create directed graph from part connections
  - Topological sort for execution order
  - Detect cycles (for recurrent connections)
  - Validate port type compatibility
  - Store graph metadata (node count, edge count)

- [ ] **T019** Implement `game/sim/forward_pass.gd`
  - Execute graph in topological order
  - Propagate signals through connections
  - Handle scalar/vector/matrix transformations
  - Cache intermediate values
  - Support recurrent iterations (with max iteration limit)

- [ ] **T020** Implement `game/sim/backward_pass.gd`
  - Reverse graph traversal
  - Compute gradients via chain rule
  - Accumulate gradients for multi-input nodes
  - Handle gradient clipping
  - Support sparse gradients

- [ ] **T021** Implement `game/sim/training_loop.gd`
  - Initialize weights (Xavier/He initialization)
  - Run forward pass → compute loss → backward pass → update weights
  - Support different optimizers (SGD, Adam)
  - Learning rate scheduling
  - Early stopping conditions
  - Emit progress signals (epoch, loss, accuracy)

- [ ] **T022** Implement `game/sim/machine_configuration.gd`
  - Store placed parts and connections
  - Serialize/deserialize to/from save data
  - Budget tracking (mass, brass, pressure)
  - Validation (check all parts connected, no cycles unless allowed)

- [ ] **T023** Implement `game/sim/level_manager.gd`
  - Load level spec from YAML
  - Validate player's machine against level constraints
  - Check win conditions (accuracy, budget)
  - Trigger level completion
  - Unlock next level

- [ ] **T024** Wire up simulation to integration tests
  - Make T011 (Act I L1) pass
  - Make T012-T015 (Act I L2-L5) pass
  - Verify training converges
  - Verify win conditions trigger

- [ ] **T025** Run all integration tests (T011-T017) - should now pass
  - Act I L1 playthrough test should complete
  - Training should converge to accuracy ≥ 0.95
  - Level completion should trigger
  - Fix any simulation bugs discovered

---

## Phase 3.5: Editor Tooling & Trace Loader (DEFERRED)

**Duration**: 2-3 days  
**Dependencies**: Phase 3.4 (Simulation Engine) complete  
**Goal**: Add editor tools and transformer trace visualization support

**Note**: Originally Phase 3.4, deferred because not blocking critical path. Can implement after simulation engine is working.

**Status**: ⏸️ DEFERRED - Focus on simulation engine first

- [ ] **T026** Implement `addons/steamfitter/validators/level_validator.gd`
  - Validate level YAML against `contracts/level_schema.yaml`
  - Check `allowed_parts` references exist
  - Check budget consistency
  - Return validation errors with descriptive messages

- [ ] **T027** Implement `addons/steamfitter/validators/part_validator.gd`
  - Validate part YAML against `contracts/part_schema.yaml`
  - Check port naming conventions
  - Check scene/icon paths exist
  - Validate port type enums

- [ ] **T028** Implement hot-reload support in `addons/steamfitter/plugin.gd`
  - Watch `data/specs/` and `data/parts/` for changes
  - Re-parse YAML on file save
  - Emit signal on spec update
  - Log reload events to Output panel

- [ ] **T029** Add editor dock for Steamfitter in `addons/steamfitter/dock.tscn`
  - Show list of all levels (28)
  - Show list of all parts (33)
  - Display validation status (✅/❌)
  - Button to validate all specs
  - Button to reload specs

- [ ] **T030** Implement `game/sim/trace_loader.gd` (for Act III transformer levels)
  - Load transformer trace JSON from `data/traces/`
  - Parse metadata (model, prompt, tokens)
  - Parse layer/attention data
  - Decompress uint8 attention weights → float32
  - Cache decompressed traces in memory

---

