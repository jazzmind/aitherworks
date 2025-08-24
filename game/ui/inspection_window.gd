extends Window
class_name InspectionWindow

##
# Inspection Window - The Spyglass View
#
# A brass-framed viewing window that displays real-time data from components
# being inspected by the Spyglass. Shows graphs, numbers, and status updates
# in a steampunk-styled interface.

@onready var title_label: Label = $VBox/TitleBar/TitleLabel
@onready var close_btn: Button = $VBox/TitleBar/CloseButton
@onready var content_area: ScrollContainer = $VBox/ContentArea
@onready var data_display: VBoxContainer = $VBox/ContentArea/DataDisplay

var connected_spyglass: Spyglass = null
var current_component_type: String = ""
var data_labels: Dictionary = {}
var update_timer: Timer = null

signal window_closed()

func _ready() -> void:
	# Set up the window
	title = "🔍 Component Inspector"
	size = Vector2i(400, 500)
	
	# Set up UI
	title_label.text = "🔍 Awaiting Inspection..."
	close_btn.pressed.connect(_on_close_pressed)
	
	# Create update timer
	update_timer = Timer.new()
	update_timer.wait_time = 0.1  # 10 FPS updates
	update_timer.timeout.connect(_update_display)
	add_child(update_timer)
	
	# Window events
	close_requested.connect(_on_close_pressed)

func connect_to_spyglass(spyglass: Spyglass) -> void:
	"""Connect this window to a spyglass for data updates"""
	if connected_spyglass:
		# Disconnect previous spyglass
		if connected_spyglass.inspection_data_ready.is_connected(_on_inspection_data_received):
			connected_spyglass.inspection_data_ready.disconnect(_on_inspection_data_received)
	
	connected_spyglass = spyglass
	
	if connected_spyglass:
		connected_spyglass.inspection_data_ready.connect(_on_inspection_data_received)
		update_timer.start()
		print("🔍 Inspection window connected to spyglass")

func _on_inspection_data_received(data: Dictionary) -> void:
	"""Handle new inspection data from the spyglass"""
	var component_type = data.get("type", "Unknown")
	
	# Update title
	title_label.text = "🔍 Inspecting: %s" % component_type
	
	# Clear previous display if component type changed
	if current_component_type != component_type:
		_clear_display()
		current_component_type = component_type
	
	# Update display based on component type
	match component_type:
		"Weight Wheel":
			_display_weight_wheel_data(data)
		"Signal Loom":
			_display_signal_loom_data(data)
		"Steam Source":
			_display_steam_source_data(data)
		_:
			_display_generic_data(data)

func _display_weight_wheel_data(data: Dictionary) -> void:
	"""Display Weight Wheel inspection data"""
	_ensure_label_exists("status", "🎡 Wheel Status:")
	_update_label("status", data.get("status", "Unknown"))
	
	_ensure_label_exists("output", "⚡ Output Signal:")
	_update_label("output", "%.3f" % data.get("output_signal", 0.0))
	
	# Display weights for each spoke
	var weights = data.get("current_weights", [])
	var spoke_descriptions = data.get("spoke_descriptions", [])
	
	for i in range(weights.size()):
		var weight_key = "weight_%d" % i
		var desc_key = "desc_%d" % i
		
		_ensure_label_exists(weight_key, "⚖️ Spoke %d Weight:" % (i + 1))
		_update_label(weight_key, "%.3f" % weights[i])
		
		if i < spoke_descriptions.size():
			_ensure_label_exists(desc_key, "  └─")
			_update_label(desc_key, spoke_descriptions[i])
	
	# Show gradients if available
	var gradients = data.get("gradients", [])
	if gradients.size() > 0:
		_ensure_label_exists("gradients_header", "📈 Learning Gradients:")
		_update_label("gradients_header", "")
		
		for i in range(gradients.size()):
			var grad_key = "gradient_%d" % i
			_ensure_label_exists(grad_key, "  Spoke %d:" % (i + 1))
			_update_label(grad_key, "%.4f" % gradients[i])

