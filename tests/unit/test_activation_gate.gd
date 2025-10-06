extends GutTest

## Unit tests for Activation Gate part
# Tests all 5 activation functions, threshold, gain, edge cases
# Part of Phase 3.2: Retrofit Testing (T204)
# CRITICAL: Activation functions must match standard ML definitions

const ActivationGate = preload("res://game/parts/activation_gate.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var activation_gate: ActivationGate
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/activation_gate.yaml")
	assert_not_null(yaml_spec, "activation_gate.yaml should load")
	
	# Create instance
	activation_gate = ActivationGate.new()
	add_child_autofree(activation_gate)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "activation_gate", "ID should be activation_gate")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "basic", "Category should be basic")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "activation", "Simulation type should be activation")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 1, "Should have 1 output")
	assert_false(sim.get("learnable", false), "Should not be learnable")

func test_yaml_has_function_parameter():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "function", "Should have function parameter")

## Port Configuration Tests

func test_yaml_ports_exist():
	var ports = yaml_spec["ports"]
	assert_not_null(ports, "Ports should exist")
	assert_true(ports.size() >= 2, "Should have at least 2 ports (in + out)")

## Initialization Tests

func test_activation_gate_initializes():
	assert_not_null(activation_gate, "Activation Gate should initialize")
	assert_true(activation_gate.is_inside_tree(), "Should be in scene tree")

func test_default_activation_type():
	assert_eq(activation_gate.activation_type, ActivationGate.ActivationType.RELU,
		"Default activation should be RELU")

func test_default_threshold():
	assert_almost_eq(activation_gate.threshold, 0.0, 0.001, "Default threshold should be 0")

func test_default_gain():
	assert_almost_eq(activation_gate.gain, 1.0, 0.001, "Default gain should be 1")

## ReLU Activation Tests - CRITICAL ML SEMANTICS

func test_relu_positive_input():
	# CRITICAL: ReLU(x) = max(0, x) for x > 0
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var output = activation_gate.apply_activation(5.0)
	
	assert_almost_eq(output, 5.0, 0.001,
		"CRITICAL ML SEMANTIC: ReLU(5) should be 5 (pass positive values)")

func test_relu_negative_input():
	# CRITICAL: ReLU(x) = max(0, x) = 0 for x < 0
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var output = activation_gate.apply_activation(-3.0)
	
	assert_almost_eq(output, 0.0, 0.001,
		"CRITICAL ML SEMANTIC: ReLU(-3) should be 0 (block negative values)")

func test_relu_zero_input():
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.0, 0.001, "ReLU(0) should be 0")

func test_relu_large_positive():
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var output = activation_gate.apply_activation(1000.0)
	
	assert_almost_eq(output, 1000.0, 0.001, "ReLU should pass large positive values")

## Sigmoid Activation Tests - CRITICAL ML SEMANTICS

func test_sigmoid_zero_input():
	# CRITICAL: sigmoid(0) = 1/(1+e^0) = 1/2 = 0.5
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.5, 0.001,
		"CRITICAL ML SEMANTIC: sigmoid(0) should be 0.5")

func test_sigmoid_positive_input():
	# sigmoid(x) approaches 1 as x → ∞
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	var output = activation_gate.apply_activation(10.0)
	
	assert_gt(output, 0.99, "sigmoid(10) should be close to 1")
	assert_lt(output, 1.0, "sigmoid should never reach exactly 1")

func test_sigmoid_negative_input():
	# sigmoid(x) approaches 0 as x → -∞
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	var output = activation_gate.apply_activation(-10.0)
	
	assert_lt(output, 0.01, "sigmoid(-10) should be close to 0")
	assert_gt(output, 0.0, "sigmoid should never reach exactly 0")

func test_sigmoid_range():
	# CRITICAL: sigmoid output is always in (0, 1)
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	for x in [-100.0, -10.0, -1.0, 0.0, 1.0, 10.0, 100.0]:
		var output = activation_gate.apply_activation(x)
		assert_gt(output, 0.0, "sigmoid output should be > 0")
		assert_lt(output, 1.0, "sigmoid output should be < 1")

## Tanh Activation Tests - CRITICAL ML SEMANTICS

func test_tanh_zero_input():
	# CRITICAL: tanh(0) = 0
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.0, 0.001,
		"CRITICAL ML SEMANTIC: tanh(0) should be 0")

