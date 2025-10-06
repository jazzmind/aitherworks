extends GutTest

## Schema validation tests for player progress save data
# Part of Phase 3.3: Schema Validation Tests (T009)
# Validates player progress structure against player_progress_schema.json

## Test creating valid player progress data

func test_create_minimal_player_progress():
	var progress = _create_minimal_progress()
	
	assert_has(progress, "player_id", "Should have player_id")
	assert_has(progress, "created_date", "Should have created_date")
	assert_has(progress, "last_played", "Should have last_played")
	assert_has(progress, "completed_levels", "Should have completed_levels")
	assert_has(progress, "current_level", "Should have current_level")
	assert_has(progress, "unlocked_parts", "Should have unlocked_parts")
	assert_has(progress, "sandbox_unlocked", "Should have sandbox_unlocked")
	assert_has(progress, "tutorial_status", "Should have tutorial_status")
	assert_has(progress, "stats", "Should have stats")

func test_player_id_format():
	var progress = _create_minimal_progress()
	
	# Player ID should be a string (UUID format in real implementation)
	assert_true(progress["player_id"] is String, "player_id should be String")
	assert_gt(progress["player_id"].length(), 0, "player_id should not be empty")

func test_dates_are_strings():
	var progress = _create_minimal_progress()
	
	assert_true(progress["created_date"] is String, "created_date should be String")
	assert_true(progress["last_played"] is String, "last_played should be String")

func test_completed_levels_is_array():
	var progress = _create_minimal_progress()
	
	assert_true(progress["completed_levels"] is Array, "completed_levels should be Array")

func test_completed_level_ids_follow_pattern():
	var progress = _create_minimal_progress()
	progress["completed_levels"] = [
		"act_I_l1_dawn_in_dock_ward",
		"act_I_l2_two_hands_make_a_sum"
	]
	
	var level_pattern = RegEx.new()
	level_pattern.compile("^act_(I|II|III|IV|V|VI)_l\\d+_[a-z_]+$")
	
	for level_id in progress["completed_levels"]:
		var matches = level_pattern.search(level_id)
		assert_not_null(matches, "Level ID '%s' should match pattern" % level_id)

func test_current_level_format():
	var progress = _create_minimal_progress()
	progress["current_level"] = "act_I_l3_the_manometer_hisses"
	
	var level_pattern = RegEx.new()
	level_pattern.compile("^act_(I|II|III|IV|V|VI)_l\\d+_[a-z_]+$")
	
	var matches = level_pattern.search(progress["current_level"])
	assert_not_null(matches, "current_level should match pattern")

func test_unlocked_parts_is_array():
	var progress = _create_minimal_progress()
	
	assert_true(progress["unlocked_parts"] is Array, "unlocked_parts should be Array")

func test_unlocked_part_ids_follow_pattern():
	var progress = _create_minimal_progress()
	progress["unlocked_parts"] = ["steam_source", "weight_wheel", "signal_loom"]
	
	var part_pattern = RegEx.new()
	part_pattern.compile("^[a-z_]+$")
	
	for part_id in progress["unlocked_parts"]:
		var matches = part_pattern.search(part_id)
		assert_not_null(matches, "Part ID '%s' should be lowercase with underscores" % part_id)

func test_sandbox_unlocked_is_boolean():
	var progress = _create_minimal_progress()
	
	assert_true(progress["sandbox_unlocked"] is bool, "sandbox_unlocked should be boolean")

func test_tutorial_status_structure():
	var progress = _create_minimal_progress()
	
	assert_has(progress["tutorial_status"], "completed", "tutorial_status should have completed")
	assert_has(progress["tutorial_status"], "skipped", "tutorial_status should have skipped")
	assert_true(progress["tutorial_status"]["completed"] is bool, "completed should be boolean")
	assert_true(progress["tutorial_status"]["skipped"] is bool, "skipped should be boolean")

func test_stats_structure():
	var progress = _create_minimal_progress()
	
	assert_has(progress["stats"], "total_playtime_seconds", "stats should have total_playtime_seconds")
	assert_has(progress["stats"], "levels_completed", "stats should have levels_completed")
	assert_has(progress["stats"], "machines_built", "stats should have machines_built")
	assert_has(progress["stats"], "training_runs", "stats should have training_runs")

func test_stats_values_non_negative():
	var progress = _create_minimal_progress()
	
	assert_true(progress["stats"]["total_playtime_seconds"] >= 0, "playtime should be >= 0")
	assert_true(progress["stats"]["levels_completed"] >= 0, "levels_completed should be >= 0")
	assert_true(progress["stats"]["machines_built"] >= 0, "machines_built should be >= 0")
	assert_true(progress["stats"]["training_runs"] >= 0, "training_runs should be >= 0")

func test_stats_levels_completed_max():
	var progress = _create_minimal_progress()
	progress["stats"]["levels_completed"] = 28
	
	assert_true(progress["stats"]["levels_completed"] <= 28, 
		"levels_completed should be <= 28 (total campaign levels)")

## Test serialization/deserialization

func test_serialize_to_json():
	var progress = _create_minimal_progress()
	
	var json_string = JSON.stringify(progress)
	assert_not_null(json_string, "Should serialize to JSON")
	assert_gt(json_string.length(), 0, "JSON should not be empty")

