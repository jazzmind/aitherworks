extends GutTest

## Unit tests for Spyglass part
# Tests component inspection, target connection, data extraction
# Part of Phase 3.2: Retrofit Testing (T209)
# CRITICAL: Spyglass must correctly inspect and report component state

const Spyglass = preload("res://game/parts/spyglass.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const SignalLoom = preload("res://game/parts/signal_loom.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var spyglass: Spyglass
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/spyglass.yaml")
	assert_not_null(yaml_spec, "spyglass.yaml should load")
	
	# Create instance
	spyglass = Spyglass.new()
	add_child_autofree(spyglass)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "spyglass", "ID should be spyglass")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "output", "Category should be output")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "inspector", "Simulation type should be inspector")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 0, "Should have 0 outputs (inspection device)")

func test_yaml_has_inspector_parameters():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "target", "Should have target parameter")
	assert_has(sim["parameters"], "update_frequency", "Should have update_frequency parameter")

func test_yaml_ports_input_only():
	assert_has(yaml_spec["ports"], "in_north", "Should have in_north port")
	assert_eq(yaml_spec["ports"]["in_north"]["type"], "signal", "Input should be signal type")
	assert_eq(yaml_spec["ports"]["in_north"]["direction"], "input", "Should be input direction")

## Initialization Tests

func test_spyglass_initializes():
	assert_not_null(spyglass, "Spyglass should initialize")
	assert_true(spyglass.is_inside_tree(), "Should be in scene tree")

func test_default_inspection_target():
	assert_eq(spyglass.inspection_target, "", "Default target should be empty")

func test_default_update_frequency():
	assert_eq(spyglass.update_frequency, 0.5, "Default update frequency should be 0.5")

func test_default_show_gradients():
	assert_false(spyglass.show_gradients, "Should not show gradients by default")

## Target Configuration Tests

func test_set_inspection_target():
	spyglass.set_inspection_target("test_component")
	assert_eq(spyglass.inspection_target, "test_component", "Should set target")

func test_set_update_frequency():
	spyglass.set_update_frequency(1.0)
	assert_eq(spyglass.update_frequency, 1.0, "Should set update frequency")

func test_update_frequency_minimum():
	spyglass.set_update_frequency(0.05)
	assert_eq(spyglass.update_frequency, 0.1, "Update frequency should be minimum 0.1")

func test_update_frequency_maximum():
	spyglass.set_update_frequency(5.0)
	assert_eq(spyglass.update_frequency, 2.0, "Update frequency should be maximum 2.0")

func test_set_show_gradients():
	spyglass.set_show_gradients(true)
	assert_true(spyglass.show_gradients, "Should enable gradient display")

## Inspection Control Tests

func test_start_inspection():
	spyglass.start_inspection()
	
	assert_not_null(spyglass.inspection_timer, "Should create timer")
	assert_true(spyglass.inspection_timer.time_left > 0.0, "Timer should be running")

func test_stop_inspection():
	spyglass.start_inspection()
	spyglass.stop_inspection()
	
	# Timer should be stopped
	assert_eq(spyglass.inspection_timer.time_left, 0.0, "Timer should be stopped")

## Signal Tests

func test_target_changed_signal():
	watch_signals(spyglass)
	
	spyglass.set_inspection_target("new_target")
	
	assert_signal_emitted(spyglass, "target_changed", "Should emit target_changed signal")

func test_focus_changed_signal_on_start():
	watch_signals(spyglass)
	
	spyglass.start_inspection()
	
	assert_signal_emitted(spyglass, "focus_changed", "Should emit focus_changed on start")

func test_focus_changed_signal_on_stop():
	spyglass.start_inspection()
	watch_signals(spyglass)
	
	spyglass.stop_inspection()
	
	assert_signal_emitted(spyglass, "focus_changed", "Should emit focus_changed on stop")

## Component Inspection Tests

func test_inspect_weight_wheel():
	# Create a Weight Wheel to inspect
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(3)
	wheel.set_weight(0, 0.5)
	wheel.set_weight(1, 1.0)
	wheel.set_weight(2, -0.5)
	
	# Inspect it directly
	var data = spyglass._inspect_weight_wheel(wheel)
	
	assert_eq(data["type"], "Weight Wheel", "Should identify as Weight Wheel")
	assert_eq(data["num_spokes"], 3, "Should report 3 spokes")
	assert_eq(data["current_weights"].size(), 3, "Should have 3 weights")
	assert_eq(data["current_weights"][0], 0.5, "Should report correct weight 0")
	assert_eq(data["current_weights"][1], 1.0, "Should report correct weight 1")
	assert_eq(data["current_weights"][2], -0.5, "Should report correct weight 2")

