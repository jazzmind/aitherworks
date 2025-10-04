extends GutTest

## Unit Test: Steam Source (Retrofit Validation)
# 
# Purpose: Validate existing SteamSource implementation against YAML spec
# Source of Truth: data/parts/steam_source.yaml
# Expected: MAY FAIL if port types or behavior incorrect

var steam_source: SteamSource
var spec_data: Dictionary

func before_each():
	# Load the YAML spec (source of truth)
	spec_data = SpecLoader.load_yaml("res://data/parts/steam_source.yaml")
	assert_not_null(spec_data, "steam_source.yaml should exist")
	
	# Create instance
	steam_source = SteamSource.new()
	add_child_autofree(steam_source)

func after_each():
	steam_source = null

# ============================================================================
# YAML SPEC VALIDATION
# ============================================================================

func test_yaml_spec_structure():
	assert_has(spec_data, "id", "YAML should have id")
	assert_eq(spec_data["id"], "steam_source", "ID should match filename")
	assert_has(spec_data, "name", "YAML should have name")
	assert_has(spec_data, "ports", "YAML should have ports")
	assert_has(spec_data, "simulation", "YAML should have simulation behavior")

func test_yaml_ports_match_schema():
	var ports = spec_data.get("ports", {})
	assert_gt(ports.size(), 0, "Should have at least one port")
	
	# Check port naming convention (schema requires in_/out_ prefix)
	for port_name in ports.keys():
		var port_config = ports[port_name]
		# Port config can be either a string (old format) or Dictionary (new format)
		var direction: String = ""
		if port_config is Dictionary:
			direction = port_config.get("direction", "")
		elif port_config is String:
			direction = port_config
		
		# Validate direction
		assert_true(
			direction in ["input", "output"],
			"Port '%s' has invalid direction: '%s'" % [port_name, direction]
		)
		
		# Validate naming convention
		if direction == "output":
			assert_true(
				port_name.begins_with("out_"),
				"Output port '%s' should start with out_ prefix" % port_name
			)
		elif direction == "input":
			assert_true(
				port_name.begins_with("in_"),
				"Input port '%s' should start with in_ prefix" % port_name
			)

# ============================================================================
# PORT TYPE VALIDATION (CRITICAL)
# ============================================================================

func test_port_types_match_yaml():
	# YAML spec says: outputs: 3 (vector with 3 channels)
	# Check if implementation actually outputs a vector
	var simulation = spec_data.get("simulation", {})
	var expected_outputs = simulation.get("outputs", 0)
	
	steam_source.num_channels = expected_outputs
	var output = steam_source.generate_steam_pressure()
	
	assert_eq(
		output.size(),
		expected_outputs,
		"Output should have %d channels as specified in YAML" % expected_outputs
	)
	assert_typeof(output, TYPE_ARRAY, "Output should be an Array (vector type)")
	
	# Validate all elements are floats
	for i in range(output.size()):
		assert_typeof(
			output[i],
			TYPE_FLOAT,
			"Channel %d should be float, got %s" % [i, typeof(output[i])]
		)

func test_default_parameters_match_yaml():
	var params = spec_data.get("simulation", {}).get("parameters", {})
	
	# YAML specifies default parameters
	if params.has("pattern"):
		assert_eq(
			steam_source.data_pattern,
			params["pattern"],
			"Default pattern should match YAML spec"
		)
	
	if params.has("amplitude"):
		assert_almost_eq(
			steam_source.amplitude,
			params["amplitude"],
			0.01,
			"Default amplitude should match YAML spec"
		)
	
	if params.has("frequency"):
		assert_almost_eq(
			steam_source.frequency,
			params["frequency"],
			0.01,
			"Default frequency should match YAML spec"
		)
	
	if params.has("noise_level"):
		assert_almost_eq(
			steam_source.noise_level,
			params["noise_level"],
			0.01,
			"Default noise_level should match YAML spec"
		)

# ============================================================================
# DATA PATTERN VALIDATION
# ============================================================================

func test_all_patterns_generate_correct_size():
	var patterns = ["sine_wave", "random_walk", "step_function", "training_data", "sensor_readings"]
	
	for pattern in patterns:
		steam_source.data_pattern = pattern
		steam_source.num_channels = 3
		var output = steam_source.generate_steam_pressure()
		
		assert_eq(
			output.size(),
			3,
			"Pattern '%s' should generate 3 channels" % pattern
		)

