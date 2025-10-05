extends Control

## Enhanced Backstory Scene - Animated story presentation with parallax backgrounds
# Shows the game's lore with typewriter effect and parallax backgrounds
# Reusable for different chapters by setting chapter_number

@onready var background_layers := $BackgroundLayers
@onready var story_card := $StoryCard
@onready var story_text := $StoryCard/VBoxContainer/StoryText
@onready var page_indicator := $StoryCard/VBoxContainer/PageIndicator
@onready var continue_btn := $StoryCard/VBoxContainer/ButtonContainer/ContinueButton
@onready var skip_btn := $StoryCard/VBoxContainer/ButtonContainer/SkipButton
@onready var typewriter_timer := $TypewriterTimer
@onready var parallax_timer := $ParallaxTimer

var story_pages := []
var current_page := 0
var current_char_index := 0
var is_typing := false
var chapter_number := 1  # Default to chapter 1
var background_textures := {}
var parallax_speeds := [0.1, 0.05, 0.02, 0.01]  # Different speeds for each layer

func _ready() -> void:
	# Wait for the scene to be fully ready
	await get_tree().process_frame
	
	# Verify all required nodes are available
	if not story_text:
		push_error("StoryText node not found!")
		return
	if not page_indicator:
		push_error("PageIndicator node not found!")
		return
	if not continue_btn:
		push_error("ContinueButton node not found!")
		return
	if not skip_btn:
		push_error("SkipButton node not found!")
		return
	if not background_layers:
		push_error("BackgroundLayers node not found!")
		return
	
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
				layer.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				layer.anchors_preset = Control.PRESET_FULL_RECT
				layer.anchor_right = 1.0
				layer.anchor_bottom = 1.0
				layer.grow_horizontal = Control.GROW_DIRECTION_BOTH
				layer.grow_vertical = Control.GROW_DIRECTION_BOTH
				
				# Set initial position for parallax effect - make layers wider than screen
				layer.position = Vector2.ZERO
				layer.custom_minimum_size = Vector2(1200, 720)  # Wider than screen for parallax
				
				background_layers.add_child(layer)
				background_textures[layer] = texture
				layer_count += 1
	
	# If no numbered layers found, try to use orig.png
	if layer_count == 0:
		var orig_path := chapter_path + "orig.png"
		if FileAccess.file_exists(orig_path):
			var texture := load(orig_path) as Texture2D
			if texture:
				var layer := TextureRect.new()
				layer.name = "Background"
				layer.texture = texture
				layer.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				layer.anchors_preset = Control.PRESET_FULL_RECT
				layer.anchor_right = 1.0
				layer.anchor_bottom = 1.0
				layer.grow_horizontal = Control.GROW_DIRECTION_BOTH
				layer.grow_vertical = Control.GROW_DIRECTION_BOTH
				layer.custom_minimum_size = Vector2(1200, 720)  # Wider than screen for parallax
				background_layers.add_child(layer)
				background_textures[layer] = texture

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
			# Move layers left for parallax effect, loop when they go off-screen
			var new_x := fmod(child.position.x - speed, 200)  # Loop every 200 pixels
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
	# Load chapter-specific story content and break into pages
	var full_story = _get_chapter_story(chapter_number)
	story_pages = _break_story_into_pages(full_story)
	current_page = 0

# Act name function removed - not needed for direct story loading

func _break_story_into_pages(full_story: String) -> Array:
	# Break story into pages at natural break points (horizontal rules, icon breaks)
	var pages := []
	var page_text := ""
	var lines := full_story.split("\n")
	
	for line in lines:
		# Check for page break indicators
		if line.contains("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━") or \
		   line.contains("⚡ ⚙️ ⚡") or \
		   line.contains("🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩"):
			# End current page and start new one
			if page_text.strip_edges() != "":
				pages.append(page_text.strip_edges())
				page_text = ""
			# Add the break line to the new page
			page_text += line + "\n"
		else:
			page_text += line + "\n"
	
	# Add the final page
	if page_text.strip_edges() != "":
		pages.append(page_text.strip_edges())
	
	# If no pages were created, just return the full story as one page
	if pages.size() == 0:
		pages.append(full_story)
	
	return pages

