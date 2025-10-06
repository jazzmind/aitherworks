extends RefCounted

## MachineConfiguration
#
# Stores the player's machine configuration including placed parts,
# connections between them, and resource budget tracking.
# Provides serialization for save/load and validation for level constraints.

class_name MachineConfiguration

## Part placement data
class PlacedPart:
	var part_id: String  ## ID from parts YAML (e.g., "steam_source")
	var instance_name: String  ## Unique name (e.g., "steam_source_123456")
	var instance: Node  ## Reference to the actual part instance
	var position: Vector2 = Vector2.ZERO  ## Position in the workbench
	var rotation: float = 0.0  ## Rotation in radians
	var parameters: Dictionary = {}  ## Custom parameter overrides
	
	func _init(pid: String, iname: String, inst: Node = null) -> void:
		part_id = pid
		instance_name = iname
		instance = inst

## Connection between two parts
class PartConnection:
	var from_part: String  ## Source part instance name
	var from_port: String  ## Source port name (e.g., "out_south")
	var to_part: String  ## Target part instance name
	var to_port: String  ## Target port name (e.g., "in_north")
	var signal_type: String = "scalar"  ## Type of data flowing through
	
	func _init(from_p: String, from_po: String, to_p: String, to_po: String) -> void:
		from_part = from_p
		from_port = from_po
		to_part = to_p
		to_port = to_po

## Budget tracking
class Budget:
	var mass_used: float = 0.0
	var brass_used: float = 0.0
	var pressure_used: float = 0.0
	
	var mass_limit: float = 100.0
	var brass_limit: float = 100.0
	var pressure_limit: float = 100.0
	
	func is_within_limits() -> bool:
		return mass_used <= mass_limit and \
		       brass_used <= brass_limit and \
		       pressure_used <= pressure_limit
	
	func get_mass_remaining() -> float:
		return mass_limit - mass_used
	
	func get_brass_remaining() -> float:
		return brass_limit - brass_used
	
	func get_pressure_remaining() -> float:
		return pressure_limit - pressure_used

## Machine state
var placed_parts: Array[PlacedPart] = []
var connections: Array[PartConnection] = []
var budget: Budget = Budget.new()

## Metadata
var machine_name: String = "Untitled Machine"
var created_at: String = ""
var modified_at: String = ""
var level_id: String = ""

## Signals
signal part_added(part: PlacedPart)
signal part_removed(instance_name: String)
signal connection_added(conn: PartConnection)
signal connection_removed(from_part: String, to_part: String)
signal budget_updated(budget: Budget)
signal configuration_changed()

func _init() -> void:
	created_at = Time.get_datetime_string_from_system()
	modified_at = created_at

## Add a part to the machine
func add_part(part_id: String, instance: Node, position: Vector2 = Vector2.ZERO) -> PlacedPart:
	var instance_name := _generate_unique_name(part_id)
	var placed := PlacedPart.new(part_id, instance_name, instance)
	placed.position = position
	
	placed_parts.append(placed)
	_update_budget_for_part(part_id, 1)
	
	emit_signal("part_added", placed)
	emit_signal("configuration_changed")
	_update_modified_time()
	
	return placed

## Remove a part from the machine
func remove_part(instance_name: String) -> bool:
	for i in range(placed_parts.size()):
		if placed_parts[i].instance_name == instance_name:
			var part_id := placed_parts[i].part_id
			placed_parts.remove_at(i)
			
			# Remove any connections involving this part
			_remove_connections_for_part(instance_name)
			
			_update_budget_for_part(part_id, -1)
			
			emit_signal("part_removed", instance_name)
			emit_signal("configuration_changed")
			_update_modified_time()
			return true
	
	return false

