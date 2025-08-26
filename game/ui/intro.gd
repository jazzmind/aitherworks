extends Control

@onready var start_btn := $Panel/StartButton
@onready var backstory_btn := $Panel/BackstoryButton

func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	backstory_btn.pressed.connect(_on_backstory)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://game/ui/workbench.tscn")

func _on_backstory() -> void:
	# Show the enhanced backstory scene for chapter 1
	get_tree().change_scene_to_file("res://game/ui/backstory_scene.tscn")
	
	# Wait for the scene to be ready, then set the chapter
	await get_tree().process_frame
	
	# Find the backstory scene and set the chapter
	var backstory_scene = get_tree().current_scene
	if backstory_scene.has_method("set_chapter"):
		backstory_scene.set_chapter(1)

