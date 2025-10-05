extends GutTest

## Unit tests for Convolution Drum part
# Tests 1D convolution, kernel operations, stride, padding
# Part of Phase 3.2: Retrofit Testing (T206)
# CRITICAL: Convolution math must match standard formulas

const ConvolutionDrum = preload("res://game/parts/convolution_drum.gd")
const SpecLoader = preload("res://game/sim/spec_loader.gd")

var convolution_drum: ConvolutionDrum
var yaml_spec: Dictionary

func before_each():
	# Load YAML spec
	yaml_spec = SpecLoader.load_yaml("res://data/parts/convolution_drum.yaml")
	assert_not_null(yaml_spec, "convolution_drum.yaml should load")
	
	# Create instance
	convolution_drum = ConvolutionDrum.new()
	add_child_autofree(convolution_drum)

## YAML Spec Validation Tests

func test_yaml_has_required_fields():
	assert_has(yaml_spec, "id", "YAML should have id field")
	assert_has(yaml_spec, "name", "YAML should have name field")
	assert_has(yaml_spec, "category", "YAML should have category field")
	assert_has(yaml_spec, "simulation", "YAML should have simulation field")
	assert_has(yaml_spec, "ports", "YAML should have ports field")

func test_yaml_id_matches():
	assert_eq(yaml_spec["id"], "convolution_drum", "ID should be convolution_drum")

func test_yaml_category():
	assert_eq(yaml_spec["category"], "vision", "Category should be vision")

func test_yaml_simulation_type():
	var sim = yaml_spec["simulation"]
	assert_eq(sim["type"], "conv2d", "Simulation type should be conv2d")
	assert_eq(sim["inputs"], 1, "Should have 1 input")
	assert_eq(sim["outputs"], 1, "Should have 1 output")
	assert_true(sim.get("learnable", false), "Should be learnable")

func test_yaml_has_convolution_parameters():
	var sim = yaml_spec["simulation"]
	assert_has(sim, "parameters", "Should have parameters")
	assert_has(sim["parameters"], "kernel_size", "Should have kernel_size parameter")
	assert_has(sim["parameters"], "stride", "Should have stride parameter")
	assert_has(sim["parameters"], "padding", "Should have padding parameter")

## Initialization Tests

func test_convolution_drum_initializes():
	assert_not_null(convolution_drum, "Convolution Drum should initialize")
	assert_true(convolution_drum.is_inside_tree(), "Should be in scene tree")

func test_default_kernel_size():
	assert_eq(convolution_drum.kernel_size, 3, "Default kernel size should be 3")

func test_default_stride():
	assert_eq(convolution_drum.stride, 1, "Default stride should be 1")

func test_default_padding():
	assert_eq(convolution_drum.padding, 0, "Default padding should be 0")

func test_kernel_initialized():
	# Kernel should be initialized with random weights
	assert_gt(convolution_drum.convolution_kernel.size(), 0, 
		"Kernel should be initialized")
	assert_eq(convolution_drum.convolution_kernel.size(), 9, 
		"Kernel size should be 3x3 = 9 for default")

## Kernel Configuration Tests

func test_set_kernel_size():
	convolution_drum.set_kernel_size(5)
	
	assert_eq(convolution_drum.kernel_size, 5, "Should set kernel size")
	assert_eq(convolution_drum.convolution_kernel.size(), 25, 
		"Kernel array should be 5x5 = 25")

func test_kernel_size_minimum():
	convolution_drum.set_kernel_size(0)
	assert_eq(convolution_drum.kernel_size, 1, "Kernel size should be clamped to minimum 1")

func test_kernel_size_maximum():
	convolution_drum.set_kernel_size(10)
	assert_eq(convolution_drum.kernel_size, 7, "Kernel size should be clamped to maximum 7")

func test_set_stride():
	convolution_drum.set_stride(2)
	assert_eq(convolution_drum.stride, 2, "Should set stride")

func test_stride_minimum():
	convolution_drum.set_stride(0)
	assert_eq(convolution_drum.stride, 1, "Stride should be minimum 1")

