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
@onready var eval_btn := $MarginContainer/MainLayout/CenterPanel/TopBar/EvalButton
@onready var story_dialog := $StoryDialog
@onready var story_label := $StoryDialog/StoryLabel
# @onready var tutorial := $TutorialLayer
@onready var story_tutorial := $StoryTutorial
@onready var input_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/InputDrawer/InputHeader
@onready var processing_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/ProcessingDrawer/ProcessingHeader
@onready var output_header := $MarginContainer/MainLayout/RightPanel/ComponentDrawers/OutputDrawer/OutputHeader
@onready var inspector_content := $MarginContainer/MainLayout/RightPanel/Inspector/InspectorContent

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
var weight_slider: HSlider
var weight_label: Label

var _last_inspection_window_pos: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	engine = Act1Engine.new()
	add_child(engine)
	_populate_palette()
	# wire controls
	level_select.item_selected.connect(_on_level_selected)
	load_btn.pressed.connect(_on_load_pressed)
	train_btn.pressed.connect(on_train_pressed)
	step_btn.pressed.connect(_on_step_pressed)
	reset_btn.pressed.connect(on_reset_pressed)
	lr_slider.value_changed.connect(on_lr_changed)
	relu_toggle.toggled.connect(on_relu_toggled)
	zoom_slider.value_changed.connect(_on_zoom_changed)
	replay_btn.pressed.connect(_on_replay_tutorial)
	settings_btn.pressed.connect(_on_open_settings)
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	run_fwd_btn.pressed.connect(_on_run_forward)
	run_back_btn.pressed.connect(_on_run_backprop)
	eval_btn.pressed.connect(_on_evaluate)
	# Connect drawer headers
	input_header.pressed.connect(_on_drawer_toggled.bind(input_palette))
	processing_header.pressed.connect(_on_drawer_toggled.bind(processing_palette))
	output_header.pressed.connect(_on_drawer_toggled.bind(output_palette))
	# levels
	level_select.add_item("Select level...")  # Placeholder
	for p in spec_paths:
		level_select.add_item(p.get_file())
	level_select.select(0)  # Select placeholder initially
	_log("Workbench ready")
	_validate_yaml_files()
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
	if graph.has_signal("node_selected"):
		graph.node_selected.connect(_on_graph_node_selected)
	# Lazy bind inspector legacy controls if still present
	weight_slider = get_node_or_null("MarginContainer/MainLayout/RightPanel/Inspector/WeightSlider")
	weight_label = get_node_or_null("MarginContainer/MainLayout/RightPanel/Inspector/WeightLabel")
	if is_instance_valid(weight_slider):
		weight_slider.value_changed.connect(_on_weight_changed)

