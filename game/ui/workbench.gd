extends Control

## Workbench UI (Act I scope)

@onready var graph := $MarginContainer/MainLayout/CenterPanel/BlueprintArea/GraphEdit
@onready var input_palette := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/InputDrawer/InputPalette
@onready var processing_palette := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/ProcessingDrawer/ProcessingPalette
@onready var output_palette := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/OutputDrawer/OutputPalette
@onready var inspector := $MarginContainer/MainLayout/RightPanel/Inspector
@onready var console := $MarginContainer/MainLayout/LeftPanel/ConsoleContainer/Console
@onready var story_text := $MarginContainer/MainLayout/LeftPanel/StoryArea/StoryContent/StoryScroll/StoryText
@onready var level_select := $MarginContainer/MainLayout/CenterPanel/TopBar/LevelSelect
@onready var load_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/LoadButton
@onready var train_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/TrainButton
@onready var step_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/StepButton
@onready var reset_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/ResetButton
@onready var lr_slider := $MarginContainer/MainLayout/CenterPanel/TopBar/LRSlider
@onready var relu_toggle := $MarginContainer/MainLayout/CenterPanel/TopBar/ReLUToggle
@onready var zoom_slider := $MarginContainer/MainLayout/CenterPanel/TopBar/ZoomSlider
@onready var replay_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/ReplayTut
@onready var settings_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/Settings
@onready var settings_dialog := $SettingsDialog
@onready var ui_scale_slider := $SettingsDialog/VBox/UIScale
@onready var fullscreen_toggle := $SettingsDialog/VBox/Fullscreen
@onready var run_fwd_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/RunFwd
@onready var run_back_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/RunBack
@onready var weight_slider := $MarginContainer/MainLayout/RightPanel/Inspector/WeightSlider
@onready var weight_label := $MarginContainer/MainLayout/RightPanel/Inspector/WeightLabel
@onready var story_dialog := $StoryDialog
@onready var story_label := $StoryDialog/StoryLabel
# @onready var tutorial := $TutorialLayer
@onready var story_tutorial := $StoryTutorial

# New drawer header references
@onready var input_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/InputDrawer/InputHeader
@onready var processing_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/ProcessingDrawer/ProcessingHeader
@onready var output_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/OutputDrawer/OutputHeader

var engine: Act1Engine
var spec_paths: Array[String] = [
	"res://data/specs/act_I_l1_dawn_in_dock_ward.yaml",
	"res://data/specs/act_I_l2_two_hands_make_a_sum.yaml",
	"res://data/specs/act_I_l3_the_manometer_hisses.yaml",
	"res://data/specs/act_I_l4_room_to_breathe.yaml",
	"res://data/specs/act_I_l5_debt_collectors_demo.yaml",
]
var current_spec: Dictionary = {}
var lane_sliders: Array = []

func _ready() -> void:
	engine = Act1Engine.new()
	add_child(engine)
	_populate_palette()
	# wire controls
	load_btn.pressed.connect(_on_load_pressed)
	train_btn.pressed.connect(on_train_pressed)
	step_btn.pressed.connect(_on_step_pressed)
	reset_btn.pressed.connect(on_reset_pressed)
	lr_slider.value_changed.connect(on_lr_changed)
	relu_toggle.toggled.connect(on_relu_toggled)
	weight_slider.value_changed.connect(_on_weight_changed)
	zoom_slider.value_changed.connect(_on_zoom_changed)
	replay_btn.pressed.connect(_on_replay_tutorial)
	settings_btn.pressed.connect(_on_open_settings)
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	run_fwd_btn.pressed.connect(_on_run_forward)
	run_back_btn.pressed.connect(_on_run_backprop)
	# Connect drawer headers
	input_header.pressed.connect(_on_drawer_toggled.bind(input_palette))
	processing_header.pressed.connect(_on_drawer_toggled.bind(processing_palette))
	output_header.pressed.connect(_on_drawer_toggled.bind(output_palette))
	# levels
	for p in spec_paths:
		level_select.add_item(p.get_file())
	level_select.select(0)
	_log("Workbench ready")
	# Apply default UI scale
	get_window().content_scale_factor = 1.4
	# Set up story tutorial
	story_tutorial.set_workbench(self)
	# kick off tutorial (choose between old and new)
	var use_story_tutorial := true  # Change this to switch tutorial types
	if use_story_tutorial:
		story_tutorial.start_story_tutorial()
	# else:
		# tutorial.show()  # Disabled - using story tutorial instead
	# enable connection requests
	graph.connection_request.connect(_on_graph_connect)
	graph.disconnection_request.connect(_on_graph_disconnect)