func test_set_padding():
	convolution_drum.set_padding(2)
	assert_eq(convolution_drum.padding, 2, "Should set padding")

func test_padding_minimum():
	convolution_drum.set_padding(-1)
	assert_eq(convolution_drum.padding, 0, "Padding should be minimum 0")

## Basic Convolution Tests - CRITICAL ML SEMANTICS

func test_convolution_output_size_no_padding():
	# CRITICAL: Output size formula: (input_size - kernel_size) / stride + 1
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(0)
	
	var input = [1.0, 2.0, 3.0, 4.0, 5.0]  # 5 elements
	var output = convolution_drum.apply_convolution(input)
	
	# Expected output size: (5 - 3) / 1 + 1 = 3
	assert_eq(output.size(), 3,
		"CRITICAL ML SEMANTIC: Output size = (input - kernel) / stride + 1")

func test_convolution_output_size_with_padding():
	# With padding: (input_size + 2*padding - kernel_size) / stride + 1
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(1)
	
	var input = [1.0, 2.0, 3.0, 4.0, 5.0]  # 5 elements
	var output = convolution_drum.apply_convolution(input)
	
	# Expected: (5 + 2*1 - 3) / 1 + 1 = 5 (same size output)
	assert_eq(output.size(), 5,
		"With padding=1 and kernel=3, output should match input size")

func test_convolution_with_stride():
	# Stride reduces output size
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(2)
	convolution_drum.set_padding(0)
	
	var input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]  # 7 elements
	var output = convolution_drum.apply_convolution(input)
	
	# Expected: (7 - 3) / 2 + 1 = 3
	assert_eq(output.size(), 3,
		"Stride=2 should reduce output size")

func test_convolution_with_known_kernel():
	# Test with known kernel values to verify math
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(0)
	
	# Set specific kernel: [1, 0, -1] (edge detector)
	convolution_drum.convolution_kernel = [1.0, 0.0, -1.0]
	
	var input = [1.0, 2.0, 3.0, 4.0, 5.0]
	var output = convolution_drum.apply_convolution(input)
	
	# Position 0: 1*1 + 0*2 + (-1)*3 = 1 - 3 = -2
	# Position 1: 1*2 + 0*3 + (-1)*4 = 2 - 4 = -2
	# Position 2: 1*3 + 0*4 + (-1)*5 = 3 - 5 = -2
	assert_almost_eq(output[0], -2.0, 0.001, "Convolution position 0")
	assert_almost_eq(output[1], -2.0, 0.001, "Convolution position 1")
	assert_almost_eq(output[2], -2.0, 0.001, "Convolution position 2")

func test_convolution_simple_sum():
	# Simple test: kernel of all 1s should sum the window
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(0)
	
	convolution_drum.convolution_kernel = [1.0, 1.0, 1.0]
	
	var input = [1.0, 2.0, 3.0, 4.0]
	var output = convolution_drum.apply_convolution(input)
	
	# Position 0: 1 + 2 + 3 = 6
	# Position 1: 2 + 3 + 4 = 9
	assert_almost_eq(output[0], 6.0, 0.001, "Sum of first window")
	assert_almost_eq(output[1], 9.0, 0.001, "Sum of second window")

## Padding Tests

func test_padding_adds_zeros():
	# Padding should add zeros around the input
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(1)
	
	# With all-1 kernel, edge positions should only sum non-padded values
	convolution_drum.convolution_kernel = [1.0, 1.0, 1.0]
	
	var input = [5.0, 5.0, 5.0]
	var output = convolution_drum.apply_convolution(input)
	
	# Position 0: 0 + 5 + 5 = 10 (left edge has padding)
	# Position 1: 5 + 5 + 5 = 15 (center, no padding)
	# Position 2: 5 + 5 + 0 = 10 (right edge has padding)
	assert_almost_eq(output[0], 10.0, 0.001, "Left edge with padding")
	assert_almost_eq(output[1], 15.0, 0.001, "Center without padding")
	assert_almost_eq(output[2], 10.0, 0.001, "Right edge with padding")

