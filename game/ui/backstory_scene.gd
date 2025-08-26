extends Control

## Enhanced Backstory Scene - Animated story presentation with parallax backgrounds
# Shows the game's lore with typewriter effect and parallax backgrounds
# Reusable for different chapters by setting chapter_number

@onready var background_layers := $BackgroundLayers
@onready var story_card := $StoryCard
@onready var story_text := $StoryCard/VBoxContainer/ScrollContainer/StoryText
@onready var continue_btn := $StoryCard/VBoxContainer/ButtonContainer/ContinueButton
@onready var skip_btn := $StoryCard/VBoxContainer/ButtonContainer/SkipButton
@onready var typewriter_timer := $TypewriterTimer
@onready var parallax_timer := $ParallaxTimer

var full_story_text := ""
var current_char_index := 0
var is_typing := false
var chapter_number := 1  # Default to chapter 1
var background_textures := {}
var parallax_speeds := [0.1, 0.05, 0.02, 0.01]  # Different speeds for each layer

func _ready() -> void:
	# Wait for the scene to be fully ready
	await get_tree().process_frame
	
	print("Backstory scene ready, checking nodes...")
	
	# Verify all required nodes are available
	if not story_text:
		push_error("StoryText node not found!")
		return
	else:
		print("StoryText node found successfully")
		
	if not continue_btn:
		push_error("ContinueButton node not found!")
		return
	else:
		print("ContinueButton node found successfully")
		
	if not skip_btn:
		push_error("SkipButton node not found!")
		return
	else:
		print("SkipButton node found successfully")
		
	if not background_layers:
		push_error("BackgroundLayers node not found!")
		return
	else:
		print("BackgroundLayers node found successfully")
	
	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_on_skip_pressed)
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	parallax_timer.timeout.connect(_on_parallax_tick)
	
	# Ensure RichTextLabel parses BBCode
	story_text.bbcode_enabled = true
	
	# Load the backstory
	_load_backstory()
	
	# Start typewriter effect
	_start_typewriter_effect()
	
	# Start parallax effect
	_start_parallax_effect()
	
	# Setup default backgrounds for chapter 1
	_setup_backgrounds()

	# Apply icons
	_apply_backstory_icons()

func set_chapter(chapter: int) -> void:
	chapter_number = chapter
	_setup_backgrounds()

func _setup_backgrounds() -> void:
	# Verify background_layers is available
	if not background_layers:
		push_error("BackgroundLayers not available for setup!")
		return
		
	print("Setting up backgrounds for chapter ", chapter_number)
		
	# Clear existing backgrounds
	for child in background_layers.get_children():
		child.queue_free()
	
	# Load background layers for the specified chapter
	var chapter_path := "res://assets/backrounds/" + str(chapter_number) + "/"
	
	# Check what background files exist for this chapter
	var dir := DirAccess.open(chapter_path)
	if not dir:
		print("Warning: Could not open background directory for chapter ", chapter_number)
		return
	
	var files := dir.get_files()
	print("Found background files: ", files)
	var layer_count := 0
	
	# Create background layers (we'll use up to 4 numbered layers)
	for i in range(1, 5):
		var filename := str(i) + ".png"
		var filepath := chapter_path + filename
		
		if FileAccess.file_exists(filepath):
			var texture := load(filepath) as Texture2D
			if texture:
				var layer := TextureRect.new()
				layer.name = "Layer" + str(i)
				layer.texture = texture
				layer.expand_mode = 1  # EXPAND_FILL
				layer.anchors_preset = Control.PRESET_FULL_RECT
				layer.anchor_right = 1.0
				layer.anchor_bottom = 1.0
				layer.grow_horizontal = 2
				layer.grow_vertical = 2
				
				# Set initial position for parallax effect
				layer.position = Vector2.ZERO
				
				background_layers.add_child(layer)
				background_textures[layer] = texture
				layer_count += 1
				print("Created background layer ", i, " for chapter ", chapter_number)
	
	# If no numbered layers found, try to use orig.png
	if layer_count == 0:
		print("No numbered layers found, trying orig.png fallback")
		var orig_path := chapter_path + "orig.png"
		if FileAccess.file_exists(orig_path):
			var texture := load(orig_path) as Texture2D
			if texture:
				var layer := TextureRect.new()
				layer.name = "Background"
				layer.texture = texture
				layer.expand_mode = 1  # EXPAND_FILL
				layer.anchors_preset = Control.PRESET_FULL_RECT
				layer.anchor_right = 1.0
				layer.anchor_bottom = 1.0
				layer.grow_horizontal = 2
				layer.grow_vertical = 2
				background_layers.add_child(layer)
				background_textures[layer] = texture
				print("Created fallback background using orig.png")
		else:
			print("No orig.png found either, using no background")
	
	print("Background setup complete. Total layers: ", layer_count)

func _start_parallax_effect() -> void:
	parallax_timer.wait_time = 0.016  # ~60 FPS
	parallax_timer.start()

