# Port Naming Schema Proposals

## Current State

- **Current parts**: Max 3 inputs, max 2 outputs (fits within 4 cardinal directions)
- **Current usage**: `in-1`, `in-2`, `out-1` (non-compliant with schema)
- **Current schema**: `^(in|out)_(north|south|east|west)$` (strict cardinal)

---

## Option 1: Strict Cardinal (Current Schema) ⭐ RECOMMENDED

**Pattern**: `(in|out)_(north|south|east|west)`

**Examples**:
```yaml
ports:
  in_north: { type: "vector", direction: "input" }
  in_east: { type: "vector", direction: "input" }
  out_south: { type: "vector", direction: "output" }
```

**Pros**:
- ✅ Visual/spatial meaning (matches Godot GraphNode visual layout)
- ✅ Intuitive for visual editor (ports literally appear on those sides)
- ✅ Current parts fit (max 3 in + 2 out = 5 ≤ 8 total cardinal slots)
- ✅ Supports up to 4 inputs AND 4 outputs (8 total ports)
- ✅ Natural for steampunk aesthetic (pipes on sides of machines)

**Cons**:
- ⚠️ Breaks if a part needs >4 inputs or >4 outputs
- ⚠️ Requires thoughtful assignment (which input goes north vs east?)

**Max Capacity**: 4 inputs + 4 outputs = **8 total ports**

**Fits Current Parts**: ✅ YES (max is 3 in + 1 out = 4 total)

**Future-Proof**: ✅ YES for typical ML parts (attention has 3 inputs: Q, K, V)

---

## Option 2: Numbered (Flexible)

**Pattern**: `(in|out)_[1-9]+`

**Examples**:
```yaml
ports:
  in_1: { type: "vector", direction: "input" }
  in_2: { type: "vector", direction: "input" }
  out_1: { type: "vector", direction: "output" }
```

**Pros**:
- ✅ Unlimited ports (in_1, in_2, ..., in_99)
- ✅ Simple, unambiguous
- ✅ Easy to generate programmatically

**Cons**:
- ❌ No spatial meaning (loses visual clarity)
- ❌ Harder to match to physical GraphNode layout
- ❌ Less intuitive ("which port is in_3?")
- ❌ Loses steampunk aesthetic

**Max Capacity**: **Unlimited**

**Fits Current Parts**: ✅ YES

**Future-Proof**: ✅ YES

---

## Option 3: Hybrid (Cardinal + Numbered) 🎯 BEST OF BOTH

**Pattern**: `(in|out)_(north|south|east|west)(?:_[1-9]+)?`

**Examples**:
```yaml
# Simple part (1-4 ports per side)
ports:
  in_north: { type: "vector", direction: "input" }
  out_south: { type: "vector", direction: "output" }

# Complex part (>4 inputs, use multiple ports per side)
ports:
  in_north_1: { type: "vector", direction: "input" }
  in_north_2: { type: "vector", direction: "input" }
  in_east_1: { type: "vector", direction: "input" }
  in_east_2: { type: "vector", direction: "input" }
  in_south_1: { type: "vector", direction: "input" }
  out_west: { type: "vector", direction: "output" }
```

**Pros**:
- ✅ Spatial meaning retained (cardinal directions)
- ✅ Unlimited capacity (multiple ports per side)
- ✅ Visual editor can stack ports on same side
- ✅ Backward compatible with Option 1 (optional `_N` suffix)
- ✅ Natural progression (simple parts use cardinal, complex parts add numbers)

**Cons**:
- ⚠️ Slightly more complex pattern
- ⚠️ Need to decide which side gets which ports

**Max Capacity**: **Unlimited** (multiple ports per cardinal direction)

**Fits Current Parts**: ✅ YES

**Future-Proof**: ✅ YES (best option for extensibility)

**Visual Layout**:
```
         [in_north_1] [in_north_2]
                 +---------+
    [in_west_1]  |  PART   |  [in_east_1]
    [in_west_2]  |         |  [in_east_2]
                 +---------+
        [out_south_1] [out_south_2]
```

---

## Comparison Matrix

| Feature | Option 1 (Cardinal) | Option 2 (Numbered) | Option 3 (Hybrid) |
|---------|---------------------|---------------------|-------------------|
| Visual Clarity | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| Extensibility | ⭐⭐ (up to 8) | ⭐⭐⭐ (unlimited) | ⭐⭐⭐ (unlimited) |
| Simplicity | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Steampunk Fit | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| Current Parts | ✅ Fits | ✅ Fits | ✅ Fits |
| Future ML Parts | ✅ Likely fits | ✅ Definitely fits | ✅ Definitely fits |