func _display_signal_loom_data(data: Dictionary) -> void:
	"""Display Signal Loom inspection data"""
	_ensure_label_exists("channels", "📡 Input Channels:")
	_update_label("channels", str(data.get("input_channels", 0)))
	
	_ensure_label_exists("strength", "💪 Signal Strength:")
	_update_label("strength", "%.2f" % data.get("signal_strength", 1.0))
	
	# Show current input/output
	var current_input = data.get("current_input", [])
	var current_output = data.get("current_output", [])
	
	if current_input.size() > 0:
		_ensure_label_exists("input_header", "🔴 Input Signals:")
		_update_label("input_header", "")
		
		for i in range(min(current_input.size(), 6)):  # Limit display
			var input_key = "input_%d" % i
			_ensure_label_exists(input_key, "  Channel %d:" % (i + 1))
			_update_label(input_key, "%.3f" % current_input[i])
	
	if current_output.size() > 0:
		_ensure_label_exists("output_header", "🟢 Output Signals:")
		_update_label("output_header", "")
		
		for i in range(min(current_output.size(), 6)):  # Limit display
			var output_key = "output_%d" % i
			_ensure_label_exists(output_key, "  Lane %d:" % (i + 1))
			_update_label(output_key, "%.3f" % current_output[i])

func _display_steam_source_data(data: Dictionary) -> void:
	"""Display Steam Source inspection data"""
	_ensure_label_exists("pattern", "🔥 Steam Pattern:")
	_update_label("pattern", data.get("pattern", "unknown"))
	
	_ensure_label_exists("status", "📊 Status:")
	_update_label("status", data.get("status", "Unknown"))
	
	_ensure_label_exists("amplitude", "📈 Amplitude:")
	_update_label("amplitude", "%.2f" % data.get("amplitude", 1.0))
	
	_ensure_label_exists("frequency", "🌊 Frequency:")
	_update_label("frequency", "%.2f Hz" % data.get("frequency", 1.0))
	
	# Show current output channels
	var current_output = data.get("current_output", [])
	var channel_descriptions = data.get("channel_descriptions", [])
	
	if current_output.size() > 0:
		_ensure_label_exists("output_header", "💨 Steam Pressure:")
		_update_label("output_header", "")
		
		for i in range(current_output.size()):
			var channel_key = "channel_%d" % i
			var desc = channel_descriptions[i] if i < channel_descriptions.size() else "Channel %d" % (i + 1)
			
			_ensure_label_exists(channel_key, "  %s:" % desc)
			_update_label(channel_key, "%.3f PSI" % current_output[i])

func _display_generic_data(data: Dictionary) -> void:
	"""Display generic component data"""
	for key in data.keys():
		var value = data[key]
		_ensure_label_exists(key, "%s:" % key.capitalize())
		_update_label(key, str(value))

func _ensure_label_exists(key: String, label_text: String) -> void:
	"""Ensure a label exists for the given key"""
	if not data_labels.has(key):
		var container = HBoxContainer.new()
		var label = Label.new()
		var value_label = Label.new()
		
		label.text = label_text
		label.custom_minimum_size.x = 120
		value_label.text = "..."
		
		# Style the labels
		label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.7))
		value_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8))
		
		container.add_child(label)
		container.add_child(value_label)
		data_display.add_child(container)
		
		data_labels[key] = {
			"container": container,
			"label": label,
			"value": value_label
		}

func _update_label(key: String, value_text: String) -> void:
	"""Update the value of a label"""
	if data_labels.has(key):
		data_labels[key]["value"].text = value_text

func _clear_display() -> void:
	"""Clear all current display elements"""
	for child in data_display.get_children():
		child.queue_free()
	data_labels.clear()

func _update_display() -> void:
	"""Regular display update (for animations, etc.)"""
	# Could add smooth animations, graphs, etc. here
	pass

func _on_close_pressed() -> void:
	"""Handle window close"""
	if update_timer:
		update_timer.stop()
	
	if connected_spyglass and connected_spyglass.inspection_data_ready.is_connected(_on_inspection_data_received):
		connected_spyglass.inspection_data_ready.disconnect(_on_inspection_data_received)
	
	emit_signal("window_closed")
	hide()

func show_inspection_window() -> void:
	"""Show the inspection window"""
	show()
	move_to_center()

func _on_window_close_requested() -> void:
	_on_close_pressed()
