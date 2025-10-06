extends GutTest

## Unit tests for MachineConfiguration
## Tests part placement, connections, budget tracking, and serialization

const MachineConfiguration = preload("res://game/sim/machine_configuration.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")

var config: MachineConfiguration

func before_each() -> void:
	config = MachineConfiguration.new()

func after_each() -> void:
	config = null

## ========================================
## Part Management
## ========================================

func test_add_part() -> void:
	var wheel := WeightWheel.new()
	var placed := config.add_part("weight_wheel", wheel, Vector2(100, 100))
	
	assert_not_null(placed, "Should return placed part")
	assert_eq(placed.part_id, "weight_wheel", "Part ID should match")
	assert_eq(placed.position, Vector2(100, 100), "Position should match")
	assert_eq(config.placed_parts.size(), 1, "Should have 1 part")
	
	wheel.free()

func test_remove_part() -> void:
	var wheel := WeightWheel.new()
	var placed := config.add_part("weight_wheel", wheel)
	
	var removed := config.remove_part(placed.instance_name)
	assert_true(removed, "Should remove part")
	assert_eq(config.placed_parts.size(), 0, "Should have 0 parts")
	
	wheel.free()

func test_get_part() -> void:
	var wheel := WeightWheel.new()
	var placed := config.add_part("weight_wheel", wheel)
	
	var retrieved := config.get_part(placed.instance_name)
	assert_not_null(retrieved, "Should find part")
	assert_eq(retrieved.instance_name, placed.instance_name, "Should be same part")
	
	wheel.free()

func test_get_parts_by_type() -> void:
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	var steam := SteamSource.new()
	
	config.add_part("weight_wheel", wheel1)
	config.add_part("weight_wheel", wheel2)
	config.add_part("steam_source", steam)
	
	var wheels := config.get_parts_by_type("weight_wheel")
	assert_eq(wheels.size(), 2, "Should find 2 weight wheels")
	
	var sources := config.get_parts_by_type("steam_source")
	assert_eq(sources.size(), 1, "Should find 1 steam source")
	
	wheel1.free()
	wheel2.free()
	steam.free()

## ========================================
## Connection Management
## ========================================

func test_add_connection() -> void:
	var conn := config.add_connection("part1", "out_south", "part2", "in_north")
	
	assert_not_null(conn, "Should return connection")
	assert_eq(conn.from_part, "part1", "From part should match")
	assert_eq(conn.to_part, "part2", "To part should match")
	assert_eq(config.connections.size(), 1, "Should have 1 connection")

func test_remove_connection() -> void:
	config.add_connection("part1", "out_south", "part2", "in_north")
	
	var removed := config.remove_connection("part1", "part2")
	assert_true(removed, "Should remove connection")
	assert_eq(config.connections.size(), 0, "Should have 0 connections")

func test_duplicate_connection_not_added() -> void:
	config.add_connection("part1", "out_south", "part2", "in_north")
	config.add_connection("part1", "out_south", "part2", "in_north")
	
	assert_eq(config.connections.size(), 1, "Should not add duplicate connection")

func test_get_connections_from() -> void:
	config.add_connection("part1", "out_south", "part2", "in_north")
	config.add_connection("part1", "out_east", "part3", "in_west")
	config.add_connection("part2", "out_south", "part3", "in_north")
	
	var from_part1 := config.get_connections_from("part1")
	assert_eq(from_part1.size(), 2, "Should find 2 connections from part1")

func test_get_connections_to() -> void:
	config.add_connection("part1", "out_south", "part2", "in_north")
	config.add_connection("part1", "out_east", "part3", "in_west")
	config.add_connection("part2", "out_south", "part3", "in_north")
	
	var to_part3 := config.get_connections_to("part3")
	assert_eq(to_part3.size(), 2, "Should find 2 connections to part3")

## ========================================
## Budget Tracking
## ========================================

func test_budget_initialization() -> void:
	assert_eq(config.budget.mass_used, 0.0, "Mass should start at 0")
	assert_eq(config.budget.brass_used, 0.0, "Brass should start at 0")
	assert_eq(config.budget.pressure_used, 0.0, "Pressure should start at 0")

func test_budget_updated_on_add_part() -> void:
	var wheel := WeightWheel.new()
	config.add_part("weight_wheel", wheel)
	
	assert_gt(config.budget.mass_used, 0.0, "Mass should increase")
	
	wheel.free()

func test_budget_updated_on_remove_part() -> void:
	var wheel := WeightWheel.new()
	var placed := config.add_part("weight_wheel", wheel)
	var initial_mass := config.budget.mass_used
	
	config.remove_part(placed.instance_name)
	
	assert_eq(config.budget.mass_used, 0.0, "Mass should return to 0")
	
	wheel.free()

