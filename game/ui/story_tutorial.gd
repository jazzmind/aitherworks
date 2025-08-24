extends Control

var _workbench: Control

@onready var _overlay: ColorRect = $DialogueOverlay
@onready var _dialog_box: Panel = $DialogueBox
@onready var _portrait: TextureRect = $DialogueBox/HBox/CharacterPortrait
@onready var _name_label: Label = $DialogueBox/HBox/VBox/CharacterName
@onready var _dialog_text: RichTextLabel = $DialogueBox/HBox/VBox/DialogueText
@onready var _continue_btn: Button = $DialogueBox/HBox/VBox/ContinueButton
@onready var _action_highlight: ColorRect = $ActionHighlight

func _ready() -> void:
	_overlay.visible = false
	_dialog_box.visible = false
	_action_highlight.visible = false
	_continue_btn.pressed.connect(_hide_dialog)

func set_workbench(w: Control) -> void:
	_workbench = w

func start_story_tutorial() -> void:
	_add_chat_message("master_cogwright", "Master Cogwright", "Welcome, apprentice. First, select 'act_I_l1_dawn_in_dock_ward.yaml' from the dropdown, then press Load.")
	_highlight_control(_get_workbench_control("MarginContainer/MainLayout/CenterPanel/TopBar/LevelSelect"))

func start_level_chapter(level_id: String) -> void:
	if level_id == "act_I_l1_dawn_in_dock_ward":
		_add_chat_message("master_cogwright", "Master Cogwright", "For this trial, keep steam modest and inference quick. When ready, press Evaluate.")
	elif level_id == "act_I_l3_the_manometer_hisses":
		_add_chat_message("aether_sage", "Aether Sage", "Watch dye flow back. Tune LR, then Evaluate to convince the Inspectorate.")

func notify_action(action: String) -> void:
	match action:
		"select_level":
			_highlight_control(_get_workbench_control("MarginContainer/MainLayout/CenterPanel/TopBar/LevelSelect"))
			_add_chat_message("master_cogwright", "Master Cogwright", "Good. Now press Load to prepare the workbench.")
		"load_level":
			_action_highlight.visible = false
			_highlight_control(_get_workbench_control("MarginContainer/MainLayout/CenterPanel/TopBar/LoadButton"), false)
			_add_chat_message("master_cogwright", "Master Cogwright", "Parts are authorized. Place a Steam Source, a Signal Loom, and a Weight Wheel. Then connect them.")
		_:
			pass

func _add_chat_message(character_id: String, display_name: String, text: String) -> void:
	_name_label.text = display_name
	_dialog_text.text = text
	var tex_path := _portrait_path_for(character_id)
	if FileAccess.file_exists(tex_path):
		var tex := load(tex_path)
		if tex is Texture2D:
			_portrait.texture = tex
	else:
		_portrait.texture = null
	_overlay.visible = true
	_dialog_box.visible = true

func _hide_dialog() -> void:
	_overlay.visible = false
	_dialog_box.visible = false

func _portrait_path_for(character_id: String) -> String:
	match character_id:
		"master_cogwright":
			return "res://assets/characters/master_cogwright.svg"
		"aether_sage":
			return "res://assets/characters/aether_sage.svg"
		"apprentice":
			return "res://assets/characters/apprentice_player.svg"
		_:
			return "res://assets/characters/apprentice_player.svg"

func _get_workbench_control(path: String) -> Control:
	if _workbench == null:
		return null
	var n := _workbench.get_node_or_null(path)
	return n if n is Control else null

func _highlight_control(ctrl: Control, should_show: bool = true) -> void:
	if ctrl == null:
		_action_highlight.visible = false
		return
	_action_highlight.visible = should_show
	if should_show:
		var r := ctrl.get_global_rect()
		_action_highlight.global_position = r.position
		_action_highlight.size = r.size
