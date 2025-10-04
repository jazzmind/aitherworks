extends SceneTree

## Part YAML Port Naming Audit
# Validates all part YAMLs against schema naming convention
# Schema requires: ^(in|out)_(north|south|east|west)$

func _init():
	print("=== Part YAML Port Naming Audit ===\n")
	
	var parts_dir = "res://data/parts"
	var dir = DirAccess.open(parts_dir)
	if dir == null:
		print("ERROR: Cannot open directory: ", parts_dir)
		quit(1)
		return
	
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".yaml"):
			files.append(parts_dir + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	files.sort()
	
	var total_files = 0
	var compliant_files = 0
	var non_compliant_files = 0
	var issues_found = 0
	var port_regex = RegEx.new()
	port_regex.compile("^(in|out)_(north|south|east|west)$")
	
	for yaml_path in files:
		var filename = yaml_path.get_file()
		total_files += 1
		
		var data = SpecLoader.load_yaml(yaml_path)
		if not data.has("ports"):
			print("⚠️  %s: No 'ports' section found" % filename)
			continue
		
		var ports = data["ports"]
		if typeof(ports) != TYPE_DICTIONARY or ports.size() == 0:
			print("⚠️  %s: Empty or invalid ports section" % filename)
			continue
		
		var file_has_issues = false
		var invalid_ports: Array[String] = []
		
		for port_name in ports.keys():
			var match_result = port_regex.search(port_name)
			if match_result == null:
				if not file_has_issues:
					file_has_issues = true
					non_compliant_files += 1
				invalid_ports.append(port_name)
				issues_found += 1
		
		if file_has_issues:
			print("❌ %s:" % filename)
			for port_name in invalid_ports:
				print("   - '%s' (should match: in|out + _ + north|south|east|west)" % port_name)
		else:
			print("✅ %s (%d ports)" % [filename, ports.size()])
			compliant_files += 1
	
	print("\n=== Summary ===")
	print("Total files:        %d" % total_files)
	print("Compliant:          %d" % compliant_files)
	print("Non-compliant:      %d" % non_compliant_files)
	print("Issues found:       %d" % issues_found)
	print("")
	
	if non_compliant_files == 0:
		print("✅ All part YAMLs follow schema naming convention!")
		quit(0)
	else:
		print("❌ Found %d files with port naming issues" % non_compliant_files)
		print("\nRecommended fix: Update port names to match schema pattern")
		print("Example: 'steam_out' → 'out_south'")
		quit(1)

