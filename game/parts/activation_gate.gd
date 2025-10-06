extends Node
class_name ActivationGate

## Activation Gate
#
# Transforms steam pressure using mathematical functions.
# Controls the flow of signals through the machine using various
# activation functions like ReLU, Sigmoid, or Tanh.
# Essential for introducing non-linearity into learning machines.

enum ActivationType {
	RELU,
	SIGMOID,
	TANH,
	LINEAR,
	STEP
}

@export var activation_type: ActivationType = ActivationType.RELU : set = set_activation_type
@export var threshold: float = 0.0 : set = set_threshold
@export var gain: float = 1.0 : set = set_gain

signal activation_changed(new_type: ActivationType)
signal threshold_changed(new_threshold: float)
signal gain_changed(new_gain: float)
signal signal_transformed(input_value: float, output_value: float)

var current_input: float = 0.0
var current_output: float = 0.0

func set_activation_type(value: ActivationType) -> void:
	activation_type = value
	emit_signal("activation_changed", activation_type)
	_recalculate_output()

func set_activation_function(name: String) -> void:
	"""Set activation function by string name (for backward compatibility)"""
	match name.to_lower():
		"relu":
			activation_type = ActivationType.RELU
		"sigmoid":
			activation_type = ActivationType.SIGMOID
		"tanh":
			activation_type = ActivationType.TANH
		"linear":
			activation_type = ActivationType.LINEAR
		"step":
			activation_type = ActivationType.STEP
		_:
			push_warning("Unknown activation function: %s, defaulting to ReLU" % name)
			activation_type = ActivationType.RELU

func set_threshold(value: float) -> void:
	threshold = value
	emit_signal("threshold_changed", threshold)
	_recalculate_output()

func set_gain(value: float) -> void:
	gain = clampf(value, 0.1, 10.0)
	emit_signal("gain_changed", gain)
	_recalculate_output()

func apply_activation(input_value: float) -> float:
	"""Apply the selected activation function to the input"""
	current_input = input_value
	var processed: float = input_value * gain + threshold
	
	match activation_type:
		ActivationType.RELU:
			current_output = max(0.0, processed)
		ActivationType.SIGMOID:
			current_output = 1.0 / (1.0 + exp(-processed))
		ActivationType.TANH:
			current_output = tanh(processed)
		ActivationType.LINEAR:
			current_output = processed
		ActivationType.STEP:
			current_output = 1.0 if processed > 0.0 else 0.0
		_:
			current_output = processed  # Default to linear
	
	emit_signal("signal_transformed", current_input, current_output)
	return current_output

func _recalculate_output() -> void:
	"""Recalculate output when parameters change"""
	if current_input != 0.0:
		apply_activation(current_input)

func get_activation_name() -> String:
	"""Get human-readable name of current activation function"""
	match activation_type:
		ActivationType.RELU:
			return "ReLU Valve"
		ActivationType.SIGMOID:
			return "Sigmoid Chamber"
		ActivationType.TANH:
			return "Hyperbolic Regulator"
		ActivationType.LINEAR:
			return "Direct Conduit"
		ActivationType.STEP:
			return "Pressure Switch"
		_:
			return "Unknown Gate"

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Activation Gate",
		"activation": get_activation_name(),
		"threshold": threshold,
		"gain": gain,
		"current_input": current_input,
		"current_output": current_output
	}

func _ready() -> void:
	# Initialize activation gate
	pass
