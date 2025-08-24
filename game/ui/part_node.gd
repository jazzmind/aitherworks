extends GraphNode

## PartNode
# GraphNode wrapper that exposes input/output ports from a part definition.

class_name PartNode

var part_id: String = ""
var input_names: Array[String] = []
var output_names: Array[String] = []
var part_instance: Node = null  # The actual functional part

# Signal processing
var input_values: Array[float] = []
var output_value: float = 0.0

func setup_from_spec(id: String, spec: Dictionary) -> void:
	part_id = id
	title = spec.get("name", id)
	tooltip_text = String(spec.get("description", ""))
	_setup_visual_appearance(id)
	_build_ports(spec.get("ports", {}))
	_create_part_instance(id)

func _build_ports(ports: Dictionary) -> void:
	input_names.clear()
	output_names.clear()
	
	print("DEBUG: Building ports for ", part_id, " with ports: ", ports)
	
	# Treat any entry with value 'input' as left ports and 'output' as right ports
	for k in ports.keys():
		var v := String(ports[k])
		print("DEBUG: Port ", k, " = ", v)
		if v == "input":
			input_names.append(k)
		elif v == "output":
			output_names.append(k)
	
	print("DEBUG: Input ports: ", input_names)
	print("DEBUG: Output ports: ", output_names)
	
	var max_slots := int(max(input_names.size(), output_names.size()))
	for i in range(max_slots):
		var left_en := i < input_names.size()
		var right_en := i < output_names.size()
		set_slot(i, left_en, 0, Color(0.6, 0.9, 1.0), right_en, 0, Color(0.9, 0.8, 0.3), null, null)
		print("DEBUG: Created slot ", i, " - left: ", left_en, " right: ", right_en)
	
	# Add simple labels inside node to suggest port order
	_refresh_labels()

func _setup_visual_appearance(id: String) -> void:
	# Create a TextureRect to show the component's SVG icon
	var part_icon := TextureRect.new()
	part_icon.custom_minimum_size = Vector2(64, 64)
	part_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	part_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Load the appropriate icon
	var icon_path := "res://assets/icons/"
	match id:
		"signal_loom":
			icon_path += "steam_pipe.svg"
		"weight_wheel":
			icon_path += "weight_dial.svg"
		"adder_manifold":
			icon_path += "manifold.svg"
		"activation_gate":
			icon_path += "gear.svg"
		"entropy_manometer":
			icon_path += "pressure_gauge.svg"
		_:
			icon_path += "gear.svg"  # Default icon
	
	if FileAccess.file_exists(icon_path):
		var texture := load(icon_path) as Texture2D
		if texture:
			part_icon.texture = texture
	
	add_child(part_icon)

func _refresh_labels() -> void:
	for c in get_children():
		if c is Label:
			remove_child(c)
			c.queue_free()
	var y := 80  # Start below the icon
	if input_names.size() > 0:
		var li := Label.new()
		li.text = "IN: " + ", ".join(input_names)
		li.position = Vector2(8, y)
		li.add_theme_font_size_override("font_size", 10)
		add_child(li)
		y += 18
	if output_names.size() > 0:
		var lo := Label.new()
		lo.text = "OUT: " + ", ".join(output_names)
		lo.position = Vector2(8, y)
		lo.add_theme_font_size_override("font_size", 10)
		add_child(lo)

func _create_part_instance(id: String) -> void:
	"""Create the actual functional part based on the ID"""
	match id:
		"steam_source":
			part_instance = SteamSource.new()
		"signal_loom":
			part_instance = SignalLoom.new()
		"weight_wheel":
			part_instance = WeightWheel.new()
		"spyglass":
			part_instance = Spyglass.new()
		"adder_manifold":
			# TODO: Implement AdderManifold class
			pass
		"activation_gate":
			# TODO: Implement ActivationGate class  
			pass
		"entropy_manometer":
			# TODO: Implement EntropyManometer class
			pass
		_:
			print("Unknown part type: ", id)
			return
	
	if part_instance:
		add_child(part_instance)
		part_instance.name = id + "_instance"
		print("Created part instance: ", id)

func process_inputs(inputs: Array[float]) -> float:
	"""Process input signals through this part and return output"""
	input_values = inputs.duplicate()
	
	if not part_instance:
		print("No part instance to process with!")
		return 0.0
	
	match part_id:
		"steam_source":
			if part_instance is SteamSource:
				var source = part_instance as SteamSource
				var generated = source.generate_steam_pressure()
				# Sum all generated channels for single output
				output_value = 0.0
				for val in generated:
					output_value += val
		"signal_loom":
			if part_instance is SignalLoom:
				var loom = part_instance as SignalLoom
				var processed = loom.process_input(inputs)
				# For now, sum all outputs (could be more sophisticated)
				output_value = 0.0
				for val in processed:
					output_value += val
		"weight_wheel":
			if part_instance is WeightWheel:
				var wheel = part_instance as WeightWheel
				output_value = wheel.process_signals(inputs)
		"spyglass":
			if part_instance is Spyglass:
				# Spyglass is passive - just passes through input
				output_value = 0.0
				for val in inputs:
					output_value += val
		_:
			# Default: just sum inputs
			output_value = 0.0
			for val in inputs:
				output_value += val
	
	return output_value

func get_part_status() -> String:
	"""Get current status of the part for debugging"""
	if not part_instance:
		return "No functional part"
	
	match part_id:
		"steam_source":
			if part_instance is SteamSource:
				var source = part_instance as SteamSource
				return source.get_source_status()
		"weight_wheel":
			if part_instance is WeightWheel:
				var wheel = part_instance as WeightWheel
				return wheel.get_wheel_status()
		"signal_loom":
			if part_instance is SignalLoom:
				var loom = part_instance as SignalLoom
				var status = loom.get_status()
				return "Processing %d channels" % status.input_channels
		"spyglass":
			if part_instance is Spyglass:
				var spyglass = part_instance as Spyglass
				return spyglass.get_spyglass_status()
		_:
			return "Active"
	
	return "Unknown status"
