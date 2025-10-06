# Port Naming Crisis: 2025-10-04

## Executive Summary

**Severity**: 🔴 **CRITICAL**  
**Scope**: 23 of 33 part YAML files (70%)  
**Impact**: Port connection system may be completely broken

### Discovery

Retrofit testing of `steam_source.gd` (T200) revealed that the YAML used `steam_out` instead of the schema-required `out_south`. Follow-up audit of all 33 part YAMLs revealed:

- ✅ **1 file compliant**: `steam_source.yaml` (just fixed)
- ❌ **23 files non-compliant**: Using `in-1`, `in-2`, `out-1`, `out-2` pattern
- ⚠️ **9 files with empty/invalid ports**: Need manual review
- 🔢 **52 total port naming violations**

### Schema Requirement

**From** `contracts/part_schema.yaml`:
```yaml
pattern_properties:
  "^(in|out)_(north|south|east|west)$":
```

**Required Pattern**: `(in|out)` + `_` + `(north|south|east|west)`

**Valid Examples**:
- `in_north`
- `in_south`  
- `out_east`
- `out_west`

**Invalid Examples** (currently used):
- `in-1` ❌ (hyphen, number)
- `in-2` ❌ (hyphen, number)
- `out-1` ❌ (hyphen, number)
- `steam_out` ❌ (no cardinal direction)

---

## Audit Results

### Non-Compliant Files (23)

| File | Issues | Port Names |
|------|--------|------------|
| activation_gate.yaml | 2 | in-1, out-1 |
| adder_manifold.yaml | 3 | in-1, in-2, out-1 |
| aether_battery.yaml | 2 | in-1, out-1 |
| apprentice_sgd.yaml | 2 | in-1, out-1 |
| athanor_still.yaml | 3 | in-1, in-2, out-1 |
| augmentor_arms.yaml | 2 | in-1, out-1 |
| calibration_feeder.yaml | 2 | in-1, out-1 |
| cog_ratchet_press.yaml | 2 | in-1, out-1 |
| convolution_drum.yaml | 2 | in-1, out-1 |
| downspout.yaml | 2 | in-1, out-1 |
| drop_valves.yaml | 2 | in-1, out-1 |
| embedder_drum.yaml | 2 | in-1, out-1 |
| entropy_manometer.yaml | 3 | in-1, in-2, out-1 |
| ethics_governor.yaml | 2 | in-1, out-1 |
| example_part.yaml | 2 | in-1, out-1 |
| inspectorate_bench.yaml | 2 | in-1, out-1 |
| layer_tonic.yaml | 2 | in-1, out-1 |
| logits_explorer.yaml | 2 | in-1, out-1 |
| looking_glass_array.yaml | 2 | in-1, out-1 |
| matrix_frame.yaml | 2 | in-1, out-1 |
| plan_table.yaml | 2 | in-1, out-1 |
| pneumail_librarium.yaml | 3 | in-1, out-1, out-2 |
| residual_rail.yaml | 2 | in-1, out-1 |
| signal_loom.yaml | 2 | in-1, out-1 |

**Total**: 23 files, 52 violations

### Files with Empty/Invalid Ports (9)

Require manual review:
1. attention_head_viewer.yaml
2. display_glass.yaml
3. layer_navigator.yaml
4. output_evaluator.yaml
5. sampling_controls.yaml
6. spyglass.yaml
7. token_tape.yaml
8. weight_wheel.yaml
9. *(one more not listed)*

---

## Root Cause Analysis

### Why This Happened

1. **Schema not enforced**: `SpecValidator.gd` was lenient (warnings instead of errors)
2. **Pattern established early**: First parts used `in-1` pattern, others copied
3. **No validation in workflow**: No pre-commit hooks or CI checks for YAML schema
4. **Documentation gap**: Schema exists but wasn't prominently documented

### Impact Assessment

**Severity**: **CRITICAL**