func test_sine_wave_pattern():
	steam_source.data_pattern = "sine_wave"
	steam_source.amplitude = 1.0
	steam_source.frequency = 1.0
	steam_source.noise_level = 0.0  # No noise for deterministic test
	steam_source.num_channels = 1
	
	# Full sine cycle = 2π ≈ 6.28 radians
	# With time_step increment of 0.1, need ~63 steps for full cycle
	# Run 70 steps to ensure we see both positive and negative values
	var outputs: Array[Array] = []
	for i in range(70):
		outputs.append(steam_source.generate_steam_pressure())
	
	# Sine wave should oscillate
	var has_positive = false
	var has_negative = false
	for output in outputs:
		if output[0] > 0.1:
			has_positive = true
		if output[0] < -0.1:
			has_negative = true
	
	assert_true(has_positive, "Sine wave should have positive values")
	assert_true(has_negative, "Sine wave should have negative values (need full cycle)")

func test_random_walk_pattern():
	steam_source.data_pattern = "random_walk"
	steam_source.amplitude = 1.0
	steam_source.num_channels = 1
	
	var first_output = steam_source.generate_steam_pressure()
	var second_output = steam_source.generate_steam_pressure()
	
	# Random walk should change but not wildly (bounded by amplitude)
	var change = abs(second_output[0] - first_output[0])
	assert_between(
		change,
		0.0,
		0.5,  # Change should be small (±0.2 * amplitude per step)
		"Random walk step should be small and bounded"
	)

func test_step_function_pattern():
	steam_source.data_pattern = "step_function"
	steam_source.amplitude = 1.0
	steam_source.noise_level = 0.0
	steam_source.num_channels = 1
	
	var outputs: Array[Array] = []
	for i in range(10):
		outputs.append(steam_source.generate_steam_pressure())
	
	# Step function should have values near ±amplitude
	for output in outputs:
		var value = output[0]
		assert_true(
			abs(value - steam_source.amplitude) < 0.2 or abs(value + steam_source.amplitude) < 0.2,
			"Step function should be near ±amplitude, got %f" % value
		)

func test_training_data_pattern():
	steam_source.data_pattern = "training_data"
	steam_source.amplitude = 1.0
	steam_source.noise_level = 0.01  # Small noise
	steam_source.num_channels = 2  # [input, target]
	
	var output = steam_source.generate_steam_pressure()
	
	assert_eq(output.size(), 2, "Training data should have 2 channels (input, target)")
	
	# Target should be approximately 0.5 * input (within noise tolerance)
	var expected_target = 0.5 * output[0]
	assert_almost_eq(
		output[1],
		expected_target,
		0.1,  # Allow for noise_level
		"Target (channel 1) should be ~0.5 * input (channel 0)"
	)

func test_sensor_readings_pattern():
	steam_source.data_pattern = "sensor_readings"
	steam_source.amplitude = 1.0
	steam_source.num_channels = 3  # Temperature, Pressure, Flow
	
	var output = steam_source.generate_steam_pressure()
	
	assert_eq(output.size(), 3, "Sensor readings should have 3 channels")
	# Sensor values should be within amplitude bounds
	for i in range(3):
		assert_between(
			output[i],
			-steam_source.amplitude - steam_source.noise_level,
			steam_source.amplitude + steam_source.noise_level,
			"Sensor channel %d out of bounds" % i
		)

# ============================================================================
# PARAMETER VALIDATION
# ============================================================================

func test_amplitude_parameter():
	steam_source.amplitude = 2.0
	steam_source.data_pattern = "sine_wave"
	steam_source.noise_level = 0.0
	steam_source.num_channels = 1
	
	var max_value = -INF
	for i in range(20):
		var output = steam_source.generate_steam_pressure()
		max_value = max(max_value, abs(output[0]))
	
	# Max value should be close to amplitude
	assert_almost_eq(max_value, 2.0, 0.3, "Amplitude should control signal magnitude")

func test_frequency_parameter():
	steam_source.data_pattern = "sine_wave"
	steam_source.frequency = 2.0  # Higher frequency (2x faster)
	steam_source.amplitude = 1.0
	steam_source.noise_level = 0.0
	steam_source.num_channels = 1
	
	# Higher frequency should cause faster oscillation
	# With frequency=2.0, full cycle = 2π/2 = π ≈ 3.14 radians
	# With time_step increment of 0.1, need ~32 steps for full cycle
	# Count zero-crossings in 40 steps (should see at least 1 complete cycle)
	var last_sign = 0
	var crossings = 0
	for i in range(40):
		var output = steam_source.generate_steam_pressure()
		var current_sign = sign(output[0])
		if current_sign != last_sign and last_sign != 0:
			crossings += 1
		last_sign = current_sign
	
	assert_gt(crossings, 0, "Higher frequency should cause oscillation (need to see negative values)")

