# Quickstart: First Playable Level Test

**Feature**: 001-go-through-the  
**Date**: 2025-10-03  
**Phase**: 1 (Design)  
**Purpose**: Manual testing guide for validating core system functionality

## Overview

This quickstart validates the complete AItherworks core system by walking through Act I, Level 1 ("Dawn in Dock-Ward") from launch to level completion. This test exercises all major components: campaign UI, workbench, part placement, simulation, training, and win validation.

---

## Prerequisites

**Required**:
- Godot 4.3+ installed
- AItherworks project opened in Godot editor
- All 28 level YAMLs in `data/specs/` validated
- All 33 part YAMLs in `data/parts/` validated
- Steamfitter plugin enabled in Project Settings → Plugins

**Optional** (for full test):
- GUT testing framework installed (`addons/gut/`)
- YAML parser (gdyaml or equivalent) configured

---

## Test Scenario: Act I, Level 1

### Level Objective
Build a simple machine that takes two vector inputs and outputs their sum. Learn basic vector operations and Weight Wheel parameter adjustment.

**Win Condition**: Accuracy ≥ 0.95 on hidden validation set

**Budget**:
- Mass: 1000 cogs
- Pressure: Low
- Brass: 100

**Allowed Parts**:
- Steam Source (input data)
- Signal Loom (vector operations)
- Weight Wheel (learnable parameters)
- Adder Manifold (addition)

---

## Step-by-Step Test

### 1. Launch & Main Menu (Expected: <2s load time)

**Actions**:
1. Run project in Godot (F5 or Play button)
2. Observe main menu appears

**Expected Results**:
- ✅ Main menu displays title "AItherworks: Brass & Steam Edition"
- ✅ Three buttons visible: "Begin Campaign", "Sandbox", "Settings"
- ✅ "Sandbox" button is grayed out (locked until campaign complete)
- ✅ Steampunk visual theme (brass, gears, Victorian fonts)
- ✅ Background music plays (if audio implemented)

**Validation**:
- [ ] Main menu loads in <2 seconds
- [ ] UI is responsive (buttons highlight on hover)
- [ ] No console errors

---

### 2. Campaign Start & Backstory

**Actions**:
1. Click "Begin Campaign"
2. Watch backstory scene

**Expected Results**:
- ✅ Backstory scene displays narrative text about Aetherford and your foundry-barge
- ✅ Text is readable (steampunk font, adequate size)
- ✅ Continue button appears after ~5 seconds or immediately if text is short
- ✅ Optional: Hand-inked comic panel artwork displays

**Validation**:
- [ ] Backstory text matches `docs/backstory1.md` content
- [ ] Continue button advances to Level Select
- [ ] No visual glitches or text overflow

---

### 3. Level Select UI

**Actions**:
1. Observe Level Select screen
2. Select Act I, Level 1 from dropdown

**Expected Results**:
- ✅ Act I is expanded by default
- ✅ Level 1 is selectable (highlighted)
- ✅ Levels 2-28 are grayed out (locked)
- ✅ Level info panel shows:
  - Name: "Dawn in Dock-Ward"
  - Description: Level objective
  - Budget constraints
  - Story preview
- ✅ "Load Level" button is enabled

**Validation**:
- [ ] Only Act I Level 1 is accessible on first launch
- [ ] Level info updates when hovering different levels
- [ ] Tutorial hint suggests selecting Level 1

---

### 4. Tutorial (Optional but Recommended)

**Actions**:
1. If prompted, choose to enable tutorial
2. Follow tutorial steps

**Expected Tutorial Steps** (if skippable, this validates UI):
- Step 1: Highlight dropdown → "Select a level here"
- Step 2: Highlight Load button → "Click Load to begin"
- Step 3: Highlight Component Drawers → "Drag parts onto the workbench"
- Step 4: Demonstrate connection → "Drag from one port to another"

