extends GutTest

## Unit tests for Display Glass part
# Tests output visualization, display modes, formatting
# Part of Phase 3.2: Retrofit Testing (T207)
# CRITICAL: Display must correctly format various output types

const DisplayGlass = preload("res://game/parts/display_glass.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var display_glass: DisplayGlass
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/display_glass.yaml")
	assert_not_null(yaml_spec, "display_glass.yaml should load")
	
	# Create instance
	display_glass = DisplayGlass.new()
	add_child_autofree(display_glass)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "display_glass", "ID should be display_glass")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "output", "Category should be output")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "display", "Simulation type should be display")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 0, "Should have 0 outputs (output-only device)")

func test_yaml_has_display_parameters():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "display_mode", "Should have display_mode parameter")
	assert_has(sim["parameters"], "precision", "Should have precision parameter")
	assert_has(sim["parameters"], "show_history", "Should have show_history parameter")

func test_yaml_ports_input_only():
	assert_has(yaml_spec["ports"], "in_north", "Should have in_north port")
	assert_eq(yaml_spec["ports"]["in_north"]["type"], "vector", "Input should be vector type")
	assert_eq(yaml_spec["ports"]["in_north"]["direction"], "input", "Should be input direction")

## Initialization Tests

func test_display_glass_initializes():
	assert_not_null(display_glass, "Display Glass should initialize")
	assert_true(display_glass.is_inside_tree(), "Should be in scene tree")

func test_default_display_mode():
	assert_eq(display_glass.display_mode, "numeric", "Default mode should be numeric")

func test_default_precision():
	assert_eq(display_glass.precision, 3, "Default precision should be 3")

func test_default_show_history():
	assert_true(display_glass.show_history, "Should show history by default")

func test_available_modes():
	assert_true(display_glass.available_modes.has("numeric"), "Should have numeric mode")
	assert_true(display_glass.available_modes.has("gauge"), "Should have gauge mode")
	assert_true(display_glass.available_modes.has("waveform"), "Should have waveform mode")
	assert_true(display_glass.available_modes.has("binary"), "Should have binary mode")
	assert_true(display_glass.available_modes.has("classification"), "Should have classification mode")

## Display Mode Tests

func test_set_display_mode():
	display_glass.set_display_mode("gauge")
	assert_eq(display_glass.display_mode, "gauge", "Should set display mode")

func test_invalid_display_mode():
	display_glass.set_display_mode("invalid_mode")
	assert_eq(display_glass.display_mode, "numeric", "Should keep default for invalid mode")

func test_set_precision():
	display_glass.set_precision(5)
	assert_eq(display_glass.precision, 5, "Should set precision")

func test_precision_minimum():
	display_glass.set_precision(-1)
	assert_eq(display_glass.precision, 0, "Precision should be clamped to minimum 0")

func test_precision_maximum():
	display_glass.set_precision(10)
	assert_eq(display_glass.precision, 6, "Precision should be clamped to maximum 6")

func test_set_show_history():
	display_glass.set_show_history(false)
	assert_false(display_glass.show_history, "Should disable history")

func test_set_history_length():
	display_glass.set_history_length(20)
	assert_eq(display_glass.history_length, 20, "Should set history length")

func test_history_length_minimum():
	display_glass.set_history_length(0)
	assert_eq(display_glass.history_length, 1, "History length should be minimum 1")

func test_history_length_maximum():
	display_glass.set_history_length(100)
	assert_eq(display_glass.history_length, 50, "History length should be maximum 50")

## Value Display Tests

func test_display_value():
	display_glass.display_value(42.5)
	
	assert_eq(display_glass.current_value, 42.5, "Should store current value")
	assert_eq(display_glass.value_history.size(), 1, "Should add to history")
	assert_eq(display_glass.value_history[0], 42.5, "History should contain value")

func test_display_multiple_values():
	display_glass.display_value(1.0)
	display_glass.display_value(2.0)
	display_glass.display_value(3.0)
	
	assert_eq(display_glass.value_history.size(), 3, "Should store 3 values")
	assert_eq(display_glass.current_value, 3.0, "Current value should be latest")

func test_display_array():
	var values: Array[float] = [1.0, 2.0, 3.0, 4.0]
	display_glass.display_array(values)
	
	# Should display average
	var expected_avg = (1.0 + 2.0 + 3.0 + 4.0) / 4.0
	assert_almost_eq(display_glass.current_value, expected_avg, 0.001,
		"Should display average of array")

