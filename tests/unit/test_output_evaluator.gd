extends GutTest

## Unit tests for Output Evaluator part
# Tests evaluation modes, tolerance, accuracy calculation
# Part of Phase 3.2: Retrofit Testing (T210)
# CRITICAL: Evaluator must correctly calculate errors and determine pass/fail

const OutputEvaluator = preload("res://game/parts/evaluator.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var evaluator: OutputEvaluator
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/output_evaluator.yaml")
	assert_not_null(yaml_spec, "output_evaluator.yaml should load")
	
	# Create instance
	evaluator = OutputEvaluator.new()
	add_child_autofree(evaluator)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "output_evaluator", "ID should be output_evaluator")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "output", "Category should be output")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "evaluator", "Simulation type should be evaluator")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 0, "Should have 0 outputs (evaluation device)")

func test_yaml_has_evaluator_parameters():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "tolerance", "Should have tolerance parameter")
	assert_has(sim["parameters"], "evaluation_mode", "Should have evaluation_mode parameter")
	assert_has(sim["parameters"], "expected_value", "Should have expected_value parameter")
	assert_has(sim["parameters"], "show_metrics", "Should have show_metrics parameter")

func test_yaml_ports_input_only():
	assert_has(yaml_spec["ports"], "in_north", "Should have in_north port")
	assert_eq(yaml_spec["ports"]["in_north"]["type"], "vector", "Input should be vector type")
	assert_eq(yaml_spec["ports"]["in_north"]["direction"], "input", "Should be input direction")

## Initialization Tests

func test_evaluator_initializes():
	assert_not_null(evaluator, "Output Evaluator should initialize")
	assert_true(evaluator.is_inside_tree(), "Should be in scene tree")

func test_default_tolerance():
	assert_eq(evaluator.tolerance, 0.1, "Default tolerance should be 0.1")

func test_default_evaluation_mode():
	assert_eq(evaluator.evaluation_mode, "absolute", "Default mode should be absolute")

func test_default_expected_value():
	assert_eq(evaluator.expected_value, 0.0, "Default expected value should be 0.0")

func test_default_show_metrics():
	assert_true(evaluator.show_metrics, "Should show metrics by default")

func test_available_modes():
	assert_true(evaluator.available_modes.has("absolute"), "Should have absolute mode")
	assert_true(evaluator.available_modes.has("relative"), "Should have relative mode")
	assert_true(evaluator.available_modes.has("classification"), "Should have classification mode")
	assert_true(evaluator.available_modes.has("threshold"), "Should have threshold mode")
	assert_true(evaluator.available_modes.has("pattern"), "Should have pattern mode")

## Configuration Tests

func test_set_tolerance():
	evaluator.set_tolerance(0.05)
	assert_eq(evaluator.tolerance, 0.05, "Should set tolerance")

func test_tolerance_minimum():
	evaluator.set_tolerance(0.0001)
	assert_eq(evaluator.tolerance, 0.001, "Tolerance should be minimum 0.001")

func test_tolerance_maximum():
	evaluator.set_tolerance(5.0)
	assert_eq(evaluator.tolerance, 1.0, "Tolerance should be maximum 1.0")

func test_set_evaluation_mode():
	evaluator.set_evaluation_mode("relative")
	assert_eq(evaluator.evaluation_mode, "relative", "Should set evaluation mode")

func test_invalid_evaluation_mode():
	evaluator.set_evaluation_mode("invalid_mode")
	assert_eq(evaluator.evaluation_mode, "absolute", "Should keep default for invalid mode")

func test_set_expected_value():
	evaluator.set_expected_value(5.0)
	assert_eq(evaluator.expected_value, 5.0, "Should set expected value")

func test_set_show_metrics():
	evaluator.set_show_metrics(false)
	assert_false(evaluator.show_metrics, "Should disable metrics")

## Absolute Mode Tests

func test_absolute_mode_pass():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	var passed = evaluator.evaluate_output(0.05, 0.0)
	
	assert_true(passed, "Should pass: error 0.05 < tolerance 0.1")
	assert_almost_eq(evaluator.current_error, 0.05, 0.001, "Error should be 0.05")

func test_absolute_mode_fail():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	var passed = evaluator.evaluate_output(0.2, 0.0)
	
	assert_false(passed, "Should fail: error 0.2 > tolerance 0.1")
	assert_almost_eq(evaluator.current_error, 0.2, 0.001, "Error should be 0.2")

func test_absolute_mode_exact_tolerance():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	var passed = evaluator.evaluate_output(0.1, 0.0)
	
	assert_true(passed, "Should pass: error 0.1 == tolerance 0.1")

## Relative Mode Tests