func test_tanh_positive_input():
	# tanh(x) approaches 1 as x → ∞
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	var output = activation_gate.apply_activation(10.0)
	
	assert_gt(output, 0.99, "tanh(10) should be close to 1")
	assert_lt(output, 1.0, "tanh should never exceed 1")

func test_tanh_negative_input():
	# tanh(x) approaches -1 as x → -∞
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	var output = activation_gate.apply_activation(-10.0)
	
	assert_lt(output, -0.99, "tanh(-10) should be close to -1")
	assert_gt(output, -1.0, "tanh should never go below -1")

func test_tanh_range():
	# CRITICAL: tanh output is always in (-1, 1)
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	for x in [-100.0, -10.0, -1.0, 0.0, 1.0, 10.0, 100.0]:
		var output = activation_gate.apply_activation(x)
		assert_gt(output, -1.0, "tanh output should be > -1")
		assert_lt(output, 1.0, "tanh output should be < 1")

func test_tanh_symmetry():
	# CRITICAL: tanh is odd function: tanh(-x) = -tanh(x)
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	var output_pos = activation_gate.apply_activation(2.0)
	var output_neg = activation_gate.apply_activation(-2.0)
	
	assert_almost_eq(output_pos, -output_neg, 0.001,
		"CRITICAL ML SEMANTIC: tanh should be symmetric (tanh(-x) = -tanh(x))")

## Linear Activation Tests

func test_linear_positive():
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	
	var output = activation_gate.apply_activation(5.0)
	
	assert_almost_eq(output, 5.0, 0.001, "Linear should pass value unchanged")

func test_linear_negative():
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	
	var output = activation_gate.apply_activation(-3.0)
	
	assert_almost_eq(output, -3.0, 0.001, "Linear should pass negative values")

func test_linear_zero():
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.0, 0.001, "Linear(0) should be 0")

## Step Activation Tests

func test_step_positive():
	activation_gate.set_activation_type(ActivationGate.ActivationType.STEP)
	
	var output = activation_gate.apply_activation(5.0)
	
	assert_almost_eq(output, 1.0, 0.001, "Step(positive) should be 1")

func test_step_negative():
	activation_gate.set_activation_type(ActivationGate.ActivationType.STEP)
	
	var output = activation_gate.apply_activation(-3.0)
	
	assert_almost_eq(output, 0.0, 0.001, "Step(negative) should be 0")

func test_step_zero():
	activation_gate.set_activation_type(ActivationGate.ActivationType.STEP)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.0, 0.001, "Step(0) should be 0")

## Threshold Parameter Tests

func test_threshold_positive():
	# Threshold shifts the input: f(x + threshold)
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	activation_gate.set_threshold(2.0)
	
	var output = activation_gate.apply_activation(1.0)
	
	# ReLU(1 + 2) = ReLU(3) = 3
	assert_almost_eq(output, 3.0, 0.001, "Threshold should shift input")

func test_threshold_negative():
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	activation_gate.set_threshold(-1.0)
	
	var output = activation_gate.apply_activation(2.0)
	
	# ReLU(2 - 1) = ReLU(1) = 1
	assert_almost_eq(output, 1.0, 0.001, "Negative threshold should shift down")

func test_threshold_blocks_positive():
	# Negative threshold can block positive inputs
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	activation_gate.set_threshold(-5.0)
	
	var output = activation_gate.apply_activation(3.0)
	
	# ReLU(3 - 5) = ReLU(-2) = 0
	assert_almost_eq(output, 0.0, 0.001, "Threshold can block inputs")

## Gain Parameter Tests

func test_gain_amplification():
	# Gain scales the input: f(x * gain)
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	activation_gate.set_gain(2.0)
	
	var output = activation_gate.apply_activation(3.0)
	
	# Linear(3 * 2) = 6
	assert_almost_eq(output, 6.0, 0.001, "Gain should amplify input")

func test_gain_attenuation():
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	activation_gate.set_gain(0.5)
	
	var output = activation_gate.apply_activation(4.0)
	
	# Linear(4 * 0.5) = 2
	assert_almost_eq(output, 2.0, 0.001, "Gain < 1 should attenuate input")

func test_gain_minimum():
	activation_gate.set_gain(0.01)
	assert_almost_eq(activation_gate.gain, 0.1, 0.001, 
		"Gain should be clamped to minimum 0.1")

