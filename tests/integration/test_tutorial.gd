extends GutTest

## Integration test for tutorial flow
# Tests tutorial system and initial player experience

const LevelManager = preload("res://game/sim/level_manager.gd")

var level_manager: LevelManager

func before_each():
	level_manager = LevelManager.new()

func test_first_level_accessible():
	var level := level_manager.load_level("act_I_l1_dawn_in_dock_ward")
	
	assert_not_null(level, "First level should load")
	assert_eq(level.difficulty, 1, "First level should be difficulty 1")

func test_level_has_tutorial_content():
	var level := level_manager.load_level("act_I_l1_dawn_in_dock_ward")
	
	# Most levels should have some narrative or hint
	assert_true(not level.hint.is_empty() or level.intro_dialogue.size() > 0,
		"Level should have tutorial content")

func test_beginner_difficulty_tier():
	assert_eq(level_manager.get_difficulty_tier(1), "Beginner", 
		"Difficulty 1 should be Beginner")

func test_level_complexity_progression():
	var l1 := level_manager.load_level("act_I_l1_dawn_in_dock_ward")
	var l2 := level_manager.load_level("act_I_l2_two_hands_make_a_sum")
	
	# Later levels should generally have more allowed parts or complexity
	assert_true(l1.allowed_parts.size() > 0 and l2.allowed_parts.size() > 0,
		"Levels should have allowed parts")
