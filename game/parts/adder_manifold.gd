extends Node
class_name AdderManifold

## Adder Manifold
#
# Combines multiple steam pressure signals into one unified output.
# Acts as a summation node, merging signals from different sources.
# Essential for creating network architectures where multiple paths converge.
# Equivalent to addition/concatenation layers in neural networks.

@export var input_ports: int = 2 : set = set_input_ports
@export var bias: float = 0.0 : set = set_bias
@export var scaling_factor: float = 1.0 : set = set_scaling_factor

signal ports_changed(new_ports: int)
signal bias_changed(new_bias: float)
signal scaling_changed(new_scaling: float)
signal signals_combined(output_value: float)

var input_signals: Array = []
var current_output: float = 0.0

func set_input_ports(value: int) -> void:
	input_ports = max(1, value)
	emit_signal("ports_changed", input_ports)
	_resize_inputs()

func set_bias(value: float) -> void:
	bias = value
	emit_signal("bias_changed", bias)
	_recalculate_output()

func set_scaling_factor(value: float) -> void:
	scaling_factor = clampf(value, 0.1, 5.0)
	emit_signal("scaling_changed", scaling_factor)
	_recalculate_output()

func _resize_inputs() -> void:
	"""Resize input array to match number of ports"""
	input_signals.resize(input_ports)
	for i in range(input_ports):
		if input_signals[i] == null:
			input_signals[i] = 0.0

func connect_input(port: int, value: float) -> void:
	"""Connect a signal to a specific input port"""
	if port >= 0 and port < input_ports:
		input_signals[port] = value
		_recalculate_output()

func process_signals(inputs: Array[float] = []) -> float:
	"""Combine all input signals into a single output"""
	# If inputs provided, use them; otherwise use internal state
	if not inputs.is_empty():
		input_signals = []
		for val in inputs:
			input_signals.append(val)
	
	var sum: float = 0.0
	for signal_value in input_signals:
		if signal_value != null:
			sum += float(signal_value)
	
	current_output = (sum + bias) * scaling_factor
	emit_signal("signals_combined", current_output)
	return current_output

func _recalculate_output() -> void:
	"""Recalculate output when parameters change"""
	process_signals()

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Adder Manifold",
		"input_ports": input_ports,
		"bias": bias,
		"scaling_factor": scaling_factor,
		"current_output": current_output,
		"connected_inputs": input_signals.size()
	}

func _ready() -> void:
	_resize_inputs()
