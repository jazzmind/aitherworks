extends GutTest

## Unit tests for SimulationGraph
## Tests graph construction, topological sort, cycle detection, and validation

const SimulationGraph = preload("res://game/sim/graph.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const SignalLoom = preload("res://game/parts/signal_loom.gd")

var graph: SimulationGraph

func before_each() -> void:
	graph = SimulationGraph.new()

func after_each() -> void:
	graph = null

## ========================================
## Basic Graph Construction
## ========================================

func test_empty_graph() -> void:
	assert_eq(graph.node_count, 0, "Empty graph should have 0 nodes")
	assert_eq(graph.edge_count, 0, "Empty graph should have 0 edges")
	assert_false(graph.has_cycles, "Empty graph should have no cycles")

func test_single_node() -> void:
	var steam := SteamSource.new()
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	var connections := []
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_true(success, "Should build successfully")
	assert_eq(graph.node_count, 1, "Should have 1 node")
	assert_eq(graph.edge_count, 0, "Should have 0 edges")
	assert_eq(graph.execution_order.size(), 1, "Execution order should contain 1 node")
	assert_false(graph.has_cycles, "Single node should have no cycles")
	
	steam.free()

func test_linear_chain() -> void:
	# steam -> signal_loom -> weight_wheel
	var steam := SteamSource.new()
	var loom := SignalLoom.new()
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "loom1", "part_id": "signal_loom", "instance": loom},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "loom1", "to_port": 0},
		{"from": "loom1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_true(success, "Should build successfully")
	assert_eq(graph.node_count, 3, "Should have 3 nodes")
	assert_eq(graph.edge_count, 2, "Should have 2 edges")
	assert_eq(graph.execution_order.size(), 3, "Execution order should contain 3 nodes")
	assert_false(graph.has_cycles, "Linear chain should have no cycles")
	
	# Verify execution order is correct
	var order_names := graph.get_execution_order_names()
	assert_eq(order_names[0], "steam1", "Steam source should execute first")
	assert_eq(order_names[1], "loom1", "Signal loom should execute second")
	assert_eq(order_names[2], "wheel1", "Weight wheel should execute third")
	
	steam.free()
	loom.free()
	wheel.free()

## ========================================
## Topological Sort
## ========================================

func test_topological_sort_multiple_sources() -> void:
	# Two independent chains:
	# steam1 -> wheel1
	# steam2 -> wheel2
	var steam1 := SteamSource.new()
	var steam2 := SteamSource.new()
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam1},
		{"name": "steam2", "part_id": "steam_source", "instance": steam2},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "steam2", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_true(success, "Should build successfully")
	assert_eq(graph.execution_order.size(), 4, "All 4 nodes should be in execution order")
	assert_false(graph.has_cycles, "Independent chains should have no cycles")
	
	# Both steam sources should execute before their respective wheels
	var order_names := graph.get_execution_order_names()
	var steam1_idx := order_names.find("steam1")
	var steam2_idx := order_names.find("steam2")
	var wheel1_idx := order_names.find("wheel1")
	var wheel2_idx := order_names.find("wheel2")
	
	assert_true(steam1_idx < wheel1_idx, "steam1 should execute before wheel1")
	assert_true(steam2_idx < wheel2_idx, "steam2 should execute before wheel2")
	
	steam1.free()
	steam2.free()
	wheel1.free()
	wheel2.free()

func test_topological_sort_diamond_pattern() -> void:
	# Diamond pattern:
	#     steam1
	#     /    \
	#  wheel1  wheel2
	#     \    /
	#     loom1
	var steam := SteamSource.new()
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	var loom := SignalLoom.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2},
		{"name": "loom1", "part_id": "signal_loom", "instance": loom}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "steam1", "from_port": 0, "to": "wheel2", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "loom1", "to_port": 0},
		{"from": "wheel2", "from_port": 0, "to": "loom1", "to_port": 1}
	]
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_true(success, "Should build successfully")
	assert_eq(graph.execution_order.size(), 4, "All 4 nodes should be in execution order")
	assert_false(graph.has_cycles, "Diamond pattern should have no cycles")
	
	# Verify dependencies are respected
	var order_names := graph.get_execution_order_names()
	var steam_idx := order_names.find("steam1")
	var wheel1_idx := order_names.find("wheel1")
	var wheel2_idx := order_names.find("wheel2")
	var loom_idx := order_names.find("loom1")
	
	assert_true(steam_idx < wheel1_idx, "steam should execute before wheel1")
	assert_true(steam_idx < wheel2_idx, "steam should execute before wheel2")
	assert_true(wheel1_idx < loom_idx, "wheel1 should execute before loom")
	assert_true(wheel2_idx < loom_idx, "wheel2 should execute before loom")
	
	steam.free()
	wheel1.free()
	wheel2.free()
	loom.free()

## ========================================
## Cycle Detection
## ========================================

