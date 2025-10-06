# Port Naming Schema Resolution (T217)

**Date**: 2025-10-05  
**Status**: ✅ RESOLVED  
**Task**: T217 (Phase 3.2.5)  
**Impact**: CRITICAL - Unblocked all 33 part YAMLs

---

## Problem Statement

During retrofit testing (T200), discovered that 23 out of 33 part YAML files violated the port naming schema:

- **Schema Expected**: `^(in|out)_(north|south|east|west)$` (strict cardinal)
- **Files Used**: `in-1`, `in-2`, `out-1`, `signal_in`, `weighted_out` (numbered/descriptive)
- **Compliance**: 1/33 files (3%) ❌
- **Violations**: 52 port names across 23 files

This was a **BLOCKING ISSUE** preventing:
- Schema validation from working
- Port type checking in tests
- GraphNode visual layout consistency

---

## User Concern

> "In some cases we might need more than 4 inputs or outputs. So cardinal naming might not be enough."

**Valid concern**: Multi-head attention parts could need 8+ inputs (one per attention head).

---

## Analysis Performed

### Current Port Usage
Analyzed all 33 part YAMLs:
- **Max inputs**: 3 (looking_glass_array)
- **Max outputs**: 2 (pneumail_librarium)
- **Max total ports**: 4 per part
- **Conclusion**: All current parts fit within 4 cardinal directions ✅

### Future Requirements
- **Transformer parts**: Multi-head attention (8-16 heads)
- **Complex parts**: May need >4 ports per direction
- **Scalability**: Schema must support unlimited ports

---

## Solution: Option 3 (Hybrid Cardinal + Numbered)

### Schema Pattern
```regex
^(in|out)_(north|south|east|west)(?:_[1-9][0-9]*)?$
```

### Examples
```yaml
# Simple parts (≤4 ports per direction)
ports:
  in_north:
    type: "vector"
    direction: "input"
  out_south:
    type: "vector"
    direction: "output"

# Complex parts (>4 ports per direction)
ports:
  in_north_1:
    type: "attention_weights"
    direction: "input"
  in_north_2:
    type: "attention_weights"
    direction: "input"
  # ... up to in_north_16 for 16-head attention
```

### Visual Layout (Godot GraphNode)
- `north` = top edge
- `south` = bottom edge
- `east` = right edge
- `west` = left edge
- Numbered ports stack vertically on same edge

---

## Benefits

1. **Visual Clarity**: Cardinal names provide spatial meaning for simple parts
2. **Unlimited Scalability**: Numbered suffix supports any number of ports
3. **Future-Proof**: Handles multi-head attention and complex parts
4. **Godot-Friendly**: Maps naturally to GraphNode layout
5. **Backward Compatible**: Existing simple parts don't need numbered suffix

---

## Implementation

### Files Updated
- **Schema**: `specs/001-go-through-the/contracts/part_schema.yaml`
  - Updated pattern with optional numbered suffix
  - Added examples and notes
- **Part YAMLs**: All 33 files in `data/parts/`
  - Converted `in-1` → `in_north`
  - Converted `in-2` → `in_east`
  - Converted `out-1` → `out_south`
  - Converted descriptive names → cardinal equivalents

### Port Mapping Strategy
Applied based on input/output configuration:

| Config | Mapping |
|--------|---------|
| 1 in, 1 out (21 files) | `in-1` → `in_north`, `out-1` → `out_south` |
| 2 in, 1 out (4 files) | `in-1` → `in_north`, `in-2` → `in_east`, `out-1` → `out_south` |
| 3 in, 1 out (1 file) | `in-1` → `in_north`, `in-2` → `in_east`, `in-3` → `in_west`, `out-1` → `out_south` |
| 1 in, 2 out (1 file) | `in-1` → `in_north`, `out-1` → `out_south`, `out-2` → `out_east` |
| 0 in, 1 out (1 file) | `out-1` → `out_south` |

### Automation
Created temporary tools (deleted after use):
- `fix_all_ports.gd`: Automated conversion for numbered ports (23 files)
- `audit_ports.gd`: Schema compliance validator
- `analyze_port_counts.gd`: Port usage analyzer

---

## Results

### Before
- ❌ Compliance: 1/33 files (3%)
- ❌ Violations: 52 port names
- ❌ Schema: Too restrictive (4 port limit)

### After
- ✅ Compliance: 33/33 files (100%)
- ✅ Violations: 0
- ✅ Schema: Supports unlimited ports
- ✅ Tests: `test_steam_source` 24/24 passing

---

## Verification

```bash
# Run audit
godot --headless --path . -s audit_ports.gd

# Output:
# ✅ All 33 part YAMLs follow schema naming convention!
# Compliant: 33
# Non-compliant: 0
# Issues found: 0
```

---

## Future Usage

### Adding Simple Parts (≤4 ports)
```yaml
ports:
  in_north:    # Use cardinal names only
    type: "vector"
    direction: "input"
  out_south:
    type: "vector"
    direction: "output"
```

### Adding Complex Parts (>4 ports)
```yaml
ports:
  in_north_1:  # Use numbered suffix
    type: "attention_weights"
    direction: "input"
  in_north_2:
    type: "attention_weights"
    direction: "input"
  # ... continue as needed
```

---

## Lessons Learned

1. **Schema Design**: Balance strictness with flexibility
2. **Future-Proofing**: Consider scalability from the start
3. **Visual Semantics**: Spatial names (north/south) aid understanding
4. **Automation**: Tools can fix bulk issues quickly
5. **Validation**: Continuous schema checking prevents drift

---

## Related Documents

- **Crisis Report**: `docs/port_naming_crisis.md`
- **Proposals**: `docs/port_naming_proposals.md`
- **Schema**: `specs/001-go-through-the/contracts/part_schema.yaml`
- **Tasks**: `specs/001-go-through-the/tasks.md` (T217)
- **Test Report**: `tests/retrofit_test_report.md`

---

## Status

✅ **RESOLVED** - All 33 part YAMLs schema-compliant  
✅ **TESTED** - Steam Source tests passing  
✅ **DOCUMENTED** - Schema updated with examples  
✅ **FUTURE-PROOF** - Supports unlimited ports

**Next**: Continue Phase 3.2 retrofit testing (T201-T210)
