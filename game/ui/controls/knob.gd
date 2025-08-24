extends Control

# Simple steampunk-style rotary knob control.
# Emits value_changed when rotated. Drawn with a brass-like ring and an indicator.

signal value_changed(value: float)

@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 0.01
@export var value: float = 0.0 : set = set_value, get = get_value

var _dragging := false

func _ready() -> void:
    mouse_filter = MOUSE_FILTER_PASS
    set_process_unhandled_input(true)
    if size == Vector2.ZERO:
        custom_minimum_size = Vector2(44, 44)

func set_value(v: float) -> void:
    var clamped = clampf(v, min_value, max_value)
    if step > 0.0:
        clamped = round(clamped / step) * step
    if !is_equal_approx(clamped, value):
        value = clamped
        queue_redraw()
        emit_signal("value_changed", value)

func get_value() -> float:
    return value

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT:
            if mb.pressed:
                _dragging = true
                _update_value_from_position(mb.position)
            else:
                _dragging = false
    elif event is InputEventMouseMotion and _dragging:
        _update_value_from_position((event as InputEventMouseMotion).position)

func _update_value_from_position(pos: Vector2) -> void:
    var center := get_rect().size * 0.5
    var vec := pos - center
    var angle := atan2(vec.y, vec.x)  # -PI..PI, 0 at +X
    # Map angle (-135deg .. 135deg) to [min_value, max_value]
    var a: float = rad_to_deg(angle)
    if a < -135:
        a = -135
    elif a > 135:
        a = 135
    var t: float = (a + 135.0) / 270.0
    var v: float = lerp(min_value, max_value, t)
    set_value(v)

func _draw() -> void:
    var r: float = min(size.x, size.y) * 0.45
    var center: Vector2 = size * 0.5
    # Ring
    draw_circle(center, r, Color(0.25, 0.2, 0.15, 1))
    draw_circle(center, r - 3.0, Color(0.12, 0.1, 0.08, 1))
    # Tick marks (min/mid/max)
    for i in [-135, 0, 135]:
        var ang: float = deg_to_rad(float(i))
        var p1: Vector2 = center + Vector2(cos(ang), sin(ang)) * (r - 6.0)
        var p2: Vector2 = center + Vector2(cos(ang), sin(ang)) * (r - 2.0)
        draw_line(p1, p2, Color(0.8, 0.68, 0.5), 2.0)
    # Indicator
    var t: float = inverse_lerp(min_value, max_value, value)
    var ang_val: float = deg_to_rad(-135.0 + t * 270.0)
    var p: Vector2 = center + Vector2(cos(ang_val), sin(ang_val)) * (r - 10.0)
    draw_line(center, p, Color(1.0, 0.9, 0.6), 3.0)


