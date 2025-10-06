extends Control

## Story-driven Tutorial System
# Features character dialogue, interactive guidance, and immersive steampunk narrative

@onready var dialogue_overlay := $DialogueOverlay
@onready var dialogue_box := $DialogueBox
@onready var character_portrait := $DialogueBox/HBox/CharacterPortrait
@onready var character_name := $DialogueBox/HBox/VBox/CharacterName
@onready var dialogue_text := $DialogueBox/HBox/VBox/DialogueText
@onready var continue_btn := $DialogueBox/HBox/VBox/ContinueButton
@onready var action_highlight := $ActionHighlight
@onready var drag_guide := $DragGuide
@onready var arrow := $Arrow

var story_chapters: Array = []
var current_chapter := 0
var current_dialogue := 0
var awaiting_action: String = ""
var target_workbench: Control = null
var story_panel: RichTextLabel = null
var chat_history: String = ""

# Character portraits
var portraits := {
	"master_cogwright": preload("res://assets/characters/master_cogwright.svg"),
	"apprentice": preload("res://assets/characters/apprentice_player.svg"),
	"aether_sage": preload("res://assets/characters/aether_sage.svg")
}

func _ready() -> void:
	_build_story()
	continue_btn.pressed.connect(_on_continue_pressed)
	# Start hidden
	hide()
	dialogue_overlay.hide()
	dialogue_box.hide()

