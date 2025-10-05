extends GutTest

## Unit tests for Adder Manifold part
# Tests multi-input addition, bias, scaling, port connectivity
# Part of Phase 3.2: Retrofit Testing (T203)

const AdderManifold = preload("res://game/parts/adder_manifold.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var adder_manifold: AdderManifold
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/adder_manifold.yaml")
	assert_not_null(yaml_spec, "adder_manifold.yaml should load")
	
	# Create instance
	adder_manifold = AdderManifold.new()
	add_child_autofree(adder_manifold)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "adder_manifold", "ID should be adder_manifold")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "basic", "Category should be basic")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "add", "Simulation type should be add")
	assert_eq(sim["inputs"], 2, "Should have 2 inputs by default")
	assert_eq(sim["outputs"], 1, "Should have 1 output")
	assert_false(sim.get("learnable", false), "Should not be learnable")

## Port Configuration Tests

func test_yaml_ports_exist():
	var ports = yaml_spec["ports"]
	assert_not_null(ports, "Ports should exist")
	assert_true(ports.size() >= 3, "Should have at least 3 ports (2 in + 1 out)")

func test_yaml_ports_match_schema():
	var ports = yaml_spec["ports"]
	
	# Check for in_north (first input)
	assert_has(ports, "in_north", "Should have in_north port")
	
	# Check for in_east (second input)
	assert_has(ports, "in_east", "Should have in_east port")
	
	# Check for out_south (output)
	assert_has(ports, "out_south", "Should have out_south port")

## Initialization Tests

func test_adder_manifold_initializes():
	assert_not_null(adder_manifold, "Adder Manifold should initialize")
	assert_true(adder_manifold.is_inside_tree(), "Should be in scene tree")

func test_default_input_ports():
	assert_gt(adder_manifold.input_ports, 0, "Should have positive input port count")
	assert_eq(adder_manifold.input_signals.size(), adder_manifold.input_ports, 
		"Input signals array should match port count")

func test_default_bias():
	assert_almost_eq(adder_manifold.bias, 0.0, 0.001, "Default bias should be 0")

func test_default_scaling_factor():
	assert_almost_eq(adder_manifold.scaling_factor, 1.0, 0.001, "Default scaling should be 1")

## Input Port Configuration Tests

func test_set_input_ports():
	adder_manifold.set_input_ports(4)
	assert_eq(adder_manifold.input_ports, 4, "Should set input port count")
	assert_eq(adder_manifold.input_signals.size(), 4, "Should resize input array")

func test_input_ports_minimum():
	adder_manifold.set_input_ports(0)
	assert_eq(adder_manifold.input_ports, 1, "Should enforce minimum of 1 port")

func test_input_ports_negative():
	adder_manifold.set_input_ports(-5)
	assert_eq(adder_manifold.input_ports, 1, "Should handle negative values")

## Connect Input Tests

func test_connect_input_single():
	adder_manifold.connect_input(0, 5.0)
	assert_almost_eq(adder_manifold.input_signals[0], 5.0, 0.001, 
		"Should connect signal to port 0")

func test_connect_input_multiple():
	adder_manifold.set_input_ports(3)
	adder_manifold.connect_input(0, 1.0)
	adder_manifold.connect_input(1, 2.0)
	adder_manifold.connect_input(2, 3.0)
	
	assert_almost_eq(adder_manifold.input_signals[0], 1.0, 0.001, "Port 0 should be 1.0")
	assert_almost_eq(adder_manifold.input_signals[1], 2.0, 0.001, "Port 1 should be 2.0")
	assert_almost_eq(adder_manifold.input_signals[2], 3.0, 0.001, "Port 2 should be 3.0")

func test_connect_input_out_of_range():
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(5, 10.0)  # Invalid port
	
	# Should not crash, just ignore invalid port
	assert_true(true, "Should handle out-of-range port gracefully")

## Process Signals Tests - CRITICAL ML SEMANTICS