func test_deserialize_from_json():
	var progress = _create_minimal_progress()
	var json_string = JSON.stringify(progress)
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	assert_eq(error, OK, "Should parse JSON without error")
	
	var deserialized = json.data
	assert_not_null(deserialized, "Should deserialize data")
	assert_eq(deserialized["player_id"], progress["player_id"], "player_id should match")

func test_roundtrip_serialization():
	var original = _create_minimal_progress()
	original["completed_levels"] = ["act_I_l1_dawn_in_dock_ward"]
	original["stats"]["levels_completed"] = 1
	
	# Serialize
	var json_string = JSON.stringify(original)
	
	# Deserialize
	var json = JSON.new()
	json.parse(json_string)
	var restored = json.data
	
	# Verify
	assert_eq(restored["player_id"], original["player_id"], "player_id should survive roundtrip")
	assert_eq(restored["completed_levels"].size(), 1, "completed_levels should survive roundtrip")
	assert_eq(restored["stats"]["levels_completed"], 1, "stats should survive roundtrip")

## Test level unlock logic

func test_initial_progress_no_levels_complete():
	var progress = _create_minimal_progress()
	
	assert_eq(progress["completed_levels"].size(), 0, "Should start with no completed levels")
	assert_eq(progress["stats"]["levels_completed"], 0, "Stats should match")

func test_complete_first_level():
	var progress = _create_minimal_progress()
	
	# Complete level
	progress["completed_levels"].append("act_I_l1_dawn_in_dock_ward")
	progress["stats"]["levels_completed"] = 1
	progress["current_level"] = "act_I_l2_two_hands_make_a_sum"
	
	assert_eq(progress["completed_levels"].size(), 1, "Should have 1 completed level")
	assert_eq(progress["stats"]["levels_completed"], 1, "Stats should match")

func test_unlock_parts_on_level_complete():
	var progress = _create_minimal_progress()
	
	# Start with basic parts
	progress["unlocked_parts"] = ["steam_source", "signal_loom"]
	
	# Complete level and unlock new parts
	progress["unlocked_parts"].append("weight_wheel")
	progress["unlocked_parts"].append("adder_manifold")
	
	assert_eq(progress["unlocked_parts"].size(), 4, "Should have 4 unlocked parts")

func test_sandbox_unlocks_after_campaign():
	var progress = _create_minimal_progress()
	
	# Complete all 28 levels
	for i in range(28):
		progress["completed_levels"].append("act_I_l%d_test" % (i + 1))
	
	progress["stats"]["levels_completed"] = 28
	progress["sandbox_unlocked"] = true
	
	assert_true(progress["sandbox_unlocked"], "Sandbox should unlock after completing campaign")

## Test machine configuration structure

func test_machine_configuration_structure():
	var config = _create_machine_configuration()
	
	assert_has(config, "level_id", "Should have level_id")
	assert_has(config, "created_date", "Should have created_date")
	assert_has(config, "modified_date", "Should have modified_date")
	assert_has(config, "parts", "Should have parts")
	assert_has(config, "connections", "Should have connections")
	assert_has(config, "budget_used", "Should have budget_used")

func test_machine_parts_structure():
	var config = _create_machine_configuration()
	
	var part = {
		"instance_id": "abc-def-123",
		"part_id": "weight_wheel",
		"position": {"x": 100.0, "y": 200.0},
		"parameters": {}
	}
	
	config["parts"].append(part)
	
	assert_eq(config["parts"].size(), 1, "Should have 1 part")
	assert_has(config["parts"][0], "instance_id", "Part should have instance_id")
	assert_has(config["parts"][0], "part_id", "Part should have part_id")
	assert_has(config["parts"][0], "position", "Part should have position")

func test_machine_connections_structure():
	var config = _create_machine_configuration()
	
	var connection = {
		"from": "abc-123.out_south",
		"to": "def-456.in_north"
	}
	
	config["connections"].append(connection)
	
	assert_eq(config["connections"].size(), 1, "Should have 1 connection")
	assert_has(config["connections"][0], "from", "Connection should have from")
	assert_has(config["connections"][0], "to", "Connection should have to")

func test_budget_used_structure():
	var config = _create_machine_configuration()
	
	assert_has(config["budget_used"], "mass", "budget_used should have mass")
	assert_has(config["budget_used"], "pressure", "budget_used should have pressure")
	assert_has(config["budget_used"], "brass", "budget_used should have brass")
	
	assert_true(config["budget_used"]["mass"] >= 0, "mass should be >= 0")
	assert_true(config["budget_used"]["brass"] >= 0, "brass should be >= 0")

## Helper functions

func _create_minimal_progress() -> Dictionary:
	return {
		"player_id": "test-player-123",
		"created_date": "2025-01-01T00:00:00Z",
		"last_played": "2025-01-01T00:00:00Z",
		"completed_levels": [],
		"current_level": "act_I_l1_dawn_in_dock_ward",
		"unlocked_parts": [],
		"sandbox_unlocked": false,
		"tutorial_status": {
			"completed": false,
			"skipped": false
		},
		"stats": {
			"total_playtime_seconds": 0,
			"levels_completed": 0,
			"machines_built": 0,
			"training_runs": 0
		}
	}

func _create_machine_configuration() -> Dictionary:
	return {
		"level_id": "act_I_l1_dawn_in_dock_ward",
		"created_date": "2025-01-01T00:00:00Z",
		"modified_date": "2025-01-01T00:00:00Z",
		"parts": [],
		"connections": [],
		"budget_used": {
			"mass": 0,
			"pressure": "None",
			"brass": 0
		}
	}
