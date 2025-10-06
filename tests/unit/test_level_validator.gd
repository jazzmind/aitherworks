extends GutTest

## Unit tests for LevelValidator
## Tests YAML validation against level schema

const LevelValidator = preload("res://addons/steamfitter/validators/level_validator.gd")

var validator: LevelValidator

func before_each() -> void:
	validator = LevelValidator.new()

func after_each() -> void:
	validator = null

## ========================================
## Basic Validation
## ========================================

func test_validate_existing_level() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	assert_not_null(result, "Should return validation result")
	assert_eq(result.level_id, "act_I_l1_dawn_in_dock_ward", "Should extract level ID")
	# May have warnings but should be structurally valid
	assert_true(result.errors.is_empty(), "Should have no errors")

func test_validate_nonexistent_file() -> void:
	var result := validator.validate_level_file("res://data/specs/nonexistent.yaml")
	
	assert_false(result.valid, "Should be invalid")
	assert_gt(result.errors.size(), 0, "Should have error about missing file")

func test_validate_all_levels() -> void:
	var results := validator.validate_all_levels()
	
	assert_gt(results.size(), 0, "Should find level files")
	
	# Count valid vs invalid
	var valid_count := 0
	var invalid_count := 0
	
	for result in results:
		if result.valid:
			valid_count += 1
		else:
			invalid_count += 1
	
	# Most levels should be valid
	assert_gt(valid_count, 0, "Should have at least some valid levels")

func test_validation_result_structure() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	assert_true(result.has_method("add_error"), "Should have add_error method")
	assert_true(result.has_method("add_warning"), "Should have add_warning method")
	assert_true("file_path" in result, "Should have file_path")
	assert_true("level_id" in result, "Should have level_id")
	assert_true("errors" in result, "Should have errors array")
	assert_true("warnings" in result, "Should have warnings array")

## ========================================
## Level ID Validation
## ========================================

func test_valid_level_id_format() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	# Should not have error about invalid ID format
	var has_id_error := false
	for error in result.errors:
		if "Invalid level ID format" in error:
			has_id_error = true
	
	assert_false(has_id_error, "Should have valid ID format")

## ========================================
## Part Reference Validation
## ========================================

func test_allowed_parts_exist() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	# Should not have errors about missing part files
	var has_missing_part_error := false
	for error in result.errors:
		if "Referenced part does not exist" in error:
			has_missing_part_error = true
			print("  Missing part error: %s" % error)
	
	assert_false(has_missing_part_error, "All referenced parts should exist")

## ========================================
## Budget Validation
## ========================================

func test_budget_has_required_fields() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	# Budget should be valid (may have warnings but no errors)
	var has_budget_error := false
	for error in result.errors:
		if "budget" in error.to_lower():
			has_budget_error = true
	
	assert_false(has_budget_error, "Budget should be valid")

## ========================================
## Win Conditions Validation
## ========================================

func test_win_conditions_present() -> void:
	var result := validator.validate_level_file("res://data/specs/act_I_l1_dawn_in_dock_ward.yaml")
	
	# Should have win conditions
	var missing_win_conditions := false
	for error in result.errors:
		if "win_conditions" in error and "Missing" in error:
			missing_win_conditions = true
	
	assert_false(missing_win_conditions, "Should have win conditions")