---

## Real-World ML Part Analysis

### Typical Neural Network Layers

**Linear/Dense Layer**:
- Inputs: 1 (data)
- Outputs: 1 (transformed data)
- **Fits**: ✅ All options

**Attention Mechanism**:
- Inputs: 3 (Query, Key, Value)
- Outputs: 1 (attention output) + optional (attention weights for visualization)
- **Fits**: ✅ All options (3 in + 2 out = 5 ≤ 8 cardinals)

**Multi-Head Attention** (most complex in transformers):
- Inputs: 3 (Q, K, V)
- Outputs: 1 (concatenated heads) + 8 (individual head outputs for inspection)
- **Problem**: 9 outputs exceeds 4 cardinal outputs
- **Solution**: Option 3 (out_south_1 through out_south_9)

**Residual Connection**:
- Inputs: 2 (main path + skip connection)
- Outputs: 1 (sum)
- **Fits**: ✅ All options

**Ensemble/Voting**:
- Inputs: 5-10 (multiple model outputs)
- Outputs: 1 (ensemble result)
- **Problem**: May exceed 4 inputs
- **Solution**: Option 3 (in_north_1 through in_north_10)

---

## Recommendation

### For AItherworks: **Option 3 (Hybrid)** 🎯

**Rationale**:
1. **Current parts fit**: Can use simple cardinal names (`in_north`, `out_south`)
2. **Future-proof**: Can add `_1`, `_2` suffixes when needed
3. **Visual clarity**: Maintains spatial meaning
4. **Steampunk aesthetic**: Pipes naturally go on sides of machines
5. **Godot GraphNode**: Matches visual layout (nodes have sides)

**Schema Update**:
```yaml
pattern_properties:
  "^(in|out)_(north|south|east|west)(?:_[1-9][0-9]*)?$":
    type: object
    required: [type, direction]
    fields:
      type: { enum: [scalar, vector, matrix, tensor, ...] }
      direction: { enum: [input, output] }
```

**Migration Path**:
1. Fix current parts with simple cardinal (most have 1-2 ports)
2. Parts with 3 inputs use `in_north`, `in_east`, `in_south`
3. Future complex parts can use `in_north_1`, `in_north_2`, etc.

---

## Implementation Plan

### Phase 1: Update Schema ✅
```yaml
# New pattern (Option 3)
"^(in|out)_(north|south|east|west)(?:_[1-9][0-9]*)?$"
```

### Phase 2: Simple Mapping for Current Parts
```
in-1  → in_north
in-2  → in_east  (or in_south if makes more visual sense)
in-3  → in_south (for looking_glass_array)
out-1 → out_south
out-2 → out_west (for pneumail_librarium)
```

### Phase 3: Update Part YAMLs
- 21 files with 1 in + 1 out: Simple cardinal assignment
- 4 files with 2 inputs: Choose north/east or north/south
- 1 file with 3 inputs (looking_glass_array): north/east/south
- 1 file with 2 outputs (pneumail_librarium): south/west

### Phase 4: Document Guidelines
```markdown
## Port Naming Guidelines

### Simple Parts (1-4 ports total)
Use cardinal directions: in_north, out_south, etc.

Visual layout:
         [in_north]
         +---------+
[in_west]|  PART   |[in_east]
         +---------+
        [out_south]

### Complex Parts (>4 ports per direction)
Use numbered suffixes: in_north_1, in_north_2, etc.

Example (8 inputs):
  in_north_1, in_north_2  (2 on north)
  in_east_1, in_east_2    (2 on east)
  in_south_1, in_south_2  (2 on south)
  in_west_1, in_west_2    (2 on west)
```

---

## Decision Required

**Question for team**: Which option?

1. **Option 1 (Strict Cardinal)**: Simple, current parts fit, but limited to 8 total ports
2. **Option 2 (Numbered)**: Unlimited, but loses visual meaning
3. **Option 3 (Hybrid)**: Best of both, slightly more complex ⭐ **RECOMMENDED**

**My vote**: **Option 3** - Future-proof while maintaining visual clarity

---

**Status**: Awaiting decision before proceeding with fixes  
**Impact**: 23 files need updating regardless of choice  
**Time Estimate**: 2-4 hours for any option


