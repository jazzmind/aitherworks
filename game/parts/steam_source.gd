extends Node
class_name SteamSource

##
# Steam Source - The Heart of Your Contraption
#
# A brass boiler that generates steam pressure readings. This is where your 
# machine gets its input data - like a steam engine's firebox providing 
# power to the entire system.
#
# In AI terms: This represents the input data source - training examples,
# sensor readings, or any data that needs to be processed by the neural network.

@export var data_pattern: String = "sine_wave" : set = set_data_pattern
@export var amplitude: float = 1.0 : set = set_amplitude
@export var frequency: float = 1.0 : set = set_frequency
@export var noise_level: float = 0.1 : set = set_noise_level
@export var num_channels: int = 3 : set = set_num_channels

# Signals for UI updates
signal pattern_changed(new_pattern: String)
signal amplitude_changed(new_amplitude: float)
signal data_generated(output_data: Array[float])

# Current output
var current_output: Array[float] = []
var time_step: float = 0.0

# Available data patterns
var available_patterns: Array[String] = [
	"sine_wave",
	"random_walk", 
	"step_function",
	"training_data",
	"sensor_readings"
]

func set_data_pattern(value: String) -> void:
	if value in available_patterns:
		data_pattern = value
		emit_signal("pattern_changed", data_pattern)
		_regenerate_data()

func set_amplitude(value: float) -> void:
	amplitude = clampf(value, 0.1, 5.0)
	emit_signal("amplitude_changed", amplitude)
	_regenerate_data()

func set_frequency(value: float) -> void:
	frequency = clampf(value, 0.1, 3.0)
	_regenerate_data()

func set_noise_level(value: float) -> void:
	noise_level = clampf(value, 0.0, 1.0)
	_regenerate_data()

func set_num_channels(value: int) -> void:
	num_channels = max(1, min(value, 8))
	_regenerate_data()

func generate_steam_pressure() -> Array[float]:
	"""Generate steam pressure readings based on current settings"""
	var output: Array[float] = []
	time_step += 0.1
	
	match data_pattern:
		"sine_wave":
			for i in range(num_channels):
				var phase_offset = i * PI / 4  # Different phase for each channel
				var base_value = amplitude * sin(frequency * time_step + phase_offset)
				var noise = randf_range(-noise_level, noise_level)
				output.append(base_value + noise)
		
		"random_walk":
			for i in range(num_channels):
				var last_value = current_output[i] if i < current_output.size() else 0.0
				var change = randf_range(-0.2, 0.2) * amplitude
				var new_value = clampf(last_value + change, -amplitude, amplitude)
				output.append(new_value + randf_range(-noise_level, noise_level))
		
		"step_function":
			for i in range(num_channels):
				var step_value = amplitude if sin(frequency * time_step + i) > 0 else -amplitude
				output.append(step_value + randf_range(-noise_level, noise_level))
		
		"training_data":
			# Generate simple training pattern: [x, y] where y = 0.5 * x + noise
			for i in range(num_channels):
				if i == 0:
					# Input feature
					output.append(randf_range(-amplitude, amplitude))
				else:
					# Target output (for the first input)
					var target = 0.5 * output[0] + randf_range(-noise_level, noise_level)
					output.append(target)
		
		"sensor_readings":
			# Simulate realistic sensor data with different ranges
			for i in range(num_channels):
				match i % 3:
					0: # Temperature sensor
						output.append(amplitude * randf_range(0.2, 0.8) + randf_range(-noise_level, noise_level))
					1: # Pressure sensor  
						output.append(amplitude * randf_range(-0.5, 1.0) + randf_range(-noise_level, noise_level))
					2: # Flow sensor
						output.append(amplitude * abs(sin(frequency * time_step)) + randf_range(-noise_level, noise_level))
	
	current_output = output
	emit_signal("data_generated", current_output)
	return current_output

func _regenerate_data() -> void:
	"""Regenerate data when settings change"""
	if current_output.size() != num_channels:
		current_output.resize(num_channels)
		for i in range(num_channels):
			current_output[i] = 0.0

func get_source_status() -> String:
	"""Get descriptive status of the steam source"""
	match data_pattern:
		"sine_wave":
			return "Generating rhythmic steam pulses (sine wave)"
		"random_walk": 
			return "Steam pressure fluctuating randomly"
		"step_function":
			return "Steam valve opening/closing in steps"
		"training_data":
			return "Providing training examples for learning"
		"sensor_readings":
			return "Reading steam gauges around the city"
		_:
			return "Steam boiler active"

func get_channel_description(index: int) -> String:
	"""Get description of what each channel represents"""
	if index >= num_channels:
		return "Inactive steam line"
	
	match data_pattern:
		"training_data":
			if index == 0:
				return "Input signal (steam pressure)"
			else:
				return "Target output (expected result)"
		"sensor_readings":
			match index % 3:
				0: return "Temperature gauge (°C)"
				1: return "Pressure gauge (PSI)" 
				2: return "Flow meter (L/min)"
		_:
			return "Steam line %d" % (index + 1)
	
	return "Steam channel %d" % (index + 1)

func _ready() -> void:
	print("Steam Source initialized: ", data_pattern)
	_regenerate_data()
