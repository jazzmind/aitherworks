extends Node

func _ready() -> void:
	print("[TEST] Evaluator basic run...")
	# Build a tiny in-memory graph substitute? Here we require integration in scene; skip if not present.
	if get_tree().current_scene == null:
		print("[TEST] Skipping evaluator test: no scene")
		return
	# If a GraphEdit exists, attempt a dry run
	var ge := get_tree().current_scene.get_node_or_null("**/GraphEdit")
	if ge == null:
		print("[TEST] No GraphEdit found; skipping")
		return
	var spec := {"targets": {"lanes": 3, "pattern": [0.5, 1.0, -0.5]}}
	var res := Evaluator.evaluate_graph(ge as GraphEdit, spec)
	print("[TEST] Eval result: ", res)