func test_display_empty_array():
	var initial_value = display_glass.current_value
	var values: Array[float] = []
	display_glass.display_array(values)
	
	# Should not change value for empty array
	assert_eq(display_glass.current_value, initial_value,
		"Empty array should not change current value")

func test_history_limit():
	display_glass.set_history_length(5)
	
	for i in range(10):
		display_glass.display_value(float(i))
	
	assert_eq(display_glass.value_history.size(), 5, "History should be limited")
	assert_eq(display_glass.value_history[0], 5.0, "Should keep most recent values")
	assert_eq(display_glass.value_history[4], 9.0, "Last value should be 9")

## Numeric Format Tests

func test_numeric_format():
	display_glass.set_display_mode("numeric")
	display_glass.set_precision(2)
	display_glass.display_value(42.567)
	
	# Should format with 2 decimal places
	assert_true(display_glass.display_text.contains("42.57"), "Should format to 2 decimals")

func test_numeric_format_with_history():
	display_glass.set_display_mode("numeric")
	display_glass.set_show_history(true)
	display_glass.set_precision(1)
	
	display_glass.display_value(1.1)
	display_glass.display_value(2.2)
	display_glass.display_value(3.3)
	
	# Should show history
	assert_true(display_glass.display_text.contains("History"), "Should show history label")
	assert_true(display_glass.display_text.contains("1.1"), "Should show first value")
	assert_true(display_glass.display_text.contains("3.3"), "Should show last value")

func test_numeric_format_without_history():
	display_glass.set_display_mode("numeric")
	display_glass.set_show_history(false)
	
	display_glass.display_value(1.0)
	display_glass.display_value(2.0)
	
	# Should not show history
	assert_false(display_glass.display_text.contains("History"),
		"Should not show history when disabled")

## Gauge Format Tests

func test_gauge_format():
	display_glass.set_display_mode("gauge")
	display_glass.display_value(0.0)
	
	# Should create gauge visualization
	assert_true(display_glass.display_text.contains("["), "Gauge should have brackets")
	assert_true(display_glass.display_text.contains("]"), "Gauge should have closing bracket")
	assert_true(display_glass.display_text.contains("PSI"), "Gauge should show PSI units")

func test_gauge_low_value():
	display_glass.set_display_mode("gauge")
	display_glass.display_value(-1.0)
	
	# Low value should have few filled bars
	var filled_bars = display_glass.display_text.count("█")
	assert_lt(filled_bars, 3, "Low value should have few filled bars")

func test_gauge_high_value():
	display_glass.set_display_mode("gauge")
	display_glass.display_value(1.0)
	
	# High value should have many filled bars
	var filled_bars = display_glass.display_text.count("█")
	assert_gt(filled_bars, 7, "High value should have many filled bars")

## Waveform Format Tests

func test_waveform_format():
	display_glass.set_display_mode("waveform")
	
	# Add some values
	for i in range(10):
		display_glass.display_value(sin(i * 0.5))
	
	# Should create waveform
	assert_true(display_glass.display_text.contains("Waveform"),
		"Should show waveform label")

func test_waveform_insufficient_data():
	display_glass.set_display_mode("waveform")
	display_glass.display_value(1.0)
	
	# With only 1 value, should show waiting message
	assert_true(display_glass.display_text.contains("Waiting"),
		"Should show waiting message with insufficient data")

## Binary Format Tests

func test_binary_format_high():
	display_glass.set_display_mode("binary")
	display_glass.display_value(1.0)
	
	assert_true(display_glass.display_text.contains("ACTIVE"),
		"Positive value should show ACTIVE")
	assert_true(display_glass.display_text.contains("HIGH"),
		"Should show HIGH signal")

func test_binary_format_low():
	display_glass.set_display_mode("binary")
	display_glass.display_value(-1.0)
	
	assert_true(display_glass.display_text.contains("INACTIVE"),
		"Negative value should show INACTIVE")
	assert_true(display_glass.display_text.contains("LOW"),
		"Should show LOW signal")

func test_binary_format_zero():
	display_glass.set_display_mode("binary")
	display_glass.display_value(0.0)
	
	assert_true(display_glass.display_text.contains("INACTIVE"),
		"Zero should show INACTIVE")

## Classification Format Tests

func test_classification_format():
	display_glass.set_display_mode("classification")
	display_glass.display_value(0.5)
	
	assert_true(display_glass.display_text.contains("Classification"),
		"Should show classification label")
	assert_true(display_glass.display_text.contains("Confidence"),
		"Should show confidence")
	assert_true(display_glass.display_text.contains("%"),
		"Should show percentage")

