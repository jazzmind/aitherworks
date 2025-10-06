extends GutTest

## Integration test for Act I Level 2
# Simplified test - validates level loading and basic structure

const LevelManager = preload("res://game/sim/level_manager.gd")

var level_manager: LevelManager
var level_id: String = "act_I_l2_two_hands_make_a_sum"
var level_spec: LevelManager.LevelSpec

func before_all():
	level_manager = LevelManager.new()
	level_spec = level_manager.load_level(level_id)
	print("\n=== Act I Level 2 Integration Test ===")
	if level_spec:
		print("Level: %s" % level_spec.title)

func test_level_loads():
	assert_not_null(level_spec, "Level YAML should load")
	assert_eq(level_spec.level_id, level_id, "Level ID should match")

func test_level_has_constraints():
	assert_gt(level_spec.allowed_parts.size(), 0, "Should have allowed parts")
	assert_gt(level_spec.budget_mass, 0.0, "Should have budget")

func test_level_has_win_conditions():
	assert_true(level_spec.target_accuracy > 0.0, "Should have target accuracy")
