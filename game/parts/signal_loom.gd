extends Node
class_name SignalLoom

## Signal Loom
#
# The "eyes" of a learning machine - processes input data streams.
# Converts raw information into structured signals that can be processed
# by downstream components like Weight Wheels and Manifolds.
# Equivalent to input layers in neural networks.

@export var input_channels: int = 1 : set = set_input_channels
@export var output_width: int = 10 : set = set_output_width
@export var signal_strength: float = 1.0 : set = set_signal_strength

signal channels_changed(new_channels: int)
signal width_changed(new_width: int)
signal strength_changed(new_strength: float)
signal data_processed(output_signals: Array)

var current_input: Array = []
var current_output: Array = []

func set_input_channels(value: int) -> void:
	input_channels = max(1, value)
	emit_signal("channels_changed", input_channels)
	_update_processing()

func set_output_width(value: int) -> void:
	output_width = max(1, value)
	emit_signal("width_changed", output_width)
	_update_processing()

func set_signal_strength(value: float) -> void:
	signal_strength = clampf(value, 0.0, 2.0)
	emit_signal("strength_changed", signal_strength)

func process_input(input_data: Array) -> Array:
	"""Process raw input data through the signal loom"""
	current_input = input_data
	var output: Array = []
	
	# Simulate signal loom processing - converts input to structured signals
	for i in range(output_width):
		var signal_value: float = 0.0
		if i < input_data.size():
			signal_value = float(input_data[i]) * signal_strength
		output.append(signal_value)
	
	current_output = output
	emit_signal("data_processed", current_output)
	return current_output

func _update_processing() -> void:
	"""Update internal processing when parameters change"""
	if current_input.size() > 0:
		process_input(current_input)

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Signal Loom",
		"input_channels": input_channels,
		"output_width": output_width,
		"signal_strength": signal_strength,
		"processing": current_input.size() > 0
	}

func _ready() -> void:
	# Initialize signal loom
	pass