func _on_parallax_tick() -> void:
	if not background_layers:
		return
		
	var children := background_layers.get_children()
	for i in range(children.size()):
		var child := children[i] as TextureRect
		if child and i < parallax_speeds.size():
			var speed: float = parallax_speeds[i]
			var new_x := fmod(child.position.x - speed, 100)  # Loop every 100 pixels
			child.position.x = new_x

func _apply_backstory_icons() -> void:
	if not skip_btn or not continue_btn:
		push_warning("Buttons not available for icon loading!")
		return
		
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
	# Try to load chapter-specific backstory first
	var chapter_backstory_path := "res://docs/act-" + _get_act_name(chapter_number) + ".md"
	var backstory_path := "res://docs/backstory.md"
	
	var file_path := ""
	if FileAccess.file_exists(chapter_backstory_path):
		file_path = chapter_backstory_path
	elif FileAccess.file_exists(backstory_path):
		file_path = backstory_path
	
	if file_path != "":
		var file := FileAccess.open(file_path, FileAccess.READ)
		var raw_text := file.get_as_text()
		file.close()
		
		# Convert markdown to BBCode for RichTextLabel
		full_story_text = _convert_markdown_to_bbcode(raw_text)
	else:
		# Fallback story if file doesn't exist
		full_story_text = _get_fallback_story()

func _get_act_name(chapter: int) -> String:
	match chapter:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		5: return "V"
		6: return "VI"
		_: return "I"

func _get_fallback_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Chapter """ + str(chapter_number) + """ ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]A New Chapter Begins[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]Welcome to Chapter """ + str(chapter_number) + """ of your AItherworks journey![/b][/color][/center]

[color=burlywood]In this chapter, you will discover new mysteries of the steam-powered learning machines and face challenges that will test your understanding of the ancient arts of artificial intelligence.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🎯 Your Mission[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Prepare yourself, apprentice. The Guild of AItherworks Engineers has prepared new lessons, new machines, and new discoveries that await your skilled hands and curious mind.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 Ready to Begin?[/b][/font_size][/color]
[font_size=22]
[color=burlywood]The steam is rising, the gears are turning, and the aether is flowing. Your journey into the mysteries of learning machines continues...[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]Chapter """ + str(chapter_number) + """ - The Adventure Continues[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _convert_markdown_to_bbcode(markdown: String) -> String:
	var bbcode := markdown
	
	# Add chapter header
	bbcode = """[center][color=goldenrod][font_size=42]⚙️ Chapter """ + str(chapter_number) + """ ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]A New Chapter Begins[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

""" + bbcode
	
	# Convert markdown headers to BBCode with steampunk styling
	bbcode = bbcode.replace("## ", "[color=lightblue][font_size=26][b]🏭 ")
	bbcode = bbcode.replace("# ", "[color=orange][font_size=32][b]📜 ")
	bbcode = bbcode.replace("### ", "[color=lightgreen][font_size=22][b]⚙️ ")
	
	# Add closing tags for headers and improve formatting
	var lines := bbcode.split("\n")
	for i in range(lines.size()):
		if lines[i].begins_with("[color=orange][font_size=32][b]📜"):
			lines[i] += "[/b][/font_size][/color]"
		elif lines[i].begins_with("[color=lightblue][font_size=26][b]🏭"):
			lines[i] += "[/b][/font_size][/color]"
		elif lines[i].begins_with("[color=lightgreen][font_size=22][b]⚙️"):
			lines[i] += "[/b][/font_size][/color]"
		# Add steampunk flavor to regular paragraphs
		elif lines[i].strip_edges() != "" and not lines[i].begins_with("["):
			lines[i] = "[color=burlywood][font_size=22]" + lines[i] + "[/font_size][/color]"
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
	if not story_text or not continue_btn:
		push_error("Required nodes not available for typewriter effect!")
		return
		
	current_char_index = 0
	is_typing = true
	# Pre-render full BBCode and reveal characters gradually
	story_text.bbcode_text = full_story_text
	story_text.visible_characters = 0
	continue_btn.disabled = true
	continue_btn.text = "⏳ Reading..."
	typewriter_timer.start()

func _on_typewriter_tick() -> void:
	if not story_text:
		push_error("StoryText not available for typewriter tick!")
		return
		
	# Use the RichTextLabel's visible characters to gradually reveal pre-rendered BBCode
	var total_chars: int = story_text.get_total_character_count()
	if current_char_index < total_chars:
		current_char_index += 1
		story_text.visible_characters = current_char_index
		
		# Auto-scroll to bottom
		var scroll_container := $StoryCard/VBoxContainer/ScrollContainer
		if scroll_container and scroll_container.get_v_scroll_bar():
			await get_tree().process_frame
			scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	else:
		_finish_typewriter()

func _finish_typewriter() -> void:
	if not story_text or not continue_btn:
		push_error("Required nodes not available for finishing typewriter!")
		return
		
	is_typing = false
	typewriter_timer.stop()
	# Show all characters of the pre-rendered BBCode
	story_text.visible_characters = -1
	continue_btn.disabled = false
	continue_btn.text = "⚙️ Begin Chapter " + str(chapter_number)

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
