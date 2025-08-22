extends Node
class_name ConvolutionDrum

## Convolution Drum
#
# A rotating cylinder with pattern-detecting grooves that slides over input data.
# Detects local features and patterns in multi-dimensional signals.
# Essential for image processing and pattern recognition in learning machines.
# Equivalent to convolutional layers in neural networks.

@export var kernel_size: int = 3 : set = set_kernel_size
@export var stride: int = 1 : set = set_stride
@export var padding: int = 0 : set = set_padding
@export var rotation_speed: float = 1.0 : set = set_rotation_speed

signal kernel_changed(new_size: int)
signal stride_changed(new_stride: int)
signal padding_changed(new_padding: int)
signal speed_changed(new_speed: float)
signal pattern_detected(features: Array)

var convolution_kernel: Array = []
var input_data: Array = []
var output_features: Array = []
var rotation_angle: float = 0.0

func set_kernel_size(value: int) -> void:
	kernel_size = clamp(value, 1, 7)
	emit_signal("kernel_changed", kernel_size)
	_initialize_kernel()

func set_stride(value: int) -> void:
	stride = max(1, value)
	emit_signal("stride_changed", stride)

func set_padding(value: int) -> void:
	padding = max(0, value)
	emit_signal("padding_changed", padding)

func set_rotation_speed(value: float) -> void:
	rotation_speed = clampf(value, 0.1, 5.0)
	emit_signal("speed_changed", rotation_speed)

func _initialize_kernel() -> void:
	"""Initialize convolution kernel with random weights"""
	convolution_kernel.clear()
	for i in range(kernel_size * kernel_size):
		convolution_kernel.append(randf_range(-0.5, 0.5))

func apply_convolution(input_matrix: Array) -> Array:
	"""Apply convolution operation to input data"""
	input_data = input_matrix.duplicate()
	output_features.clear()
	
	if input_data.size() == 0:
		return output_features
	
	# Simulate 2D convolution for 1D input (treat as image row)
	var input_size: int = input_data.size()
	var padded_input: Array = _apply_padding(input_data)
	
	# Slide the convolution drum across the input
	var output_size: int = int((input_size + 2 * padding - kernel_size) / stride) + 1
	
	for i in range(output_size):
		var pos: int = i * stride
		var feature_value: float = 0.0
		
		# Apply kernel at current position
		for k in range(kernel_size):
			if pos + k < padded_input.size():
				feature_value += float(padded_input[pos + k]) * convolution_kernel[k]
		
		output_features.append(feature_value)
	
	# Update rotation for visual effect
	rotation_angle += rotation_speed * 10.0
	if rotation_angle >= 360.0:
		rotation_angle -= 360.0
	
	emit_signal("pattern_detected", output_features)
	return output_features

func _apply_padding(input: Array) -> Array:
	"""Apply zero padding to input data"""
	var padded: Array = []
	
	# Add left padding
	for i in range(padding):
		padded.append(0.0)
	
	# Add original data
	for value in input:
		padded.append(value)
	
	# Add right padding
	for i in range(padding):
		padded.append(0.0)
	
	return padded

func train_kernel(target_features: Array, learning_rate: float = 0.01) -> void:
	"""Update kernel weights based on target features"""
	if output_features.size() != target_features.size():
		return
	
	# Simple gradient descent update for kernel weights
	for i in range(min(convolution_kernel.size(), target_features.size())):
		var error: float = float(target_features[i]) - (output_features[i] if i < output_features.size() else 0.0)
		convolution_kernel[i] += learning_rate * error

func get_kernel_pattern() -> String:
	"""Get visual representation of current kernel"""
	var pattern: String = ""
	for i in range(kernel_size):
		for j in range(kernel_size):
			var idx: int = i * kernel_size + j
			if idx < convolution_kernel.size():
				var weight: float = convolution_kernel[idx]
				if weight > 0.3:
					pattern += "●"
				elif weight > 0.0:
					pattern += "○"
				elif weight > -0.3:
					pattern += "·"
				else:
					pattern += "×"
			else:
				pattern += " "
		if i < kernel_size - 1:
			pattern += "\n"
	return pattern

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Convolution Drum",
		"kernel_size": kernel_size,
		"stride": stride,
		"padding": padding,
		"rotation_speed": rotation_speed,
		"rotation_angle": rotation_angle,
		"features_detected": output_features.size(),
		"kernel_pattern": get_kernel_pattern()
	}

func _ready() -> void:
	_initialize_kernel()