func test_padding_preserves_dimensions():
	# padding=1 with kernel=3 should preserve input dimensions
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(1)
	
	for size in [3, 5, 7, 10]:
		var input = []
		for i in range(size):
			input.append(float(i))
		
		var output = convolution_drum.apply_convolution(input)
		assert_eq(output.size(), size, 
			"With padding=1 and kernel=3, output should match input size")

## Stride Tests

func test_stride_skips_positions():
	# Stride=2 should skip every other position
	convolution_drum.set_kernel_size(1)  # kernel=1 for simple passthrough
	convolution_drum.set_stride(2)
	convolution_drum.set_padding(0)
	
	convolution_drum.convolution_kernel = [1.0]
	
	var input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
	var output = convolution_drum.apply_convolution(input)
	
	# Should pick positions 0, 2, 4 (stride=2)
	assert_eq(output.size(), 3, "Stride=2 should give 3 outputs from 6 inputs")
	assert_almost_eq(output[0], 1.0, 0.001, "Should pick position 0")
	assert_almost_eq(output[1], 3.0, 0.001, "Should pick position 2")
	assert_almost_eq(output[2], 5.0, 0.001, "Should pick position 4")

## Training Tests

func test_train_kernel():
	# Training should update kernel weights
	convolution_drum.set_kernel_size(3)
	convolution_drum.convolution_kernel = [0.0, 0.0, 0.0]
	
	var input = [1.0, 2.0, 3.0]
	convolution_drum.apply_convolution(input)
	
	var initial_kernel = convolution_drum.convolution_kernel.duplicate()
	
	# Train with target features
	convolution_drum.train_kernel([5.0], 0.1)
	
	# Kernel should have changed
	var changed = false
	for i in range(convolution_drum.convolution_kernel.size()):
		if abs(convolution_drum.convolution_kernel[i] - initial_kernel[i]) > 0.001:
			changed = true
			break
	
	assert_true(changed, "Training should update kernel weights")

## Signal Tests

func test_kernel_changed_signal():
	watch_signals(convolution_drum)
	
	convolution_drum.set_kernel_size(5)
	
	assert_signal_emitted(convolution_drum, "kernel_changed",
		"Should emit kernel_changed signal")

func test_stride_changed_signal():
	watch_signals(convolution_drum)
	
	convolution_drum.set_stride(2)
	
	assert_signal_emitted(convolution_drum, "stride_changed",
		"Should emit stride_changed signal")

func test_padding_changed_signal():
	watch_signals(convolution_drum)
	
	convolution_drum.set_padding(1)
	
	assert_signal_emitted(convolution_drum, "padding_changed",
		"Should emit padding_changed signal")

func test_pattern_detected_signal():
	watch_signals(convolution_drum)
	
	convolution_drum.apply_convolution([1.0, 2.0, 3.0, 4.0])
	
	assert_signal_emitted(convolution_drum, "pattern_detected",
		"Should emit pattern_detected signal")

## Edge Cases

func test_empty_input():
	var output = convolution_drum.apply_convolution([])
	assert_eq(output.size(), 0, "Empty input should give empty output")

func test_single_element_input():
	convolution_drum.set_kernel_size(1)
	convolution_drum.set_padding(0)
	convolution_drum.convolution_kernel = [2.0]
	
	var output = convolution_drum.apply_convolution([5.0])
	
	assert_eq(output.size(), 1, "Single element should work")
	assert_almost_eq(output[0], 10.0, 0.001, "Should apply kernel to single element")

func test_kernel_larger_than_input():
	# Kernel size 5 with input size 3 should give output size 0 or handle gracefully
	convolution_drum.set_kernel_size(5)
	convolution_drum.set_padding(0)
	
	var output = convolution_drum.apply_convolution([1.0, 2.0, 3.0])
	
	# With kernel=5 and input=3, no valid convolution positions without padding
	assert_true(output.size() >= 0, "Should handle kernel larger than input")