func _build_story() -> void:
	story_chapters = [
		{
			"title": "The Apprentice Arrives",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Ah, young apprentice! Welcome to the Guild of AItherworks Engineers. I am Master Cogwright, and today you begin your journey into the arcane art of [color=yellow]Machine Learning[/color]."
				},
				{
					"character": "apprentice",
					"name": "You",
					"text": "Master Cogwright! I've dreamed of this day. But... what exactly is Machine Learning? I've heard whispers in the taverns about contraptions that can [i]think[/i] and [i]learn[/i]..."
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright", 
					"text": "Excellent question! In our steampunk world, we build mechanical minds from brass, steam, and aether. These contraptions can learn patterns from data - just like how you learned to recognize faces or speak. But our machines use [color=cyan]steam pressure[/color] instead of thoughts!"
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Your workbench awaits! First, we must select a challenge. See that dropdown above? Click it and choose [b]act_I_l1_dawn_in_dock_ward.yaml[/b] - your first lesson from the Dawn Ward.",
					"action": "select_level",
					"target": "MarginContainer/MainLayout/CenterPanel/TopBar/LevelSelect"
				}
			]
		},
		{
			"title": "Loading the Challenge",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Perfect choice! Now press the [b]Load[/b] button to load this challenge into your workbench. This will prepare the training data and show you what your machine needs to learn.",
					"action": "load_level",
					"target": "MarginContainer/MainLayout/CenterPanel/TopBar/LoadButton"
				}
			]
		},
		{
			"title": "Understanding the Challenge",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Splendid! You've loaded your first puzzle. Look at the console - it shows the training data. These numbers represent [color=cyan]steam pressure readings[/color] from various pipes in the city."
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "[i]*materializes from the shadows*[/i] Greetings, apprentice. I am the Aether Sage. The data you see represents input signals and their desired outputs. Your machine must learn to transform inputs into correct outputs."
				},
				{
					"character": "apprentice",
					"name": "You", 
					"text": "So... the machine needs to learn the pattern? Like figuring out a secret code?"
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "Precisely! But first, every machine needs a [color=yellow]Steam Source[/color] – the boiler that produces input steam signals.",
					"action": "place_steam_source",
					"target": "MarginContainer/MainLayout/RightPanel/ComponentDrawers"
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "Now add the [color=yellow]Signal Loom[/color] – the eyes that process raw steam into usable signals.",
					"action": "place_signal_loom",
					"target": "MarginContainer/MainLayout/RightPanel/ComponentDrawers"
				}
			]
		},
		{
			"title": "Building the Mind",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Well done! The Signal Loom is like the [color=cyan]eyes[/color] of your machine - it processes raw input data and converts it into usable steam pressure. Now we need a [color=yellow]brain[/color]!"
				},
				{
					"character": "aether_sage", 
					"name": "Aether Sage",
					"text": "The brain of any learning machine is the [color=yellow]Weight Wheel[/color] - a brass wheel with adjustable counterweights on its spokes. Each spoke controls how much one input signal affects the output. Heavy weights amplify signals, light weights dampen them. During training, the wheel automatically adjusts these weights to learn patterns!",
					"action": "place_weight_wheel",
					"target": "MarginContainer/MainLayout/RightPanel/ComponentDrawers"
				}
			]
		},
		{
			"title": "Connecting the Steam Pipes",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Excellent! Now you have both eyes and brain. But they must be connected! See those colored ports? [color=yellow]Yellow[/color] ports output steam pressure, [color=cyan]blue[/color] ports receive it."
				},
				{
					"character": "apprentice",
					"name": "You",
					"text": "Like connecting pipes in a steam engine! The pressure flows from one component to another."
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Exactly! [color=yellow]Connect the Steam Source's output to the Signal Loom's input[/color]. Drag from a yellow output port to a blue input port.",
					"action": "connect_components",
					"target": "MarginContainer/MainLayout/CenterPanel/BlueprintArea/GraphEdit"
				}
			]
		},
		{
			"title": "Peering Through the Spyglass",
			"dialogues": [
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "To see inside your machine, place a [color=yellow]Spyglass[/color], or simply [b]double-click[/b] a component to open the Inspector.",
					"action": "place_spyglass",
					"target": "MarginContainer/MainLayout/RightPanel/ComponentDrawers"
				}
			]
		},
		{
			"title": "Tuning the Learning Rate",
			"dialogues": [
				{
					"character": "aether_sage",
					"name": "Aether Sage", 
					"text": "Magnificent! Your machine has a connected nervous system. But before we fire up the boiler, we must set the [color=yellow]Learning Rate[/color] - how aggressively the Weight Wheel adjusts itself."
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "Too high, and the wheels spin wildly, overshooting the target. Too low, and progress crawls like cold molasses. [color=yellow]Set it to around 0.1[/color] - a good balance for beginners.",
					"action": "adjust_learning_rate", 
					"target": "MarginContainer/MainLayout/CenterPanel/TopBar/LRSlider"
				}
			]
		},
		{
			"title": "The First Training",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "The moment of truth, apprentice! Time to [color=red]fire up the boiler[/color] and begin training. Your machine will see the training data and slowly adjust its weights to match the patterns."
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Watch the console carefully - the [color=red]loss[/color] number shows how wrong your machine is. As it learns, this number should decrease. [color=yellow]Click TRAIN[/color] to begin the learning process!",
					"action": "start_training",
					"target": "MarginContainer/MainLayout/CenterPanel/TopBar/TrainButton"
				}
			]
		},
		{
			"title": "Success and Understanding",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Marvelous! Look at that loss decreasing! Your machine is learning! The Weight Wheel automatically adjusted its internal parameters to better match the training data."
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "What you've witnessed is the essence of machine learning: a system that improves its performance through experience. Your contraption literally [i]learned[/i] from the data!"
				},
				{
					"character": "apprentice", 
					"name": "You",
					"text": "Incredible! It's like the machine developed intuition about the patterns. But how does it actually work inside the Weight Wheel?"
				},
				{
					"character": "aether_sage",
					"name": "Aether Sage",
					"text": "The wheels contain numerical weights - think of them as tension settings on steam valves. During training, we measure the error and [i]backpropagate[/i] corrections through the system, adjusting each weight slightly."
				}
			]
		},
		{
			"title": "Graduation",
			"dialogues": [
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Congratulations, apprentice! You've built and trained your first thinking machine. You now understand the fundamental principles that power all our guild's contraptions."
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright", 
					"text": "Remember: [color=cyan]Signal Looms[/color] process input, [color=yellow]Weight Wheels[/color] learn patterns, [color=green]connections[/color] carry data, and [color=red]training[/color] teaches the machine. These are the building blocks of mechanical intelligence!"
				},
				{
					"character": "apprentice",
					"name": "You",
					"text": "Thank you, Master Cogwright and Aether Sage! I feel ready to tackle more complex challenges. When do we build machines that can see images or understand language?"
				},
				{
					"character": "master_cogwright",
					"name": "Master Cogwright",
					"text": "Patience, young engineer! Master the fundamentals first. Experiment with different components, adjust the learning rate, try the ReLU valve. Each lesson builds upon the last. Your journey has only just begun!"
				}
			]
		}
	]