func test_cycle_detection_simple() -> void:
	# Simple cycle: wheel1 -> wheel2 -> wheel1
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "wheel1", "from_port": 0, "to": "wheel2", "to_port": 0},
		{"from": "wheel2", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	# Expect warnings about cycle detection
	gut.p("Note: Cycle detection warnings are expected for this test")
	
	var success := graph.build_from_arrays(parts, connections)
	
	# Graph should build but detect cycle
	assert_true(success, "Should build (but with cycle)")
	assert_true(graph.has_cycles, "Should detect cycle")
	assert_true(graph.execution_order.size() < graph.node_count, 
		"Execution order should be incomplete due to cycle")
	
	wheel1.free()
	wheel2.free()

func test_cycle_detection_self_loop() -> void:
	# Self-loop: wheel1 -> wheel1
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "wheel1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	# Expect warnings about cycle detection
	gut.p("Note: Cycle detection warnings are expected for this test")
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_true(success, "Should build (but with cycle)")
	assert_true(graph.has_cycles, "Should detect self-loop as cycle")
	
	wheel.free()

## ========================================
## Graph Queries
## ========================================

func test_get_source_nodes() -> void:
	# steam1 -> wheel1 -> wheel2
	var steam := SteamSource.new()
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	
	var sources := graph.get_source_nodes()
	assert_eq(sources.size(), 1, "Should have 1 source node")
	assert_eq(sources[0].name, "steam1", "Steam source should be the only source")
	
	steam.free()
	wheel1.free()
	wheel2.free()

func test_get_sink_nodes() -> void:
	# steam1 -> wheel1 -> wheel2
	var steam := SteamSource.new()
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	
	var sinks := graph.get_sink_nodes()
	assert_eq(sinks.size(), 1, "Should have 1 sink node")
	assert_eq(sinks[0].name, "wheel2", "wheel2 should be the only sink")
	
	steam.free()
	wheel1.free()
	wheel2.free()

func test_get_node_by_name() -> void:
	var steam := SteamSource.new()
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	
	graph.build_from_arrays(parts, [])
	
	var node := graph.get_node("steam1")
	assert_not_null(node, "Should find node by name")
	assert_eq(node.name, "steam1", "Node name should match")
	assert_eq(node.part_id, "steam_source", "Part ID should match")
	
	var missing := graph.get_node("nonexistent")
	assert_null(missing, "Should return null for missing node")
	
	steam.free()

## ========================================
## Edge Cases
## ========================================

func test_invalid_connection_missing_node() -> void:
	var steam := SteamSource.new()
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "nonexistent", "to_port": 0}
	]
	
	# Expect error about missing node
	gut.p("Note: Error about missing node is expected for this test")
	
	var success := graph.build_from_arrays(parts, connections)
	
	assert_false(success, "Should fail when connection references missing node")
	
	steam.free()

func test_clear_graph() -> void:
	var steam := SteamSource.new()
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	
	graph.build_from_arrays(parts, [])
	assert_eq(graph.node_count, 1, "Should have 1 node before clear")
	
	graph.clear()
	assert_eq(graph.node_count, 0, "Should have 0 nodes after clear")
	assert_eq(graph.edge_count, 0, "Should have 0 edges after clear")
	assert_eq(graph.execution_order.size(), 0, "Execution order should be empty")
	
	steam.free()

func test_multiple_builds() -> void:
	# Build graph twice, second should replace first
	var steam1 := SteamSource.new()
	var steam2 := SteamSource.new()
	
	var parts1 := [{"name": "steam1", "part_id": "steam_source", "instance": steam1}]
	graph.build_from_arrays(parts1, [])
	assert_eq(graph.node_count, 1, "First build should have 1 node")
	
	var parts2 := [{"name": "steam2", "part_id": "steam_source", "instance": steam2}]
	graph.build_from_arrays(parts2, [])
	assert_eq(graph.node_count, 1, "Second build should replace first")
	assert_not_null(graph.get_node("steam2"), "Should have new node")
	assert_null(graph.get_node("steam1"), "Should not have old node")
	
	steam1.free()
	steam2.free()

## ========================================
## Performance
## ========================================

func test_large_graph_performance() -> void:
	# Create a chain of 100 nodes
	var parts := []
	var connections := []
	var instances := []
	
	for i in range(100):
		var steam := SteamSource.new()
		instances.append(steam)
		parts.append({
			"name": "steam%d" % i,
			"part_id": "steam_source",
			"instance": steam
		})
		
		if i > 0:
			connections.append({
				"from": "steam%d" % (i - 1),
				"from_port": 0,
				"to": "steam%d" % i,
				"to_port": 0
			})
	
	var start_time := Time.get_ticks_msec()
	var success := graph.build_from_arrays(parts, connections)
	var elapsed := Time.get_ticks_msec() - start_time
	
	assert_true(success, "Should build large graph successfully")
	assert_eq(graph.node_count, 100, "Should have 100 nodes")
	assert_eq(graph.edge_count, 99, "Should have 99 edges")
	assert_true(elapsed < 100, "Should build in less than 100ms (got %dms)" % elapsed)
	
	# Clean up
	for instance in instances:
		instance.free()

