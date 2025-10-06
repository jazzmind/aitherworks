extends Node
class_name WeightWheel

##
# WeightWheel - The Learning Brain of Your Contraption
#
# A brass wheel with adjustable counterweights along its spokes. Each spoke
# represents a different input channel. By sliding the brass weights along 
# the spokes, you control how much each input signal affects the output.
# 
# In AI terms: This implements a learnable weight matrix that scales input
# vectors. During training, the weights automatically adjust via gradient descent.

@export var num_weights: int = 3 : set = set_num_weights
@export var weights: Array[float] = [1.0, 1.0, 1.0] : set = set_weights
@export var learning_rate: float = 0.1

# Signals for UI updates
signal weights_changed(new_weights: Array[float])
signal weight_adjusted(index: int, new_value: float)

# Input/output connections
var input_signals: Array[float] = []
var output_signal: float = 0.0

# For gradient descent learning
var gradients: Array[float] = []

func set_num_weights(count: int) -> void:
	num_weights = max(1, count)
	# Resize weights array
	weights.resize(num_weights)
	gradients.resize(num_weights)
	# Initialize new weights to 1.0
	for i in range(weights.size()):
		if weights[i] == 0.0:  # Uninitialized
			weights[i] = 1.0
	emit_signal("weights_changed", weights)

func set_weights(new_weights: Array[float]) -> void:
	weights = new_weights.duplicate()
	num_weights = weights.size()
	gradients.resize(num_weights)
	emit_signal("weights_changed", weights)

func set_weight(index: int, value: float) -> void:
	if index >= 0 and index < weights.size():
		weights[index] = value
		emit_signal("weight_adjusted", index, value)
		emit_signal("weights_changed", weights)

func get_weight(index: int) -> float:
	if index >= 0 and index < weights.size():
		return weights[index]
	return 0.0

# Process incoming steam pressure through the weight wheel
func process_signals(inputs: Array[float]) -> float:
	input_signals = inputs.duplicate()
	output_signal = 0.0
	
	# Each spoke of the wheel scales its corresponding input
	var min_size = min(inputs.size(), weights.size())
	for i in range(min_size):
		output_signal += inputs[i] * weights[i]
	
	return output_signal

# Learn from experience - adjust weights based on error
func apply_gradients(error_gradient: float) -> void:
	# Ensure gradients array is sized correctly
	if gradients.size() != weights.size():
		gradients.resize(weights.size())
		for i in range(gradients.size()):
			gradients[i] = 0.0
	
	# Calculate gradients for each weight
	for i in range(min(input_signals.size(), weights.size())):
		# Gradient = input * error_gradient (chain rule)
		gradients[i] = input_signals[i] * error_gradient
		
		# Update weight using gradient descent
		# New weight = old weight - learning_rate * gradient
		weights[i] -= learning_rate * gradients[i]
	
	emit_signal("weights_changed", weights)

# Reset the wheel to default position (all weights = 1.0)
func reset_weights() -> void:
	for i in range(weights.size()):
		weights[i] = 1.0
	emit_signal("weights_changed", weights)

func _ready() -> void:
	# Initialize with default configuration
	if weights.is_empty():
		set_num_weights(3)  # Default to 3 spokes
	
	print("Weight Wheel initialized with ", num_weights, " spokes")
	print("Initial weights: ", weights)

# Steampunk flavor text for UI
func get_spoke_description(index: int) -> String:
	if index >= weights.size():
		return "Empty spoke"
	
	var weight_val = weights[index]
	if weight_val > 1.5:
		return "Heavy brass counterweight (amplifies signal)"
	elif weight_val > 0.5:
		return "Balanced brass weight (normal signal)"
	elif weight_val > 0.0:
		return "Light copper weight (dampens signal)"
	else:
		return "No weight (blocks signal)"

func get_wheel_status() -> String:
	var total_weight = 0.0
	for w in weights:
		total_weight += abs(w)
	
	if total_weight > weights.size() * 1.5:
		return "Heavy wheel - amplifying signals strongly"
	elif total_weight < weights.size() * 0.5:
		return "Light wheel - dampening most signals"
	else:
		return "Balanced wheel - processing signals normally"
