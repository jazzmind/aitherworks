extends GutTest

## Unit tests for Entropy Manometer part
# Tests loss functions (MSE, Cross Entropy, etc.), entropy calculations
# Part of Phase 3.2: Retrofit Testing (T205)
# CRITICAL: Loss functions must match standard ML formulas

const EntropyManometer = preload("res://game/parts/entropy_manometer.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var entropy_manometer: EntropyManometer
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/entropy_manometer.yaml")
	assert_not_null(yaml_spec, "entropy_manometer.yaml should load")
	
	# Create instance
	entropy_manometer = EntropyManometer.new()
	add_child_autofree(entropy_manometer)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "entropy_manometer", "ID should be entropy_manometer")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "instrumentation", "Category should be instrumentation")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "loss_meter", "Simulation type should be loss_meter")
	assert_eq(sim["inputs"], 2, "Should have 2 inputs (predictions + targets)")
	assert_eq(sim["outputs"], 1, "Should have 1 output (loss)")
	assert_false(sim.get("learnable", false), "Should not be learnable")

## Initialization Tests

func test_entropy_manometer_initializes():
	assert_not_null(entropy_manometer, "Entropy Manometer should initialize")
	assert_true(entropy_manometer.is_inside_tree(), "Should be in scene tree")

func test_default_measurement_type():
	assert_eq(entropy_manometer.measurement_type, EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR,
		"Default should be MSE")

func test_default_smoothing_factor():
	assert_almost_eq(entropy_manometer.smoothing_factor, 0.1, 0.001, "Default smoothing should be 0.1")

## Mean Squared Error Tests - CRITICAL ML SEMANTICS

func test_mse_perfect_prediction():
	# CRITICAL: MSE = 0 when predictions match targets
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([1.0, 2.0, 3.0])
	
	var result = entropy_manometer.measure_entropy([1.0, 2.0, 3.0])
	
	assert_almost_eq(result["loss"], 0.0, 0.001,
		"CRITICAL ML SEMANTIC: MSE should be 0 for perfect predictions")

func test_mse_formula():
	# CRITICAL: MSE = mean((pred - target)^2)
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([0.0, 0.0, 0.0])
	
	var result = entropy_manometer.measure_entropy([1.0, 2.0, 3.0])
	
	# Expected: ((1-0)^2 + (2-0)^2 + (3-0)^2) / 3 = (1 + 4 + 9) / 3 = 14/3 = 4.667
	assert_almost_eq(result["loss"], 14.0/3.0, 0.01,
		"CRITICAL ML SEMANTIC: MSE = mean(squared errors)")

func test_mse_single_value():
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([5.0])
	
	var result = entropy_manometer.measure_entropy([3.0])
	
	# Expected: (3-5)^2 = 4
	assert_almost_eq(result["loss"], 4.0, 0.001, "MSE for single value")

func test_mse_symmetric():
	# MSE should be symmetric in errors: (pred-target)^2 = (target-pred)^2
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	
	entropy_manometer.set_target_values([5.0])
	var result1 = entropy_manometer.measure_entropy([3.0])  # error = -2
	
	entropy_manometer.set_target_values([3.0])
	var result2 = entropy_manometer.measure_entropy([5.0])  # error = +2
	
	assert_almost_eq(result1["loss"], result2["loss"], 0.001,
		"MSE should be symmetric (squared errors)")

## Cross Entropy Tests - CRITICAL ML SEMANTICS

func test_cross_entropy_perfect_binary():
	# CRITICAL: Cross entropy for perfect binary classification should be ~0
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0, 0.0, 1.0])
	
	# Predictions very close to targets (not exact to avoid log(0))
	var result = entropy_manometer.measure_entropy([0.9999, 0.0001, 0.9999])
	
	assert_lt(result["loss"], 0.01,
		"CRITICAL ML SEMANTIC: Cross entropy should be low for confident correct predictions")

func test_cross_entropy_worst_binary():
	# Cross entropy for worst binary classification should be high
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0, 0.0])
	
	# Predictions opposite of targets
	var result = entropy_manometer.measure_entropy([0.0001, 0.9999])
	
	assert_gt(result["loss"], 5.0,
		"Cross entropy should be high for confident wrong predictions")

func test_cross_entropy_uncertain():
	# Cross entropy for uncertain predictions (0.5) should be moderate
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0])
	
	var result = entropy_manometer.measure_entropy([0.5])
	
	# CE = -[1*log(0.5) + 0*log(0.5)] = -log(0.5) ≈ 0.693
	assert_almost_eq(result["loss"], 0.693, 0.01,
		"Cross entropy for 0.5 prediction on binary target")

