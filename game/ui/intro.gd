extends Control

@onready var body := $Panel/Body
@onready var start_btn := $Panel/StartButton

func _ready() -> void:
    start_btn.pressed.connect(_on_start)
    # Load backstory text
    var path := "res://docs/backstory.md"
    if FileAccess.file_exists(path):
        var f := FileAccess.open(path, FileAccess.READ)
        if f:
            var text := f.get_as_text()
            body.text = text

func _on_start() -> void:
    get_tree().change_scene_to_file("res://game/ui/workbench.tscn")

