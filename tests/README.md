# AItherworks Test Suite

This directory contains all automated tests for the AItherworks project using the GUT (Godot Unit Test) framework.

## Directory Structure

```
tests/
├── .gutconfig.json         # GUT configuration (test directories, colors, output)
├── unit/                   # Part behavior tests (33 parts)
├── integration/            # Level playthrough tests (Acts I-VI)
├── validation/             # Schema validation tests (YAML/JSON)
└── performance/            # Profiling and performance benchmark tests
```

## Test Categories

### Unit Tests (`unit/`)
Test individual machine parts in isolation:
- Part behavior (forward pass, backward pass)
- Port connectivity and type validation
- Parameter adjustment (e.g., Weight Wheel spokes)
- Gradient flow accuracy

**Naming Convention**: `test_<part_name>.gd`
**Example**: `test_weight_wheel.gd`, `test_steam_source.gd`

### Integration Tests (`integration/`)
Test complete level playthroughs end-to-end:
- Level loading from YAML
- Part placement and connection
- Training loop (forward + backward passes)
- Win condition validation
- Player progress persistence

**Naming Convention**: `test_act_<act>_l<level>.gd`
**Example**: `test_act_I_l1.gd` (Act I, Level 1: Dawn in Dock-Ward)

### Validation Tests (`validation/`)
Test YAML/JSON schema compliance:
- All 28 level specs validate against `contracts/level_schema.yaml`
- All 33 part specs validate against `contracts/part_schema.yaml`
- Player progress JSON matches schema
- Transformer trace JSON matches schema

**Naming Convention**: `test_<entity>_schemas.gd`
**Example**: `test_level_schemas.gd`, `test_part_schemas.gd`

### Performance Tests (`performance/`)
Benchmark critical performance paths:
- Simulation loop (forward/backward pass) <16ms target
- Level load times <3s target
- Spyglass real-time updates (60 FPS)
- YAML parsing performance

**Naming Convention**: `test_<system>_performance.gd`
**Example**: `test_simulation_performance.gd`

## Running Tests

### Via Godot Editor
1. Open project in Godot
2. Open GUT panel (usually at bottom of editor)
3. Click "Run All" to execute all tests
4. Or select specific test file from tree

### Via Command Line (Headless)
```bash
# Run all tests
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=tests/ -gexit

# Run specific directory
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=tests/unit/ -gexit

# Run single test file
godot --headless --path . -s addons/gut/gut_cmdln.gd -gselect=tests/unit/test_weight_wheel.gd -gexit
```

### CI/CD Integration
See `.github/workflows/godot-ci.yml` for automated test execution on every commit.

## Test-Driven Development (TDD) Workflow

Per Constitution v1.1.0 and `tasks.md`, AItherworks follows **strict TDD**:

1. **Write test first** (e.g., `test_weight_wheel.gd`)
2. **Run test** → MUST FAIL (no implementation yet)
3. **Implement feature** (e.g., `game/parts/weight_wheel.gd`)
4. **Run test** → should now PASS
5. **Refactor** if needed
6. **Commit** test + implementation together

**Example**:
- T030: Write unit test for Weight Wheel (FAIL expected)
- T031: Implement Weight Wheel (test now PASS)

## Test Writing Guidelines

### GUT Assertion Syntax
```gdscript
extends GutTest

func test_weight_wheel_forward_pass():
    var wheel = preload("res://game/parts/weight_wheel.tscn").instantiate()
    add_child(wheel)
    
    # Setup
    wheel.set_spokes([0.5, 0.3, 0.9])
    var input = [1.0, 2.0, 3.0]
    
    # Execute
    var output = wheel._forward(input)
    
    # Assert
    assert_eq(output.size(), 3, "Output size matches input")
    assert_almost_eq(output[0], 0.5, 0.001, "Spoke multiplication correct")
    assert_almost_eq(output[1], 0.6, 0.001, "Spoke multiplication correct")
    assert_almost_eq(output[2], 2.7, 0.001, "Spoke multiplication correct")
```

### Common Assertions
- `assert_eq(a, b, msg)` - Equality check
- `assert_ne(a, b, msg)` - Inequality check
- `assert_almost_eq(a, b, tolerance, msg)` - Float comparison with tolerance
- `assert_true(condition, msg)` - Boolean true
- `assert_false(condition, msg)` - Boolean false
- `assert_null(value, msg)` - Null check
- `assert_not_null(value, msg)` - Not null check
- `assert_has(container, value, msg)` - Array/dictionary contains check

## Performance Targets

Per `plan.md` Technical Context:
- **Simulation loop**: <16ms for 20-part machine (60 FPS)
- **Level load**: <3s on mid-range hardware
- **Forward/backward pass**: <100ms for typical machines
- **Spyglass updates**: 60 FPS with 3 windows open, ≥45 FPS with more

## Coverage Goals

- **Unit Tests**: 100% of 33 parts
- **Integration Tests**: All Act I levels (L1-L5) minimum, ideally all Acts
- **Validation Tests**: 100% of YAML/JSON schemas
- **Performance Tests**: All critical paths profiled

## Status

Current test coverage: **0%** (Phase 3.1 setup)

Tests will be implemented in **Phase 3.2** (T007-T017) following TDD strict workflow.

## See Also

- `tasks.md` - Complete task list with test task IDs
- `quickstart.md` - Manual test scenario for Act I Level 1
- `contracts/` - Schema definitions for validation tests
- `data-model.md` - Entity definitions for test fixtures