func _populate_palette() -> void:
	var input_parts = [
		{
			"id": "signal_loom", 
			"icon": "res://assets/icons/steam_pipe.svg",
			"tooltip": "Signal Loom\n\nProcesses input data - the 'eyes' of your machine.\nConverts raw information into usable steam pressure."
		}
	]
	
	var processing_parts = [
		{
			"id": "weight_wheel", 
			"icon": "res://assets/icons/weight_dial.svg",
			"tooltip": "Weight Wheel\n\nThe 'brain' that learns! Adjusts how much each input matters.\nThis is where the actual learning happens."
		},
		{
			"id": "adder_manifold", 
			"icon": "res://assets/icons/manifold.svg",
			"tooltip": "Adder Manifold\n\nCombines multiple steam pressures into one.\nUseful for merging signals from different sources."
		},
		{
			"id": "activation_gate", 
			"icon": "res://assets/icons/gear.svg",
			"tooltip": "Activation Gate\n\nTransforms steam pressure using mathematical functions.\nCan apply ReLU, sigmoid, or other transformations."
		}
	]
	
	var output_parts = [
		{
			"id": "entropy_manometer", 
			"icon": "res://assets/icons/pressure_gauge.svg",
			"tooltip": "Entropy Manometer\n\nMeasures uncertainty and information content.\nHelps optimize learning efficiency."
		}
	]
	
	_add_parts_to_drawer(input_parts, input_palette)
	_add_parts_to_drawer(processing_parts, processing_palette)
	_add_parts_to_drawer(output_parts, output_palette)
	
	# tutorial step: palette ready
	# tutorial.notify("next")  # Disabled

func _add_parts_to_drawer(parts: Array, drawer: Container) -> void:
	for part in parts:
		var btn := Button.new()
		btn.text = part.id.replace("_", " ").capitalize()
		btn.tooltip_text = part.tooltip
		btn.custom_minimum_size = Vector2(0, 35)
		print("Loading icon for ", part.id, " from ", part.icon)
		if FileAccess.file_exists(part.icon):
			print("Icon file exists, loading...")
			var tex := load(part.icon) as Texture2D
			if tex:
				print("Icon loaded successfully")
				btn.icon = tex
			else:
				print("Failed to load icon as Texture2D")
		else:
			print("Icon file does not exist: ", part.icon)
		btn.pressed.connect(_on_palette_part_pressed.bind(part.id))
		drawer.add_child(btn)

func _on_drawer_toggled(drawer: Container) -> void:
	drawer.visible = !drawer.visible

func _populate_allowed_parts(allowed_ids: Array) -> void:
	# Define all parts with their categories
	var all_parts = {
		"signal_loom": {"category": "input", "icon": "res://assets/icons/steam_pipe.svg", "tooltip": "Signal Loom\n\nProcesses input data - the 'eyes' of your machine.\nConverts raw information into usable steam pressure."},
		"weight_wheel": {"category": "processing", "icon": "res://assets/icons/weight_dial.svg", "tooltip": "Weight Wheel\n\nThe 'brain' that learns! Adjusts how much each input matters.\nThis is where the actual learning happens."},
		"adder_manifold": {"category": "processing", "icon": "res://assets/icons/manifold.svg", "tooltip": "Adder Manifold\n\nCombines multiple steam pressures into one.\nUseful for merging signals from different sources."},
		"activation_gate": {"category": "processing", "icon": "res://assets/icons/gear.svg", "tooltip": "Activation Gate\n\nTransforms steam pressure using mathematical functions.\nCan apply ReLU, sigmoid, or other transformations."},
		"entropy_manometer": {"category": "output", "icon": "res://assets/icons/pressure_gauge.svg", "tooltip": "Entropy Manometer\n\nMeasures uncertainty and information content.\nHelps optimize learning efficiency."}
	}
	
	# Organize allowed parts by category
	var input_parts: Array = []
	var processing_parts: Array = []
	var output_parts: Array = []
	
	for id in allowed_ids:
		if all_parts.has(id):
			var part_data = {"id": id, "icon": all_parts[id].icon, "tooltip": all_parts[id].tooltip}
			match all_parts[id].category:
				"input":
					input_parts.append(part_data)
				"processing":
					processing_parts.append(part_data)
				"output":
					output_parts.append(part_data)
	
	# Add to appropriate drawers
	_add_parts_to_drawer(input_parts, input_palette)
	_add_parts_to_drawer(processing_parts, processing_palette)
	_add_parts_to_drawer(output_parts, output_palette)

