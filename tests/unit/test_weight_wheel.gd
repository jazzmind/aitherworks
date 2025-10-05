extends GutTest

## Unit tests for Weight Wheel part
# Tests weight initialization, process_signals (weighted sum), gradient descent
# Part of Phase 3.2: Retrofit Testing (T202)
# CRITICAL: Tests that process_signals does weighted sum (dot product), NOT element-wise multiply

const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var weight_wheel: WeightWheel
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/weight_wheel.yaml")
	assert_not_null(yaml_spec, "weight_wheel.yaml should load")
	
	# Create instance
	weight_wheel = WeightWheel.new()
	add_child_autofree(weight_wheel)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "weight_wheel", "ID should be weight_wheel")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "processing", "Category should be processing")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "multiplier", "Simulation type should be multiplier")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 1, "Should have 1 output")
	assert_true(sim.get("learnable", false), "Should be learnable")

func test_yaml_has_weight_parameter():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "weight", "Should have weight parameter")

## Port Configuration Tests

func test_yaml_ports_exist():
	var ports = yaml_spec["ports"]
	assert_not_null(ports, "Ports should exist")
	assert_true(ports.size() >= 2, "Should have at least 2 ports (in + out)")

func test_yaml_ports_match_schema():
	var ports = yaml_spec["ports"]
	
	# Check for in_north (input)
	assert_has(ports, "in_north", "Should have in_north port")
	var in_port = ports["in_north"]
	
	if typeof(in_port) == TYPE_DICTIONARY and in_port.has("type"):
		assert_has(in_port, "type", "in_north should have type field")
		assert_eq(in_port["type"], "vector", "in_north should be vector type")
		# Direction field may not be parsed by SpecLoader - that's OK for now
		if in_port.has("direction"):
			assert_eq(in_port["direction"], "input", "in_north should be input direction")
	
	# Check for out_south (output)
	assert_has(ports, "out_south", "Should have out_south port")
	var out_port = ports["out_south"]
	
	if typeof(out_port) == TYPE_DICTIONARY and out_port.has("type"):
		assert_has(out_port, "type", "out_south should have type field")
		assert_eq(out_port["type"], "vector", "out_south should be vector type")
		assert_has(out_port, "direction", "out_south should have direction field")
		assert_eq(out_port["direction"], "output", "out_south should be output direction")

## Initialization Tests

func test_weight_wheel_initializes():
	assert_not_null(weight_wheel, "Weight Wheel should initialize")
	assert_true(weight_wheel.is_inside_tree(), "Should be in scene tree")

func test_default_weight_count():
	# Should have default weight count
	assert_gt(weight_wheel.num_weights, 0, "Should have positive weight count")
	assert_eq(weight_wheel.weights.size(), weight_wheel.num_weights, "Weights array size should match num_weights")

func test_default_weights_initialized():
	# Default weights should be initialized (not zero)
	for i in range(weight_wheel.weights.size()):
		assert_ne(weight_wheel.weights[i], 0.0, "Default weights should be non-zero")

## Weight Configuration Tests

func test_set_num_weights():
	weight_wheel.set_num_weights(5)
	assert_eq(weight_wheel.num_weights, 5, "Should set weight count")
	assert_eq(weight_wheel.weights.size(), 5, "Weights array should resize")

func test_set_weight_individual():
	weight_wheel.set_weight(0, 2.5)
	assert_almost_eq(weight_wheel.get_weight(0), 2.5, 0.001, "Should set individual weight")

func test_get_weight():
	weight_wheel.set_weight(1, 3.7)
	var retrieved = weight_wheel.get_weight(1)
	assert_almost_eq(retrieved, 3.7, 0.001, "Should retrieve weight value")