func test_relative_mode_pass():
	evaluator.set_evaluation_mode("relative")
	evaluator.set_tolerance(0.1)  # 10%
	
	# Output 10.5 vs expected 10.0 = 5% error
	var passed = evaluator.evaluate_output(10.5, 10.0)
	
	assert_true(passed, "Should pass: 5% error < 10% tolerance")
	assert_almost_eq(evaluator.current_error, 0.05, 0.01, "Error should be 5%")

func test_relative_mode_fail():
	evaluator.set_evaluation_mode("relative")
	evaluator.set_tolerance(0.1)  # 10%
	
	# Output 12.0 vs expected 10.0 = 20% error
	var passed = evaluator.evaluate_output(12.0, 10.0)
	
	assert_false(passed, "Should fail: 20% error > 10% tolerance")
	assert_almost_eq(evaluator.current_error, 0.2, 0.01, "Error should be 20%")

func test_relative_mode_zero_target():
	evaluator.set_evaluation_mode("relative")
	evaluator.set_tolerance(0.1)
	
	# With target near zero, falls back to absolute comparison
	var passed = evaluator.evaluate_output(0.05, 0.0)
	
	assert_true(passed, "Should handle zero target")

## Classification Mode Tests

func test_classification_mode_correct():
	evaluator.set_evaluation_mode("classification")
	
	# Both positive - same sign
	var passed1 = evaluator.evaluate_output(0.8, 0.5)
	assert_true(passed1, "Both positive should pass")
	
	# Both negative - same sign
	var passed2 = evaluator.evaluate_output(-0.8, -0.5)
	assert_true(passed2, "Both negative should pass")

func test_classification_mode_incorrect():
	evaluator.set_evaluation_mode("classification")
	
	# Positive vs negative
	var passed1 = evaluator.evaluate_output(0.5, -0.5)
	assert_false(passed1, "Opposite signs should fail")
	
	# Negative vs positive
	var passed2 = evaluator.evaluate_output(-0.5, 0.5)
	assert_false(passed2, "Opposite signs should fail")

func test_classification_mode_zero_boundary():
	evaluator.set_evaluation_mode("classification")
	
	# Positive output, zero target (zero is not positive)
	var passed = evaluator.evaluate_output(0.5, 0.0)
	assert_false(passed, "Positive vs zero should fail")

## Threshold Mode Tests

func test_threshold_mode_above():
	evaluator.set_evaluation_mode("threshold")
	
	var passed = evaluator.evaluate_output(0.8, 0.5)
	
	assert_true(passed, "Output 0.8 >= threshold 0.5 should pass")
	assert_eq(evaluator.current_error, 0.0, "Error should be 0 when above threshold")

func test_threshold_mode_below():
	evaluator.set_evaluation_mode("threshold")
	
	var passed = evaluator.evaluate_output(0.3, 0.5)
	
	assert_false(passed, "Output 0.3 < threshold 0.5 should fail")
	assert_almost_eq(evaluator.current_error, 0.2, 0.001, "Error should be distance below threshold")

func test_threshold_mode_exact():
	evaluator.set_evaluation_mode("threshold")
	
	var passed = evaluator.evaluate_output(0.5, 0.5)
	
	assert_true(passed, "Output == threshold should pass")

## Pattern Mode Tests

func test_pattern_mode_similar_positive():
	evaluator.set_evaluation_mode("pattern")
	evaluator.set_tolerance(0.2)  # Allow 20% difference
	
	var passed = evaluator.evaluate_output(0.9, 1.0)
	
	assert_true(passed, "Similar positive values should pass")

func test_pattern_mode_similar_negative():
	evaluator.set_evaluation_mode("pattern")
	evaluator.set_tolerance(0.2)
	
	var passed = evaluator.evaluate_output(-0.9, -1.0)
	
	assert_true(passed, "Similar negative values should pass")

func test_pattern_mode_different_magnitudes():
	evaluator.set_evaluation_mode("pattern")
	evaluator.set_tolerance(0.2)
	
	# 0.5 vs 1.0 = 50% difference
	var passed = evaluator.evaluate_output(0.5, 1.0)
	
	assert_false(passed, "Different magnitudes should fail")

func test_pattern_mode_opposite_signs():
	evaluator.set_evaluation_mode("pattern")
	evaluator.set_tolerance(0.1)
	
	var passed = evaluator.evaluate_output(0.9, -0.9)
	
	assert_false(passed, "Opposite signs should always fail in pattern mode")

## Batch Evaluation Tests

func test_evaluate_batch():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	var outputs: Array[float] = [0.05, 0.15, 0.08]
	var expected: Array[float] = [0.0, 0.0, 0.0]
	
	var results = evaluator.evaluate_batch(outputs, expected)
	
	assert_eq(results["total"], 3, "Should evaluate 3 outputs")
	assert_eq(results["passed"], 2, "Should pass 2 (0.05 and 0.08)")
	assert_eq(results["failed"], 1, "Should fail 1 (0.15)")
	assert_almost_eq(results["accuracy"], 2.0/3.0, 0.01, "Accuracy should be 66.7%")