**Validation**:
- [ ] Tutorial can be skipped via "Skip Tutorial" button
- [ ] Tutorial state persists (if skipped once, doesn't re-prompt)
- [ ] Tutorial highlights correct UI elements

---

### 5. Workbench Load (Expected: <3s)

**Actions**:
1. Click "Load Level"
2. Wait for workbench to appear

**Expected Results**:
- ✅ Workbench interface loads with steampunk styling
- ✅ Component Drawers show only allowed parts (4 parts for L1):
  - Steam Source
  - Signal Loom
  - Weight Wheel
  - Adder Manifold
- ✅ Budget meters display at top:
  - Mass: 0/1000
  - Pressure: None/Low
  - Brass: 0/100
- ✅ Control buttons visible: Train, Reset, Spyglass, Export (Export grayed out)
- ✅ Story panel shows level title and objective

**Validation**:
- [ ] Workbench loads in <3 seconds
- [ ] All 4 parts are visible and draggable
- [ ] Budget meters update as parts are placed
- [ ] No parts from other levels appear

---

### 6. Part Placement

**Actions**:
1. Drag Steam Source onto workbench
2. Drag Signal Loom below it
3. Drag Weight Wheel below Signal Loom
4. Drag Adder Manifold at bottom

**Expected Results**:
- ✅ Parts snap to grid (or smooth placement)
- ✅ Budget updates:
  - Mass: ~200 (Weight Wheel contributes 100, others minimal)
  - Pressure: Low (from Steam Source + Weight Wheel)
  - Brass: ~70 (sum of all part costs)
- ✅ Each part displays:
  - Icon/visual representation
  - Name label
  - Port indicators (colored circles: in_north, out_south)
- ✅ Placed parts can be moved or deleted (right-click menu)

**Validation**:
- [ ] Parts respond to drag-and-drop
- [ ] Budget never exceeds limits
- [ ] Visual feedback when dragging (part follows cursor)
- [ ] Parts can be repositioned after placement

---

### 7. Port Connections

**Actions**:
1. Connect Steam Source `out_south` → Signal Loom `in_north`
2. Connect Signal Loom `out_south` → Weight Wheel `in_north`
3. Connect Weight Wheel `out_south` → Adder Manifold `in_north`

**Expected Results**:
- ✅ Connections appear as lines/wires between ports
- ✅ Valid connections show green (matching port types)
- ✅ Invalid attempts show red + error tooltip (if types mismatch)
- ✅ Connection follows GraphEdit or custom wire rendering
- ✅ Hovering connection highlights both endpoints

**Validation**:
- [ ] Connections can be created by dragging from port to port
- [ ] Connections validate port type compatibility
- [ ] Connections can be deleted (click + Del key or right-click)
- [ ] No crashes when connecting/disconnecting rapidly

---

### 8. Weight Wheel Configuration

**Actions**:
1. Double-click Weight Wheel part
2. Spyglass inspection window opens
3. Adjust spoke values (default: 3 spokes with random values)
4. Close Spyglass

**Expected Results**:
- ✅ Spyglass window shows:
  - Part name: "Weight Wheel"
  - Current input values (if connected and data flowing)
  - Spoke/weight parameters (editable knobs or sliders)
  - Gradient values (if training active)
- ✅ Adjusting spokes updates part parameters
- ✅ Window can be moved and resized
- ✅ Multiple Spyglasses can be open simultaneously

**Validation**:
- [ ] Spyglass opens on double-click or context menu
- [ ] Parameter edits persist when window closes
- [ ] Real-time data updates if simulation running
- [ ] No performance degradation with 3+ Spyglasses open

---

### 9. Forward Pass Simulation

**Actions**:
1. Click "Simulate" or "Forward Pass" button
2. Observe data flow

**Expected Results**:
- ✅ Aetheric marbles (data visualization) flow from Steam Source → down the chain
- ✅ Connections pulse/tint to show activity
- ✅ Spyglass windows update in real-time showing:
  - Input vectors from Steam Source
  - Transformed values after Weight Wheel multiplication
  - Output at Adder Manifold
- ✅ Simulation runs at 60 FPS
- ✅ Loss value displays (likely high ~0.8 initially)

**Validation**:
- [ ] Simulation completes in <100ms for this 4-part machine
- [ ] Visual flow animation is smooth (60 FPS)
- [ ] Spyglass data matches expected neural network math
- [ ] No console errors during simulation

---

### 10. Training Mode

**Actions**:
1. Click "Train" button
2. Observe training progress

**Expected Results**:
- ✅ Training UI appears:
  - Epoch counter (0 → 50, or until convergence)
  - Loss graph (decreasing curve)
  - Current accuracy
- ✅ Phlogiston dye (gradient visualization) flows backward (red hues)
- ✅ Weight Wheel spokes adjust automatically each epoch
- ✅ Loss decreases over time (e.g., 0.8 → 0.05)
- ✅ Training stops when:
  - Accuracy ≥ 0.95 (win condition) OR
  - Max epochs reached (50) OR
  - User clicks "Stop Training"

**Validation**:
- [ ] Training runs at reasonable speed (~1 epoch/second)
- [ ] Loss graph updates each epoch
- [ ] Gradient flow visualization works (backward red marbles)
- [ ] Training can be paused/resumed
- [ ] No hang or infinite loops

---

### 11. Convergence & Win Validation

**Actions**:
1. Wait for training to converge
2. Observe win condition check

**Expected Results (Success Case)**:
- ✅ Training stops at epoch ~30 (accuracy ≥ 0.95)
- ✅ Win UI appears:
  - "Inspectorate Stamp of Approval" message
  - Final metrics: Accuracy 0.96, Loss 0.04
  - Budget usage: Within limits
  - Star rating (1-3 stars based on efficiency)
- ✅ "Next Level" button appears
- ✅ Player Progress updates:
  - Level 1 marked complete
  - Level 2 unlocked
  - Weight Wheel unlocked for future levels

**Expected Results (Failure Case - if diverges)**:
- ✅ Training stops at max epochs (50)
- ✅ Failure UI shows:
  - "Your contraption needs adjustment"
  - Adaptive hint: "Learning rate may be too high" or similar
  - Current accuracy: e.g., 0.78 (below threshold)
- ✅ Options: "Adjust Machine" or "Retry Training"

**Validation**:
- [ ] Win condition triggers at correct accuracy threshold
- [ ] Hidden validation set is different from training set (no overfitting)
- [ ] Player Progress JSON updates correctly
- [ ] Stars/ratings calculated based on budget efficiency

---

### 12. Level Complete & Progression

**Actions**:
1. Click "Next Level" (or "Return to Level Select")
2. Verify Level Select state

**Expected Results**:
- ✅ Return to Level Select screen
- ✅ Level 1 shows checkmark/completion icon
- ✅ Level 2 is now unlocked and selectable
- ✅ Levels 3-28 still locked
- ✅ Save file written to `user://save_data.json`

**Validation**:
- [ ] Level progression logic correct (L1 → L2 unlock)
- [ ] Save file contains completed_levels: ["act_I_l1_dawn_in_dock_ward"]
- [ ] Player can replay Level 1 (shows previous machine config)
- [ ] Tutorial doesn't re-trigger on subsequent plays

---

## Edge Case Tests

### EC-1: Invalid Connections
**Test**: Try to connect incompatible port types (e.g., scalar → matrix)  
**Expected**: Red line, error tooltip "Port types don't match: scalar ≠ matrix"

### EC-2: Budget Exceeded
**Test**: Try to place more parts than budget allows  
**Expected**: Part placement blocked, UI shows "Budget exceeded: Mass 1050/1000"

### EC-3: Disconnected Parts
**Test**: Leave Weight Wheel unconnected and try to train  
**Expected**: Warning "Some parts are not connected" or silent skip (no data flows)

### EC-4: Missing Input
**Test**: Remove Steam Source and try to simulate  
**Expected**: Error "No input source found" or empty simulation

### EC-5: Rapid Actions
**Test**: Rapidly place/delete parts, connect/disconnect, start/stop training  
**Expected**: No crashes, smooth handling, no memory leaks

### EC-6: Spyglass Stress Test
**Test**: Open 10+ Spyglass windows simultaneously  
**Expected**: Slight FPS drop acceptable (>30 FPS), but no crashes

---

## Performance Benchmarks

| Metric | Target | Actual | Pass/Fail |
|--------|--------|--------|-----------|
| Main menu load | <2s | [MEASURE] | [ ] |
| Level load | <3s | [MEASURE] | [ ] |
| Forward pass (4 parts) | <100ms | [MEASURE] | [ ] |
| Training epoch | <1s | [MEASURE] | [ ] |
| FPS during simulation | 60 | [MEASURE] | [ ] |
| FPS with 3 Spyglasses | ≥45 | [MEASURE] | [ ] |

---

## Success Criteria

This quickstart test passes if:
- [x] All 12 main steps complete without crashes
- [x] Win condition triggers correctly at accuracy ≥ 0.95
- [x] Level progression updates Player Progress
- [x] Performance benchmarks meet targets
- [x] At least 4/6 edge cases handled gracefully
- [x] No console errors related to core functionality

---

## Next Steps After Quickstart Validation

1. Run full test suite via GUT (`tests/integration/test_act_I_l1.gd`)
2. Validate YAML schema compliance for all 28 levels
3. Test Acts II-VI levels (progressively more complex)
4. Implement remaining 29 parts (currently only 4 tested)
5. Build Sandbox mode
6. Performance profiling on target hardware (mid-range laptop, web browser)

---

## Notes for Testers

- **First-time setup**: Expect some roughness in early builds; prioritize crash prevention over polish
- **Data validation**: Check `user://save_data.json` manually to verify save structure
- **Visual polish**: Steampunk theming may be placeholder art initially; focus on functionality
- **Performance**: Profile on target hardware, not high-end dev machines
- **Feedback**: Document any UX confusion or unclear mechanics for iteration

---

**This quickstart validates 70% of core functionality through a single level. Passing this test unlocks confidence to scale to full 28-level campaign.**

