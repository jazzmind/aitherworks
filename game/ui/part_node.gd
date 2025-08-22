extends GraphNode

## PartNode
# GraphNode wrapper that exposes input/output ports from a part definition.

class_name PartNode

var part_id: String = ""
var input_names: Array[String] = []
var output_names: Array[String] = []

func setup_from_spec(id: String, spec: Dictionary) -> void:
	part_id = id
	title = spec.get("name", id)
	tooltip_text = String(spec.get("description", ""))
	_setup_visual_appearance(id)
	_build_ports(spec.get("ports", {}))

func _build_ports(ports: Dictionary) -> void:
	input_names.clear()
	output_names.clear()
	# Treat any entry with value 'input' as left ports and 'output' as right ports
	for k in ports.keys():
		var v := String(ports[k])
		if v == "input":
			input_names.append(k)
		elif v == "output":
			output_names.append(k)
	var max_slots := int(max(input_names.size(), output_names.size()))
	for i in range(max_slots):
		var left_en := i < input_names.size()
		var right_en := i < output_names.size()
		set_slot(i, left_en, 0, Color(0.6, 0.9, 1.0), right_en, 0, Color(0.9, 0.8, 0.3), null, null)
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