func test_evaluate_batch_empty():
	var outputs: Array[float] = []
	var expected: Array[float] = []
	
	var results = evaluator.evaluate_batch(outputs, expected)
	
	assert_eq(results["total"], 0, "Should handle empty batch")
	assert_eq(results["accuracy"], 0.0, "Accuracy should be 0 for empty batch")

func test_evaluate_batch_mismatched_sizes():
	var outputs: Array[float] = [1.0, 2.0, 3.0]
	var expected: Array[float] = [1.0, 2.0]  # Shorter
	
	var results = evaluator.evaluate_batch(outputs, expected)
	
	assert_eq(results["total"], 3, "Total should be outputs size")
	# Only evaluates min(outputs, expected) = 2

## Statistics Tests

func test_evaluation_statistics():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	evaluator.reset_statistics()  # Ensure clean state
	
	evaluator.evaluate_output(0.05, 0.0)  # Pass
	evaluator.evaluate_output(0.15, 0.0)  # Fail
	evaluator.evaluate_output(0.08, 0.0)  # Pass
	
	assert_eq(evaluator.total_evaluations, 3, "Should count 3 evaluations")
	assert_eq(evaluator.passed_evaluations, 2, "Should count 2 passes")
	assert_almost_eq(evaluator.get_accuracy(), 66.7, 0.1, "Accuracy should be 66.7%")

func test_reset_statistics():
	evaluator.evaluate_output(0.05, 0.0)
	evaluator.evaluate_output(0.15, 0.0)
	
	evaluator.reset_statistics()
	
	assert_eq(evaluator.total_evaluations, 0, "Should reset count")
	assert_eq(evaluator.passed_evaluations, 0, "Should reset passes")
	assert_eq(evaluator.get_accuracy(), 0.0, "Accuracy should be 0")

## History Tests

func test_evaluation_history():
	evaluator.evaluate_output(1.0, 0.0)
	evaluator.evaluate_output(2.0, 0.0)
	
	assert_eq(evaluator.evaluation_history.size(), 2, "Should store 2 history entries")
	assert_eq(evaluator.evaluation_history[0]["output"], 1.0, "First entry should be 1.0")
	assert_eq(evaluator.evaluation_history[1]["output"], 2.0, "Second entry should be 2.0")

func test_history_limit():
	# Add more than 100 evaluations
	for i in range(110):
		evaluator.evaluate_output(float(i), 0.0)
	
	assert_eq(evaluator.evaluation_history.size(), 100, "History should be limited to 100")

## Signal Tests

func test_evaluation_complete_signal():
	watch_signals(evaluator)
	
	evaluator.evaluate_output(0.05, 0.0)
	
	assert_signal_emitted(evaluator, "evaluation_complete", "Should emit evaluation_complete")

func test_tolerance_changed_signal():
	watch_signals(evaluator)
	
	evaluator.set_tolerance(0.2)
	
	assert_signal_emitted(evaluator, "tolerance_changed", "Should emit tolerance_changed")

func test_mode_changed_signal():
	watch_signals(evaluator)
	
	evaluator.set_evaluation_mode("relative")
	
	assert_signal_emitted(evaluator, "mode_changed", "Should emit mode_changed")

func test_light_status_changed_signal():
	watch_signals(evaluator)
	
	evaluator.evaluate_output(0.05, 0.0)
	
	assert_signal_emitted(evaluator, "light_status_changed", "Should emit light_status_changed")

## UI/Display Tests

func test_get_status_text_pass():
	evaluator.evaluate_output(0.05, 0.0)
	
	var status = evaluator.get_status_text()
	
	assert_true(status.contains("PASS") or status.contains("✓"), "Should show pass status")

func test_get_status_text_fail():
	evaluator.set_tolerance(0.05)
	evaluator.evaluate_output(0.2, 0.0)
	
	var status = evaluator.get_status_text()
	
	assert_true(status.contains("FAIL") or status.contains("✗"), "Should show fail status")

func test_get_light_color_green():
	evaluator.evaluate_output(0.05, 0.0)  # Pass
	
	var color = evaluator.get_light_color()
	
	assert_gt(color.g, 0.5, "Green should be bright for passing")
	assert_lt(color.r, 0.5, "Red should be dim for passing")

func test_get_light_color_red():
	evaluator.set_tolerance(0.05)
	evaluator.evaluate_output(0.2, 0.0)  # Fail
	
	var color = evaluator.get_light_color()
	
	assert_gt(color.r, 0.5, "Red should be bright for failing")
	assert_lt(color.g, 0.5, "Green should be dim for failing")

