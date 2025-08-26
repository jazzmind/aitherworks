extends Node
class_name Evaluator

##
# Evaluator - The Judge of Your Contraption
#
# A brass inspection device with red and green indicator lights that compares
# your machine's output with expected results. Essential for training and
# testing your contraption's accuracy. The heart glows green when outputs
# match expectations, red when they diverge.
#
# In AI terms: This is your loss/accuracy calculator that measures how well
# your model is performing against ground truth labels or target values.

@export var tolerance: float = 0.1 : set = set_tolerance
@export var evaluation_mode: String = "absolute" : set = set_evaluation_mode
@export var expected_value: float = 0.0 : set = set_expected_value
@export var show_metrics: bool = true : set = set_show_metrics

# Signals for UI updates
signal evaluation_complete(passed: bool, error: float)
signal tolerance_changed(new_tolerance: float)
signal mode_changed(new_mode: String)
signal light_status_changed(is_green: bool)

# Evaluation state
var current_output: float = 0.0
var current_error: float = 0.0
var is_passing: bool = false
var evaluation_history: Array[Dictionary] = []
var total_evaluations: int = 0
var passed_evaluations: int = 0

# Available evaluation modes
var available_modes: Array[String] = [
	"absolute",     # Direct value comparison
	"relative",     # Percentage-based comparison
	"classification", # Binary classification
	"threshold",    # Above/below threshold
	"pattern"       # Pattern matching
]

func set_tolerance(value: float) -> void:
	tolerance = clampf(value, 0.001, 1.0)
	emit_signal("tolerance_changed", tolerance)
	_reevaluate()

func set_evaluation_mode(value: String) -> void:
	if value in available_modes:
		evaluation_mode = value
		emit_signal("mode_changed", evaluation_mode)
		_reevaluate()

func set_expected_value(value: float) -> void:
	expected_value = value
	_reevaluate()

func set_show_metrics(value: bool) -> void:
	show_metrics = value

func evaluate_output(output: float, expected: float = NAN) -> bool:
	"""Evaluate an output value against expected result"""
	current_output = output
	
	# Use provided expected value or stored one
	var target = expected if not is_nan(expected) else expected_value
	
	# Calculate error based on evaluation mode
	match evaluation_mode:
		"absolute":
			current_error = abs(output - target)
			is_passing = current_error <= tolerance
		
		"relative":
			if abs(target) > 0.001:
				current_error = abs((output - target) / target)
				is_passing = current_error <= tolerance
			else:
				current_error = abs(output)
				is_passing = current_error <= tolerance
		
		"classification":
			# Binary classification: both should have same sign
			is_passing = (output > 0) == (target > 0)
			current_error = 0.0 if is_passing else 1.0
		
		"threshold":
			# Output should be above threshold (expected_value)
			is_passing = output >= target
			current_error = max(0.0, target - output)
		
		"pattern":
			# For pattern matching, check if signs match and magnitudes are similar
			var same_sign = (output > 0) == (target > 0)
			var magnitude_ratio = min(abs(output), abs(target)) / max(abs(output), abs(target), 0.001)
			is_passing = same_sign and magnitude_ratio > (1.0 - tolerance)
			current_error = 1.0 - magnitude_ratio if same_sign else 2.0
	
	# Update statistics
	total_evaluations += 1
	if is_passing:
		passed_evaluations += 1
	
	# Add to history
	var result = {
		"output": output,
		"expected": target,
		"error": current_error,
		"passed": is_passing,
		"timestamp": Time.get_ticks_msec()
	}
	evaluation_history.append(result)
	
	# Keep history reasonable size
	if evaluation_history.size() > 100:
		evaluation_history.pop_front()
	
	# Emit signals
	emit_signal("evaluation_complete", is_passing, current_error)
	emit_signal("light_status_changed", is_passing)
	
	return is_passing

func evaluate_batch(outputs: Array[float], expected_values: Array[float]) -> Dictionary:
	"""Evaluate a batch of outputs against expected values"""
	var batch_results = {
		"total": outputs.size(),
		"passed": 0,
		"failed": 0,
		"average_error": 0.0,
		"accuracy": 0.0
	}
	
	var min_size = min(outputs.size(), expected_values.size())
	var total_error = 0.0
	
	for i in range(min_size):
		var passed = evaluate_output(outputs[i], expected_values[i])
		if passed:
			batch_results["passed"] += 1
		else:
			batch_results["failed"] += 1
		total_error += current_error
	
	batch_results["average_error"] = total_error / max(min_size, 1)
	batch_results["accuracy"] = float(batch_results["passed"]) / max(min_size, 1)
	
	return batch_results

func _reevaluate() -> void:
	"""Re-evaluate current output with new settings"""
	if not is_nan(current_output):
		evaluate_output(current_output)

func get_accuracy() -> float:
	"""Get overall accuracy percentage"""
	if total_evaluations == 0:
		return 0.0
	return float(passed_evaluations) / float(total_evaluations) * 100.0

func get_status_text() -> String:
	"""Get descriptive status for UI"""
	if is_passing:
		return "✓ PASS - Output within tolerance"
	else:
		match evaluation_mode:
			"absolute":
				return "✗ FAIL - Error: %.3f (tolerance: %.3f)" % [current_error, tolerance]
			"relative":
				return "✗ FAIL - Error: %.1f%% (tolerance: %.1f%%)" % [current_error * 100, tolerance * 100]
			"classification":
				return "✗ FAIL - Misclassified"
			"threshold":
				return "✗ FAIL - Below threshold by %.3f" % current_error
			"pattern":
				return "✗ FAIL - Pattern mismatch"
			_:
				return "✗ FAIL"

func get_light_color() -> Color:
	"""Get current indicator light color"""
	if is_passing:
		return Color(0.2, 0.9, 0.2) # Green
	else:
		return Color(0.9, 0.2, 0.2) # Red

func get_metrics_text() -> String:
	"""Get detailed metrics for display"""
	if not show_metrics:
		return ""
	
	var text = "=== Evaluation Metrics ===\n"
	text += "Mode: %s\n" % evaluation_mode
	text += "Tolerance: %.3f\n" % tolerance
	text += "Expected: %.3f\n" % expected_value
	text += "Current: %.3f\n" % current_output
	text += "Error: %.3f\n" % current_error
	text += "\n"
	text += "Total Tests: %d\n" % total_evaluations
	text += "Passed: %d\n" % passed_evaluations  
	text += "Accuracy: %.1f%%\n" % get_accuracy()
	
	return text

func reset_statistics() -> void:
	"""Reset evaluation statistics"""
	total_evaluations = 0
	passed_evaluations = 0
	evaluation_history.clear()
	current_error = 0.0
	is_passing = false

func _ready() -> void:
	print("Evaluator initialized in ", evaluation_mode, " mode")
	print("Tolerance: ", tolerance)