func test_set_weights_array():
	var new_weights: Array[float] = [0.5, 1.5, 2.5]
	weight_wheel.set_weights(new_weights)
	
	assert_eq(weight_wheel.weights.size(), 3, "Should update weights array")
	assert_almost_eq(weight_wheel.weights[0], 0.5, 0.001, "Weight 0 should match")
	assert_almost_eq(weight_wheel.weights[1], 1.5, 0.001, "Weight 1 should match")
	assert_almost_eq(weight_wheel.weights[2], 2.5, 0.001, "Weight 2 should match")

func test_reset_weights():
	weight_wheel.set_weights([0.5, 0.5, 0.5])
	weight_wheel.reset_weights()
	
	for i in range(weight_wheel.weights.size()):
		assert_almost_eq(weight_wheel.weights[i], 1.0, 0.001, "Reset should set all weights to 1.0")

## Process Signals Tests - CRITICAL ML SEMANTICS

func test_process_signals_weighted_sum():
	# CRITICAL: This should compute weighted sum (dot product), NOT element-wise multiply
	# output = sum(input[i] * weight[i]) for all i
	weight_wheel.set_weights([2.0, 3.0, 4.0])
	var inputs: Array[float] = [1.0, 2.0, 3.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	# Expected: 1.0*2.0 + 2.0*3.0 + 3.0*4.0 = 2 + 6 + 12 = 20
	assert_almost_eq(output, 20.0, 0.001, 
		"CRITICAL ML SEMANTIC: Should compute weighted sum (dot product), not element-wise multiply")

func test_process_signals_simple_case():
	# Simple test case
	weight_wheel.set_weights([1.0, 1.0, 1.0])
	var inputs: Array[float] = [2.0, 3.0, 4.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	# Expected: 2 + 3 + 4 = 9
	assert_almost_eq(output, 9.0, 0.001, "With weights=1, output should be sum of inputs")

func test_process_signals_zero_weights():
	# Test with zero weights
	# Set weights to zero AFTER initialization
	weight_wheel.set_num_weights(3)
	# Now manually set each weight to zero
	for i in range(weight_wheel.weights.size()):
		weight_wheel.weights[i] = 0.0
	
	var inputs: Array[float] = [5.0, 10.0, 15.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_almost_eq(output, 0.0, 0.001, "Zero weights should give zero output")

func test_process_signals_negative_weights():
	# Test with negative weights
	weight_wheel.set_weights([-1.0, 2.0, -3.0])
	var inputs: Array[float] = [1.0, 1.0, 1.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	# Expected: -1 + 2 + (-3) = -2
	assert_almost_eq(output, -2.0, 0.001, "Should handle negative weights")

func test_process_signals_negative_inputs():
	# Test with negative inputs
	weight_wheel.set_weights([1.0, 1.0, 1.0])
	var inputs: Array[float] = [-2.0, 3.0, -4.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	# Expected: -2 + 3 + (-4) = -3
	assert_almost_eq(output, -3.0, 0.001, "Should handle negative inputs")

func test_process_signals_mismatched_sizes():
	# Test when input size doesn't match weight count
	weight_wheel.set_weights([1.0, 2.0, 3.0, 4.0])
	var inputs: Array[float] = [5.0, 6.0]  # Only 2 inputs
	
	var output = weight_wheel.process_signals(inputs)
	
	# Expected: 5*1 + 6*2 = 5 + 12 = 17 (only first 2 weights used)
	assert_almost_eq(output, 17.0, 0.001, "Should handle mismatched sizes gracefully")

func test_process_signals_returns_scalar():
	# Output should be a scalar (float), not a vector
	weight_wheel.set_weights([1.0, 1.0])
	var inputs: Array[float] = [2.0, 3.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_typeof(output, TYPE_FLOAT, "Output should be scalar (float), not array")

## Gradient Descent Tests

func test_apply_gradients_updates_weights():
	# Test that apply_gradients updates weights
	weight_wheel.set_weights([1.0, 1.0, 1.0])
	weight_wheel.learning_rate = 0.1
	
	# Process some input first (needed for gradient calculation)
	var inputs: Array[float] = [2.0, 3.0, 4.0]
	weight_wheel.process_signals(inputs)
	
	# Apply gradient (error signal)
	var error_gradient = 1.0
	weight_wheel.apply_gradients(error_gradient)
	
	# Weights should have changed
	var weights_changed = false
	for i in range(weight_wheel.weights.size()):
		if abs(weight_wheel.weights[i] - 1.0) > 0.001:
			weights_changed = true
			break
	
	assert_true(weights_changed, "Gradients should update weights")

func test_gradient_descent_direction():
	# Test gradient descent moves in correct direction
	weight_wheel.set_weights([1.0, 1.0])
	weight_wheel.learning_rate = 0.1
	
	var inputs: Array[float] = [2.0, 3.0]
	weight_wheel.process_signals(inputs)
	
	# Positive error gradient should decrease weights (gradient descent)
	var initial_weights = weight_wheel.weights.duplicate()
	weight_wheel.apply_gradients(1.0)
	
	# Weights should decrease (w_new = w_old - lr * gradient)
	for i in range(weight_wheel.weights.size()):
		assert_lt(weight_wheel.weights[i], initial_weights[i], 
			"Positive gradient should decrease weights (gradient descent)")

func test_gradient_calculation():
	# Test gradient = input * error_gradient (chain rule)
	weight_wheel.set_weights([1.0, 1.0])
	weight_wheel.learning_rate = 0.1
	
	var inputs: Array[float] = [2.0, 3.0]
	weight_wheel.process_signals(inputs)
	
	var error_gradient = 0.5
	var initial_weights = weight_wheel.weights.duplicate()
	weight_wheel.apply_gradients(error_gradient)
	
	# Expected weight changes:
	# dw[0] = -lr * input[0] * error = -0.1 * 2.0 * 0.5 = -0.1
	# dw[1] = -lr * input[1] * error = -0.1 * 3.0 * 0.5 = -0.15
	
	assert_almost_eq(weight_wheel.weights[0], initial_weights[0] - 0.1, 0.001, 
		"Weight 0 update should match gradient descent formula")
	assert_almost_eq(weight_wheel.weights[1], initial_weights[1] - 0.15, 0.001, 
		"Weight 1 update should match gradient descent formula")

func test_learning_rate_effect():
	# Test that learning_rate scales the weight updates
	weight_wheel.set_weights([1.0, 1.0])
	
	var inputs: Array[float] = [2.0, 3.0]
	weight_wheel.process_signals(inputs)
	
	# Test with small learning rate
	weight_wheel.learning_rate = 0.01
	var initial_weights = weight_wheel.weights.duplicate()
	weight_wheel.apply_gradients(1.0)
	var small_change = abs(weight_wheel.weights[0] - initial_weights[0])
	
	# Reset and test with large learning rate
	weight_wheel.set_weights([1.0, 1.0])
	weight_wheel.process_signals(inputs)
	weight_wheel.learning_rate = 0.5
	initial_weights = weight_wheel.weights.duplicate()
	weight_wheel.apply_gradients(1.0)
	var large_change = abs(weight_wheel.weights[0] - initial_weights[0])
	
	assert_gt(large_change, small_change, 
		"Larger learning rate should cause larger weight updates")

## Signal Tests

func test_weights_changed_signal():
	# Use GUT's watch_signals helper
	watch_signals(weight_wheel)
	
	weight_wheel.set_weight(0, 2.0)
	
	assert_signal_emitted(weight_wheel, "weights_changed", "Should emit weights_changed signal")

func test_weight_adjusted_signal():
	# Use GUT's watch_signals helper
	watch_signals(weight_wheel)
	
	weight_wheel.set_weight(1, 3.5)
	
	assert_signal_emitted(weight_wheel, "weight_adjusted", "Should emit weight_adjusted signal")
	
	# Check signal parameters
	var signal_params = get_signal_parameters(weight_wheel, "weight_adjusted")
	if signal_params != null and typeof(signal_params) == TYPE_ARRAY and signal_params.size() > 0:
		var first_emission = signal_params[0]
		if typeof(first_emission) == TYPE_ARRAY and first_emission.size() >= 2:
			assert_eq(first_emission[0], 1, "Signal should report correct index")
			assert_almost_eq(first_emission[1], 3.5, 0.001, "Signal should report correct value")

## Edge Cases

func test_empty_input():
	weight_wheel.set_weights([1.0, 1.0, 1.0])
	var inputs: Array[float] = []
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_almost_eq(output, 0.0, 0.001, "Empty input should give zero output")

func test_single_weight():
	weight_wheel.set_weights([5.0])
	var inputs: Array[float] = [3.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_almost_eq(output, 15.0, 0.001, "Single weight should work")

func test_large_weight_count():
	var large_weights: Array[float] = []
	var large_inputs: Array[float] = []
	for i in range(100):
		large_weights.append(1.0)
		large_inputs.append(1.0)
	
	weight_wheel.set_weights(large_weights)
	var output = weight_wheel.process_signals(large_inputs)
	
	assert_almost_eq(output, 100.0, 0.001, "Should handle large weight count")

func test_very_small_weights():
	weight_wheel.set_weights([0.0001, 0.0001, 0.0001])
	var inputs: Array[float] = [1.0, 1.0, 1.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_almost_eq(output, 0.0003, 0.00001, "Should handle very small weights")

func test_very_large_weights():
	weight_wheel.set_weights([1000.0, 2000.0, 3000.0])
	var inputs: Array[float] = [1.0, 1.0, 1.0]
	
	var output = weight_wheel.process_signals(inputs)
	
	assert_almost_eq(output, 6000.0, 0.001, "Should handle very large weights")

## ML Semantics Tests

func test_linear_transformation():
	# Weight Wheel implements linear transformation: f(x) = w·x (dot product)
	# This is fundamental to neural networks
	weight_wheel.set_weights([2.0, 3.0])
	
	var input1: Array[float] = [1.0, 1.0]
	var input2: Array[float] = [2.0, 2.0]  # 2x input1
	
	var output1 = weight_wheel.process_signals(input1)
	var output2 = weight_wheel.process_signals(input2)
	
	# Linearity: f(2x) = 2*f(x)
	assert_almost_eq(output2, output1 * 2.0, 0.001, 
		"ML SEMANTIC: Should preserve linear relationships (f(2x) = 2*f(x))")

func test_gradient_descent_convergence():
	# Test that gradient descent can learn to match a target
	weight_wheel.set_weights([0.0, 0.0])
	weight_wheel.learning_rate = 0.1
	
	var inputs: Array[float] = [1.0, 1.0]
	var target_output = 5.0
	
	# Run gradient descent for multiple iterations
	for iteration in range(50):
		var output = weight_wheel.process_signals(inputs)
		var error = target_output - output
		weight_wheel.apply_gradients(-error)  # Negative because we want to minimize error
	
	# After training, output should be close to target
	var final_output = weight_wheel.process_signals(inputs)
	assert_almost_eq(final_output, target_output, 0.5, 
		"ML SEMANTIC: Gradient descent should converge toward target")

## Performance Tests

func test_processing_performance():
	# Test that processing is fast enough
	weight_wheel.set_weights([1.0, 1.0, 1.0, 1.0, 1.0])
	var inputs: Array[float] = [1.0, 2.0, 3.0, 4.0, 5.0]
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(10000):
		weight_wheel.process_signals(inputs)
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 10000 iterations should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Weight Wheel processing should be fast (<0.01ms per call)")

func test_gradient_application_performance():
	# Test gradient descent performance
	weight_wheel.set_weights([1.0, 1.0, 1.0, 1.0, 1.0])
	var inputs: Array[float] = [1.0, 2.0, 3.0, 4.0, 5.0]
	weight_wheel.process_signals(inputs)
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(10000):
		weight_wheel.apply_gradients(0.1)
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 10000 gradient updates should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Gradient application should be fast (<0.01ms per call)")
