extends GutTest

## Unit tests for ForwardPass
## Tests signal propagation, caching, and execution order

const ForwardPass = preload("res://game/sim/forward_pass.gd")
const SimulationGraph = preload("res://game/sim/graph.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const SignalLoom = preload("res://game/parts/signal_loom.gd")
const AdderManifold = preload("res://game/parts/adder_manifold.gd")
const ActivationGate = preload("res://game/parts/activation_gate.gd")

var forward_pass: ForwardPass
var graph: SimulationGraph

func before_each() -> void:
	forward_pass = ForwardPass.new()
	graph = SimulationGraph.new()

func after_each() -> void:
	forward_pass = null
	graph = null

## ========================================
## Basic Forward Pass
## ========================================

func test_single_source_node() -> void:
	# Single steam source with no connections
	var steam := SteamSource.new()
	# Steam source will use default sine wave pattern
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	
	graph.build_from_arrays(parts, [])
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order.size(), 1, "Should execute 1 node")
	assert_eq(ctx.execution_order[0], "steam1", "Should execute steam1")
	assert_has(ctx.activations, "steam1", "Should have activation for steam1")
	
	var output := forward_pass.get_node_output(ctx, "steam1")
	assert_typeof(output, TYPE_ARRAY, "Steam source should output array")
	assert_gt(output.size(), 0, "Steam source should generate data")
	
	steam.free()

func test_linear_chain() -> void:
	# steam -> wheel
	var steam := SteamSource.new()
	steam.amplitude = 2.0
	
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 3.0)
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order.size(), 2, "Should execute 2 nodes")
	assert_eq(ctx.execution_order[0], "steam1", "Steam should execute first")
	assert_eq(ctx.execution_order[1], "wheel1", "Wheel should execute second")
	
	# Check that steam output was propagated to wheel
	assert_has(ctx.activations, "steam1", "Should have steam activation")
	assert_has(ctx.activations, "wheel1", "Should have wheel activation")
	
	# Just verify output exists and is numeric (sine wave makes exact value unpredictable)
	var wheel_output := forward_pass.get_node_output(ctx, "wheel1")
	assert_not_null(wheel_output, "Wheel should produce output")
	assert_typeof(wheel_output, TYPE_FLOAT, "Wheel output should be float")
	
	steam.free()
	wheel.free()

## ========================================
## Multiple Inputs
## ========================================

func test_multiple_inputs_converge() -> void:
	# steam1 -> wheel1 \
	#                    adder
	# steam2 -> wheel2 /
	var steam1 := SteamSource.new()
	steam1.amplitude = 1.0
	
	var steam2 := SteamSource.new()
	steam2.amplitude = 2.0
	
	var wheel1 := WeightWheel.new()
	wheel1.set_num_weights(1)
	wheel1.set_weight(0, 1.0)
	
	var wheel2 := WeightWheel.new()
	wheel2.set_num_weights(1)
	wheel2.set_weight(0, 1.0)
	
	var adder := AdderManifold.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam1},
		{"name": "steam2", "part_id": "steam_source", "instance": steam2},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2},
		{"name": "adder1", "part_id": "adder_manifold", "instance": adder}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "steam2", "from_port": 0, "to": "wheel2", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "adder1", "to_port": 0},
		{"from": "wheel2", "from_port": 0, "to": "adder1", "to_port": 1}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order.size(), 5, "Should execute all 5 nodes")
	
	# Verify execution order respects dependencies
	var steam1_idx := ctx.execution_order.find("steam1")
	var steam2_idx := ctx.execution_order.find("steam2")
	var wheel1_idx := ctx.execution_order.find("wheel1")
	var wheel2_idx := ctx.execution_order.find("wheel2")
	var adder_idx := ctx.execution_order.find("adder1")
	
	assert_true(steam1_idx < wheel1_idx, "steam1 before wheel1")
	assert_true(steam2_idx < wheel2_idx, "steam2 before wheel2")
	assert_true(wheel1_idx < adder_idx, "wheel1 before adder")
	assert_true(wheel2_idx < adder_idx, "wheel2 before adder")
	
	# Check adder output exists
	var adder_output := forward_pass.get_node_output(ctx, "adder1")
	assert_not_null(adder_output, "Adder should produce output")
	assert_typeof(adder_output, TYPE_FLOAT, "Adder output should be float")
	
	steam1.free()
	steam2.free()
	wheel1.free()
	wheel2.free()
	adder.free()

## ========================================
## Diamond Pattern
## ========================================

func test_diamond_pattern() -> void:
	# Diamond: steam -> wheel1 \
	#                           adder
	#          steam -> wheel2 /
	var steam := SteamSource.new()
	steam.amplitude = 4.0
	
	var wheel1 := WeightWheel.new()
	wheel1.set_num_weights(1)
	wheel1.set_weight(0, 0.5)
	
	var wheel2 := WeightWheel.new()
	wheel2.set_num_weights(1)
	wheel2.set_weight(0, 0.25)
	
	var adder := AdderManifold.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2},
		{"name": "adder1", "part_id": "adder_manifold", "instance": adder}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "steam1", "from_port": 0, "to": "wheel2", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "adder1", "to_port": 0},
		{"from": "wheel2", "from_port": 0, "to": "adder1", "to_port": 1}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order.size(), 4, "Should execute 4 nodes")
	
	# Verify outputs exist
	var wheel1_output := forward_pass.get_node_output(ctx, "wheel1")
	var wheel2_output := forward_pass.get_node_output(ctx, "wheel2")
	var adder_output := forward_pass.get_node_output(ctx, "adder1")
	
	assert_not_null(wheel1_output, "wheel1 should produce output")
	assert_not_null(wheel2_output, "wheel2 should produce output")
	assert_not_null(adder_output, "adder should produce output")
	
	steam.free()
	wheel1.free()
	wheel2.free()
	adder.free()