func _on_palette_part_pressed(id: String) -> void:
	# create a PartNode with ports from part spec if available
	var spec: Dictionary = {}
	var part_path := "res://data/parts/%s.yaml" % id + ""
	if FileAccess.file_exists(part_path):
		spec = SpecLoader.load_yaml(part_path)
	var scene := load("res://game/ui/part_node.tscn") as PackedScene
	var node := scene.instantiate()
	node.setup_from_spec(id, spec)
	node.position_offset = Vector2(randi()%400, randi()%200)
	graph.add_child(node)
	
	# Notify tutorial of specific part placement
	if id == "signal_loom":
		# tutorial.notify("placed_part")  # Disabled
		story_tutorial.notify_action("place_signal_loom")
	elif id == "weight_wheel":
		# tutorial.notify("placed_weight_wheel")  # Disabled
		story_tutorial.notify_action("place_weight_wheel")
	else:
		# tutorial.notify("placed_part")  # Disabled
		story_tutorial.notify_action("place_part")


func on_train_pressed() -> void:
	var packed: Array = _lanes_and_epochs_from_spec()
	var lanes: int = int(packed[0])
	var epochs: int = int(packed[1])
	engine.set_num_lanes(lanes)
	for e in range(epochs):
		var samples: Array = _make_synthetic_samples(lanes)
		var loss: float = engine.run_epoch(samples)
		_log("epoch %d loss=%.4f" % [e + 1, loss])
	_sync_weight_ui()
	# tutorial.notify("trained")  # Disabled
	story_tutorial.notify_action("start_training")

func on_reset_pressed() -> void:
	engine.set_all_weights(1.0)
	_sync_weight_ui()
	_log("reset weights")

func on_lr_changed(value: float) -> void:
	engine.learning_rate = value
	_log("lr=%.3f" % value)
	# tutorial.notify("lr_changed")  # Disabled
	story_tutorial.notify_action("adjust_learning_rate")

func on_relu_toggled(pressed: bool) -> void:
	engine.use_relu = pressed
	_log("relu=" + str(pressed))
	# tutorial.notify("relu_toggled")  # Disabled

func _on_step_pressed() -> void:
	on_train_pressed()

func _on_weight_changed(value: float) -> void:
	engine.set_all_weights(value)
	_sync_weight_ui()
	_log("weights=%.2f" % value)
	# tutorial.notify("weight_changed")  # Disabled

func _on_load_pressed() -> void:
	print("Load button pressed!")
	var idx: int = level_select.get_selected()
	var path: String = spec_paths[idx]
	print("Loading spec from: ", path)
	current_spec = SpecLoader.load_spec(path)
	if current_spec.is_empty():
		_log("failed to load: %s" % path)
		print("Failed to load spec!")
		return
	_apply_spec_to_ui(current_spec)
	_log("🎯 LEVEL LOADED: " + current_spec.get("name", "Unknown Level"))
	_log("📋 GOAL: " + current_spec.get("description", "No description"))
	_log("💡 Ready to build your contraption!")
	# tutorial.notify("loaded")  # Disabled
	print("Notifying story tutorial of load_level action")
	story_tutorial.notify_action("load_level")

