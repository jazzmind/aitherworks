extends SceneTree

func _init():
	print("=== Port Count Analysis ===\n")
	
	var parts_dir = "res://data/parts"
	var dir = DirAccess.open(parts_dir)
	if dir == null:
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
	
	var max_inputs = 0
	var max_outputs = 0
	var parts_exceeding_4_total: Array[String] = []
	
	for yaml_path in files:
		var filename = yaml_path.get_file()
		var data = SpecLoader.load_yaml(yaml_path)
		
		if not data.has("ports") or typeof(data["ports"]) != TYPE_DICTIONARY:
			continue
		
		var ports = data["ports"]
		var input_count = 0
		var output_count = 0
		
		for port_name in ports.keys():
			var port_data = ports[port_name]
			var direction = ""
			if port_data is Dictionary:
				direction = port_data.get("direction", "")
			elif port_data is String:
				direction = port_data
			
			# Detect from name pattern
			if port_name.begins_with("in"):
				input_count += 1
			elif port_name.begins_with("out"):
				output_count += 1
		
		var total_ports = input_count + output_count
		
		if total_ports > 4:
			parts_exceeding_4_total.append("%s (%d in + %d out = %d total)" % [
				filename, input_count, output_count, total_ports
			])
		
		if input_count > 4 or output_count > 4 or total_ports > 0:
			var status = ""
			if input_count > 4:
				status += "⚠️ TOO MANY INPUTS (%d) " % input_count
			if output_count > 4:
				status += "⚠️ TOO MANY OUTPUTS (%d) " % output_count
			
			print("%s: %d in, %d out (total: %d) %s" % [
				filename.rpad(30), input_count, output_count, total_ports, status
			])
		
		max_inputs = max(max_inputs, input_count)
		max_outputs = max(max_outputs, output_count)
	
	print("\n=== Summary ===")
	print("Max inputs on any part:  %d" % max_inputs)
	print("Max outputs on any part: %d" % max_outputs)
	print("Parts exceeding 4 total ports: %d" % parts_exceeding_4_total.size())
	
	if parts_exceeding_4_total.size() > 0:
		print("\n=== Parts with >4 Total Ports ===")
		for part in parts_exceeding_4_total:
			print("  - %s" % part)
	
	print("\n=== Cardinal Direction Analysis ===")
	print("Cardinal directions available: north, south, east, west (4 max)")
	print("")
	if max_inputs > 4:
		print("❌ PROBLEM: Max inputs (%d) exceeds 4 cardinal directions" % max_inputs)
	else:
		print("✅ Inputs fit: Max %d ≤ 4 cardinal directions" % max_inputs)
	
	if max_outputs > 4:
		print("❌ PROBLEM: Max outputs (%d) exceeds 4 cardinal directions" % max_outputs)
	else:
		print("✅ Outputs fit: Max %d ≤ 4 cardinal directions" % max_outputs)
	
	print("\n=== Recommendation ===")
	if max_inputs > 4 or max_outputs > 4:
		print("❌ Cardinal naming is INSUFFICIENT")
		print("   Need numbered or hybrid approach: in_north_1, in_north_2, etc.")
	else:
		print("✅ Cardinal naming is ADEQUATE for current parts")
		print("   But consider: What if we add parts with >4 ports later?")
	
	quit()