## Signal Tests

func test_mode_changed_signal():
	watch_signals(display_glass)
	
	display_glass.set_display_mode("gauge")
	
	assert_signal_emitted(display_glass, "mode_changed",
		"Should emit mode_changed signal")

func test_value_received_signal():
	watch_signals(display_glass)
	
	display_glass.display_value(42.0)
	
	assert_signal_emitted(display_glass, "value_received",
		"Should emit value_received signal")

func test_display_updated_signal():
	watch_signals(display_glass)
	
	display_glass.display_value(42.0)
	
	assert_signal_emitted(display_glass, "display_updated",
		"Should emit display_updated signal")

## Utility Function Tests

func test_get_glass_status():
	display_glass.set_display_mode("numeric")
	var status = display_glass.get_glass_status()
	
	assert_true(status.contains("numerical") or status.contains("numeric"),
		"Status should describe numeric mode")

func test_clear_display():
	display_glass.display_value(1.0)
	display_glass.display_value(2.0)
	display_glass.display_value(3.0)
	
	display_glass.clear_display()
	
	assert_eq(display_glass.current_value, 0.0, "Should clear current value")
	assert_eq(display_glass.value_history.size(), 0, "Should clear history")

## Edge Cases

func test_very_large_value():
	display_glass.display_value(999999.999)
	
	# Should not crash
	assert_not_null(display_glass.display_text, "Should handle large values")

func test_very_small_value():
	display_glass.display_value(0.0000001)
	
	# Should not crash
	assert_not_null(display_glass.display_text, "Should handle small values")

func test_negative_values():
	display_glass.display_value(-42.5)
	
	assert_eq(display_glass.current_value, -42.5, "Should handle negative values")

func test_infinity():
	display_glass.display_value(INF)
	
	# Should not crash
	assert_not_null(display_glass.display_text, "Should handle infinity")

func test_nan():
	display_glass.display_value(NAN)
	
	# Should not crash
	assert_not_null(display_glass.display_text, "Should handle NaN")

func test_rapid_value_changes():
	for i in range(100):
		display_glass.display_value(randf_range(-10.0, 10.0))
	
	# Should not crash with rapid updates
	assert_eq(display_glass.value_history.size(), 
		min(100, display_glass.history_length),
		"Should handle rapid updates")

## ML Semantics Tests

func test_output_only_device():
	# CRITICAL: Display Glass is an output-only device (no outputs, only input)
	var sim = yaml_spec["simulation"]
	assert_eq(sim["inputs"], 1, "Should accept input")
	assert_eq(sim["outputs"], 0, "Should have NO outputs - pure display device")

func test_visualizes_network_output():
	# Display Glass should show final network predictions
	display_glass.set_display_mode("numeric")
	
	# Simulate network output
	var predictions: Array[float] = [0.1, 0.7, 0.2]  # Softmax-like output
	display_glass.display_array(predictions)
	
	# Should display something meaningful
	assert_not_null(display_glass.display_text, "Should visualize predictions")
	assert_gt(display_glass.display_text.length(), 0, "Should have content")

func test_supports_multiple_display_formats():
	# CRITICAL: Should support different output interpretations
	var test_value = 0.75
	
	for mode in display_glass.available_modes:
		display_glass.set_display_mode(mode)
		display_glass.display_value(test_value)
		
		assert_not_null(display_glass.display_text,
			"Mode %s should produce output" % mode)
		assert_gt(display_glass.display_text.length(), 0,
			"Mode %s should have content" % mode)

func test_history_for_debugging():
	# CRITICAL: History is essential for debugging/monitoring
	display_glass.set_show_history(true)
	display_glass.set_display_mode("numeric")
	
	# Add some training trajectory
	for i in range(5):
		var loss = 1.0 / (i + 1)  # Decreasing loss
		display_glass.display_value(loss)
	
	# History should be maintained
	assert_eq(display_glass.value_history.size(), 5,
		"Should maintain history for debugging")
	assert_gt(display_glass.value_history[0], display_glass.value_history[-1],
		"Should track improvement over time")

## Performance Tests

func test_display_performance():
	var start_time = Time.get_ticks_msec()
	
	for i in range(1000):
		display_glass.display_value(randf())
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 1000 display updates should be fast
	assert_lt(elapsed_ms, 100, "Display updates should be fast (<0.1ms per update)")
