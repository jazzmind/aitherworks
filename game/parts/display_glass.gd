extends Node
class_name DisplayGlass

##
# Display Glass - The Eye of Your Contraption
#
# A brass-framed looking glass that displays the final output of your machine.
# Shows numerical readouts, patterns, or status messages in an elegant 
# steampunk display. Essential for monitoring what your contraption produces.
#
# In AI terms: This is your output visualization layer - shows predictions,
# classifications, or generated data in a human-readable format.

@export var display_mode: String = "numeric" : set = set_display_mode
@export var precision: int = 3 : set = set_precision
@export var show_history: bool = true : set = set_show_history
@export var history_length: int = 10 : set = set_history_length

# Signals for UI updates
signal display_updated(value: String)
signal mode_changed(new_mode: String)
signal value_received(value: float)

# Display state
var current_value: float = 0.0
var value_history: Array[float] = []
var display_text: String = ""

# Available display modes
var available_modes: Array[String] = [
	"numeric",
	"gauge",
	"waveform", 
	"binary",
	"classification"
]

func set_display_mode(value: String) -> void:
	if value in available_modes:
		display_mode = value
		emit_signal("mode_changed", display_mode)
		_update_display()

func set_precision(value: int) -> void:
	precision = clamp(value, 0, 6)
	_update_display()

func set_show_history(value: bool) -> void:
	show_history = value
	_update_display()

func set_history_length(value: int) -> void:
	history_length = max(1, min(value, 50))
	# Trim history if needed
	while value_history.size() > history_length:
		value_history.pop_front()
	_update_display()

func display_value(value: float) -> void:
	"""Display a new value on the glass"""
	current_value = value
	emit_signal("value_received", value)
	
	# Add to history
	value_history.append(value)
	if value_history.size() > history_length:
		value_history.pop_front()
	
	_update_display()

func display_array(values: Array[float]) -> void:
	"""Display multiple values (for multi-output networks)"""
	# For now, display the first value or average
	if values.size() > 0:
		var avg: float = 0.0
		for v in values:
			avg += v
		avg /= values.size()
		display_value(avg)

func _update_display() -> void:
	"""Update the display text based on mode and current value"""
	match display_mode:
		"numeric":
			display_text = _format_numeric()
		"gauge":
			display_text = _format_gauge()
		"waveform":
			display_text = _format_waveform()
		"binary":
			display_text = _format_binary()
		"classification":
			display_text = _format_classification()
	
	emit_signal("display_updated", display_text)

func _format_numeric() -> String:
	"""Format as a simple numeric display"""
	var text = "Output: %.*f" % [precision, current_value]
	
	if show_history and value_history.size() > 1:
		text += "\nHistory: "
		var recent = value_history.slice(-5) # Last 5 values
		for i in range(recent.size()):
			text += "%.*f " % [precision, recent[i]]
	
	return text

func _format_gauge() -> String:
	"""Format as a pressure gauge visualization"""
	var normalized = clampf((current_value + 1.0) / 2.0, 0.0, 1.0)
	var bars = int(normalized * 10)
	var gauge = "["
	for i in range(10):
		gauge += "█" if i < bars else "░"
	gauge += "] %.*f PSI" % [precision, current_value]
	return gauge

func _format_waveform() -> String:
	"""Format as a simple ASCII waveform"""
	if value_history.size() < 2:
		return "Waiting for data..."
	
	var text = "Signal Waveform:\n"
	var height = 5
	var width = min(value_history.size(), 20)
	
	# Simple ASCII plot
	for y in range(height):
		var line = ""
		for x in range(width):
			var idx = value_history.size() - width + x
			var val = value_history[idx]
			var normalized = (val + 1.0) / 2.0 # Normalize to 0-1
			var level = int(normalized * height)
			line += "█" if (height - y - 1) == level else "·"
		text += line + "\n"
	
	return text

func _format_binary() -> String:
	"""Format as binary (on/off) indicator"""
	if current_value > 0:
		return "⚡ ACTIVE ⚡\nSignal: HIGH"
	else:
		return "◯ INACTIVE ◯\nSignal: LOW"

func _format_classification() -> String:
	"""Format as classification result"""
	var classes = ["Aether", "Steam", "Copper", "Iron", "Brass"]
	var idx = clampi(int(current_value * classes.size()), 0, classes.size() - 1)
	return "Classification:\n→ %s\nConfidence: %.1f%%" % [classes[idx], abs(current_value) * 100]

func get_glass_status() -> String:
	"""Get descriptive status of the display glass"""
	match display_mode:
		"numeric":
			return "Displaying numerical readout"
		"gauge":
			return "Showing pressure gauge visualization"
		"waveform":
			return "Plotting signal waveform"
		"binary":
			return "Binary state indicator active"
		"classification":
			return "Classification display mode"
		_:
			return "Display glass active"

func clear_display() -> void:
	"""Clear the display and history"""
	current_value = 0.0
	value_history.clear()
	_update_display()

func _ready() -> void:
	print("Display Glass initialized in ", display_mode, " mode")
	_update_display()

