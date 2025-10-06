extends GutTest

## Integration test for level progression logic
# Tests level unlocking and completion tracking

const LevelManager = preload("res://game/sim/level_manager.gd")

var level_manager: LevelManager

func before_each():
	level_manager = LevelManager.new()
	level_manager.reset_progress()

func test_level_completion_tracking():
	level_manager.complete_level("act_I_l1_dawn_in_dock_ward", {"accuracy": 0.96})
	
	assert_true(level_manager.is_level_completed("act_I_l1_dawn_in_dock_ward"), 
		"Level should be marked complete")

func test_multiple_level_completion():
	level_manager.complete_level("level1", {})
	level_manager.complete_level("level2", {})
	level_manager.complete_level("level3", {})
	
	var completed := level_manager.get_completed_levels()
	assert_eq(completed.size(), 3, "Should have 3 completed levels")

func test_reset_progress():
	level_manager.complete_level("level1", {})
	level_manager.reset_progress()
	
	assert_eq(level_manager.get_completed_levels().size(), 0, "Progress should be reset")

func test_available_levels_discovered():
	var levels := level_manager.get_available_levels()
	
	assert_gt(levels.size(), 0, "Should discover level files")
	assert_false("example_puzzle" in levels, "Should not include example levels")