func test_inspect_weight_wheel_with_gradients():
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(2)
	
	# Enable gradient display
	spyglass.set_show_gradients(true)
	
	var data = spyglass._inspect_weight_wheel(wheel)
	
	assert_has(data, "gradients", "Should include gradients when enabled")

func test_inspect_weight_wheel_without_gradients():
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(2)
	
	# Disable gradient display (default)
	spyglass.set_show_gradients(false)
	
	var data = spyglass._inspect_weight_wheel(wheel)
	
	assert_eq(data["gradients"].size(), 0, "Should not include gradients when disabled")

func test_inspect_signal_loom():
	var loom = SignalLoom.new()
	loom.name = "TestLoom"
	add_child_autofree(loom)
	
	loom.set_output_width(4)
	loom.set_signal_strength(0.8)
	
	var data = spyglass._inspect_signal_loom(loom)
	
	assert_eq(data["type"], "Signal Loom", "Should identify as Signal Loom")
	assert_eq(data["output_width"], 4, "Should report output width")
	assert_almost_eq(data["signal_strength"], 0.8, 0.001, "Should report signal strength")

func test_inspect_steam_source():
	var source = SteamSource.new()
	source.name = "TestSource"
	add_child_autofree(source)
	
	# Steam Source defaults to "sine_wave" pattern
	source.set_amplitude(2.0)
	source.set_num_channels(3)
	
	var data = spyglass._inspect_steam_source(source)
	
	assert_eq(data["type"], "Steam Source", "Should identify as Steam Source")
	assert_eq(data["pattern"], "sine_wave", "Should report default pattern")
	assert_almost_eq(data["amplitude"], 2.0, 0.001, "Should report amplitude")
	assert_eq(data["num_channels"], 3, "Should report channel count")

func test_inspect_generic_component():
	var generic = Node.new()
	generic.name = "GenericComponent"
	add_child_autofree(generic)
	
	var data = spyglass._inspect_generic_component(generic)
	
	assert_eq(data["type"], "Unknown Component", "Should identify as unknown")
	assert_eq(data["name"], "GenericComponent", "Should report name")

## Component Finding Tests

func test_find_component_by_name():
	# Create a component to find
	var test_component = Node.new()
	test_component.name = "FindMe"
	add_child_autofree(test_component)
	
	var found = spyglass._find_component_by_name(self, "FindMe")
	
	assert_not_null(found, "Should find component")
	assert_eq(found.name, "FindMe", "Should find correct component")

func test_find_nested_component():
	# Create nested structure
	var parent = Node.new()
	parent.name = "Parent"
	add_child_autofree(parent)
	
	var child = Node.new()
	child.name = "NestedChild"
	parent.add_child(child)
	
	var found = spyglass._find_component_by_name(self, "NestedChild")
	
	assert_not_null(found, "Should find nested component")
	assert_eq(found.name, "NestedChild", "Should find correct nested component")

func test_component_not_found():
	var found = spyglass._find_component_by_name(self, "DoesNotExist")
	
	assert_null(found, "Should return null for non-existent component")

## Status Tests

func test_get_spyglass_status_no_target():
	var status = spyglass.get_spyglass_status()
	
	assert_true(status.contains("ready") or status.contains("select"),
		"Should indicate ready status")

func test_get_spyglass_status_with_target():
	# Create a target
	var target = Node.new()
	target.name = "TestTarget"
	add_child_autofree(target)
	
	spyglass.set_inspection_target("TestTarget")
	spyglass._connect_to_target()
	
	var status = spyglass.get_spyglass_status()
	
	assert_true(status.contains("TestTarget"), "Should mention target name")

func test_get_spyglass_status_target_not_found():
	spyglass.set_inspection_target("NonExistentTarget")
	spyglass._connect_to_target()
	
	var status = spyglass.get_spyglass_status()
	
	assert_true(status.contains("not found") or status.contains("NonExistentTarget"),
		"Should indicate target not found")

## Inspection Data Extraction Tests