func test_gain_maximum():
	activation_gate.set_gain(20.0)
	assert_almost_eq(activation_gate.gain, 10.0, 0.001,
		"Gain should be clamped to maximum 10.0")

## Combined Threshold + Gain Tests

func test_threshold_and_gain():
	# Order: input * gain + threshold
	activation_gate.set_activation_type(ActivationGate.ActivationType.LINEAR)
	activation_gate.set_gain(2.0)
	activation_gate.set_threshold(1.0)
	
	var output = activation_gate.apply_activation(3.0)
	
	# Linear(3 * 2 + 1) = Linear(7) = 7
	assert_almost_eq(output, 7.0, 0.001,
		"Should apply gain then threshold: (x * gain) + threshold")

## Signal Tests

func test_activation_changed_signal():
	watch_signals(activation_gate)
	
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	assert_signal_emitted(activation_gate, "activation_changed",
		"Should emit activation_changed signal")

func test_threshold_changed_signal():
	watch_signals(activation_gate)
	
	activation_gate.set_threshold(2.5)
	
	assert_signal_emitted(activation_gate, "threshold_changed",
		"Should emit threshold_changed signal")

func test_gain_changed_signal():
	watch_signals(activation_gate)
	
	activation_gate.set_gain(1.5)
	
	assert_signal_emitted(activation_gate, "gain_changed",
		"Should emit gain_changed signal")

func test_signal_transformed_signal():
	watch_signals(activation_gate)
	
	activation_gate.apply_activation(5.0)
	
	assert_signal_emitted(activation_gate, "signal_transformed",
		"Should emit signal_transformed signal")

## Edge Cases

func test_very_large_input():
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	var output = activation_gate.apply_activation(1000.0)
	
	# sigmoid(1000) should saturate to ~1
	assert_gt(output, 0.999, "Should handle very large inputs")

func test_very_small_input():
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	var output = activation_gate.apply_activation(-1000.0)
	
	# sigmoid(-1000) should saturate to ~0
	assert_lt(output, 0.001, "Should handle very small inputs")

func test_activation_name_strings():
	# Test that get_activation_name() returns reasonable strings
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	assert_eq(activation_gate.get_activation_name(), "ReLU Valve")
	
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	assert_eq(activation_gate.get_activation_name(), "Sigmoid Chamber")
	
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	assert_eq(activation_gate.get_activation_name(), "Hyperbolic Regulator")

## ML Semantics Tests

func test_relu_introduces_nonlinearity():
	# CRITICAL: ReLU is nonlinear (breaks linearity)
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var output1 = activation_gate.apply_activation(1.0)   # ReLU(1) = 1
	var output2 = activation_gate.apply_activation(-1.0)  # ReLU(-1) = 0
	
	# If linear: f(1) + f(-1) = f(1 + -1) = f(0) = 0
	# But ReLU: f(1) + f(-1) = 1 + 0 = 1 ≠ 0
	var sum = output1 + output2
	var output_sum = activation_gate.apply_activation(0.0)
	
	assert_ne(sum, output_sum,
		"CRITICAL ML SEMANTIC: ReLU is nonlinear (f(a) + f(b) ≠ f(a+b))")

func test_sigmoid_output_probability():
	# Sigmoid outputs can be interpreted as probabilities (0 to 1)
	activation_gate.set_activation_type(ActivationGate.ActivationType.SIGMOID)
	
	for x in [-5.0, -2.0, 0.0, 2.0, 5.0]:
		var output = activation_gate.apply_activation(x)
		assert_ge(output, 0.0, "Sigmoid output should be valid probability (≥ 0)")
		assert_le(output, 1.0, "Sigmoid output should be valid probability (≤ 1)")

func test_tanh_centered_output():
	# Tanh is centered at 0 (unlike sigmoid centered at 0.5)
	# This makes it better for hidden layers
	activation_gate.set_activation_type(ActivationGate.ActivationType.TANH)
	
	var output = activation_gate.apply_activation(0.0)
	
	assert_almost_eq(output, 0.0, 0.001,
		"CRITICAL ML SEMANTIC: tanh(0) = 0 (zero-centered, unlike sigmoid)")

## Performance Tests

func test_processing_performance():
	activation_gate.set_activation_type(ActivationGate.ActivationType.RELU)
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(10000):
		activation_gate.apply_activation(float(i % 100 - 50))
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 10000 iterations should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Activation processing should be fast (<0.01ms per call)")
