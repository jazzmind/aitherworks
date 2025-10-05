extends SceneTree

func _init():
	var spec = SpecLoader.load_yaml("res://data/parts/weight_wheel.yaml")
	print("=== Weight Wheel YAML Debug ===")
	print("Ports: ", spec.get("ports", {}))
	print("Port keys: ", spec.get("ports", {}).keys())
	print("Port count: ", spec.get("ports", {}).size())
	
	var ports = spec.get("ports", {})
	for key in ports.keys():
		print("  Port '", key, "': ", ports[key])
	
	quit()
