extends Node
class_name Evaluator

# Evaluates the current graph by running inputs through and comparing to expected outputs,
# while collecting environmental (steam/water) and performance (time) metrics.

static func evaluate_graph(graph: GraphEdit, spec: Dictionary) -> Dictionary:
	var start_time := Time.get_ticks_usec()
	var metrics := {
		"samples": 0,
		"correct": 0,
		"mse": 0.0,
		"steam_used": 0.0,
		"water_used": 0.0,
		"inference_ms": 0.0,
		"training_ms": 0.0
	}
	# Build nodes map
	var part_nodes: Array = []
	for child in graph.get_children():
		if child is PartNode:
			part_nodes.append(child)
	var name_to_node: Dictionary = {}
	for pn in part_nodes:
		name_to_node[pn.name] = pn
	var conns := graph.get_connection_list()
	if conns.is_empty():
		return {"ok": false, "reason": "no_connections", "metrics": metrics}
	# Build dataset from spec or synthetic
	var dataset: Array = _make_dataset_from_spec(spec)
	if dataset.is_empty():
		return {"ok": false, "reason": "no_dataset", "metrics": metrics}
	# Evaluate
	var inf_start := Time.get_ticks_usec()
	for sample in dataset:
		var outputs := _forward_dataset_sample(sample, conns, name_to_node)
		var y_hat: Array = outputs.get("terminal_values", [])
		var y_true: Array = sample.get("y", [])
		metrics["mse"] += _mse(y_hat, y_true)
		metrics["samples"] += 1
		if _match_success(y_hat, y_true):
			metrics["correct"] += 1
		# Environment accounting (simple): steam source usage proportional to channels; water used to cool
		metrics["steam_used"] += outputs.get("steam_used", 0.0)
		metrics["water_used"] += outputs.get("water_used", 0.0)
	var inf_end := Time.get_ticks_usec()
	metrics["inference_ms"] = float(inf_end - inf_start) / 1000.0
	# Aggregate
	if metrics["samples"] > 0:
		metrics["mse"] /= float(metrics["samples"])
	var total_time := Time.get_ticks_usec() - start_time
	return {
		"ok": true,
		"accuracy": (float(metrics["correct"]) / max(1.0, float(metrics["samples"]))),
		"metrics": metrics
	}

static func _make_dataset_from_spec(spec: Dictionary) -> Array:
	# Expect spec.data.{inputs, targets} or generate from targets.pattern
	if spec.has("data") and spec["data"].has("samples"):
		return spec["data"]["samples"]
	var ds: Array = []
	if spec.has("targets") and spec["targets"].has("lanes"):
		var lanes := int(spec["targets"]["lanes"])
		var patt: Array = spec["targets"].get("pattern", [])
		for i in range(32):
			var x: Array = []
			for j in range(lanes):
				x.append(randf_range(-1, 1))
			var y: Array = []
			if patt.size() == lanes:
				for j in range(lanes):
					y.append(float(patt[j]) * float(x[j]))
			else:
				for j in range(lanes):
					y.append(0.5 * float(x[j]))
			ds.append({"x": x, "y": y})
	return ds

static func _forward_dataset_sample(sample: Dictionary, conns: Array, name_to_node: Dictionary) -> Dictionary:
	var outputs: Dictionary = {}
	var steam_used := 0.0
	var water_used := 0.0
	# Start at steam sources; if none, feed sample.x to first signal_loom
	var sources: Array = []
	for k in name_to_node.keys():
		var n: PartNode = name_to_node[k]
		if n.part_id == "steam_source":
			sources.append(n)
	if sources.is_empty():
		for k in name_to_node.keys():
			var n2: PartNode = name_to_node[k]
			if n2.part_id == "signal_loom":
				sources.append(n2)
	# Forward
	var visited: Array = []
	for s in sources:
		var out_val: float = 0.0
		if s.part_id == "steam_source":
			out_val = s.process_inputs([])
			steam_used += 1.0
			water_used += 0.2
		else:
			out_val = s.process_inputs(sample.get("x", []))
		_process_from_node(s, out_val, conns, name_to_node, outputs, visited)
	# Collect terminal values
	var to_names: Array = []
	for c in conns:
		to_names.append(str(c["to"]))
	var terminal_values: Array = []
	for k2 in name_to_node.keys():
		if k2 not in to_names:
			terminal_values.append(float(outputs.get(k2, 0.0)))
	outputs["terminal_values"] = terminal_values
	outputs["steam_used"] = steam_used
	outputs["water_used"] = water_used
	return outputs

static func _process_from_node(node: PartNode, input_value: float, conns: Array, name_to_node: Dictionary, outputs: Dictionary, visited: Array) -> void:
	if node.name in visited:
		return
	visited.append(node.name)
	outputs[node.name] = input_value
	for c in conns:
		if str(c["from"]) == node.name:
			var tgt_name := str(c["to"])
			if name_to_node.has(tgt_name):
				var tgt: PartNode = name_to_node[tgt_name]
				var out := tgt.process_inputs([input_value])
				_process_from_node(tgt, out, conns, name_to_node, outputs, visited)

static func _mse(a: Array, b: Array) -> float:
	var s := 0.0
	var n := max(1, min(a.size(), b.size()))
	for i in range(n):
		var e := float(a[i]) - float(b[i])
		s += e * e
	return s / float(n)

static func _match_success(y_hat: Array, y_true: Array) -> bool:
	if y_hat.size() == 0 or y_true.size() == 0:
		return false
	# Success if average absolute error below threshold
	var s := 0.0
	var n := max(1, min(y_hat.size(), y_true.size()))
	for i in range(n):
		s += abs(float(y_hat[i]) - float(y_true[i]))
	return (s / float(n)) < 0.1

