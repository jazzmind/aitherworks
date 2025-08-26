extends Node
class_name SpecValidator

## SpecValidator
# Validates part and level YAML files and logs readable messages.

static func _list_yaml(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".yaml"):
			out.append(dir_path + "/" + f)
		f = dir.get_next()
	dir.list_dir_end()
	return out

static func _load_catalog(parts_dir: String) -> Dictionary:
	var cat: Dictionary = {}
	var files := _list_yaml(parts_dir)
	for p in files:
		var d := SpecLoader.load_yaml(p)
		if d.has("id"):
			cat[String(d["id"])]=d
	return cat

static func _stringify_path(p: String) -> String:
	return p.get_file()

func validate_parts_and_specs(parts_dir: String, specs_dir: String) -> Dictionary:
	var messages: Array[String] = []
	var ok := true
	# Parts
	var part_files := _list_yaml(parts_dir)
	for pf in part_files:
		var data := SpecLoader.load_yaml(pf)
		var id := String(data.get("id", ""))
		if id == "":
			ok = false
			messages.append("❌ Part missing id: " + _stringify_path(pf))
			continue
		if not data.has("ports"):
			messages.append("⚠️ Part has no ports: " + id)
		else:
			for k in data["ports"].keys():
				var v := String(data["ports"][k])
				if v != "input" and v != "output":
					messages.append("⚠️ Port '"+k+"' on "+id+" is '"+v+"' (expected 'input'|'output')")
				# Normalize: allow cardinal names and map to in/out in docs; just warn for now
				if k in ["north", "east", "south", "west"]:
					messages.append("ℹ️ Port uses cardinal key '"+k+"' on "+id+"; consider 'in'/'out' naming.")
	# Specs
	var catalog := _load_catalog(parts_dir)
	var spec_files := _list_yaml(specs_dir)
	for sf in spec_files:
		var s := SpecLoader.load_yaml(sf)
		var allowed: Array = s.get("allowed_parts", [])
		for pid in allowed:
			if not catalog.has(String(pid)):
				ok = false
				messages.append("❌ Spec references unknown part '"+String(pid)+"' in "+_stringify_path(sf))
		# Name/description guard
		if not s.has("name"):
			messages.append("⚠️ Spec missing name: "+_stringify_path(sf))
		if not s.has("description"):
			messages.append("⚠️ Spec missing description: "+_stringify_path(sf))

	if ok:
		messages.push_front("✅ YAML validation OK ("+str(part_files.size())+" parts, "+str(spec_files.size())+" specs)")
	return {"ok": ok, "messages": messages}
