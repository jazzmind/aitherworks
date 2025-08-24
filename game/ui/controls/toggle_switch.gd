extends Control

# Simple steampunk 2-state toggle switch. Emits toggled(bool)

signal toggled(pressed: bool)

@export var pressed: bool = false : set = set_pressed, get = is_pressed

func set_pressed(p: bool) -> void:
	if pressed == p:
		return
	pressed = p
	queue_redraw()
	emit_signal("toggled", pressed)

func is_pressed() -> bool:
	return pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_pressed(!pressed)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var bg := Color(0.15, 0.12, 0.09)
	var brass := Color(0.75, 0.62, 0.48)
	var glow := Color(1.0, 0.85, 0.6)
	draw_rect(r, bg)
	# Track
	var track_rect := Rect2(6, size.y * 0.35, size.x - 12, size.y * 0.3)
	draw_rect(track_rect, Color(0.25, 0.2, 0.15))
	# Knob
	var knob_w := (size.x - 12) * 0.5
	var knob_x := track_rect.position.x + (0.0 if pressed else knob_w)
	var knob_rect := Rect2(knob_x, track_rect.position.y - 6, knob_w, track_rect.size.y + 12)
	draw_rect(knob_rect, brass)
	# Glow indicator
	if pressed:
		draw_rect(Rect2(track_rect.position - Vector2(0, 2), Vector2(track_rect.size.x, 2)), glow)