func _start_tutorial() -> void:
	current_chapter = 0
	current_dialogue = 0
	_show_current_dialogue()

func _show_current_dialogue() -> void:
	if current_chapter >= story_chapters.size():
		_complete_tutorial()
		return
	
	var chapter = story_chapters[current_chapter]
	if current_dialogue >= chapter.dialogues.size():
		_next_chapter()
		return
	
	var dialogue = chapter.dialogues[current_dialogue]
	
	# Add message to chat panel instead of modal overlay
	_add_chat_message(dialogue.character, dialogue.name, dialogue.text)
	
	# Handle action requirements
	if dialogue.has("action"):
		awaiting_action = dialogue.action
		
		# Check if action already satisfied
		if _check_action_satisfied(awaiting_action):
			print("Tutorial action already satisfied: ", awaiting_action)
			awaiting_action = ""
			_clear_highlights()
			await get_tree().create_timer(1.0).timeout
			_next_dialogue()
			return
		
		if dialogue.has("target"):
			_highlight_target(dialogue.target)
		# Don't auto-advance - wait for user action
	else:
		awaiting_action = ""
		_clear_highlights()
		# Auto-advance after reading time
		await get_tree().create_timer(3.0).timeout
		_next_dialogue()

func _highlight_target(target_path: String) -> void:
	if not target_workbench or not target_workbench.has_node(target_path):
		return
	
	var target = target_workbench.get_node(target_path)
	var rect = target.get_global_rect()
	
	action_highlight.position = rect.position - Vector2(8, 8)
	action_highlight.size = rect.size + Vector2(16, 16)
	action_highlight.show()
	
	# Pulse animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(action_highlight, "color:a", 0.3, 0.6)
	tween.tween_property(action_highlight, "color:a", 0.6, 0.6)

func _clear_highlights() -> void:
	action_highlight.hide()
	drag_guide.hide()
	arrow.hide()

func _on_continue_pressed() -> void:
	current_dialogue += 1
	_show_current_dialogue()

func _next_dialogue() -> void:
	current_dialogue += 1
	_show_current_dialogue()

func _next_chapter() -> void:
	current_chapter += 1
	current_dialogue = 0
	_show_current_dialogue()

func _complete_tutorial() -> void:
	hide()
	_clear_highlights()
	# Notify workbench that tutorial is complete
	if target_workbench and target_workbench.has_method("_on_tutorial_complete"):
		target_workbench._on_tutorial_complete()

func set_workbench(workbench: Control) -> void:
	target_workbench = workbench
	# Get reference to the story panel in the workbench
	story_panel = workbench.get_node("MarginContainer/MainLayout/LeftPanel/StoryArea/StoryContent/StoryScroll/StoryText")
	if story_panel:
		print("DEBUG: Found story_panel, configuring BBCode...")
		# Configure BBCode first, before any other settings
		story_panel.bbcode_enabled = true
		story_panel.fit_content = true
		
		# Clear all theme overrides first
		for size_name in ["normal_font_size", "bold_font_size", "italics_font_size"]:
			if story_panel.has_theme_font_size_override(size_name):
				story_panel.remove_theme_font_size_override(size_name)
		
		# Set base font size without theme override initially
		# Let BBCode handle sizing relative to default font
		
		print("DEBUG: BBCode enabled: ", story_panel.bbcode_enabled)
		print("DEBUG: Font size override: ", story_panel.get_theme_font_size("normal_font_size"))
		_initialize_chat_panel()
	else:
		print("ERROR: Could not find story_panel at path: MarginContainer/MainLayout/LeftPanel/StoryArea/StoryContent/StoryScroll/StoryText")

func _initialize_chat_panel() -> void:
	chat_history = """[center][color=goldenrod]📜 Chronicle & Instructions[/color][/center]

[color=orange][i]The Guild of AItherworks Engineers has assigned you a mentor...[/i][/color]

"""
	print("DEBUG: Setting chat_history with clean BBCode...")
	_update_chat_display()