func test_get_metrics_text():
	evaluator.set_show_metrics(true)
	evaluator.evaluate_output(0.05, 0.0)
	
	var metrics = evaluator.get_metrics_text()
	
	assert_true(metrics.contains("Mode"), "Should show mode")
	assert_true(metrics.contains("Tolerance"), "Should show tolerance")
	assert_true(metrics.contains("Accuracy"), "Should show accuracy")

func test_metrics_text_disabled():
	evaluator.set_show_metrics(false)
	
	var metrics = evaluator.get_metrics_text()
	
	assert_eq(metrics, "", "Should return empty string when disabled")

## Edge Cases

func test_nan_expected_value():
	# NAN means use stored expected_value
	evaluator.set_expected_value(1.0)
	
	var passed = evaluator.evaluate_output(1.0, NAN)
	
	assert_true(passed, "Should use stored expected_value")

func test_very_small_tolerance():
	evaluator.set_tolerance(0.001)
	evaluator.set_evaluation_mode("absolute")
	
	var passed1 = evaluator.evaluate_output(0.0005, 0.0)
	var passed2 = evaluator.evaluate_output(0.002, 0.0)
	
	assert_true(passed1, "Should pass with small error")
	assert_false(passed2, "Should fail with larger error")

func test_negative_values():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	var passed = evaluator.evaluate_output(-0.05, 0.0)
	
	assert_true(passed, "Should handle negative output")
	assert_almost_eq(evaluator.current_error, 0.05, 0.001, "Error should be absolute")

func test_large_values():
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(10.0)  # Will be clamped to 1.0
	
	var passed = evaluator.evaluate_output(1000.5, 1000.0)
	
	# With tolerance clamped to 1.0, error 0.5 should pass
	assert_true(passed, "Should handle large values")

## ML Semantics Tests

func test_loss_calculation_device():
	# CRITICAL: Evaluator is a loss/error measurement device
	var sim = yaml_spec["simulation"]
	assert_eq(sim["inputs"], 1, "Should accept network output")
	assert_eq(sim["outputs"], 0, "Should have NO outputs - evaluation device")

func test_training_feedback():
	# CRITICAL: Provides feedback for training
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	
	# Simulated training: output gets closer to target
	var passed1 = evaluator.evaluate_output(0.5, 0.0)  # Early training
	var passed2 = evaluator.evaluate_output(0.15, 0.0)  # Improving
	var passed3 = evaluator.evaluate_output(0.05, 0.0)  # Converged
	
	assert_false(passed1, "Early training should fail")
	assert_false(passed2, "Improving but not there yet")
	assert_true(passed3, "Converged output should pass")

func test_multiple_evaluation_modes():
	# CRITICAL: Different modes for different tasks
	var test_output = 0.8
	var test_target = 0.5  # Changed: threshold should pass when output > target
	
	# Absolute: strict value matching
	evaluator.set_evaluation_mode("absolute")
	evaluator.set_tolerance(0.1)
	var abs_result = evaluator.evaluate_output(test_output, test_target)
	
	# Classification: just care about sign
	evaluator.set_evaluation_mode("classification")
	var class_result = evaluator.evaluate_output(test_output, test_target)
	
	# Threshold: care about minimum value (output should be >= target)
	evaluator.set_evaluation_mode("threshold")
	var thresh_result = evaluator.evaluate_output(test_output, test_target)
	
	assert_false(abs_result, "Absolute mode is strict (0.8 vs 0.5 = 0.3 error > 0.1 tolerance)")
	assert_true(class_result, "Classification mode is lenient (same sign)")
	assert_true(thresh_result, "Threshold mode passes when output >= target (0.8 >= 0.5)")

func test_batch_accuracy_measurement():
	# CRITICAL: Batch evaluation for validation sets
	evaluator.set_evaluation_mode("classification")
	
	var outputs: Array[float] = [0.8, -0.5, 0.3, -0.9]  # Predictions
	var targets: Array[float] = [1.0, -1.0, -1.0, -1.0]  # Ground truth
	
	var results = evaluator.evaluate_batch(outputs, targets)
	
	# Correct: [✓, ✓, ✗, ✓] = 3/4 = 75%
	assert_eq(results["passed"], 3, "Should correctly classify 3 out of 4")
	assert_almost_eq(results["accuracy"], 0.75, 0.01, "Accuracy should be 75%")

## Performance Tests

func test_evaluation_performance():
	evaluator.set_evaluation_mode("absolute")
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(1000):
		evaluator.evaluate_output(randf(), randf())
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 1000 evaluations should be fast
	assert_lt(elapsed_ms, 50, "Evaluations should be fast (<0.05ms per evaluation)")