func _get_chapter_story(chapter: int) -> String:
	match chapter:
		1: return _get_act_1_story()
		2: return _get_act_2_story()
		3: return _get_act_3_story()
		4: return _get_act_4_story()
		5: return _get_act_5_story()
		6: return _get_act_6_story()
		_: return _get_fallback_story()

func _get_act_1_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act I - Cinders & Sums ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]Vectors, Loss, and the First Steps of Backpropagation[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]Welcome to the Foundry, Young Apprentice![/b][/color][/center]

[color=burlywood]The oil-lamp mornings of Dock-Ward await you. Here, among the ledger dust and honest mathematics, you will learn the fundamental arts of the AItherworks Engineers.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🔍 Your First Lessons[/b][/font_size][/color]
[font_size=22]
[color=burlywood]You will begin with simple parts and honest math: Signal Looms that weave patterns, Weight Wheels that adjust themselves, and the mysterious art of backpropagation with Stochastic Gradient Descent.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Path Ahead[/b][/font_size][/color]
[font_size=22]
[color=burlywood]From vectors and scaling to loss functions and learning rates, you will build machines that think. The steam is rising, the gears are turning, and your journey into artificial intelligence begins now.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]May your gears turn true and your steam pressure hold steady[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _get_act_2_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act II - The Cogwright's Challenge ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]Advanced Patterns and the Art of Composition[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]Your Skills Grow, Apprentice![/b][/color][/center]

[color=burlywood]The Guild recognizes your progress. Now you face more complex challenges: combining multiple inputs, creating sophisticated patterns, and mastering the art of machine composition.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🎯 New Challenges Await[/b][/font_size][/color]
[font_size=22]
[color=burlywood]You will learn to stamp the cog with precision, navigate the archives of knowledge, and discover the deeper mysteries that lie within the steam-powered learning machines.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Journey Continues[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Your understanding deepens, your machines grow more sophisticated, and the secrets of artificial intelligence reveal themselves layer by layer.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]The Guild watches with pride as you advance[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _get_act_3_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act III - Keys in the Looking Glass ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]Transformation and the Mini-Transformer[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]A New Realm Opens, Master Engineer![/b][/color][/center]

[color=burlywood]You have reached a pivotal moment in your journey. The Looking Glass reveals new dimensions of understanding, and the Mini-Transformer awaits your skilled hands.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🔑 Unlock New Powers[/b][/font_size][/color]
[font_size=22]
[color=burlywood]The transformation architecture opens doors to understanding that were previously hidden. Your machines will now possess the ability to see patterns in ways that transcend simple addition and multiplication.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Looking Glass Beckons[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Step through the mirror, engineer. A world of attention mechanisms, self-attention, and the true power of the transformer architecture awaits your discovery.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]The keys are in your hands[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _get_act_4_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act IV - Forger vs Examiner ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]The Mode Collapse Clinic and Advanced Ethics[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]The Ethical Dimensions Emerge, Wise Engineer![/b][/color][/center]

[color=burlywood]Your journey takes a profound turn. Beyond the mechanics of learning machines, you now confront the deeper questions of what these machines should learn, and how they should behave.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]⚖️ The Balance of Power[/b][/font_size][/color]
[font_size=22]
[color=burlywood]The Forger creates, the Examiner judges. In this delicate dance, you will learn to build machines that not only learn efficiently, but learn wisely and ethically.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Ethical Governor[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Your machines will now possess conscience, restraint, and the ability to make ethical decisions. The steam-powered future of AI requires not just intelligence, but wisdom.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]Forge with wisdom, examine with care[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _get_act_5_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act V - The Teacher's Whisper ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]Press to Fit and Advanced Training[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]The Master's Voice Guides You, Esteemed Engineer![/b][/color][/center]

[color=burlywood]You have reached the advanced levels of the Guild. The Teacher's Whisper carries secrets of optimization, fine-tuning, and the subtle art of making machines that truly understand.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🎯 Precision and Mastery[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Press to fit, adjust with care, and listen to the subtle feedback of your machines. This is where true mastery emerges - in the details that separate good from great.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Whisper of Wisdom[/b][/font_size][/color]
[font_size=22]
[color=burlywood]The ancient knowledge flows through you now. Your machines will possess not just learning ability, but the refined understanding that comes from generations of accumulated wisdom.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]Listen carefully to the Teacher's Whisper[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

