extends Control

## TutorialManager
# Guides the player through the Workbench UI with highlights and prompts.

@onready var dim := $Dim
@onready var highlight := $Highlight
@onready var hint := $Hint
@onready var hint_text := $Hint/VBox/Text
@onready var btn_prev := $Hint/VBox/Buttons/Prev
@onready var btn_next := $Hint/VBox/Buttons/Next
@onready var btn_skip := $Hint/VBox/Buttons/Skip

var steps: Array = []
var step_index := 0
var awaiting_action: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_steps()
	print("Tutorial ready, built ", steps.size(), " steps")
	btn_prev.pressed.connect(_on_prev)
	btn_next.pressed.connect(_on_next)
	btn_skip.pressed.connect(_on_skip)
	_show_step(0)

func _build_steps() -> void:
	steps = [
		{
			"id": "welcome",
			"text": "🎩 Welcome to the Signalworks Workbench!\n\nYou're about to learn how to build steam-powered learning machines! We'll guide you step-by-step through creating your first contraption.\n\nClick Next when you're ready to begin.",
			"target": "",
			"wait_for": "next"
		},
		{
			"id": "load_level",
			"text": "📋 STEP 1: Load Your First Challenge\n\nThe dropdown shows 'act_I_l1_dawn_in_dock_ward.yaml' - this is your first puzzle. It teaches basic signal processing.\n\n👆 Click the LOAD button now to load this level.",
			"target": "TopBar/LoadButton",
			"wait_for": "loaded"
		},
		{
			"id": "understand_problem",
			"text": "📊 THE CHALLENGE\n\nYou now have a simple learning problem loaded. Look at the console - it shows what data you're working with.\n\nYour goal: Build a contraption that can learn to process signals correctly.\n\nClick Next to continue.",
			"target": "",
			"wait_for": "next"
		},
		{
			"id": "place_signal_loom",
			"text": "⚙️ STEP 2: Add a Signal Loom\n\nThe Signal Loom processes input data - it's like the 'eyes' of your machine.\n\n👆 Click the 'Signal Loom' button in the palette (left side) to add one to your blueprint.",
			"target": "HBoxContainer/Palette",
			"wait_for": "placed_part"
		},
		{
			"id": "place_weight_wheel",
			"text": "🎛️ STEP 3: Add a Weight Wheel\n\nThe Weight Wheel adjusts how much each input matters - it's the 'brain' that learns.\n\n👆 Now click 'Weight Wheel' to add one to your contraption.",
			"target": "HBoxContainer/Palette",
			"wait_for": "placed_weight_wheel"
		},
		{
			"id": "connect_parts",
			"text": "🔗 STEP 4: Connect Your Parts\n\nSee the green and yellow connection points (ports)? These carry steam pressure between parts.\n\n👆 Drag from a green OUTPUT port to a yellow INPUT port to connect them.",
			"target": "GraphEdit",
			"wait_for": "connected_parts"
		},
		{
			"id": "adjust_learning_rate",
			"text": "🔧 STEP 5: Set Learning Speed\n\nThe Learning Rate controls how fast your machine learns. Start with a moderate speed.\n\n👆 Move the LR slider to around 0.1 (middle position).",
			"target": "TopBar/LRSlider",
			"wait_for": "lr_changed"
		},
		{
			"id": "first_training",
			"text": "🚂 STEP 6: Train Your Machine!\n\nTime to fire up the boiler! Your contraption will learn from the data.\n\n👆 Click TRAIN to start learning. Watch the loss number get smaller - that means it's working!",
			"target": "TopBar/TrainButton",
			"wait_for": "trained"
		},
		{
			"id": "observe_results",
			"text": "📈 EXCELLENT! \n\nLook at the console - the loss decreased! Your machine learned something.\n\nThe Weight Wheel adjusted itself to better process the signals. This is how machine learning works!\n\nClick Next to continue.",
			"target": "",
			"wait_for": "next"
		},
		{
			"id": "experiment",
			"text": "🧪 STEP 7: Experiment!\n\nTry these experiments:\n• Click TRAIN again - see the loss get even smaller\n• Adjust the Learning Rate and train again\n• Try the ReLU checkbox (it filters negative values)\n• Click 'Run Forward' to see data flow\n\nClick Next when you've experimented.",
			"target": "",
			"wait_for": "next"
		},
		{
			"id": "graduation",
			"text": "⭐ CONGRATULATIONS!\n\nYou've built and trained your first learning machine! You now understand:\n\n• Signal Looms process input data\n• Weight Wheels learn and adjust\n• Training reduces error (loss)\n• Learning Rate controls speed\n• Connections carry data\n\nYou're ready to tackle more complex challenges!",
			"target": "",
			"wait_for": "next"
		}
	]

func _on_prev() -> void:
	if step_index > 0:
		_show_step(step_index - 1)

func _on_next() -> void:
	if step_index < steps.size() - 1:
		_show_step(step_index + 1)
	else:
		hide()

func _on_skip() -> void:
	hide()

func start_tutorial() -> void:
	print("Starting tutorial...")
	_show_step(0)

func _show_step(index: int) -> void:
	if index < 0 or index >= steps.size():
		hide()
		return
	step_index = index
	var s: Dictionary = steps[index]
	var text_content := String(s.get("text", "Tutorial step " + str(index)))
	print("Tutorial showing step ", index, ": ", text_content.substr(0, 50))
	hint_text.text = text_content
	awaiting_action = String(s.get("wait_for", ""))
	_apply_target(String(s.get("target", "")))
	# button states
	btn_prev.disabled = (step_index == 0)
	btn_next.disabled = (step_index == steps.size() - 1 and awaiting_action != "next")
	show()
	hint.show()
	dim.show()

func _apply_target(target_path: String) -> void:
	if target_path == "" or not get_parent().has_node(target_path):
		highlight.hide()
		dim.show()
		hint.show()
		hint.position = Vector2(24, size.y - hint.size.y - 24)
		return
	var target: Control = get_parent().get_node(target_path)
	var rect := target.get_global_rect()
	var to_local := get_global_transform().affine_inverse()
	var local_pos := to_local * rect.position
	
	# Add padding to highlight for better visibility
	var padding := 8
	highlight.position = local_pos - Vector2(padding, padding)
	highlight.size = rect.size + Vector2(padding * 2, padding * 2)
	highlight.color = Color(0.98, 0.85, 0.3, 0.5)  # Brighter highlight
	highlight.show()
	
	# Pulse animation for extra attention
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(highlight, "color:a", 0.2, 0.8)
	tween.tween_property(highlight, "color:a", 0.5, 0.8)
	
	dim.show()
	hint.show()
	# Position hint near target, prefer below
	var hint_pos := Vector2(local_pos.x, local_pos.y + rect.size.y + 8)
	if hint_pos.y + hint.size.y > size.y:
		hint_pos.y = max(8.0, local_pos.y - hint.size.y - 8)
	hint.position = hint_pos

func notify(action: String, _data: Variant = null) -> void:
	if awaiting_action == "":
		return
	if action == awaiting_action:
		_on_next()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		# Reposition highlight on resize
		if steps.size() == 0:
			return
		if step_index < 0 or step_index >= steps.size():
			return
		var s: Dictionary = steps[step_index]
		_apply_target(String(s.get("target", "")))