func test_noise_level_parameter():
	steam_source.data_pattern = "sine_wave"
	steam_source.noise_level = 0.5  # High noise
	steam_source.amplitude = 1.0
	steam_source.frequency = 0.1  # Slow oscillation
	steam_source.num_channels = 1
	
	var outputs: Array[float] = []
	for i in range(20):
		outputs.append(steam_source.generate_steam_pressure()[0])
	
	# Calculate variance - higher noise should increase variance
	var mean = 0.0
	for val in outputs:
		mean += val
	mean /= outputs.size()
	
	var variance = 0.0
	for val in outputs:
		variance += pow(val - mean, 2)
	variance /= outputs.size()
	
	# Lower threshold - noise adds ±0.5 on slow sine wave
	# Realistic variance for noise_level=0.5 is ~0.05-0.10
	assert_gt(variance, 0.02, "Noise should increase output variance (got %.3f)" % variance)

func test_num_channels_parameter():
	for num in [1, 3, 5, 8]:
		steam_source.num_channels = num
		var output = steam_source.generate_steam_pressure()
		assert_eq(
			output.size(),
			num,
			"num_channels=%d should generate %d outputs" % [num, num]
		)

# ============================================================================
# ML SEMANTICS VALIDATION
# ============================================================================

func test_output_is_vector_type():
	# Per port_schema.yaml, "vector" type is "1D array of floats"
	var output = steam_source.generate_steam_pressure()
	
	assert_typeof(output, TYPE_ARRAY, "Vector should be Array type")
	assert_gt(output.size(), 0, "Vector should not be empty")
	
	# Check it's 1D (not nested arrays)
	for element in output:
		assert_false(
			element is Array,
			"Vector should be 1D (flat), not nested arrays"
		)
		assert_typeof(element, TYPE_FLOAT, "Vector elements should be floats")

func test_deterministic_with_zero_noise():
	steam_source.data_pattern = "step_function"
	steam_source.noise_level = 0.0
	steam_source.amplitude = 1.0
	steam_source.frequency = 1.0
	steam_source.num_channels = 1
	steam_source.time_step = 0.0  # Reset
	
	var first_run: Array[float] = []
	for i in range(5):
		first_run.append(steam_source.generate_steam_pressure()[0])
	
	steam_source.time_step = 0.0  # Reset
	var second_run: Array[float] = []
	for i in range(5):
		second_run.append(steam_source.generate_steam_pressure()[0])
	
	# With zero noise, should be deterministic
	for i in range(5):
		assert_almost_eq(
			first_run[i],
			second_run[i],
			0.001,
			"Output should be deterministic with zero noise (step %d)" % i
		)

# ============================================================================
# EDGE CASES & ERROR HANDLING
# ============================================================================

func test_zero_channels():
	steam_source.num_channels = 0
	var output = steam_source.generate_steam_pressure()
	# Should handle gracefully (empty array or minimum 1 channel)
	assert_typeof(output, TYPE_ARRAY, "Should return array even with 0 channels")

func test_large_channel_count():
	steam_source.num_channels = 8  # Max per set_num_channels
	var output = steam_source.generate_steam_pressure()
	assert_eq(output.size(), 8, "Should handle max channel count (8)")

func test_invalid_pattern():
	# Should not crash, should use default or last valid pattern
	steam_source.data_pattern = "invalid_pattern_xyz"
	var output = steam_source.generate_steam_pressure()
	assert_typeof(output, TYPE_ARRAY, "Should handle invalid pattern gracefully")

func test_extreme_amplitude():
	steam_source.amplitude = 100.0  # Very large
	var output = steam_source.generate_steam_pressure()
	
	# Should clamp or handle reasonably
	for val in output:
		assert_true(
			abs(val) < 200.0,  # Should be bounded
			"Extreme amplitude should be bounded, got %f" % val
		)

# ============================================================================
# SIGNAL EMISSION VALIDATION
# ============================================================================

func test_pattern_changed_signal():
	watch_signals(steam_source)
	steam_source.data_pattern = "random_walk"
	assert_signal_emitted(steam_source, "pattern_changed", "Should emit pattern_changed")

func test_amplitude_changed_signal():
	watch_signals(steam_source)
	steam_source.amplitude = 2.5
	assert_signal_emitted(steam_source, "amplitude_changed", "Should emit amplitude_changed")

func test_data_generated_signal():
	watch_signals(steam_source)
	steam_source.generate_steam_pressure()
	assert_signal_emitted(steam_source, "data_generated", "Should emit data_generated")

# ============================================================================
# PERFORMANCE VALIDATION
# ============================================================================

func test_generation_performance():
	# Manual performance timing (SimulationProfiler has type issues)
	steam_source.num_channels = 8
	
	var start_time = Time.get_ticks_msec()
	for i in range(1000):
		steam_source.generate_steam_pressure()
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Should generate 1000 samples in < 50ms (0.05ms per sample target)
	assert_lt(elapsed, 50, "Should generate 1000 samples quickly (<%dms, got %dms)" % [50, elapsed])

