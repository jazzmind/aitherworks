extends Node
class_name EntropyManometer

## Entropy Manometer
#
# Measures uncertainty and information content in signal flows.
# Acts as both an output device and a diagnostic tool for learning machines.
# Calculates loss functions, entropy measures, and optimization metrics.
# Essential for training and evaluating machine performance.

enum MeasurementType {
	MEAN_SQUARED_ERROR,
	CROSS_ENTROPY,
	BINARY_CROSSENTROPY,
	INFORMATION_GAIN,
	VARIANCE
}

@export var measurement_type: MeasurementType = MeasurementType.MEAN_SQUARED_ERROR : set = set_measurement_type
@export var target_values: Array = [] : set = set_target_values
@export var smoothing_factor: float = 0.1 : set = set_smoothing_factor

signal measurement_changed(new_type: MeasurementType)
signal targets_changed(new_targets: Array)
signal smoothing_changed(new_smoothing: float)
signal entropy_measured(loss_value: float, entropy_value: float)

var current_predictions: Array = []
var current_loss: float = 0.0
var current_entropy: float = 0.0
var smoothed_loss: float = 0.0

func set_measurement_type(value: MeasurementType) -> void:
	measurement_type = value
	emit_signal("measurement_changed", measurement_type)
	_recalculate_metrics()

func set_target_values(values: Array) -> void:
	target_values = values.duplicate()
	emit_signal("targets_changed", target_values)
	_recalculate_metrics()

func set_smoothing_factor(value: float) -> void:
	smoothing_factor = clampf(value, 0.01, 1.0)
	emit_signal("smoothing_changed", smoothing_factor)

func measure_entropy(predictions: Array) -> Dictionary:
	"""Calculate loss and entropy from predictions vs targets"""
	current_predictions = predictions.duplicate()
	
	if target_values.size() == 0 or predictions.size() == 0:
		return {"loss": 0.0, "entropy": 0.0}
	
	var loss: float = 0.0
	var entropy: float = 0.0
	
	match measurement_type:
		MeasurementType.MEAN_SQUARED_ERROR:
			loss = _calculate_mse(predictions, target_values)
			entropy = _calculate_variance(predictions)
		MeasurementType.CROSS_ENTROPY:
			loss = _calculate_cross_entropy(predictions, target_values)
			entropy = _calculate_information_content(predictions)
		MeasurementType.BINARY_CROSSENTROPY:
			loss = _calculate_binary_cross_entropy(predictions, target_values)
			entropy = _calculate_binary_entropy(predictions)
		MeasurementType.INFORMATION_GAIN:
			loss = _calculate_information_gain(predictions, target_values)
			entropy = _calculate_entropy(predictions)
		MeasurementType.VARIANCE:
			loss = _calculate_variance(predictions)
			entropy = _calculate_entropy(predictions)
	
	current_loss = loss
	current_entropy = entropy
	
	# Apply smoothing
	if smoothed_loss == 0.0:
		smoothed_loss = loss
	else:
		smoothed_loss = smoothed_loss * (1.0 - smoothing_factor) + loss * smoothing_factor
	
	emit_signal("entropy_measured", current_loss, current_entropy)
	
	return {
		"loss": current_loss,
		"entropy": current_entropy,
		"smoothed_loss": smoothed_loss
	}

func _calculate_mse(predictions: Array, targets: Array) -> float:
	"""Calculate Mean Squared Error"""
	var total: float = 0.0
	var count: int = min(predictions.size(), targets.size())
	
	for i in range(count):
		var diff: float = float(predictions[i]) - float(targets[i])
		total += diff * diff
	
	return total / max(1, count)

func _calculate_cross_entropy(predictions: Array, targets: Array) -> float:
	"""Calculate Cross Entropy Loss"""
	var total: float = 0.0
	var count: int = min(predictions.size(), targets.size())
	
	for i in range(count):
		var pred: float = clampf(float(predictions[i]), 1e-7, 1.0 - 1e-7)
		var target: float = float(targets[i])
		total -= target * log(pred) + (1.0 - target) * log(1.0 - pred)
	
	return total / max(1, count)

func _calculate_binary_cross_entropy(predictions: Array, targets: Array) -> float:
	"""Calculate Binary Cross Entropy"""
	return _calculate_cross_entropy(predictions, targets)

func _calculate_information_gain(predictions: Array, targets: Array) -> float:
	"""Calculate Information Gain"""
	var pred_entropy: float = _calculate_entropy(predictions)
	var target_entropy: float = _calculate_entropy(targets)
	return target_entropy - pred_entropy

func _calculate_variance(values: Array) -> float:
	"""Calculate variance of values"""
	if values.size() == 0:
		return 0.0
	
	var mean: float = 0.0
	for val in values:
		mean += float(val)
	mean /= values.size()
	
	var variance: float = 0.0
	for val in values:
		var diff: float = float(val) - mean
		variance += diff * diff
	
	return variance / values.size()

func _calculate_entropy(values: Array) -> float:
	"""Calculate Shannon entropy"""
	if values.size() == 0:
		return 0.0
	
	var entropy: float = 0.0
	for val in values:
		var p: float = clampf(float(val), 1e-7, 1.0 - 1e-7)
		entropy -= p * log(p) / log(2.0)
	
	return entropy

func _calculate_information_content(values: Array) -> float:
	"""Calculate average information content"""
	return _calculate_entropy(values)

func _calculate_binary_entropy(values: Array) -> float:
	"""Calculate binary entropy"""
	return _calculate_entropy(values)

func _recalculate_metrics() -> void:
	"""Recalculate metrics when parameters change"""
	if current_predictions.size() > 0:
		measure_entropy(current_predictions)

func get_measurement_name() -> String:
	"""Get human-readable name of current measurement"""
	match measurement_type:
		MeasurementType.MEAN_SQUARED_ERROR:
			return "Mean Squared Error"
		MeasurementType.CROSS_ENTROPY:
			return "Cross Entropy"
		MeasurementType.BINARY_CROSSENTROPY:
			return "Binary Cross Entropy"
		MeasurementType.INFORMATION_GAIN:
			return "Information Gain"
		MeasurementType.VARIANCE:
			return "Variance"
		_:
			return "Unknown Measurement"

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Entropy Manometer",
		"measurement": get_measurement_name(),
		"current_loss": current_loss,
		"current_entropy": current_entropy,
		"smoothed_loss": smoothed_loss,
		"targets_set": target_values.size() > 0
	}

func _ready() -> void:
	# Initialize entropy manometer
	pass
