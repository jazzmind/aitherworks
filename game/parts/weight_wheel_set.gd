extends Node
class_name WeightWheelSet

##
# WeightWheelSet - The Complete Learning Layer
#
# An array of Weight Wheels arranged in a lattice. Each wheel (neuron) in the set
# processes the entire input vector and produces one output value. Together, they
# form a complete linear layer (fully connected layer).
# 
# Single Weight Wheel: vector → scalar (one neuron)
# Weight Wheel Set:    vector → vector (multiple neurons in parallel)
#
# In AI terms: This implements a learnable weight matrix (W) where output = input @ W
# During training, all wheels adjust simultaneously via gradient descent.

@export var input_size: int = 3 : set = set_input_size
@export var output_size: int = 3 : set = set_output_size
@export var learning_rate: float = 0.1

# Weight matrix: [input_size][output_size]
# Each column represents one neuron's weights
var weight_matrix: Array[Array] = []

# Signals for UI updates
signal weights_changed(new_weights: Array)
signal layer_configured(in_size: int, out_size: int)

# Input/output connections
var input_vector: Array[float] = []
var output_vector: Array[float] = []

# For gradient descent learning
var gradients: Array[Array] = []  # Same shape as weight_matrix

func set_input_size(size: int) -> void:
	input_size = max(1, size)
	_initialize_weights()
	emit_signal("layer_configured", input_size, output_size)

func set_output_size(size: int) -> void:
	output_size = max(1, size)
	_initialize_weights()
	emit_signal("layer_configured", input_size, output_size)

func _initialize_weights() -> void:
	"""Initialize weight matrix with Xavier/Glorot initialization"""
	weight_matrix.clear()
	gradients.clear()
	
	# Xavier initialization: scale = sqrt(2 / (fan_in + fan_out))
	var scale = sqrt(2.0 / (input_size + output_size))
	
	for i in range(input_size):
		var row: Array = []
		var grad_row: Array = []
		for j in range(output_size):
			# Initialize with small random values
			row.append(randf_range(-scale, scale))
			grad_row.append(0.0)
		weight_matrix.append(row)
		gradients.append(grad_row)
	
	emit_signal("weights_changed", weight_matrix)

func get_weight(input_idx: int, output_idx: int) -> float:
	"""Get weight for connection from input_idx to output_idx"""
	if input_idx >= 0 and input_idx < input_size and output_idx >= 0 and output_idx < output_size:
		return weight_matrix[input_idx][output_idx]
	return 0.0

func set_weight(input_idx: int, output_idx: int, value: float) -> void:
	"""Set weight for connection from input_idx to output_idx"""
	if input_idx >= 0 and input_idx < input_size and output_idx >= 0 and output_idx < output_size:
		weight_matrix[input_idx][output_idx] = value
		emit_signal("weights_changed", weight_matrix)

# Process incoming signals through the weight matrix
func process_signals(inputs: Array[float]) -> Array[float]:
	"""
	Perform matrix multiplication: output = input @ weights
	
	Mathematical operation:
	For each output neuron j:
	    output[j] = sum(input[i] * weight[i][j] for all i)
	
	This is equivalent to having output_size Weight Wheels running in parallel,
	each computing a dot product with the input.
	"""
	input_vector = inputs.duplicate()
	output_vector.clear()
	
	# Each output neuron computes a weighted sum of all inputs
	for j in range(output_size):
		var sum: float = 0.0
		var min_size = min(inputs.size(), input_size)
		
		# This is one "wheel" (neuron) - computes dot product
		for i in range(min_size):
			sum += inputs[i] * weight_matrix[i][j]
		
		output_vector.append(sum)
	
	return output_vector

# Learn from experience - adjust weights based on error
func apply_gradients(error_gradients: Array[float]) -> void:
	"""
	Apply gradient descent to all weights in the matrix
	
	error_gradients: gradient for each output neuron
	Formula: dL/dW[i,j] = input[i] * dL/dOutput[j]
	Update: W[i,j] -= learning_rate * dL/dW[i,j]
	"""
	if error_gradients.size() != output_size:
		push_warning("WeightWheelSet: error_gradients size mismatch")
		return
	
	# Calculate gradients for each weight
	for i in range(min(input_vector.size(), input_size)):
		for j in range(output_size):
			# Gradient = input * error_gradient (chain rule)
			gradients[i][j] = input_vector[i] * error_gradients[j]
			
			# Update weight using gradient descent
			weight_matrix[i][j] -= learning_rate * gradients[i][j]
	
	emit_signal("weights_changed", weight_matrix)

# Reset all wheels to default position
func reset_weights() -> void:
	"""Reset to Xavier initialization"""
	_initialize_weights()

func get_total_parameters() -> int:
	"""Return total number of learnable parameters"""
	return input_size * output_size

func _ready() -> void:
	# Initialize with default configuration
	if weight_matrix.is_empty():
		_initialize_weights()
	
	print("Weight Wheel Set initialized: %dx%d (%d parameters)" % [input_size, output_size, get_total_parameters()])

# Steampunk flavor text for UI
func get_wheel_status(output_idx: int) -> String:
	"""Get status for one wheel (neuron) in the set"""
	if output_idx >= output_size:
		return "Empty wheel position"
	
	# Calculate average weight magnitude for this neuron
	var avg_weight = 0.0
	for i in range(input_size):
		avg_weight += abs(weight_matrix[i][output_idx])
	avg_weight /= input_size
	
	if avg_weight > 1.5:
		return "Heavy wheel - strong feature detector"
	elif avg_weight > 0.5:
		return "Balanced wheel - moderate response"
	elif avg_weight > 0.1:
		return "Light wheel - subtle features"
	else:
		return "Minimal wheel - nearly dormant"

func get_set_status() -> String:
	"""Get overall status of the wheel set"""
	var active_wheels = 0
	for j in range(output_size):
		var has_signal = false
		for i in range(input_size):
			if abs(weight_matrix[i][j]) > 0.1:
				has_signal = true
				break
		if has_signal:
			active_wheels += 1
	
	return "%d of %d wheels active (%d total connections)" % [active_wheels, output_size, get_total_parameters()]