func test_process_signals_simple_addition():
	# CRITICAL: Should perform element-wise addition of all inputs
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(0, 3.0)
	adder_manifold.connect_input(1, 4.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: 3 + 4 = 7
	assert_almost_eq(output, 7.0, 0.001, 
		"CRITICAL ML SEMANTIC: Should sum all inputs")

func test_process_signals_three_inputs():
	adder_manifold.set_input_ports(3)
	adder_manifold.connect_input(0, 1.0)
	adder_manifold.connect_input(1, 2.0)
	adder_manifold.connect_input(2, 3.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: 1 + 2 + 3 = 6
	assert_almost_eq(output, 6.0, 0.001, "Should sum three inputs")

func test_process_signals_with_bias():
	# Test bias parameter (adds constant to sum)
	adder_manifold.set_input_ports(2)
	adder_manifold.set_bias(10.0)
	adder_manifold.connect_input(0, 2.0)
	adder_manifold.connect_input(1, 3.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: (2 + 3 + 10) = 15
	assert_almost_eq(output, 15.0, 0.001, "Should add bias to sum")

func test_process_signals_with_scaling():
	# Test scaling_factor parameter (multiplies sum)
	adder_manifold.set_input_ports(2)
	adder_manifold.set_scaling_factor(2.0)
	adder_manifold.connect_input(0, 3.0)
	adder_manifold.connect_input(1, 4.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: (3 + 4) * 2 = 14
	assert_almost_eq(output, 14.0, 0.001, "Should scale the sum")

func test_process_signals_with_bias_and_scaling():
	# Test both bias and scaling (order: sum, add bias, then scale)
	adder_manifold.set_input_ports(2)
	adder_manifold.set_bias(1.0)
	adder_manifold.set_scaling_factor(2.0)
	adder_manifold.connect_input(0, 2.0)
	adder_manifold.connect_input(1, 3.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: (2 + 3 + 1) * 2 = 12
	assert_almost_eq(output, 12.0, 0.001, 
		"Should apply bias then scaling: (sum + bias) * scale")

func test_process_signals_negative_inputs():
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(0, -5.0)
	adder_manifold.connect_input(1, 3.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: -5 + 3 = -2
	assert_almost_eq(output, -2.0, 0.001, "Should handle negative inputs")

func test_process_signals_zero_inputs():
	adder_manifold.set_input_ports(3)
	adder_manifold.connect_input(0, 0.0)
	adder_manifold.connect_input(1, 0.0)
	adder_manifold.connect_input(2, 0.0)
	
	var output = adder_manifold.process_signals()
	
	assert_almost_eq(output, 0.0, 0.001, "Zero inputs should give zero output")

func test_process_signals_unconnected_ports():
	# Test with some ports not explicitly connected (should default to 0)
	adder_manifold.set_input_ports(3)
	adder_manifold.connect_input(0, 5.0)
	# Port 1 and 2 not connected (should be 0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: 5 + 0 + 0 = 5
	assert_almost_eq(output, 5.0, 0.001, 
		"Unconnected ports should default to 0")

## Bias Tests

func test_set_bias_positive():
	adder_manifold.set_bias(5.5)
	assert_almost_eq(adder_manifold.bias, 5.5, 0.001, "Should set positive bias")

func test_set_bias_negative():
	adder_manifold.set_bias(-3.2)
	assert_almost_eq(adder_manifold.bias, -3.2, 0.001, "Should set negative bias")

func test_set_bias_zero():
	adder_manifold.set_bias(0.0)
	assert_almost_eq(adder_manifold.bias, 0.0, 0.001, "Should set zero bias")

## Scaling Factor Tests

func test_set_scaling_factor():
	adder_manifold.set_scaling_factor(2.5)
	assert_almost_eq(adder_manifold.scaling_factor, 2.5, 0.001, 
		"Should set scaling factor")

func test_scaling_factor_minimum():
	adder_manifold.set_scaling_factor(0.05)
	assert_almost_eq(adder_manifold.scaling_factor, 0.1, 0.001, 
		"Should enforce minimum scaling of 0.1")

func test_scaling_factor_maximum():
	adder_manifold.set_scaling_factor(10.0)
	assert_almost_eq(adder_manifold.scaling_factor, 5.0, 0.001, 
		"Should enforce maximum scaling of 5.0")

## Signal Tests

func test_ports_changed_signal():
	watch_signals(adder_manifold)
	
	adder_manifold.set_input_ports(5)
	
	assert_signal_emitted(adder_manifold, "ports_changed", 
		"Should emit ports_changed signal")

func test_bias_changed_signal():
	watch_signals(adder_manifold)
	
	adder_manifold.set_bias(3.5)
	
	assert_signal_emitted(adder_manifold, "bias_changed", 
		"Should emit bias_changed signal")

func test_scaling_changed_signal():
	watch_signals(adder_manifold)
	
	adder_manifold.set_scaling_factor(2.0)
	
	assert_signal_emitted(adder_manifold, "scaling_changed", 
		"Should emit scaling_changed signal")

func test_signals_combined_signal():
	watch_signals(adder_manifold)
	
	adder_manifold.connect_input(0, 1.0)
	adder_manifold.connect_input(1, 2.0)
	adder_manifold.process_signals()
	
	assert_signal_emitted(adder_manifold, "signals_combined", 
		"Should emit signals_combined signal")

## Edge Cases

func test_single_input_port():
	adder_manifold.set_input_ports(1)
	adder_manifold.connect_input(0, 7.0)
	
	var output = adder_manifold.process_signals()
	
	assert_almost_eq(output, 7.0, 0.001, "Should work with single input")

func test_many_input_ports():
	adder_manifold.set_input_ports(10)
	
	for i in range(10):
		adder_manifold.connect_input(i, 1.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: 10 * 1.0 = 10
	assert_almost_eq(output, 10.0, 0.001, "Should handle many inputs")

func test_very_large_values():
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(0, 1000000.0)
	adder_manifold.connect_input(1, 2000000.0)
	
	var output = adder_manifold.process_signals()
	
	assert_almost_eq(output, 3000000.0, 1.0, "Should handle large values")

func test_very_small_values():
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(0, 0.0001)
	adder_manifold.connect_input(1, 0.0002)
	
	var output = adder_manifold.process_signals()
	
	assert_almost_eq(output, 0.0003, 0.00001, "Should handle small values")

## ML Semantics Tests

func test_residual_connection_semantics():
	# CRITICAL: Adder Manifold enables residual connections in neural networks
	# Residual: output = input + transformation(input)
	# Here we simulate: output = x + f(x) where x=5, f(x)=3
	adder_manifold.set_input_ports(2)
	adder_manifold.connect_input(0, 5.0)  # Original input (x)
	adder_manifold.connect_input(1, 3.0)  # Transformed input (f(x))
	
	var output = adder_manifold.process_signals()
	
	# Expected: 5 + 3 = 8 (residual connection)
	assert_almost_eq(output, 8.0, 0.001, 
		"ML SEMANTIC: Should enable residual connections (x + f(x))")

func test_broadcasting_with_bias():
	# Bias should broadcast across all inputs (scalar addition)
	adder_manifold.set_input_ports(3)
	adder_manifold.set_bias(1.0)
	adder_manifold.connect_input(0, 1.0)
	adder_manifold.connect_input(1, 2.0)
	adder_manifold.connect_input(2, 3.0)
	
	var output = adder_manifold.process_signals()
	
	# Expected: (1 + 2 + 3) + 1 = 7 (bias added once to sum, not per input)
	assert_almost_eq(output, 7.0, 0.001, 
		"ML SEMANTIC: Bias should be scalar addition to sum")

func test_linearity():
	# Addition should be linear: f(ax + by) = af(x) + bf(y)
	adder_manifold.set_input_ports(2)
	adder_manifold.set_bias(0.0)
	adder_manifold.set_scaling_factor(1.0)
	
	# Test case 1: x=1, y=1
	adder_manifold.connect_input(0, 1.0)
	adder_manifold.connect_input(1, 1.0)
	var output1 = adder_manifold.process_signals()
	
	# Test case 2: x=2, y=2 (double the inputs)
	adder_manifold.connect_input(0, 2.0)
	adder_manifold.connect_input(1, 2.0)
	var output2 = adder_manifold.process_signals()
	
	# Linearity: f(2x, 2y) = 2*f(x, y)
	assert_almost_eq(output2, output1 * 2.0, 0.001, 
		"ML SEMANTIC: Addition should be linear")

func test_commutativity():
	# Addition should be commutative: a + b = b + a
	adder_manifold.set_input_ports(2)
	
	# Order 1: a=3, b=5
	adder_manifold.connect_input(0, 3.0)
	adder_manifold.connect_input(1, 5.0)
	var output1 = adder_manifold.process_signals()
	
	# Order 2: a=5, b=3 (swapped)
	adder_manifold.connect_input(0, 5.0)
	adder_manifold.connect_input(1, 3.0)
	var output2 = adder_manifold.process_signals()
	
	assert_almost_eq(output1, output2, 0.001, 
		"ML SEMANTIC: Addition should be commutative (a+b = b+a)")

## Performance Tests

func test_processing_performance():
	adder_manifold.set_input_ports(5)
	for i in range(5):
		adder_manifold.connect_input(i, float(i))
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(10000):
		adder_manifold.process_signals()
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 10000 iterations should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Adder Manifold processing should be fast (<0.01ms per call)")