func test_weight_wheel_spoke_descriptions():
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(3)
	
	var descriptions = spyglass._get_spoke_descriptions(wheel)
	
	assert_eq(descriptions.size(), 3, "Should have 3 spoke descriptions")
	assert_true(descriptions[0] is String, "Description should be string")

func test_steam_source_channel_descriptions():
	var source = SteamSource.new()
	source.name = "TestSource"
	add_child_autofree(source)
	
	source.set_num_channels(2)
	
	var descriptions = spyglass._get_channel_descriptions(source)
	
	assert_eq(descriptions.size(), 2, "Should have 2 channel descriptions")
	assert_true(descriptions[0] is String, "Description should be string")

## Edge Cases

func test_inspect_with_null_component():
	spyglass.connected_component = null
	
	# Should not crash
	spyglass._update_inspection()
	
	# No assertions - just verify it doesn't crash

func test_multiple_start_stop_cycles():
	for i in range(5):
		spyglass.start_inspection()
		spyglass.stop_inspection()
	
	# Should handle multiple cycles
	assert_not_null(spyglass.inspection_timer, "Should maintain timer")

func test_change_target_while_inspecting():
	var target1 = Node.new()
	target1.name = "Target1"
	add_child_autofree(target1)
	
	var target2 = Node.new()
	target2.name = "Target2"
	add_child_autofree(target2)
	
	spyglass.set_inspection_target("Target1")
	spyglass.start_inspection()
	
	spyglass.set_inspection_target("Target2")
	
	# Should switch targets smoothly
	assert_eq(spyglass.inspection_target, "Target2", "Should update target")

## ML Semantics Tests

func test_debugging_tool():
	# CRITICAL: Spyglass is a debugging tool, not a computational part
	var sim = yaml_spec["simulation"]
	assert_eq(sim["inputs"], 1, "Should accept optional input")
	assert_eq(sim["outputs"], 0, "Should have NO outputs - pure inspection device")

func test_inspects_internal_state():
	# CRITICAL: Should access and report internal state
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(3)
	wheel.set_weight(0, 0.1)
	wheel.set_weight(1, 0.2)
	wheel.set_weight(2, 0.3)
	
	var data = spyglass._inspect_weight_wheel(wheel)
	
	# Should capture internal state
	assert_has(data, "current_weights", "Should expose weights")
	assert_has(data, "learning_rate", "Should expose learning params")
	assert_has(data, "status", "Should provide status info")

func test_gradient_visualization():
	# CRITICAL: Gradients are essential for understanding learning
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(2)
	
	# Without gradient display
	spyglass.set_show_gradients(false)
	var data_no_grad = spyglass._inspect_weight_wheel(wheel)
	assert_eq(data_no_grad["gradients"].size(), 0, "Should hide gradients when disabled")
	
	# With gradient display
	spyglass.set_show_gradients(true)
	var data_with_grad = spyglass._inspect_weight_wheel(wheel)
	assert_gt(data_with_grad["gradients"].size(), 0, "Should show gradients when enabled")

func test_supports_multiple_component_types():
	# CRITICAL: Should inspect various component types
	var components = [
		WeightWheel.new(),
		SignalLoom.new(),
		SteamSource.new()
	]
	
	for comp in components:
		add_child_autofree(comp)
	
	# Should handle each type
	var wheel_data = spyglass._inspect_weight_wheel(components[0])
	var loom_data = spyglass._inspect_signal_loom(components[1])
	var source_data = spyglass._inspect_steam_source(components[2])
	
	assert_true(wheel_data.has("type"), "Weight Wheel inspection should work")
	assert_true(loom_data.has("type"), "Signal Loom inspection should work")
	assert_true(source_data.has("type"), "Steam Source inspection should work")

func test_real_time_monitoring():
	# CRITICAL: Update frequency controls monitoring rate
	spyglass.set_update_frequency(0.5)
	spyglass.start_inspection()
	
	assert_almost_eq(spyglass.inspection_timer.wait_time, 0.5, 0.001,
		"Timer should match update frequency")

## Performance Tests

func test_inspection_performance():
	var wheel = WeightWheel.new()
	wheel.name = "TestWheel"
	add_child_autofree(wheel)
	
	wheel.set_num_weights(10)
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(100):
		spyglass._inspect_weight_wheel(wheel)
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 100 inspections should be fast
	assert_lt(elapsed_ms, 50, "Inspection should be fast (<0.5ms per inspection)")