func _add_chat_message(character: String, speaker_name: String, text: String) -> void:
	var character_color := "lightblue"
	var avatar_path := ""
	
	match character:
		"master_cogwright":
			character_color = "orange"
			avatar_path = "res://assets/characters/master_cogwright.svg"
		"aether_sage":
			character_color = "lightgreen" 
			avatar_path = "res://assets/characters/aether_sage.svg"
		"apprentice":
			character_color = "yellow"
			avatar_path = "res://assets/characters/apprentice_player.svg"
	
	# Try BBCode img tag first, fallback to emoji if not supported
	var avatar_display := ""
	if avatar_path != "":
		avatar_display = "[img=32x32]%s[/img]" % avatar_path
	else:
		avatar_display = "👤"
	
	var message := "[color=%s]%s [b]%s:[/b][/color] %s\n\n" % [character_color, avatar_display, speaker_name, text]
	chat_history += message
	_update_chat_display()

func _update_chat_display() -> void:
	if story_panel:
		print("DEBUG: Updating chat display, BBCode enabled: ", story_panel.bbcode_enabled)
		print("DEBUG: Font size: ", story_panel.get_theme_font_size("normal_font_size"))
		print("DEBUG: Has theme font: ", story_panel.has_theme_font_size_override("normal_font_size"))
		print("DEBUG: Setting text: ", chat_history.substr(0, 100) + "...")
		
		# Try forcing BBCode configuration again
		story_panel.bbcode_enabled = true
		# set base size and then use BBCode sizes for headings
		story_panel.add_theme_font_size_override("normal_font_size", 16)
		story_panel.add_theme_font_size_override("bold_font_size", 18)
		story_panel.add_theme_font_size_override("italics_font_size", 16)
		story_panel.text = chat_history
		
		print("DEBUG: Text after setting: ", story_panel.text.substr(0, 100) + "...")
		
		# Auto-scroll to bottom
		await get_tree().process_frame
		var scroll_container = story_panel.get_parent()
		if scroll_container is ScrollContainer:
			scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	else:
		print("ERROR: story_panel is null in _update_chat_display")

func start_story_tutorial() -> void:
	_start_tutorial()

func notify_action(action: String) -> void:
	print("Story tutorial received action: ", action, " (awaiting: ", awaiting_action, ")")
	
	# Check if the action requirement is already satisfied
	if awaiting_action != "" and _check_action_satisfied(awaiting_action):
		print("Action already satisfied, auto-advancing")
		awaiting_action = ""
		_clear_highlights()
		_next_dialogue()
		return
	
	if awaiting_action == action:
		awaiting_action = ""
		_clear_highlights()
		# Auto-advance to next dialogue
		_next_dialogue()

func _check_action_satisfied(action: String) -> bool:
	"""Check if the tutorial requirement is already met"""
	if not target_workbench:
		return false
	
	var graph = target_workbench.get_node_or_null("MarginContainer/MainLayout/CenterPanel/BlueprintArea/GraphEdit")
	if not graph:
		return false
	
	match action:
		"select_level":
			var level_select = target_workbench.get_node_or_null("MarginContainer/MainLayout/CenterPanel/TopBar/LevelSelect")
			return level_select and level_select.get_selected() > 0
		"load_level":
			# Check if any parts are available (level loaded)
			return target_workbench.current_spec.size() > 0
		"place_steam_source":
			return _has_part_on_workbench(graph, "steam_source")
		"place_signal_loom":
			return _has_part_on_workbench(graph, "signal_loom")
		"place_weight_wheel":
			return _has_part_on_workbench(graph, "weight_wheel")
		"place_spyglass":
			return _has_part_on_workbench(graph, "spyglass")
		"connect_components":
			return graph.get_connection_list().size() > 0
		_:
			return false

func _has_part_on_workbench(graph: Node, part_id: String) -> bool:
	"""Check if a specific part type exists on the workbench"""
	for child in graph.get_children():
		if child.has_method("get") and "part_id" in child:
			if child.part_id == part_id:
				return true
	return false