## ========================================
## Activation Functions
## ========================================

func test_activation_gate_in_chain() -> void:
	# steam -> wheel -> activation -> wheel2
	var steam := SteamSource.new()
	steam.amplitude = 2.0  # Will oscillate, so sometimes negative
	
	var wheel1 := WeightWheel.new()
	wheel1.set_num_weights(1)
	wheel1.set_weight(0, 1.0)
	
	var activation := ActivationGate.new()
	activation.set_activation_function("relu")
	
	var wheel2 := WeightWheel.new()
	wheel2.set_num_weights(1)
	wheel2.set_weight(0, 2.0)
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "activation1", "part_id": "activation_gate", "instance": activation},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0},
		{"from": "wheel1", "from_port": 0, "to": "activation1", "to_port": 0},
		{"from": "activation1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	# Check intermediate values exist
	var wheel1_output := forward_pass.get_node_output(ctx, "wheel1")
	var activation_output := forward_pass.get_node_output(ctx, "activation1")
	var wheel2_output := forward_pass.get_node_output(ctx, "wheel2")
	
	assert_not_null(wheel1_output, "wheel1 should produce output")
	assert_not_null(activation_output, "activation gate should produce output")
	assert_not_null(wheel2_output, "wheel2 should produce output")
	# Note: Can't check exact values due to sine wave variability
	
	steam.free()
	wheel1.free()
	activation.free()
	wheel2.free()

## ========================================
## Context and Caching
## ========================================

func test_context_stores_all_activations() -> void:
	var steam := SteamSource.new()
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.activations.size(), 2, "Should store 2 activations")
	assert_has(ctx.activations, "steam1", "Should cache steam activation")
	assert_has(ctx.activations, "wheel1", "Should cache wheel activation")
	
	steam.free()
	wheel.free()

func test_context_stores_execution_order() -> void:
	var steam := SteamSource.new()
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order, ["steam1", "wheel1"], "Should record execution order")
	
	steam.free()
	wheel.free()

func test_context_tracks_timing() -> void:
	var steam := SteamSource.new()
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam}
	]
	
	graph.build_from_arrays(parts, [])
	var ctx := forward_pass.execute(graph)
	
	# Timing might be 0 on fast machines, so just check it's non-negative
	assert_true(ctx.total_time_ms >= 0.0, "Should track total time")
	assert_has(ctx.node_execution_times, "steam1", "Should track node time")
	assert_true(ctx.node_execution_times["steam1"] >= 0.0, "Node time should be non-negative")
	
	steam.free()

## ========================================
## Output Extraction
## ========================================

func test_get_output_values() -> void:
	# steam1 -> wheel1
	# steam2 -> wheel2
	# (two independent chains, so two sinks)
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
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	var outputs := forward_pass.get_output_values(ctx, graph)
	assert_eq(outputs.size(), 2, "Should have 2 sink outputs")
	
	steam1.free()
	steam2.free()
	wheel1.free()
	wheel2.free()

func test_get_all_outputs() -> void:
	var steam := SteamSource.new()
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "steam1", "part_id": "steam_source", "instance": steam},
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	var connections := [
		{"from": "steam1", "from_port": 0, "to": "wheel1", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	var ctx := forward_pass.execute(graph)
	
	var all_outputs := forward_pass.get_all_outputs(ctx)
	assert_eq(all_outputs.size(), 2, "Should return all node outputs")
	assert_has(all_outputs, "steam1", "Should include steam output")
	assert_has(all_outputs, "wheel1", "Should include wheel output")
	
	steam.free()
	wheel.free()

## ========================================
## Edge Cases
## ========================================

func test_empty_graph() -> void:
	# Expect warning about empty graph
	gut.p("Note: Warning about empty graph is expected")
	var ctx := forward_pass.execute(graph)
	
	assert_eq(ctx.execution_order.size(), 0, "Empty graph should process 0 nodes")
	assert_eq(ctx.activations.size(), 0, "Empty graph should have 0 activations")

func test_graph_with_cycle() -> void:
	# Create a cycle: wheel1 -> wheel2 -> wheel1
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
	
	graph.build_from_arrays(parts, connections)
	
	# Expect error/warning about cycle
	gut.p("Note: Error about cycle is expected for this test")
	var ctx := forward_pass.execute(graph)
	
	# Should not execute any nodes due to cycle
	assert_eq(ctx.execution_order.size(), 0, "Cycle should prevent execution")
	
	wheel1.free()
	wheel2.free()

## ========================================
## Performance
## ========================================

func test_large_linear_chain_performance() -> void:
	# Create a chain of 50 nodes
	var parts := []
	var connections := []
	var instances := []
	
	for i in range(50):
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
	
	graph.build_from_arrays(parts, connections)
	
	var start_time := Time.get_ticks_msec()
	var ctx := forward_pass.execute(graph)
	var elapsed := Time.get_ticks_msec() - start_time
	
	assert_eq(ctx.execution_order.size(), 50, "Should execute all 50 nodes")
	assert_true(elapsed < 100, "50-node chain should execute in < 100ms (got %dms)" % elapsed)
	
	# Clean up
	for instance in instances:
		instance.free()

