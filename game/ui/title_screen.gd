extends Control

## Title Screen - Main Menu System
# Handles navigation between game sections and settings

@onready var new_game_btn := $MainContainer/MenuPanel/MenuContent/NewGameButton
@onready var load_game_btn := $MainContainer/MenuPanel/MenuContent/LoadGameButton
@onready var settings_btn := $MainContainer/MenuPanel/MenuContent/SettingsButton
@onready var quit_btn := $MainContainer/MenuPanel/MenuContent/QuitButton

@onready var settings_dialog := $SettingsDialog
@onready var master_volume_slider := $SettingsDialog/VBox/MasterVolumeSlider
@onready var music_volume_slider := $SettingsDialog/VBox/MusicVolumeSlider
@onready var fullscreen_toggle := $SettingsDialog/VBox/FullscreenToggle
@onready var ui_scale_slider := $SettingsDialog/VBox/UIScaleSlider

var save_file_path := "user://signalworks_save.dat"

func _ready() -> void:
	# Connect menu buttons
	new_game_btn.pressed.connect(_on_new_game_pressed)
	load_game_btn.pressed.connect(_on_load_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# Connect settings controls
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	
	# Check if save file exists to enable/disable load button
	_update_load_button()
	
	# Load and apply saved settings
	_load_settings()
	
	# Entrance animation
	_animate_entrance()

func _animate_entrance() -> void:
	# Animate panels using scale and fade for a smoother effect
	var title_panel := $MainContainer/TitlePanel
	var menu_panel := $MainContainer/MenuPanel
	
	# Start with panels invisible and small
	title_panel.modulate = Color.TRANSPARENT
	menu_panel.modulate = Color.TRANSPARENT
	title_panel.scale = Vector2(0.8, 0.8)
	menu_panel.scale = Vector2(0.8, 0.8)
	
	# Create entrance animation
	var tween := create_tween()
	tween.set_parallel(true)
	
	# Animate title panel
	tween.tween_property(title_panel, "modulate", Color.WHITE, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_panel, "scale", Vector2.ONE, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Animate menu panel with delay
	tween.tween_property(menu_panel, "modulate", Color.WHITE, 0.6).set_ease(Tween.EASE_OUT).set_delay(0.3)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.3)

func _on_new_game_pressed() -> void:
	print("Starting new apprenticeship...")
	_fade_to_scene("res://game/ui/backstory_scene.tscn")

func _on_load_game_pressed() -> void:
	if FileAccess.file_exists(save_file_path):
		print("Loading saved journey...")
		# Load save data here
		_fade_to_scene("res://game/ui/workbench.tscn")
	else:
		print("No saved journey found")

func _on_settings_pressed() -> void:
	print("Opening settings dialog...")
	settings_dialog.popup_centered()
	# Ensure the dialog is modal and exclusive
	settings_dialog.grab_focus()

func _on_quit_pressed() -> void:
	print("Farewell, apprentice...")
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	get_tree().quit()

func _fade_to_scene(scene_path: String) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)

func _update_load_button() -> void:
	load_game_btn.disabled = not FileAccess.file_exists(save_file_path)
	if load_game_btn.disabled:
		load_game_btn.tooltip_text = "No saved journey found"
	else:
		load_game_btn.tooltip_text = "Continue your apprenticeship"

# Settings handlers
func _on_master_volume_changed(value: float) -> void:
	# Set master volume bus
	var bus_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))

func _on_music_volume_changed(value: float) -> void:
	# Set music volume bus (if it exists)
	var bus_index := AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))

func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_ui_scale_changed(value: float) -> void:
	print("UI scale changed to: ", value)
	# Use the proper Godot 4 method for UI scaling
	get_window().content_scale_factor = value

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume_slider.value)
	config.set_value("audio", "music_volume", music_volume_slider.value)
	config.set_value("display", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("display", "ui_scale", ui_scale_slider.value)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume_slider.value = config.get_value("audio", "master_volume", 80.0)
		music_volume_slider.value = config.get_value("audio", "music_volume", 70.0)
		fullscreen_toggle.button_pressed = config.get_value("display", "fullscreen", false)
		ui_scale_slider.value = config.get_value("display", "ui_scale", 1.4)
		
		# Apply the loaded settings
		_on_master_volume_changed(master_volume_slider.value)
		_on_music_volume_changed(music_volume_slider.value)
		_on_fullscreen_toggled(fullscreen_toggle.button_pressed)
		_on_ui_scale_changed(ui_scale_slider.value)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()
		get_tree().quit()
