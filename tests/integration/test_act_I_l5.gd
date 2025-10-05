extends GutTest

## Integration test for Act I Level 5: Debt Collectors Demo
# Part of Phase 3.3: Integration Tests (T015)
# EXPECTED TO FAIL: No simulation engine implemented yet

const SpecLoader = preload("res://game/sim/spec_loader.gd")

var level_spec: Dictionary
var level_id: String = "act_I_l5_debt_collectors_demo"

func before_all():
	level_spec = SpecLoader.load_yaml("res://data/specs/act_I_l5_debt_collectors_demo.yaml")
	print("\n=== Act I Level 5 Integration Test ===")

func test_level_loads():
	assert_not_null(level_spec, "Level YAML should load")
	assert_eq(level_spec["id"], level_id, "Level ID should match")

func test_level_playthrough():
	pending("Simulation engine not implemented - Level 5 playthrough not possible yet")