## Add a connection between two parts
func add_connection(from_part: String, from_port: String, to_part: String, to_port: String) -> PartConnection:
	# Check if connection already exists
	for conn in connections:
		if conn.from_part == from_part and conn.to_part == to_part and \
		   conn.from_port == from_port and conn.to_port == to_port:
			return conn
	
	var conn := PartConnection.new(from_part, from_port, to_part, to_port)
	connections.append(conn)
	
	emit_signal("connection_added", conn)
	emit_signal("configuration_changed")
	_update_modified_time()
	
	return conn

## Remove a connection
func remove_connection(from_part: String, to_part: String) -> bool:
	for i in range(connections.size()):
		if connections[i].from_part == from_part and connections[i].to_part == to_part:
			connections.remove_at(i)
			
			emit_signal("connection_removed", from_part, to_part)
			emit_signal("configuration_changed")
			_update_modified_time()
			return true
	
	return false

## Get a placed part by instance name
func get_part(instance_name: String) -> PlacedPart:
	for part in placed_parts:
		if part.instance_name == instance_name:
			return part
	return null

## Get all parts of a specific type
func get_parts_by_type(part_id: String) -> Array[PlacedPart]:
	var result: Array[PlacedPart] = []
	for part in placed_parts:
		if part.part_id == part_id:
			result.append(part)
	return result

## Get all connections from a specific part
func get_connections_from(instance_name: String) -> Array[PartConnection]:
	var result: Array[PartConnection] = []
	for conn in connections:
		if conn.from_part == instance_name:
			result.append(conn)
	return result

## Get all connections to a specific part
func get_connections_to(instance_name: String) -> Array[PartConnection]:
	var result: Array[PartConnection] = []
	for conn in connections:
		if conn.to_part == instance_name:
			result.append(conn)
	return result

## Validate the machine configuration
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	
	# Check budget
	if not budget.is_within_limits():
		errors.append("Budget exceeded")
	
	# Check for disconnected parts (optional warning)
	for part in placed_parts:
		var has_input := false
		var has_output := false
		
		for conn in connections:
			if conn.to_part == part.instance_name:
				has_input = true
			if conn.from_part == part.instance_name:
				has_output = true
		
		# Sources don't need inputs, sinks don't need outputs
		if part.part_id != "steam_source" and not has_input:
			warnings.append("Part '%s' has no inputs" % part.instance_name)
		# Skip output warning for now - display parts might not have outputs
	
	# Check for cycles (if not allowed)
	# This would require building a graph and checking for cycles
	# For now, we'll defer this to the SimulationGraph
	
	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}

## Serialize to dictionary for saving
func to_dict() -> Dictionary:
	var parts_data := []
	for part in placed_parts:
		parts_data.append({
			"part_id": part.part_id,
			"instance_name": part.instance_name,
			"position": {"x": part.position.x, "y": part.position.y},
			"rotation": part.rotation,
			"parameters": part.parameters
		})
	
	var connections_data := []
	for conn in connections:
		connections_data.append({
			"from_part": conn.from_part,
			"from_port": conn.from_port,
			"to_part": conn.to_part,
			"to_port": conn.to_port,
			"signal_type": conn.signal_type
		})
	
	return {
		"machine_name": machine_name,
		"level_id": level_id,
		"created_at": created_at,
		"modified_at": modified_at,
		"placed_parts": parts_data,
		"connections": connections_data,
		"budget": {
			"mass_used": budget.mass_used,
			"brass_used": budget.brass_used,
			"pressure_used": budget.pressure_used,
			"mass_limit": budget.mass_limit,
			"brass_limit": budget.brass_limit,
			"pressure_limit": budget.pressure_limit
		}
	}

