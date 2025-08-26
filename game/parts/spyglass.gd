extends Node
class_name Spyglass

##
# Spyglass - The Inspector's Eye
#
# A brass telescope that lets you peer into any component to see what's 
# happening inside. Point it at a Weight Wheel to see the weights adjusting,
# or at a Signal Loom to watch data flowing through.
#
# In AI terms: This is a debugging/visualization tool that shows internal
# states, activations, and data transformations in real-time.

@export var inspection_target: String = "" : set = set_inspection_target
@export var update_frequency: float = 0.5 : set = set_update_frequency
@export var show_gradients: bool = false : set = set_show_gradients

# Signals for UI updates
signal target_changed(new_target: String)
signal inspection_data_ready(data: Dictionary)
signal focus_changed(is_focused: bool)

# Current inspection data
var current_data: Dictionary = {}
var connected_component: Node = null
var inspection_timer: Timer = null

func set_inspection_target(value: String) -> void:
	inspection_target = value
	emit_signal("target_changed", inspection_target)
	_connect_to_target()

func set_update_frequency(value: float) -> void:
	update_frequency = clampf(value, 0.1, 2.0)
	if inspection_timer:
		inspection_timer.wait_time = update_frequency

func set_show_gradients(value: bool) -> void:
	show_gradients = value
	_update_inspection()

func start_inspection() -> void:
	"""Begin inspecting the target component"""
	if not inspection_timer:
		inspection_timer = Timer.new()
		inspection_timer.wait_time = update_frequency
		inspection_timer.timeout.connect(_update_inspection)
		add_child(inspection_timer)
	
	inspection_timer.start()
	emit_signal("focus_changed", true)
	print("🔍 Spyglass focused on: ", inspection_target)

func stop_inspection() -> void:
	"""Stop inspecting"""
	if inspection_timer:
		inspection_timer.stop()
	emit_signal("focus_changed", false)
	print("🔍 Spyglass inspection stopped")

func _connect_to_target() -> void:
	"""Connect to the target component for inspection"""
	connected_component = null
	
	# Find the target component in the scene tree
	var root = get_tree().current_scene
	if root:
		connected_component = _find_component_by_name(root, inspection_target)
	
	if connected_component:
		print("🔍 Spyglass connected to: ", connected_component.name)
	else:
		print("🔍 Spyglass target not found: ", inspection_target)

func _find_component_by_name(node: Node, target_name: String) -> Node:
	"""Recursively find a component by name"""
	if node.name == target_name:
		return node
	
	for child in node.get_children():
		var result = _find_component_by_name(child, target_name)
		if result:
			return result
	
	return null

func _update_inspection() -> void:
	"""Update inspection data from the connected component"""
	if not connected_component:
		return
	
	var inspection_data = {}
	
	# Inspect based on component type
	if connected_component.has_method("get_class"):
		var component_class = connected_component.get_class()
		inspection_data["component_type"] = component_class
	
	# Check for PartNode wrapper
	var part_instance = null
	if connected_component.has_method("has_property"):
		if connected_component.has_property("part_instance"):
			part_instance = connected_component.part_instance
	else:
		part_instance = connected_component
	
	if part_instance is WeightWheel:
		inspection_data = _inspect_weight_wheel(part_instance)
	elif part_instance is SignalLoom:
		inspection_data = _inspect_signal_loom(part_instance)
	elif part_instance is SteamSource:
		inspection_data = _inspect_steam_source(part_instance)
	else:
		inspection_data = _inspect_generic_component(connected_component)
	
	current_data = inspection_data
	emit_signal("inspection_data_ready", current_data)

func _inspect_weight_wheel(wheel: WeightWheel) -> Dictionary:
	"""Inspect a Weight Wheel's internal state"""
	return {
		"type": "Weight Wheel",
		"num_spokes": wheel.num_weights,
		"current_weights": wheel.weights.duplicate(),
		"gradients": wheel.gradients.duplicate() if show_gradients else [],
		"input_signals": wheel.input_signals.duplicate(),
		"output_signal": wheel.output_signal,
		"learning_rate": wheel.learning_rate,
		"status": wheel.get_wheel_status(),
		"spoke_descriptions": _get_spoke_descriptions(wheel)
	}

func _inspect_signal_loom(loom: SignalLoom) -> Dictionary:
	"""Inspect a Signal Loom's processing"""
	var status = loom.get_status()
	return {
		"type": "Signal Loom",
		"input_channels": status.input_channels,
		"output_width": status.output_width,
		"signal_strength": status.signal_strength,
		"current_input": loom.current_input.duplicate(),
		"current_output": loom.current_output.duplicate(),
		"processing": status.processing
	}

func _inspect_steam_source(source: SteamSource) -> Dictionary:
	"""Inspect a Steam Source's generation"""
	return {
		"type": "Steam Source",
		"pattern": source.data_pattern,
		"amplitude": source.amplitude,
		"frequency": source.frequency,
		"noise_level": source.noise_level,
		"num_channels": source.num_channels,
		"current_output": source.current_output.duplicate(),
		"status": source.get_source_status(),
		"channel_descriptions": _get_channel_descriptions(source)
	}

func _inspect_generic_component(component: Node) -> Dictionary:
	"""Generic inspection for unknown components"""
	var data = {
		"type": "Unknown Component",
		"name": component.name,
		"class": component.get_class()
	}
	if component.has_method("has_property"):
		# Try to get some common properties
		if component.has_property("input_values"):
			data["input_values"] = component.input_values
		if component.has_property("output_value"):
			data["output_value"] = component.output_value
	
	return data

func _get_spoke_descriptions(wheel: WeightWheel) -> Array[String]:
	"""Get descriptions for each spoke of the weight wheel"""
	var descriptions: Array[String] = []
	for i in range(wheel.num_weights):
		descriptions.append(wheel.get_spoke_description(i))
	return descriptions

func _get_channel_descriptions(source: SteamSource) -> Array[String]:
	"""Get descriptions for each channel of the steam source"""
	var descriptions: Array[String] = []
	for i in range(source.num_channels):
		descriptions.append(source.get_channel_description(i))
	return descriptions

func get_spyglass_status() -> String:
	"""Get current status of the spyglass"""
	if inspection_target.is_empty():
		return "Spyglass ready - select a component to inspect"
	elif connected_component:
		return "Inspecting: %s" % inspection_target
	else:
		return "Target not found: %s" % inspection_target

func _ready() -> void:
	print("🔍 Spyglass ready for inspection")