func _get_act_6_story() -> String:
	return """[center][color=goldenrod][font_size=42]⚙️ Act VI - The Charter ⚙️[/font_size][/color][/center]

[center][color=peru][font_size=28][i]Citywide Dispatch and the Final Challenge[/i][/font_size][/color][/center]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[font_size=24]
[center][color=lightblue][b]The Culmination of Your Journey, Master Engineer![/b][/color][/center]

[color=burlywood]You stand at the pinnacle of the Guild's teachings. The citywide dispatch system awaits your mastery, and the Charter of AItherworks Engineering calls for your signature.[/color]
[/font_size]

[center]⚡ ⚙️ ⚡ ⚙️ ⚡ ⚙️ ⚡[/center]

[color=lightblue][font_size=26][b]🏛️ The Final Challenge[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Coordinate the entire city's learning machines, manage the flow of knowledge across districts, and prove that you are worthy of the highest honor the Guild can bestow.[/color]
[/font_size]

[center]🔧 ⚙️ 🔩 ⚙️ 🔧 ⚙️ 🔩[/center]

[color=goldenrod][font_size=24][b]🌟 The Charter Awaits[/b][/font_size][/color]
[font_size=22]
[color=burlywood]Your name will be inscribed in the great ledger of AItherworks Engineers. You will join the ranks of those who have mastered the art of steam-powered artificial intelligence.[/color]
[/font_size]

[center]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/center]

[center][color=goldenrod][i][font_size=24]The Charter of Mastery awaits your signature[/font_size][/i][/color][/center]

[center]⚙️ 🔧 ⚙️ 🔧 ⚙️ 🔧 ⚙️[/center]"""

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

# Markdown conversion removed - using direct BBCode stories instead

func _start_typewriter_effect() -> void:
	if not story_text or not continue_btn:
		push_error("Required nodes not available for typewriter effect!")
		return
		
	current_char_index = 0
	is_typing = true
	# Show current page
	_show_current_page()
	continue_btn.disabled = true
	continue_btn.text = "⏳ Reading..."
	typewriter_timer.start()

func _show_current_page() -> void:
	if not story_text or current_page >= story_pages.size():
		return
	
	story_text.bbcode_text = story_pages[current_page]
	story_text.visible_characters = 0
	current_char_index = 0
	
	# Update page indicator
	if page_indicator:
		page_indicator.text = "Page " + str(current_page + 1) + " of " + str(story_pages.size())

func _on_typewriter_tick() -> void:
	if not story_text:
		push_error("StoryText not available for typewriter tick!")
		return
		
	# Use the RichTextLabel's visible characters to gradually reveal current page
	var total_chars: int = story_text.get_total_character_count()
	if current_char_index < total_chars:
		current_char_index += 1
		story_text.visible_characters = current_char_index
	else:
		_finish_typewriter()

func _finish_typewriter() -> void:
	if not story_text or not continue_btn:
		push_error("Required nodes not available for finishing typewriter!")
		return
		
	is_typing = false
	typewriter_timer.stop()
	# Show all characters of the current page
	story_text.visible_characters = -1
	continue_btn.disabled = false
	
	# Check if there are more pages
	if current_page < story_pages.size() - 1:
		continue_btn.text = "⚙️ Continue Reading"
	else:
		continue_btn.text = "⚙️ Begin Chapter " + str(chapter_number)

func _on_skip_pressed() -> void:
	# Skip button always skips the entire backstory
	_fade_to_tutorial()

func _on_continue_pressed() -> void:
	if is_typing:
		_finish_typewriter()
	elif current_page < story_pages.size() - 1:
		# Go to next page
		current_page += 1
		_start_typewriter_effect()
	else:
		# Last page, go to tutorial
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
			_on_continue_pressed()
	
	# Allow spacebar or enter to continue
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_on_continue_pressed()
