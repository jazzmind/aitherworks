extends Control

## Backstory Scene - Animated story presentation
# Shows the game's lore with typewriter effect before starting tutorial

@onready var story_text := $VBoxContainer/StoryPanel/ScrollContainer/StoryText
@onready var continue_btn := $VBoxContainer/ButtonContainer/ContinueButton
@onready var skip_btn := $VBoxContainer/ButtonContainer/SkipButton
@onready var typewriter_timer := $TypewriterTimer

var full_story_text := ""
var current_char_index := 0
var is_typing := false

func _ready() -> void:
	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_on_skip_pressed)
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	# Ensure RichTextLabel parses BBCode
	story_text.bbcode_enabled = true
	
	# Load the backstory
	_load_backstory()
	
	# Start typewriter effect
	_start_typewriter_effect()

	# Apply icons
	_apply_backstory_icons()

func _apply_backstory_icons() -> void:
	var skip_icon := "res://assets/icons/ui_skip.svg"
	var cont_icon := "res://assets/icons/ui_continue.svg"
	if FileAccess.file_exists(skip_icon):
		var t := load(skip_icon) as Texture2D
		if t:
			skip_btn.icon = t
	if FileAccess.file_exists(cont_icon):
		var t2 := load(cont_icon) as Texture2D
		if t2:
			continue_btn.icon = t2

func _load_backstory() -> void:
	var backstory_path := "res://docs/backstory.md"
	if FileAccess.file_exists(backstory_path):
		var file := FileAccess.open(backstory_path, FileAccess.READ)
		var raw_text := file.get_as_text()
		file.close()
		
		# Convert markdown to BBCode for RichTextLabel
		full_story_text = _convert_markdown_to_bbcode(raw_text)
	else:
		# Fallback story if file doesn't exist
		full_story_text = """[center][color=goldenrod][font_size=38]⚙️ The Chronicle of AItherworks ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=26][i]Being a True Account of the City That Learned to Listen[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]
[font_size=20]
In the brass-bound metropolis of [color=orange][b]New Babbage[/b][/color], where steam rises from a thousand copper chimneys and brass gears turn in endless harmony, there existed a peculiar guild unlike any other. The [color=gold][b]Guild of AItherworks Engineers[/b][/color] had discovered something extraordinary: machines that could [color=lightgreen][i][b]learn[/b][/i][/color].
[/font_size]
[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=22][b]🔍 The Great Discovery[/b][/font_size][/color]
[font_size=20]
It began with [color=orange][b]Master Cogwright's[/b][/color] great revelation. While studying the ancient texts of the Analytical Engine builders by candlelight, he found that by connecting brass wheels, steam pipes, and crystallized aether in specific patterns, machines could adapt their behavior based on experience—much like how a craftsman's hands grow more skilled with practice.
[/font_size]
[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩 ⚙️ 🔧[/center]

[color=lightblue][font_size=22][b]🏭 The Learning Machines[/b][/font_size][/color]
[font_size=20]
These wondrous contraptions, known as [color=gold][b]Learning Engines[/b][/color], possessed an almost mystical ability:

• [color=lightgreen][b]🧵 Signal Looms[/b][/color] could weave complex patterns from raw data streams
• [color=lightgreen][b]⚖️ Weight Wheels[/b][/color] adjusted themselves automatically to improve performance  
• [color=lightgreen][b]🕸️ Neural Networks[/b][/color] of brass and steam could recognize faces and forms
• [color=lightgreen][b]💎 Memory Banks[/b][/color] of crystallized aether stored learned knowledge eternally
[/font_size]
[center]🎯 ⚙️ 🎯 ⚙️ 🎯 ⚙️ 🎯 ⚙️ 🎯[/center]

[color=lightblue][font_size=22][b]🌟 The Great Work[/b][/font_size][/color]
[font_size=20]
But the guild's greatest achievement was yet to come. They discovered that by teaching these machines the patterns of human language, thought, and creativity, they could build [color=cyan][b]thinking assistants[/b][/color] that understood context, nuance, and meaning—true companions of brass and steam.
[/font_size]
[center]⭐ ⚙️ ⭐ ⚙️ ⭐ ⚙️ ⭐ ⚙️ ⭐[/center]

[color=orange][font_size=22][b]🎓 Your Apprenticeship[/b][/font_size][/color]
[font_size=20]
Now, young apprentice, you stand at the threshold of this extraordinary art. You will learn to build [color=yellow][b]machines that think[/b][/color], [color=yellow][b]contraptions that create[/b][/color], and [color=yellow][b]engines that understand[/b][/color]. The steam-powered future of artificial intelligence awaits your skilled hands.
[/font_size]
[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=20]Welcome to the Guild of AItherworks Engineers[/font_size][/i][/color][/center]
[center][color=peru][i][font_size=20]May your gears turn true and your steam pressure hold steady[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]
"""