func test_budget_within_limits() -> void:
	config.budget.mass_limit = 100.0
	config.budget.mass_used = 50.0
	
	assert_true(config.budget.is_within_limits(), "Should be within limits")

func test_budget_exceeds_limits() -> void:
	config.budget.mass_limit = 100.0
	config.budget.mass_used = 150.0
	
	assert_false(config.budget.is_within_limits(), "Should exceed limits")

## ========================================
## Validation
## ========================================

func test_validate_empty_machine() -> void:
	var result := config.validate()
	
	assert_true(result["valid"], "Empty machine should be valid")
	assert_eq(result["errors"].size(), 0, "Should have no errors")

func test_validate_budget_exceeded() -> void:
	config.budget.mass_used = 200.0
	config.budget.mass_limit = 100.0
	
	var result := config.validate()
	
	assert_false(result["valid"], "Should be invalid")
	assert_gt(result["errors"].size(), 0, "Should have errors")

## ========================================
## Serialization
## ========================================

func test_to_dict() -> void:
	var wheel := WeightWheel.new()
	config.add_part("weight_wheel", wheel, Vector2(50, 75))
	config.add_connection("part1", "out_south", "part2", "in_north")
	config.machine_name = "Test Machine"
	config.level_id = "test_level"
	
	var data := config.to_dict()
	
	assert_eq(data["machine_name"], "Test Machine", "Name should match")
	assert_eq(data["level_id"], "test_level", "Level should match")
	assert_eq(data["placed_parts"].size(), 1, "Should have 1 part")
	assert_eq(data["connections"].size(), 1, "Should have 1 connection")
	
	wheel.free()

func test_from_dict() -> void:
	var data := {
		"machine_name": "Loaded Machine",
		"level_id": "loaded_level",
		"created_at": "2025-01-01T00:00:00",
		"modified_at": "2025-01-02T00:00:00",
		"placed_parts": [
			{
				"part_id": "weight_wheel",
				"instance_name": "wheel_12345",
				"position": {"x": 100.0, "y": 200.0},
				"rotation": 0.5,
				"parameters": {}
			}
		],
		"connections": [
			{
				"from_part": "part1",
				"from_port": "out_south",
				"to_part": "part2",
				"to_port": "in_north",
				"signal_type": "scalar"
			}
		],
		"budget": {
			"mass_used": 25.0,
			"brass_used": 15.0,
			"pressure_used": 5.0,
			"mass_limit": 100.0,
			"brass_limit": 100.0,
			"pressure_limit": 100.0
		}
	}
	
	config.from_dict(data)
	
	assert_eq(config.machine_name, "Loaded Machine", "Name should load")
	assert_eq(config.level_id, "loaded_level", "Level should load")
	assert_eq(config.placed_parts.size(), 1, "Should load 1 part")
	assert_eq(config.connections.size(), 1, "Should load 1 connection")
	assert_eq(config.budget.mass_used, 25.0, "Budget should load")

func test_roundtrip_serialization() -> void:
	var wheel := WeightWheel.new()
	config.add_part("weight_wheel", wheel, Vector2(123, 456))
	config.add_connection("part1", "out_south", "part2", "in_north")
	config.machine_name = "Roundtrip Test"
	
	var data := config.to_dict()
	var config2 := MachineConfiguration.new()
	config2.from_dict(data)
	
	assert_eq(config2.machine_name, config.machine_name, "Name should match")
	assert_eq(config2.placed_parts.size(), config.placed_parts.size(), "Part count should match")
	assert_eq(config2.connections.size(), config.connections.size(), "Connection count should match")
	
	wheel.free()

## ========================================
## Clear and Reset
## ========================================

func test_clear() -> void:
	var wheel := WeightWheel.new()
	config.add_part("weight_wheel", wheel)
	config.add_connection("part1", "out_south", "part2", "in_north")
	
	config.clear()
	
	assert_eq(config.placed_parts.size(), 0, "Should clear parts")
	assert_eq(config.connections.size(), 0, "Should clear connections")
	assert_eq(config.budget.mass_used, 0.0, "Should reset budget")
	
	wheel.free()

## ========================================
## Statistics
## ========================================

func test_get_stats() -> void:
	var wheel := WeightWheel.new()
	config.add_part("weight_wheel", wheel)
	config.add_connection("part1", "out_south", "part2", "in_north")
	
	var stats := config.get_stats()
	
	assert_eq(stats["part_count"], 1, "Should count parts")
	assert_eq(stats["connection_count"], 1, "Should count connections")
	assert_true(stats.has("mass_used"), "Should include mass")
	assert_true(stats.has("budget_ok"), "Should include budget status")
	
	wheel.free()

