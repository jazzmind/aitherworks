extends SceneTree

## Automated Port Naming Fixer
# Converts in-1, in-2, out-1 pattern to hybrid cardinal pattern
# Option 3: ^(in|out)_(north|south|east|west)(?:_[1-9][0-9]*)?$

# Port assignment strategy for different configurations
var PORT_MAPPINGS = {
	# 1 input, 1 output (most common - 21 files)
	"1in_1out": {
		"in-1": "in_north",
		"out-1": "out_south"
	},
	# 2 inputs, 1 output (4 files: adder_manifold, athanor_still, entropy_manometer)
	"2in_1out": {
		"in-1": "in_north",
		"in-2": "in_east",
		"out-1": "out_south"
	},
	# 3 inputs, 1 output (1 file: looking_glass_array)
	"3in_1out": {
		"in-1": "in_north",
		"in-2": "in_east",
		"in-3": "in_west",  # Use west instead of south to leave south for output
		"out-1": "out_south"
	},
	# 1 input, 2 outputs (1 file: pneumail_librarium)
	"1in_2out": {
		"in-1": "in_north",
		"out-1": "out_south",
		"out-2": "out_east"
	},
	# 0 input, 1 output (steam_source - already fixed)
	"0in_1out": {
		"out-1": "out_south"
	}
}

func _init():
	print("=== Automated Port Naming Fixer ===\n")
	
	var parts_dir = "res://data/parts"
	var dir = DirAccess.open(parts_dir)
	if dir == null:
		print("ERROR: Cannot open directory")
		quit(1)
		return
	
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".yaml") and file_name != "steam_source.yaml":  # Skip already fixed
			files.append(parts_dir + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	files.sort()
	
	var fixed_count = 0
	var skipped_count = 0
	var error_count = 0
	
	for yaml_path in files:
		var filename = yaml_path.get_file()
		var result = fix_file(yaml_path)
		
		if result == "fixed":
			print("✅ Fixed: %s" % filename)
			fixed_count += 1
		elif result == "skipped":
			print("⚠️  Skipped: %s (empty/invalid ports)" % filename)
			skipped_count += 1
		else:
			print("❌ Error: %s (%s)" % [filename, result])
			error_count += 1
	
	print("\n=== Summary ===")
	print("Fixed:   %d" % fixed_count)
	print("Skipped: %d (need manual review)" % skipped_count)
	print("Errors:  %d" % error_count)
	
	if error_count == 0:
		print("\n✅ Port naming fix complete!")
		quit(0)
	else:
		print("\n❌ Some files had errors")
		quit(1)

func fix_file(yaml_path: String) -> String:
	# Read original content
	var file = FileAccess.open(yaml_path, FileAccess.READ)
	if file == null:
		return "cannot_read"
	var original_content = file.get_as_text()
	file.close()
	
	# Parse YAML to determine port configuration
	var data = SpecLoader.load_yaml(yaml_path)
	if not data.has("ports") or typeof(data["ports"]) != TYPE_DICTIONARY:
		return "skipped"
	
	var ports = data["ports"]
	if ports.size() == 0:
		return "skipped"
	
	# Determine configuration
	var input_ports: Array[String] = []
	var output_ports: Array[String] = []
	
	for port_name in ports.keys():
		if port_name.begins_with("in"):
			input_ports.append(port_name)
		elif port_name.begins_with("out"):
			output_ports.append(port_name)
	
	input_ports.sort()
	output_ports.sort()
	
	var config_key = "%din_%dout" % [input_ports.size(), output_ports.size()]
	
	if not PORT_MAPPINGS.has(config_key):
		return "unknown_config_%s" % config_key
	
	var mapping = PORT_MAPPINGS[config_key]
	
	# Apply replacements to file content
	var new_content = original_content
	
	for old_port in mapping.keys():
		var new_port = mapping[old_port]
		# Replace port name as a key (with colon)
		new_content = new_content.replace(old_port + ":", new_port + ":")
	
	# Write back
	file = FileAccess.open(yaml_path, FileAccess.WRITE)
	if file == null:
		return "cannot_write"
	file.store_string(new_content)
	file.close()
	
	return "fixed"