func _apply_spec_to_ui(spec: Dictionary) -> void:
	# Clear existing palette items
	for c in input_palette.get_children():
		c.queue_free()
	for c in processing_palette.get_children():
		c.queue_free()
	for c in output_palette.get_children():
		c.queue_free()
	
	# Repopulate with allowed parts
	var allowed: Array = []
	if spec.has("allowed_parts"):
		allowed = spec["allowed_parts"]
	else:
		allowed = ["signal_loom", "weight_wheel", "adder_manifold", "activation_gate", "entropy_manometer"]
	
	# Re-populate drawers with only allowed parts
	_populate_allowed_parts(allowed)
	# Story
	if spec.has("story") and spec["story"].has("text"):
		story_label.text = str(spec["story"]["text"]) 
		story_dialog.popup_centered()
	# set up lanes and per-lane controls
	var packed: Array = _lanes_and_epochs_from_spec()
	var lanes: int = int(packed[0])
	engine.set_num_lanes(lanes)
	_create_lane_controls(lanes)

func _lanes_and_epochs_from_spec() -> Array:
	var lanes := 3
	if current_spec.has("targets") and current_spec["targets"].has("lanes"):
		lanes = int(current_spec["targets"]["lanes"])
	var epochs := 10
	if current_spec.has("training") and current_spec["training"].has("epochs"):
		epochs = int(current_spec["training"]["epochs"])
	return [lanes, epochs]

func _make_synthetic_samples(lanes: int) -> Array:
	var samples: Array = []
	for i in range(32):
		var x: Array = []
		for j in range(lanes):
			x.append(randf_range(-1, 1))
		var target: Array = []
		for j in range(lanes):
			target.append(0.5 * x[j])
		samples.append({"x": x, "y": target})
	return samples

func _create_lane_controls(lanes: int) -> void:
	for s in lane_sliders:
		if is_instance_valid(s):
			(s as Node).queue_free()
	lane_sliders.clear()
	for i in range(lanes):
		var label := Label.new()
		label.text = "Lane %d" % (i + 1)
		inspector.add_child(label)
		var slider := HSlider.new()
		slider.min_value = -5
		slider.max_value = 5
		slider.step = 0.01
		slider.value = engine.get_weights()[i]
		slider.value_changed.connect(_on_lane_weight_changed.bind(i))
		inspector.add_child(slider)
		lane_sliders.append(slider)
	_sync_weight_ui()

func _on_lane_weight_changed(value: float, index: int) -> void:
	engine.set_weight_at(index, value)
	_sync_weight_ui()

func _sync_weight_ui() -> void:
	var ws: Array = engine.get_weights()
	if is_instance_valid(weight_label) and ws.size() > 0:
		weight_label.text = "Weight: %.2f / lanes=%d" % [float(ws[0]), ws.size()]
	for i in range(min(ws.size(), lane_sliders.size())):
		if is_instance_valid(lane_sliders[i]):
			(lane_sliders[i] as HSlider).set_value_no_signal(float(ws[i]))

func _log(t: String) -> void:
	if console and console.has_method("append_text"):
		console.append_text(t + "\n")

func _on_graph_connect(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.connect_node(from_node, from_port, to_node, to_port)
	_log("connected %s[%d] to %s[%d]" % [from_node, from_port, to_node, to_port])
	# tutorial.notify("connected_parts")  # Disabled
	story_tutorial.notify_action("connect_components")

func _on_graph_disconnect(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.disconnect_node(from_node, from_port, to_node, to_port)
	_log("disconnected %s[%d] from %s[%d]" % [from_node, from_port, to_node, to_port])

func _on_zoom_changed(value: float) -> void:
	graph.zoom = clampf(value, 0.4, 2.0)

func _on_replay_tutorial() -> void:
	# Tutorial replay disabled - using story chat system instead
	pass

func _on_open_settings() -> void:
	settings_dialog.popup_centered()

func _on_ui_scale_changed(value: float) -> void:
	# Use the proper Godot 4 method for UI scaling
	get_window().content_scale_factor = clampf(value, 0.5, 1.8)

func _on_fullscreen_toggled(pressed: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _on_run_forward() -> void:
	# Demo: iterate connections and log flow; future: animate wire colors
	var conns: Array = graph.get_connection_list()
	for c in conns:
		_log("flow: %s[%d] -> %s[%d]" % [str(c["from"]), int(c["from_port"]), str(c["to"]), int(c["to_port"])])

func _on_run_backprop() -> void:
	var conns: Array = graph.get_connection_list()
	for i in range(conns.size()-1, -1, -1):
		var c = conns[i]
		_log("grad: %s[%d] <- %s[%d]" % [str(c["from"]), int(c["from_port"]), str(c["to"]), int(c["to_port"])])