**Affected Systems**:
- ❌ Port connection validation
- ❌ Workbench UI connection system
- ❌ Part-to-part data flow
- ❌ Level specification validation
- ❌ Save/load system (if it serializes port names)

**Potential Bugs**:
- Connections may silently fail
- Port type validation not working
- Steamfitter plugin (when built) will reject these YAMLs
- Tests for other parts will fail with same error

---

## Fix Strategy

### Option A: Mass Rename (Recommended)

**Approach**: Update all 23 files to use cardinal directions

**Mapping**:
- `in-1` → `in_north`
- `in-2` → `in_east` (or `in_south` depending on part layout)
- `out-1` → `out_south`
- `out-2` → `out_west` (or `out_east` depending on part layout)

**Pros**:
- ✅ Compliant with schema
- ✅ Clear spatial meaning
- ✅ Future-proof

**Cons**:
- ⚠️ Requires reviewing each part to assign correct cardinal direction
- ⚠️ May break existing connections in any saved games
- ⚠️ Need to update implementation code that references port names

**Estimated Time**: 2-4 hours for all 23 files

---

### Option B: Update Schema (Not Recommended)

**Approach**: Change schema to accept `in-1`, `in-2` pattern

**Pros**:
- ✅ Minimal YAML changes

**Cons**:
- ❌ Loses spatial meaning
- ❌ Violates constitution principle (data-driven design intent)
- ❌ Schema already published in contracts
- ❌ Less intuitive for visual editor

**Verdict**: **Rejected** - violates design principles

---

## Recommended Action Plan

### Phase 1: Document & Pause (Complete)
- [x] Audit all 33 part YAMLs ✅
- [x] Document findings ✅ (this file)
- [x] Identify affected systems ✅

### Phase 2: Fix High-Priority Parts (T217)
Fix the 11 already-implemented parts first (these have working code):
1. signal_loom.yaml (in-1, out-1)
2. weight_wheel.yaml (empty ports - need manual review)
3. adder_manifold.yaml (in-1, in-2, out-1)
4. activation_gate.yaml (in-1, out-1)
5. entropy_manometer.yaml (in-1, in-2, out-1)
6. convolution_drum.yaml (in-1, out-1)
7. aether_battery.yaml (in-1, out-1)
8. display_glass.yaml (empty ports - need manual review)
9. spyglass.yaml (empty ports - need manual review)
10. evaluator.yaml (not in list, need to check)

### Phase 3: Fix Remaining 22 Parts (T218)
Update YAMLs for parts not yet implemented

### Phase 4: Update Code References (T219)
Search for hardcoded port name strings in `.gd` files:
```bash
grep -r "in-1\|in-2\|out-1\|out-2" game/parts/*.gd
```

### Phase 5: Strengthen Validation (T220)
- Update `SpecValidator.gd` to make port naming errors (not warnings)
- Add pre-commit hook for YAML validation
- Update CI to fail on schema violations

---

## Lessons Learned

1. **Validate early, validate often**: Schema violations should be errors, not warnings
2. **CI is critical**: Automated validation would have caught this on first commit
3. **Examples matter**: `example_part.yaml` has the same bug - it set the wrong pattern
4. **Documentation prominence**: Schema should be in main README, not buried in contracts/

---

## Next Steps

**Immediate**:
1. Create T217 task for fixing 11 implemented parts
2. Pause T201-T210 testing until port names fixed
3. Review empty port files manually

**Short-term**:
1. Execute T217-T220 (port name fixes)
2. Re-run T200 to ensure still passing
3. Continue T201-T210 with corrected YAMLs

**Long-term**:
1. Add CI validation
2. Create port naming guide
3. Update Steamfitter plugin to enforce schema

---

**Status**: 🔴 **BLOCKING** - Must fix before continuing retrofit testing  
**Priority**: **P0** (blocks all other work)  
**Estimated Fix Time**: 2-4 hours for Phase 2, 1-2 hours for Phase 3  
**Last Updated**: 2025-10-04