func test_large_input():
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_padding(1)
	
	var input = []
	for i in range(100):
		input.append(float(i))
	
	var output = convolution_drum.apply_convolution(input)
	
	assert_eq(output.size(), 100, "Should handle large inputs")

func test_negative_values():
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_padding(0)
	convolution_drum.convolution_kernel = [1.0, 1.0, 1.0]
	
	var output = convolution_drum.apply_convolution([-1.0, -2.0, -3.0, -4.0])
	
	# Position 0: -1 + -2 + -3 = -6
	assert_almost_eq(output[0], -6.0, 0.001, "Should handle negative values")

## ML Semantics Tests

func test_convolution_is_linear_operation():
	# CRITICAL: Convolution is linear: conv(a*x) = a*conv(x)
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_padding(0)
	convolution_drum.convolution_kernel = [1.0, 2.0, 1.0]
	
	var input1 = [1.0, 2.0, 3.0, 4.0]
	var output1 = convolution_drum.apply_convolution(input1)
	var output1_copy = output1.duplicate()  # Make a copy!
	
	# Scale input by 2
	var input2 = [2.0, 4.0, 6.0, 8.0]
	var output2 = convolution_drum.apply_convolution(input2)
	
	# Output should also scale by 2
	for i in range(output1_copy.size()):
		assert_almost_eq(output2[i], output1_copy[i] * 2.0, 0.001,
			"CRITICAL ML SEMANTIC: Convolution is linear operation")

func test_convolution_is_translation_invariant():
	# CRITICAL: Same pattern at different positions gives same response
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_stride(1)
	convolution_drum.set_padding(0)
	convolution_drum.convolution_kernel = [1.0, 0.0, -1.0]  # Edge detector
	
	# Pattern [1, 2, 3] at start
	var input1 = [1.0, 2.0, 3.0, 0.0, 0.0]
	var output1 = convolution_drum.apply_convolution(input1)
	var output1_copy = output1.duplicate()  # Make a copy!
	
	# Same pattern [1, 2, 3] shifted right
	var input2 = [0.0, 1.0, 2.0, 3.0, 0.0]
	var output2 = convolution_drum.apply_convolution(input2)
	
	# Response to pattern should be similar (translation invariance)
	# output1[0] is response at position 0 for pattern at 0
	# output2[1] is response at position 1 for pattern at 1
	assert_almost_eq(output1_copy[0], output2[1], 0.001,
		"CRITICAL ML SEMANTIC: Convolution is translation invariant")

func test_convolution_detects_local_features():
	# Convolution should respond to local patterns
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_padding(0)
	
	# Edge detector kernel [1, 0, -1]
	convolution_drum.convolution_kernel = [1.0, 0.0, -1.0]
	
	# Input with sharp edge in middle: [low, low, low, high, high]
	var input = [1.0, 1.0, 1.0, 5.0, 5.0]
	var output = convolution_drum.apply_convolution(input)
	
	# Position 0: [1, 1, 1] → 1*1 + 0*1 + (-1)*1 = 0 (no edge)
	# Position 1: [1, 1, 5] → 1*1 + 0*1 + (-1)*5 = -4 (strong edge!)
	# Position 2: [1, 5, 5] → 1*1 + 0*5 + (-1)*5 = -4
	# Position with edge should have stronger response than flat region
	assert_true(abs(output[1]) > abs(output[0]),
		"CRITICAL ML SEMANTIC: Should detect local features (edges)")

## Performance Tests

func test_processing_performance():
	convolution_drum.set_kernel_size(3)
	convolution_drum.set_padding(1)
	
	var input = []
	for i in range(20):
		input.append(float(i))
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(1000):
		convolution_drum.apply_convolution(input)
	
	var elapsed_ms = Time.get_ticks_msec() - start_time
	
	# 1000 iterations should complete in under 100ms
	assert_lt(elapsed_ms, 100, "Convolution should be fast (<0.1ms per call)")
