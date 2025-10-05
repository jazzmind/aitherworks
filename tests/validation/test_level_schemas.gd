extends GutTest

## Schema validation tests for all level YAML files
# Part of Phase 3.3: Schema Validation Tests (T007)
# Validates all 28+ levels in data/specs/ against level_schema.yaml

const SpecLoader = preload("res://game/sim/spec_loader.gd")

var level_files: Array = []
var all_part_ids: Array = []

func before_all():
	# Get all level YAML files
	level_files = _get_yaml_files("res://data/specs/")
	
	# Get all part IDs for reference validation
	var part_files = _get_yaml_files("res://data/parts/")
	for part_file in part_files:
		var part_spec = SpecLoader.load_yaml(part_file)
		if part_spec.has("id"):
			all_part_ids.append(part_spec["id"])
	
	print("Found %d level files to validate" % level_files.size())
	print("Found %d parts for reference validation" % all_part_ids.size())

func _get_yaml_files(dir_path: String) -> Array:
	var files: Array = []
	var dir = DirAccess.open(dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".yaml"):
				files.append(dir_path.path_join(file_name))
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return files

## Test all levels have required fields

func test_all_levels_have_id():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "id", 
			"Level %s should have 'id' field" % level_file.get_file())

func test_all_levels_have_name():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "name", 
			"Level %s should have 'name' field" % level_file.get_file())

func test_all_levels_have_description():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "description", 
			"Level %s should have 'description' field" % level_file.get_file())

func test_all_levels_have_budget():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "budget", 
			"Level %s should have 'budget' field" % level_file.get_file())

func test_all_levels_have_allowed_parts():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "allowed_parts", 
			"Level %s should have 'allowed_parts' field" % level_file.get_file())

func test_all_levels_have_win_conditions():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		assert_has(level, "win_conditions", 
			"Level %s should have 'win_conditions' field" % level_file.get_file())

## Test ID format

func test_level_ids_follow_pattern():
	# Pattern: act_{act}_l{number}_{slug} OR special cases (act_mid_, example_, level_)
	var id_pattern = RegEx.new()
	id_pattern.compile("^(act_(I|II|III|IV|V|VI)_l\\d+_|act_mid_|example_|level_\\d+_)[a-z_]+$")
	
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("id"):
			var matches = id_pattern.search(level["id"])
			assert_not_null(matches, 
				"Level ID '%s' should match pattern act_{act}_l{num}_{slug} (or act_mid_/example_/level_{num}_)" % level["id"])

func test_level_ids_are_unique():
	var seen_ids = {}
	
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("id"):
			var id = level["id"]
			assert_false(seen_ids.has(id), 
				"Level ID '%s' is duplicated (first in %s, again in %s)" % [
					id, seen_ids.get(id, ""), level_file.get_file()
				])
			seen_ids[id] = level_file.get_file()

## Test name field

func test_level_names_have_content():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("name"):
			var name = level["name"]
			assert_gt(name.length(), 2, 
				"Level name '%s' should be at least 3 characters" % name)
			assert_lt(name.length(), 101, 
				"Level name '%s' should be at most 100 characters" % name)

## Test budget fields

func test_budgets_have_mass():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("budget"):
			assert_has(level["budget"], "mass", 
				"Level %s budget should have 'mass' field" % level_file.get_file())

func test_budgets_have_brass():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("budget"):
			assert_has(level["budget"], "brass", 
				"Level %s budget should have 'brass' field" % level_file.get_file())

func test_budget_values_are_positive():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("budget"):
			var budget = level["budget"]
			
			if budget.has("mass"):
				assert_gt(budget["mass"], 0, 
					"Level %s mass budget should be positive" % level_file.get_file())
			
			if budget.has("brass"):
				assert_gt(budget["brass"], 0, 
					"Level %s brass budget should be positive" % level_file.get_file())
			
			if budget.has("pressure"):
				var pressure = budget["pressure"]
				if pressure is int or pressure is float:
					assert_gt(pressure, 0, 
						"Level %s pressure budget should be positive" % level_file.get_file())

## Test allowed_parts references

func test_allowed_parts_is_array():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("allowed_parts"):
			assert_true(level["allowed_parts"] is Array, 
				"Level %s allowed_parts should be an array" % level_file.get_file())

func test_allowed_parts_not_empty():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("allowed_parts"):
			var parts = level["allowed_parts"]
			assert_gt(parts.size(), 0, 
				"Level %s should allow at least one part" % level_file.get_file())

func test_allowed_parts_reference_existing_parts():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("allowed_parts"):
			var parts = level["allowed_parts"]
			for part_id in parts:
				assert_true(all_part_ids.has(part_id), 
					"Level %s references non-existent part '%s'" % [
						level_file.get_file(), part_id
					])

## Test win_conditions

func test_win_conditions_have_accuracy_or_alternative():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("win_conditions"):
			var wc = level["win_conditions"]
			# Win conditions should have either:
			# 1. accuracy field (most levels)
			# 2. Alternative metrics for special levels (GAN, distillation, etc.)
			# 3. Array of conditions for complex levels
			var has_condition = (
				wc.has("accuracy") or
				wc.has("student_accuracy") or
				wc.has("discriminator_accuracy") or
				wc.has("generator_fooling_rate") or
				wc.has("generator_diversity_index") or
				wc is Array
			)
			assert_true(has_condition, 
				"Level %s win_conditions should have at least one valid metric" % level_file.get_file())

func test_win_accuracy_in_valid_range():
	for level_file in level_files:
		var level = SpecLoader.load_yaml(level_file)
		if level.has("win_conditions") and level["win_conditions"].has("accuracy"):
			var accuracy = level["win_conditions"]["accuracy"]
			assert_true(accuracy >= 0.0, 
				"Level %s accuracy should be >= 0.0 (got %.2f)" % [level_file.get_file(), accuracy])
			assert_true(accuracy <= 1.0, 
				"Level %s accuracy should be <= 1.0 (got %.2f)" % [level_file.get_file(), accuracy])

## Summary test

func test_count_all_levels():
	# We should have at least 18 level files (based on docs)
	assert_true(level_files.size() >= 18, 
		"Should have at least 18 level files (found %d)" % level_files.size())
	
	print("✅ Validated %d level files" % level_files.size())