func test_cross_entropy_formula():
	# CRITICAL: CE = -mean(target * log(pred) + (1-target) * log(1-pred))
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0, 0.0])
	
	var result = entropy_manometer.measure_entropy([0.8, 0.2])
	
	# For sample 0: CE = -(1*log(0.8) + 0*log(0.2)) = -log(0.8) ≈ 0.223
	# For sample 1: CE = -(0*log(0.8) + 1*log(0.8)) = -log(0.8) ≈ 0.223
	# Mean = (0.223 + 0.223) / 2 = 0.223
	assert_almost_eq(result["loss"], 0.223, 0.01,
		"CRITICAL ML SEMANTIC: Cross entropy formula (averaged per sample)")

## Variance Tests

func test_variance_zero_for_constant():
	# Variance of constant array should be 0
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.VARIANCE)
	entropy_manometer.set_target_values([5.0, 5.0, 5.0])
	
	var result = entropy_manometer.measure_entropy([5.0, 5.0, 5.0])
	
	assert_almost_eq(result["loss"], 0.0, 0.001,
		"Variance of constant values should be 0")

func test_variance_formula():
	# CRITICAL: Variance = mean((x - mean(x))^2)
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.VARIANCE)
	entropy_manometer.set_target_values([])  # Variance doesn't use targets
	
	var result = entropy_manometer.measure_entropy([1.0, 2.0, 3.0, 4.0, 5.0])
	
	# Mean = 3.0
	# Variance = ((1-3)^2 + (2-3)^2 + (3-3)^2 + (4-3)^2 + (5-3)^2) / 5
	#          = (4 + 1 + 0 + 1 + 4) / 5 = 10 / 5 = 2.0
	assert_almost_eq(result["loss"], 2.0, 0.001,
		"CRITICAL ML SEMANTIC: Variance formula")

## Smoothing Tests

func test_smoothing_first_measurement():
	# First measurement should set smoothed_loss directly
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([0.0])
	entropy_manometer.set_smoothing_factor(0.5)
	
	var result = entropy_manometer.measure_entropy([2.0])
	
	# First measurement: smoothed_loss = loss = 4.0
	assert_almost_eq(result["smoothed_loss"], 4.0, 0.001,
		"First measurement should set smoothed_loss directly")

func test_smoothing_exponential():
	# Smoothing should apply exponential moving average
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([0.0])
	entropy_manometer.set_smoothing_factor(0.5)
	
	# First measurement
	entropy_manometer.measure_entropy([2.0])  # loss = 4.0, smoothed = 4.0
	
	# Second measurement
	var result = entropy_manometer.measure_entropy([0.0])  # loss = 0.0
	
	# smoothed = 4.0 * (1 - 0.5) + 0.0 * 0.5 = 2.0
	assert_almost_eq(result["smoothed_loss"], 2.0, 0.001,
		"Smoothing should use exponential moving average")

func test_smoothing_factor_minimum():
	entropy_manometer.set_smoothing_factor(0.001)
	assert_almost_eq(entropy_manometer.smoothing_factor, 0.01, 0.001,
		"Smoothing factor should be clamped to minimum 0.01")

func test_smoothing_factor_maximum():
	entropy_manometer.set_smoothing_factor(2.0)
	assert_almost_eq(entropy_manometer.smoothing_factor, 1.0, 0.001,
		"Smoothing factor should be clamped to maximum 1.0")

## Target Values Tests

func test_set_target_values():
	entropy_manometer.set_target_values([1.0, 2.0, 3.0])
	
	assert_eq(entropy_manometer.target_values.size(), 3, "Should set target values")
	assert_almost_eq(entropy_manometer.target_values[0], 1.0, 0.001, "Target 0")
	assert_almost_eq(entropy_manometer.target_values[1], 2.0, 0.001, "Target 1")
	assert_almost_eq(entropy_manometer.target_values[2], 3.0, 0.001, "Target 2")

func test_empty_predictions():
	# Should handle empty predictions gracefully
	entropy_manometer.set_target_values([1.0, 2.0])
	
	var result = entropy_manometer.measure_entropy([])
	
	assert_almost_eq(result["loss"], 0.0, 0.001, "Empty predictions should give 0 loss")

func test_empty_targets():
	# Should handle empty targets gracefully
	entropy_manometer.set_target_values([])
	
	var result = entropy_manometer.measure_entropy([1.0, 2.0])
	
	assert_almost_eq(result["loss"], 0.0, 0.001, "Empty targets should give 0 loss")