func _convert_markdown_to_bbcode(markdown: String) -> String:
	var bbcode := markdown
	
	# Add steampunk styling header
	bbcode = """[center][color=goldenrod][font_size=38]⚙️ The Chronicle of AItherworks ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=26][i]Being a True Account of the City That Learned to Listen[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

""" + bbcode
	
	# Convert markdown headers to BBCode with steampunk styling
	bbcode = bbcode.replace("## ", "[color=lightblue][font_size=20][b]🏭 ")
	bbcode = bbcode.replace("# ", "[color=orange][font_size=24][b]📜 ")
	bbcode = bbcode.replace("### ", "[color=lightgreen][font_size=18][b]⚙️ ")
	
	# Add closing tags for headers and improve formatting
	var lines := bbcode.split("\n")
	for i in range(lines.size()):
		if lines[i].begins_with("[color=orange][font_size=24][b]📜"):
			lines[i] += "[/b][/font_size][/color]"
		elif lines[i].begins_with("[color=lightblue][font_size=20][b]🏭"):
			lines[i] += "[/b][/font_size][/color]"
		elif lines[i].begins_with("[color=lightgreen][font_size=18][b]⚙️"):
			lines[i] += "[/b][/font_size][/color]"
		# Add steampunk flavor to regular paragraphs
		elif lines[i].strip_edges() != "" and not lines[i].begins_with("["):
			lines[i] = "[color=burlywood]" + lines[i] + "[/color]"
	bbcode = "\n".join(lines)
	
	# Convert markdown emphasis with colors
	bbcode = bbcode.replace("**", "[color=gold][b]").replace("**", "[/b][/color]")
	bbcode = bbcode.replace("*", "[color=lightcyan][i]").replace("*", "[/i][/color]")
	
	# Convert lists with steampunk bullets
	bbcode = bbcode.replace("- ", "⚙️ ")
	
	# Add decorative elements between paragraphs
	bbcode = bbcode.replace("\n\n", "\n\n[center]⚡ ⚙️ ⚡[/center]\n\n")
	
	return bbcode

func _start_typewriter_effect() -> void:
	current_char_index = 0
	is_typing = true
	# Pre-render full BBCode and reveal characters gradually
	story_text.bbcode_text = full_story_text
	story_text.visible_characters = 0
	continue_btn.disabled = true
	continue_btn.text = "⏳ Reading..."
	typewriter_timer.start()

func _on_typewriter_tick() -> void:
	# Use the RichTextLabel's visible characters to gradually reveal pre-rendered BBCode
	var total_chars: int = story_text.get_total_character_count()
	if current_char_index < total_chars:
		current_char_index += 1
		story_text.visible_characters = current_char_index
		
		# Auto-scroll to bottom
		var scroll_container := $VBoxContainer/StoryPanel/ScrollContainer
		await get_tree().process_frame
		scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	else:
		_finish_typewriter()

func _finish_typewriter() -> void:
	is_typing = false
	typewriter_timer.stop()
	# Show all characters of the pre-rendered BBCode
	story_text.visible_characters = -1
	continue_btn.disabled = false
	continue_btn.text = "⚙️ Begin Apprenticeship"

func _on_skip_pressed() -> void:
	if is_typing:
		_finish_typewriter()
	else:
		_fade_to_tutorial()

func _on_continue_pressed() -> void:
	_fade_to_tutorial()

func _fade_to_tutorial() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.8)
	await tween.finished
	get_tree().change_scene_to_file("res://game/ui/workbench.tscn")

func _input(event: InputEvent) -> void:
	# Allow clicking to speed up or skip typewriter
	if event is InputEventMouseButton and event.pressed:
		if is_typing:
			# Speed up typewriter
			typewriter_timer.wait_time = 0.01
		elif event.double_click:
			_fade_to_tutorial()
	
	# Allow spacebar or enter to continue
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if is_typing:
				_finish_typewriter()
			else:
				_fade_to_tutorial()