func _populate_palette() -> void:
	var input_parts = [
		{
			"id": "steam_source",
			"icon": "res://assets/icons/steam_pipe.svg",
			"tooltip": "Steam Source\n\nThe heart of your contraption - generates steam pressure.\nProvides the input data your machine needs to process."
		},
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
		},
		{
			"id": "spyglass",
			"icon": "res://assets/icons/gear.svg",
			"tooltip": "Spyglass\n\nPeer into components to see what's happening inside.\nShows real-time data flow and component states."
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
		"steam_source": {"category": "input", "icon": "res://assets/icons/steam_pipe.svg", "tooltip": "Steam Source\n\nThe heart of your contraption - generates steam pressure.\nProvides the input data your machine needs to process."},
		"signal_loom": {"category": "input", "icon": "res://assets/icons/steam_pipe.svg", "tooltip": "Signal Loom\n\nProcesses input data - the 'eyes' of your machine.\nConverts raw information into usable steam pressure."},
		"weight_wheel": {"category": "processing", "icon": "res://assets/icons/weight_dial.svg", "tooltip": "Weight Wheel\n\nThe 'brain' that learns! Adjusts how much each input matters.\nThis is where the actual learning happens."},
		"adder_manifold": {"category": "processing", "icon": "res://assets/icons/manifold.svg", "tooltip": "Adder Manifold\n\nCombines multiple steam pressures into one.\nUseful for merging signals from different sources."},
		"activation_gate": {"category": "processing", "icon": "res://assets/icons/gear.svg", "tooltip": "Activation Gate\n\nTransforms steam pressure using mathematical functions.\nCan apply ReLU, sigmoid, or other transformations."},
		"entropy_manometer": {"category": "output", "icon": "res://assets/icons/pressure_gauge.svg", "tooltip": "Entropy Manometer\n\nMeasures uncertainty and information content.\nHelps optimize learning efficiency."},
		"spyglass": {"category": "output", "icon": "res://assets/icons/gear.svg", "tooltip": "Spyglass\n\nPeer into components to see what's happening inside.\nShows real-time data flow and component states."}
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
	# Ensure unique name so Spyglass can target by name
	node.name = "%s_%d" % [id, Time.get_ticks_msec()]
	# Connect inspection request from node
	if node.has_signal("inspect_requested"):
		node.inspect_requested.connect(_open_inspection_window)
	node.position_offset = Vector2(randi()%400, randi()%200)
	graph.add_child(node)
	
	# Notify tutorial of specific part placement
	if id == "steam_source":
		story_tutorial.notify_action("place_steam_source")
	elif id == "signal_loom":
		# tutorial.notify("placed_part")  # Disabled
		story_tutorial.notify_action("place_signal_loom")
	elif id == "weight_wheel":
		# tutorial.notify("placed_weight_wheel")  # Disabled
		story_tutorial.notify_action("place_weight_wheel")
	elif id == "spyglass":
		story_tutorial.notify_action("place_spyglass")
	else:
		# tutorial.notify("placed_part")  # Disabled
		story_tutorial.notify_action("place_part")


func on_train_pressed() -> void:
	var packed: Array = _lanes_and_epochs_from_spec()
	var lanes: int = int(packed[0])
	var epochs: int = int(packed[1])
	# If there is a built graph with connections, train over it; otherwise use engine fallback
	var conns: Array = graph.get_connection_list()
	if conns.is_empty():
		engine.set_num_lanes(lanes)
		for e in range(epochs):
			var samples: Array = _make_synthetic_samples(lanes)
			var loss: float = engine.run_epoch(samples)
			_log("epoch %d loss=%.4f" % [e + 1, loss])
		_sync_weight_ui()
	else:
		for e in range(epochs):
			var loss := _train_graph_once(conns)
			_log("epoch %d graph_loss=%.4f" % [e + 1, loss])
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
	
	# Check if placeholder is selected
	if idx == 0:
		_log("⚠️ Please select a level first!")
		print("Placeholder selected, nothing to load")
		return
	
	# Adjust index for placeholder offset
	var spec_idx: int = idx - 1
	if spec_idx < 0 or spec_idx >= spec_paths.size():
		_log("⚠️ Invalid level selection!")
		return
		
	var path: String = spec_paths[spec_idx]
	print("Loading spec from: ", path)
	current_spec = SpecLoader.load_spec(path)
	if current_spec.is_empty():
		_log("failed to load: %s" % path)
		print("Failed to load spec!")
		return
	
	# Debug: print what we actually loaded
	print("DEBUG: Loaded spec keys: ", current_spec.keys())
	print("DEBUG: Spec name field: ", current_spec.get("name", "NOT_FOUND"))
	
	_apply_spec_to_ui(current_spec)
	_log("🎯 LEVEL LOADED: " + str(current_spec.get("name", "Unknown Level")))
	_log("📋 GOAL: " + current_spec.get("description", "No description"))
	
	# Show what parts are available
	var allowed: Array = []
	if current_spec.has("allowed_parts"):
		allowed = current_spec["allowed_parts"]
	else:
		allowed = ["steam_source", "signal_loom", "weight_wheel", "adder_manifold", "activation_gate", "entropy_manometer", "spyglass"]
	_log("🔧 Available parts: " + str(allowed))
	
	# Show training data info if available
	if current_spec.has("data"):
		_log("📊 Training data loaded - ready to learn!")
	
	# Show level requirements
	if current_spec.has("win_conditions"):
		var win_cond = current_spec["win_conditions"]
		_log("🎯 WIN CONDITION: Achieve " + str(win_cond.get("accuracy", "unknown")) + " accuracy")
	
	# Show budget constraints
	if current_spec.has("budget"):
		var budget = current_spec["budget"]
		_log("💰 BUDGET: Mass=" + str(budget.get("mass", "∞")) + ", Pressure=" + str(budget.get("pressure", "∞")) + ", Brass=" + str(budget.get("brass", "∞")))
	
	_log("💡 Ready to build your contraption!")
	# tutorial.notify("loaded")  # Disabled
	print("Notifying story tutorial of load_level action")
	story_tutorial.notify_action("load_level")

func _on_level_selected(index: int) -> void:
	print("Level selected: ", index)
	if index == 0:
		print("Placeholder selected")
		return
	
	var level_name = level_select.get_item_text(index)
	print("Selected level: ", level_name)
	
	# Check if it's the Dawn Ward level for tutorial
	if level_name == "act_I_l1_dawn_in_dock_ward.yaml":
		print("Dawn Ward level selected - notifying tutorial")
		story_tutorial.notify_action("select_level")
	else:
		print("Different level selected: ", level_name)

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
	
	# Re-populate drawers with only allowed parts, preserving ordering per allowed_parts
	_populate_allowed_parts(allowed)
	# Story
	if spec.has("story") and spec["story"].has("text"):
		story_label.text = str(spec["story"]["text"]) 
		story_dialog.popup_centered()
	else:
		story_label.text = "Welcome to AItherworks! Build and train your first contraption."
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

func _open_inspection_window(part: PartNode) -> void:
	# Create a spyglass bound to this part node's name
	var spy := Spyglass.new()
	add_child(spy)
	spy.inspection_target = part.name
	spy.start_inspection()
	# Create window
	var win_scene := load("res://game/ui/inspection_window.tscn") as PackedScene
	var win: InspectionWindow = win_scene.instantiate()
	add_child(win)
	win.connect_to_spyglass(spy)
	if _last_inspection_window_pos.x >= 0:
		win.position = _last_inspection_window_pos
	win.window_closed.connect(func():
		_last_inspection_window_pos = win.position
		if is_instance_valid(spy):
			spy.stop_inspection()
			spy.queue_free()
		win.queue_free()
	)
	win.show_inspection_window()

func _validate_yaml_files() -> void:
	# Validate parts and specs, log readable errors
	if Engine.is_editor_hint():
		return
	var validator := SpecValidator.new()
	var result := validator.validate_parts_and_specs("res://data/parts", "res://data/specs")
	for msg in result.messages:
		_log(msg)

func _on_run_forward() -> void:
	_log("🚀 Running forward pass through your contraption...")
	
	# Get all connections
	var conns: Array = graph.get_connection_list()
	if conns.is_empty():
		_log("⚠️ No connections found! Connect your components first.")
		return
	
	# Find all PartNodes in the graph
	var part_nodes: Array[PartNode] = []
	for child in graph.get_children():
		if child is PartNode:
			part_nodes.append(child)
	
	if part_nodes.is_empty():
		_log("⚠️ No parts found! Add some components first.")
		return
	
	# Process signal flow through connected components
	_log("💨 Processing steam pressure through %d components..." % part_nodes.size())
	
	# Process signal flow starting from steam sources
	var steam_sources: Array = []
	var processed_nodes: Array = []
	
	# Find all steam sources
	for part_node in part_nodes:
		if part_node.part_id == "steam_source":
			steam_sources.append(part_node)
	
	# If no steam sources, look for signal looms as backup
	if steam_sources.is_empty():
		for part_node in part_nodes:
			if part_node.part_id == "signal_loom":
				steam_sources.append(part_node)
	
	# Process each steam source and follow the signal flow
	for source_node in steam_sources:
		var current_output: float = 0.0
		
		if source_node.part_id == "steam_source":
			# Steam source generates data
			current_output = source_node.process_inputs([])
			_log("🔥 %s generated steam → %.3f PSI" % [source_node.title, current_output])
		else:
			# Signal loom needs input data
			var test_inputs = [1.0, 0.5, -0.3]
			current_output = source_node.process_inputs(test_inputs)
			_log("📡 %s processed [%s] → %.3f" % [source_node.title, str(test_inputs), current_output])
		
		processed_nodes.append(source_node)
		
		# Follow connections from this source
		_process_connected_components(source_node, current_output, conns, part_nodes, processed_nodes)
	
	# Handle any spyglasses for inspection
	for part_node in part_nodes:
		if part_node.part_id == "spyglass":
			_log("🔍 %s status: %s" % [part_node.title, part_node.get_part_status()])
	
	_log("✅ Forward pass complete!")

func _process_connected_components(source_node: PartNode, signal_value: float, conns: Array, all_nodes: Array, processed: Array) -> void:
	"""Recursively process components connected to the source"""
	for conn in conns:
		if conn["from"] == source_node.name:
			var target_node = graph.get_node(conn["to"])
			if target_node is PartNode and target_node not in processed:
				# forward pulse highlight
				_pulse_connection(conn["from"], int(conn["from_port"]), conn["to"], int(conn["to_port"]), Color(1.0, 0.8, 0.3, 1.0))
				var output = target_node.process_inputs([signal_value])
				_log("⚙️ %s processed [%.3f] → %.3f" % [target_node.title, signal_value, output])
				_log("   Status: %s" % target_node.get_part_status())
				
				processed.append(target_node)
				
				# Continue processing down the chain
				_process_connected_components(target_node, output, conns, all_nodes, processed)

func _on_run_backprop() -> void:
	var conns: Array = graph.get_connection_list()
	for i in range(conns.size()-1, -1, -1):
		var c = conns[i]
		_log("grad: %s[%d] <- %s[%d]" % [str(c["from"]), int(c["from_port"]), str(c["to"]), int(c["to_port"])])
		# reverse pulse highlight (red hues)
		_pulse_connection(str(c["to"]), int(c["to_port"]), str(c["from"]), int(c["from_port"]), Color(1.0, 0.2, 0.2, 1.0))

func _pulse_connection(from_node: String, from_port: int, to_node: String, to_port: int, _color: Color) -> void:
	# Try to use GraphEdit's per-connection activity if available; otherwise, briefly toggle selection
	if graph.has_method("set_connection_activity"):
		graph.set_connection_activity(from_node, from_port, to_node, to_port, 1.0)
		# fade after a short delay
		await get_tree().create_timer(0.15).timeout
		graph.set_connection_activity(from_node, from_port, to_node, to_port, 0.0)
	else:
		# Fallback: temporarily clear selection to hint activity
		graph.set_selected(null)
		await get_tree().create_timer(0.01).timeout

func _on_evaluate() -> void:
	var res: Dictionary = Evaluator.evaluate_graph(graph, current_spec)
	if not bool(res.get("ok", false)):
		_log("❌ Eval failed: " + String(res.get("reason", "unknown")))
		return
	var acc: float = float(res.get("accuracy", 0.0))
	var m: Dictionary = res.get("metrics", {})
	_log("📊 Eval: acc=%.3f mse=%.4f samples=%d" % [acc, float(m.get("mse", 0.0)), int(m.get("samples", 0))])
	_log("🌫️ Steam=%.2f 💧 Water=%.2f ⏱️ Infer=%.2fms Train=%.2fms" % [float(m.get("steam_used", 0.0)), float(m.get("water_used", 0.0)), float(m.get("inference_ms", 0.0)), float(m.get("training_ms", 0.0))])
	var verdict: Dictionary = res.get("verdict", {"passed": false, "reasons": ["no verdict"]})
	if bool(verdict.get("passed", false)):
		_log("✅ PASS")
	else:
		_log("❌ FAIL: " + ", ".join(verdict.get("reasons", [])))

func _train_graph_once(conns: Array) -> float:
	# Simple training over the current graph: forward from steam sources, accumulate outputs,
	# compute loss against spec target if present, and apply gradients to WeightWheels.
	var part_nodes: Array[PartNode] = []
	for child in graph.get_children():
		if child is PartNode:
			part_nodes.append(child)
	if part_nodes.is_empty():
		return 0.0
	# Map names to nodes
	var name_to_node: Dictionary = {}
	for n in part_nodes:
		name_to_node[n.name] = n
	# Forward pass: breadth-first from steam_source(s)
	var outputs: Dictionary = {}
	# Find sources
	var sources: Array = []
	for pn in part_nodes:
		if pn.part_id == "steam_source":
			sources.append(pn)
	if sources.is_empty():
		# fallback: signal_loom as a starting node with dummy inputs
		for pn in part_nodes:
			if pn.part_id == "signal_loom":
				sources.append(pn)
	# Forward
	for s in sources:
		var out_val: float = 0.0
		if s.part_id == "steam_source":
			out_val = s.process_inputs([])
		else:
			out_val = s.process_inputs([1.0, 0.5, -0.3])
		outputs[s.name] = out_val
		# propagate
		_forward_from_node(s, out_val, conns, name_to_node, outputs)
	# Determine targets
	var target: float = 0.0
	if current_spec.has("targets") and current_spec["targets"].has("pattern"):
		# use average of pattern as scalar goal for this simple graph trainer
		var patt: Array = current_spec["targets"]["pattern"]
		for v in patt:
			target += float(v)
		target /= max(1, patt.size())
	# Identify terminals (nodes with no outgoing edges)
	var to_names: Array = []
	for c in conns:
		to_names.append(str(c["to"]))
	var terminals: Array[PartNode] = []
	for pn2 in part_nodes:
		if pn2.name not in to_names:
			terminals.append(pn2)
	# Compute loss as MSE across terminal outputs vs target
	var total_loss: float = 0.0
	var grads_per_wheel: Dictionary = {}
	for t in terminals:
		var y_hat := float(outputs.get(t.name, 0.0))
		var err := (y_hat - target)
		total_loss += err * err
		# Backprop only into direct upstream WeightWheels for now
		for c2 in conns:
			if str(c2["to"]) == t.name:
				var up_name := str(c2["from"])
				if name_to_node.has(up_name):
					var up_node: PartNode = name_to_node[up_name]
					if up_node.part_id == "weight_wheel" and up_node.part_instance is WeightWheel:
						grads_per_wheel[up_node.name] = float(err)
	# Apply gradients to wheels
	for k in grads_per_wheel.keys():
		var wheel_node: PartNode = name_to_node[k]
		var wheel := wheel_node.part_instance as WeightWheel
		wheel.apply_gradients(grads_per_wheel[k])
	return total_loss / max(1, terminals.size())

func _forward_from_node(node: PartNode, input_value: float, conns: Array, name_to_node: Dictionary, outputs: Dictionary) -> void:
	for c in conns:
		if str(c["from"]) == node.name:
			var target_name := str(c["to"])
			if name_to_node.has(target_name):
				var tgt: PartNode = name_to_node[target_name]
				var out := tgt.process_inputs([input_value])
				outputs[target_name] = out
				_forward_from_node(tgt, out, conns, name_to_node, outputs)

func _on_graph_node_selected(node_name: StringName) -> void:
	var node := graph.get_node_or_null(String(node_name))
	if node == null:
		return
	if node is PartNode:
		_populate_inspector_for_part(node)

func _clear_inspector() -> void:
	if is_instance_valid(inspector_content):
		for c in inspector_content.get_children():
			(c as Node).queue_free()

func _populate_inspector_for_part(p: PartNode) -> void:
	_clear_inspector()
	var title := Label.new()
	title.text = "Inspecting: %s" % p.title
	inspector_content.add_child(title)
	match p.part_id:
		"weight_wheel":
			if p.part_instance and p.part_instance is WeightWheel:
				var wheel := p.part_instance as WeightWheel
				var weights: Array[float] = wheel.weights
				for i in range(weights.size()):
					var row := HBoxContainer.new()
					var lbl := Label.new()
					lbl.text = "Spoke %d" % (i + 1)
					row.add_child(lbl)
					var knob_script := load("res://game/ui/controls/knob.gd")
					var knob: Control = knob_script.new()
					knob.min_value = -2.0
					knob.max_value = 2.0
					knob.step = 0.01
					knob.value = weights[i]
					knob.custom_minimum_size = Vector2(44, 44)
					knob.value_changed.connect(func(v: float): wheel.set_weight(i, v))
					row.add_child(knob)
					inspector_content.add_child(row)
			else:
				var info := Label.new()
				info.text = "Wheel instance not ready"
				inspector_content.add_child(info)
		"steam_source":
			if p.part_instance and p.part_instance is SteamSource:
				var src := p.part_instance as SteamSource
				_inspector_slider("Amplitude", 0.1, 5.0, 0.01, src.amplitude, func(v: float): src.set_amplitude(v))
				_inspector_slider("Frequency", 0.1, 3.0, 0.01, src.frequency, func(v: float): src.set_frequency(v))
				_inspector_slider("Noise", 0.0, 1.0, 0.01, src.noise_level, func(v: float): src.set_noise_level(v))
				_inspector_slider("Channels", 1, 8, 1, src.num_channels, func(v: float): src.set_num_channels(int(v)))
				var info3 := Label.new()
				info3.text = src.get_source_status()
				inspector_content.add_child(info3)
		"signal_loom":
			if p.part_instance and p.part_instance is SignalLoom:
				var loom := p.part_instance as SignalLoom
				_inspector_slider("Input Channels", 1, 8, 1, loom.input_channels, func(v: float): loom.set_input_channels(int(v)))
				_inspector_slider("Output Width", 1, 16, 1, loom.output_width, func(v: float): loom.set_output_width(int(v)))
				_inspector_slider("Signal Strength", 0.0, 2.0, 0.01, loom.signal_strength, func(v: float): loom.set_signal_strength(v))
		_:
			var info2 := Label.new()
			info2.text = p.get_part_status()
			inspector_content.add_child(info2)

func _inspector_slider(label_text: String, min_v: float, max_v: float, step: float, cur: float, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	row.add_child(lbl)
	var knob_script := load("res://game/ui/controls/knob.gd")
	var knob: Control = knob_script.new()
	knob.min_value = min_v
	knob.max_value = max_v
	knob.step = step
	knob.value = cur
	knob.custom_minimum_size = Vector2(44, 44)
	knob.value_changed.connect(func(v: float): on_change.call(v))
	row.add_child(knob)
	inspector_content.add_child(row)