func test_mismatched_sizes():
	# Should handle mismatched prediction/target sizes
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([1.0, 2.0, 3.0, 4.0, 5.0])
	
	# Only 3 predictions for 5 targets
	var result = entropy_manometer.measure_entropy([1.0, 2.0, 3.0])
	
	# Should only use first 3 elements
	assert_almost_eq(result["loss"], 0.0, 0.001, "Should use min(pred, target) size")

## Signal Tests

func test_measurement_changed_signal():
	watch_signals(entropy_manometer)
	
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	
	assert_signal_emitted(entropy_manometer, "measurement_changed",
		"Should emit measurement_changed signal")

func test_targets_changed_signal():
	watch_signals(entropy_manometer)
	
	entropy_manometer.set_target_values([1.0, 2.0])
	
	assert_signal_emitted(entropy_manometer, "targets_changed",
		"Should emit targets_changed signal")

func test_smoothing_changed_signal():
	watch_signals(entropy_manometer)
	
	entropy_manometer.set_smoothing_factor(0.5)
	
	assert_signal_emitted(entropy_manometer, "smoothing_changed",
		"Should emit smoothing_changed signal")

func test_entropy_measured_signal():
	watch_signals(entropy_manometer)
	
	entropy_manometer.set_target_values([1.0])
	entropy_manometer.measure_entropy([2.0])
	
	assert_signal_emitted(entropy_manometer, "entropy_measured",
		"Should emit entropy_measured signal")

## Edge Cases

func test_very_large_errors():
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([0.0])
	
	var result = entropy_manometer.measure_entropy([1000.0])
	
	assert_almost_eq(result["loss"], 1000000.0, 1.0, "Should handle large errors")

func test_negative_predictions_mse():
	# MSE should work with negative values
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([-5.0, -3.0])
	
	var result = entropy_manometer.measure_entropy([-4.0, -2.0])
	
	# Errors: (-4 - -5)^2 + (-2 - -3)^2 = 1 + 1 = 2, mean = 1.0
	assert_almost_eq(result["loss"], 1.0, 0.001, "Should handle negative values")

func test_cross_entropy_clips_probabilities():
	# Cross entropy should clip predictions to avoid log(0)
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0])
	
	# Prediction of exactly 0 would cause log(0) = -inf
	# Implementation should clip to small epsilon
	var result = entropy_manometer.measure_entropy([0.0])
	
	# Should return finite value, not infinity
	assert_true(is_finite(result["loss"]), "Should clip probabilities to avoid log(0)")
	assert_gt(result["loss"], 10.0, "Loss should be very high but finite")

func test_measurement_name_strings():
	# Test that get_measurement_name() returns reasonable strings
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	assert_eq(entropy_manometer.get_measurement_name(), "Mean Squared Error")
	
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	assert_eq(entropy_manometer.get_measurement_name(), "Cross Entropy")
	
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.VARIANCE)
	assert_eq(entropy_manometer.get_measurement_name(), "Variance")

## ML Semantics Tests

func test_mse_for_regression():
	# CRITICAL: MSE is the standard loss for regression tasks
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([2.5, 3.7, 1.2])
	
	# Regression predictions
	var result = entropy_manometer.measure_entropy([2.6, 3.5, 1.3])
	
	# Small errors should give small loss
	assert_lt(result["loss"], 0.1,
		"CRITICAL ML SEMANTIC: MSE for good regression predictions should be small")

func test_cross_entropy_for_classification():
	# CRITICAL: Cross entropy is the standard loss for binary classification
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.CROSS_ENTROPY)
	entropy_manometer.set_target_values([1.0, 0.0, 1.0])
	
	# Good classification predictions (after sigmoid)
	var result = entropy_manometer.measure_entropy([0.9, 0.1, 0.85])
	
	assert_lt(result["loss"], 0.5,
		"CRITICAL ML SEMANTIC: Cross entropy for good classification should be low")

func test_loss_gradients_drive_learning():
	# Loss should increase with worse predictions (provides gradient signal)
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([5.0])
	
	var loss_close = entropy_manometer.measure_entropy([4.9])["loss"]  # error = 0.1
	var loss_far = entropy_manometer.measure_entropy([3.0])["loss"]    # error = 2.0
	
	assert_gt(loss_far, loss_close,
		"CRITICAL ML SEMANTIC: Larger errors should give larger loss (gradient signal)")

## Performance Tests

func test_processing_performance():
	entropy_manometer.set_measurement_type(EntropyManometer.MeasurementType.MEAN_SQUARED_ERROR)
	entropy_manometer.set_target_values([1.0, 2.0, 3.0, 4.0, 5.0])
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(10000):
		entropy_manometer.measure_entropy([1.1, 2.1, 3.1, 4.1, 5.1])
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 10000 iterations should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Entropy measurement should be fast (<0.01ms per call)")