## Deserialize from dictionary (for loading)
func from_dict(data: Dictionary) -> void:
	machine_name = data.get("machine_name", "Untitled Machine")
	level_id = data.get("level_id", "")
	created_at = data.get("created_at", "")
	modified_at = data.get("modified_at", "")
	
	# Clear existing data
	placed_parts.clear()
	connections.clear()
	
	# Load parts (without instances - those need to be recreated)
	var parts_data: Array = data.get("placed_parts", [])
	for part_data in parts_data:
		if not part_data is Dictionary:
			continue
		var placed := PlacedPart.new(
			part_data.get("part_id", ""),
			part_data.get("instance_name", ""),
			null
		)
		var pos_data: Dictionary = part_data.get("position", {"x": 0.0, "y": 0.0})
		placed.position = Vector2(pos_data.get("x", 0.0), pos_data.get("y", 0.0))
		placed.rotation = part_data.get("rotation", 0.0)
		placed.parameters = part_data.get("parameters", {})
		placed_parts.append(placed)
	
	# Load connections
	var connections_data: Array = data.get("connections", [])
	for conn_data in connections_data:
		if not conn_data is Dictionary:
			continue
		var conn := PartConnection.new(
			conn_data.get("from_part", ""),
			conn_data.get("from_port", ""),
			conn_data.get("to_part", ""),
			conn_data.get("to_port", "")
		)
		conn.signal_type = conn_data.get("signal_type", "scalar")
		connections.append(conn)
	
	# Load budget
	var budget_data: Dictionary = data.get("budget", {})
	budget.mass_used = budget_data.get("mass_used", 0.0)
	budget.brass_used = budget_data.get("brass_used", 0.0)
	budget.pressure_used = budget_data.get("pressure_used", 0.0)
	budget.mass_limit = budget_data.get("mass_limit", 100.0)
	budget.brass_limit = budget_data.get("brass_limit", 100.0)
	budget.pressure_limit = budget_data.get("pressure_limit", 100.0)

## Clear all parts and connections
func clear() -> void:
	placed_parts.clear()
	connections.clear()
	budget.mass_used = 0.0
	budget.brass_used = 0.0
	budget.pressure_used = 0.0
	
	emit_signal("configuration_changed")
	_update_modified_time()

## Generate a unique instance name for a part
func _generate_unique_name(part_id: String) -> String:
	var timestamp := Time.get_ticks_msec()
	var random_suffix := randi() % 10000
	return "%s_%d%d" % [part_id, timestamp, random_suffix]

## Remove all connections involving a specific part
func _remove_connections_for_part(instance_name: String) -> void:
	var to_remove: Array[int] = []
	for i in range(connections.size()):
		if connections[i].from_part == instance_name or connections[i].to_part == instance_name:
			to_remove.append(i)
	
	# Remove in reverse order to preserve indices
	to_remove.reverse()
	for i in to_remove:
		connections.remove_at(i)

## Update budget for adding/removing a part
func _update_budget_for_part(part_id: String, delta: int) -> void:
	# Default costs (would normally load from part spec)
	var mass_cost := 10.0
	var brass_cost := 5.0
	var pressure_cost := 2.0
	
	budget.mass_used += mass_cost * delta
	budget.brass_used += brass_cost * delta
	budget.pressure_used += pressure_cost * delta
	
	emit_signal("budget_updated", budget)

## Update modified timestamp
func _update_modified_time() -> void:
	modified_at = Time.get_datetime_string_from_system()

## Get machine statistics
func get_stats() -> Dictionary:
	return {
		"part_count": placed_parts.size(),
		"connection_count": connections.size(),
		"mass_used": budget.mass_used,
		"brass_used": budget.brass_used,
		"pressure_used": budget.pressure_used,
		"budget_ok": budget.is_within_limits()
	}

## Print configuration summary
func print_summary() -> void:
	print("=== Machine Configuration ===")
	print("Name: %s" % machine_name)
	print("Level: %s" % level_id)
	print("Parts: %d" % placed_parts.size())
	print("Connections: %d" % connections.size())
	print("Budget: %.1f/%.1f mass, %.1f/%.1f brass, %.1f/%.1f pressure" % [
		budget.mass_used, budget.mass_limit,
		budget.brass_used, budget.brass_limit,
		budget.pressure_used, budget.pressure_limit
	])
	print("============================")

