extends Node

## SpecLoader
# Minimal YAML loader for AItherworks specs/parts.
# Supports maps, sequences, inline arrays, numbers/bools, and block scalars (|).
# This is intentionally small and tailored to our data files.

class_name SpecLoader

static func load_yaml(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SpecLoader: cannot open %s" % path)
		return {}
	var text := file.get_as_text()
	print("DEBUG: Loaded file: ", file.get_as_text().substr(0, 100))
	return _parse_yaml(text)

static func _parse_yaml(text: String) -> Dictionary:
	var root: Dictionary = {}
	var stack: Array = [{"indent": -1, "container": root, "key": null, "type": "map"}]
	var _i := 0
	var lines := text.split("\n")
	var in_block := false
	var block_key := ""
	var block_indent := 0
	var block_lines: Array = []

	for raw_line in lines:
		var line: String = raw_line
		# strip CR
		if line.ends_with("\r"):
			line = line.substr(0, line.length() - 1)
		# ignore full-line comments
		var hash_pos := line.find("#")
		if hash_pos == 0:
			continue
		if hash_pos > 0:
			# allow inline comments by trimming after hash when preceded by space
			var before := line.substr(0, hash_pos)
			if before.ends_with(" "):
				line = before.strip_edges()
		if line.strip_edges() == "":
			# blank
			continue

		var indent := 0
		while indent < line.length() and line[indent] == ' ':
			indent += 1

		if in_block:
			if indent <= block_indent:
				# end block
				_assign_value(stack, block_key, _join_lines(block_lines))
				in_block = false
				block_key = ""
				block_lines.clear()
				# fall through to process this line
			else:
				var content := line.substr(block_indent + 1)
				block_lines.append(content)
				continue

		# unwind stack to current indent
		while stack.size() > 0 and indent <= stack[-1]["indent"]:
			stack.pop_back()
		if stack.size() == 0:
			stack.append({"indent": -1, "container": root, "key": null, "type": "map"})

		var current: Dictionary = stack[-1]
		var trimmed := line.strip_edges()

		if trimmed.begins_with("- "):
			# sequence item
			if typeof(current["container"]) != TYPE_ARRAY:
				# convert to array
				var arr: Array = []
				# attach arr to parent under last key if parent is a map and the last pushed was with a key
				if current["type"] == "map" and current["key"] != null:
					# attach to this map at the stored key
					current["container"][current["key"]] = arr
				elif current["type"] == "map" and current["key"] == null and stack.size() >= 2 and stack[-2].has("key") and stack[-2]["key"] != null:
					# special case: we previously opened a key with unknown type (map or seq)
					# the parent frame (stack[-2]) stores the parent container and the pending key
					stack[-2]["container"][stack[-2]["key"]] = arr
				else:
					# Root-level sequence (rare in our files)
					root = {"_": arr}
				current["container"] = arr
				current["type"] = "seq"
			var item_str := trimmed.substr(2).strip_edges()
			var value = _parse_scalar(item_str)
			if item_str == "" or item_str.ends_with(":"):
				# nested structure under this item (e.g., '- key:')
				var map := {}
				current["container"].append(map)
				stack.append({"indent": indent, "container": map, "key": null, "type": "map"})
				if item_str.ends_with(":"):
					var k := item_str.substr(0, item_str.length() - 1).strip_edges()
					map[k] = {}
					stack.append({"indent": indent + 2, "container": map, "key": k, "type": "map"})
			else:
				current["container"].append(value)
			continue

		# key: value or key: |
		var colon := trimmed.find(":")
		if colon > 0:
			var key := trimmed.substr(0, colon).strip_edges()
			var rest := trimmed.substr(colon + 1).strip_edges()
			if rest == "|":
				in_block = true
				block_key = key
				block_indent = indent
				block_lines.clear()
				# content lines appended in block mode
				# push a new map context to allow nested keys after block
				stack.append({"indent": indent, "container": current["container"], "key": key, "type": "map"})
				continue
			elif rest == "":
				# start new container under key; its true type (map or seq) will be
				# determined by the following lines. We keep two frames:
				# 1) a reference to the parent and the pending key so a subsequent
				#    sequence ('- ') can replace the value with an array
				# 2) a child map context so nested "key: value" pairs work
				var child := {}
				current["container"][key] = child
				# frame pointing to parent with the pending key
				stack.append({"indent": indent, "container": current["container"], "key": key, "type": "map"})
				# frame for the child map context
				stack.append({"indent": indent, "container": child, "key": null, "type": "map"})
			else:
				current["container"][key] = _parse_scalar(rest)
			continue

		# bare value? ignore

	if in_block:
		_assign_value(stack, block_key, _join_lines(block_lines))

	return root

static func _assign_value(stack: Array, key: String, value):
	for i in range(stack.size() - 1, -1, -1):
		var ctx = stack[i]
		if typeof(ctx["container"]) == TYPE_DICTIONARY:
			ctx["container"][key] = value
			return

static func _parse_scalar(s: String):
	if s == "true":
		return true
	if s == "false":
		return false
	if s == "null":
		return null
	if s.length() >= 2 and s[0] == '"' and s[s.length()-1] == '"':
		return s.substr(1, s.length()-2)
	if s.length() >= 2 and s[0] == '\'' and s[s.length()-1] == '\'':
		return s.substr(1, s.length()-2)
	if s.begins_with("[") and s.ends_with("]"):
		var inner := s.substr(1, s.length()-2)
		var parts := []
		var temp := inner.split(",")
		for p in temp:
			parts.append(_parse_scalar(p.strip_edges()))
		return parts
	# number?
	if s.find(".") != -1:
		var f = s.to_float()
		if str(f) != "0" or s == "0" or s == "0.0":
			return f
	var n = s.to_int()
	if str(n) == s:
		return n
	return s

static func _join_lines(arr: Array) -> String:
	var out := ""
	for i in range(arr.size()):
		out += String(arr[i])
		if i < arr.size() - 1:
			out += "\n"
	return out

static func load_parts_from_dir(dir_path: String) -> Dictionary:
	var catalog: Dictionary = {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return catalog
	# Godot 4: no args for list_dir_begin
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".yaml"):
				var path := dir_path + "/" + file_name
				var data := load_yaml(path)
				if data.has("id"):
					catalog[data["id"]] = data
		file_name = dir.get_next()
	dir.list_dir_end()
	return catalog

static func load_spec(path: String) -> Dictionary:
	return load_yaml(path)
