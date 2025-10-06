extends GutTest

## Unit tests for BackwardPass
## Tests gradient computation, backpropagation, and parameter updates

const BackwardPass = preload("res://game/sim/backward_pass.gd")
const ForwardPass = preload("res://game/sim/forward_pass.gd")
const SimulationGraph = preload("res://game/sim/graph.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")
const AdderManifold = preload("res://game/parts/adder_manifold.gd")
const ActivationGate = preload("res://game/parts/activation_gate.gd")

var backward_pass: BackwardPass
var forward_pass: ForwardPass
var graph: SimulationGraph

func before_each() -> void:
	backward_pass = BackwardPass.new()
	forward_pass = ForwardPass.new()
	graph = SimulationGraph.new()
	assert_not_null(graph, "Graph should be created")

func after_each() -> void:
	backward_pass = null
	forward_pass = null
	graph = null

## ========================================
## Basic Backward Pass
## ========================================

func test_single_node_backward() -> void:
	# Single weight wheel
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 2.0)
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	# Forward pass
	var forward_ctx := forward_pass.execute(graph)
	
	# Backward pass with gradient of 1.0
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	assert_has(backward_ctx.accumulated_gradients, "wheel1", "Should have gradient for wheel1")
	assert_eq(backward_ctx.accumulated_gradients["wheel1"], 1.0, "Gradient should be 1.0")
	
	wheel.free()

func test_linear_chain_backward() -> void:
	# steam -> wheel
	var steam := SteamSource.new()
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
	
	# Forward and backward
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	# Both nodes should have gradients
	assert_has(backward_ctx.accumulated_gradients, "wheel1", "Wheel should have gradient")
	assert_has(backward_ctx.accumulated_gradients, "steam1", "Steam should have gradient")
	
	# Gradient should flow backward
	var wheel_grad: float = backward_ctx.accumulated_gradients.get("wheel1", 0.0)
	var steam_grad: float = backward_ctx.accumulated_gradients.get("steam1", 0.0)
	assert_eq(wheel_grad, 1.0, "Wheel gradient should be 1.0")
	assert_ne(steam_grad, 0.0, "Steam gradient should not be zero")
	
	steam.free()
	wheel.free()

## ========================================
## Gradient Accumulation
## ========================================

func test_multiple_outputs_accumulate_gradients() -> void:
	# Diamond pattern: steam -> wheel1 \
	#                                    adder
	#                  steam -> wheel2 /
	var steam := SteamSource.new()
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
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
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	# Steam source receives gradients from both paths
	var steam_grad := backward_ctx.accumulated_gradients.get("steam1", 0.0)
	assert_gt(steam_grad, 0.0, "Steam should receive accumulated gradients from both paths")
	
	steam.free()
	wheel1.free()
	wheel2.free()
	adder.free()

## ========================================
## Activation Function Gradients
## ========================================

func test_relu_gradient() -> void:
	# wheel -> relu -> wheel2
	var wheel1 := WeightWheel.new()
	var activation := ActivationGate.new()
	activation.activation_type = ActivationGate.ActivationType.RELU
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "relu1", "part_id": "activation_gate", "instance": activation},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "wheel1", "from_port": 0, "to": "relu1", "to_port": 0},
		{"from": "relu1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	# Check that gradients exist for all nodes
	assert_has(backward_ctx.accumulated_gradients, "wheel2", "wheel2 should have gradient")
	assert_has(backward_ctx.accumulated_gradients, "relu1", "ReLU should have gradient")
	assert_has(backward_ctx.accumulated_gradients, "wheel1", "wheel1 should have gradient")
	
	wheel1.free()
	activation.free()
	wheel2.free()

## ========================================
## Edge Gradients
## ========================================

func test_edge_gradients_stored() -> void:
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "wheel1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	# Edge gradients should be stored
	assert_gt(backward_ctx.edge_gradients.size(), 0, "Should store edge gradients")
	
	wheel1.free()
	wheel2.free()

## ========================================
## Gradient Queries
## ========================================

func test_get_node_gradient() -> void:
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 2.5)
	
	var grad := backward_pass.get_node_gradient(backward_ctx, "wheel1")
	assert_eq(grad, 2.5, "Should retrieve node gradient")
	
	wheel.free()

func test_get_all_gradients() -> void:
	var wheel1 := WeightWheel.new()
	var wheel2 := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel1},
		{"name": "wheel2", "part_id": "weight_wheel", "instance": wheel2}
	]
	var connections := [
		{"from": "wheel1", "from_port": 0, "to": "wheel2", "to_port": 0}
	]
	
	graph.build_from_arrays(parts, connections)
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	var all_grads := backward_pass.get_all_gradients(backward_ctx)
	assert_eq(all_grads.size(), 2, "Should return all node gradients")
	assert_has(all_grads, "wheel1", "Should include wheel1")
	assert_has(all_grads, "wheel2", "Should include wheel2")
	
	wheel1.free()
	wheel2.free()

## ========================================
## Context Management
## ========================================

func test_context_tracks_timing() -> void:
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	assert_true(backward_ctx.total_time_ms >= 0.0, "Should track total time")
	assert_has(backward_ctx.node_execution_times, "wheel1", "Should track node time")
	
	wheel.free()

## ========================================
## Edge Cases
## ========================================

func test_empty_graph() -> void:
	var forward_ctx := forward_pass.execute(graph)
	
	# Expect warning
	gut.p("Note: Warning about empty graph is expected")
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	assert_eq(backward_ctx.accumulated_gradients.size(), 0, "Empty graph should have no gradients")

func test_graph_with_cycle() -> void:
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
	
	var forward_ctx := forward_pass.execute(graph)
	
	# Expect warning
	gut.p("Note: Warning about cycle is expected")
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	
	# Should not execute
	assert_eq(backward_ctx.accumulated_gradients.size(), 0, "Cycle should prevent execution")
	
	wheel1.free()
	wheel2.free()

func test_zero_gradient() -> void:
	var wheel := WeightWheel.new()
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var forward_ctx := forward_pass.execute(graph)
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 0.0)
	
	var grad := backward_pass.get_node_gradient(backward_ctx, "wheel1")
	assert_eq(grad, 0.0, "Zero gradient should propagate")
	
	wheel.free()

## ========================================
## Performance
## ========================================

func test_backward_pass_performance() -> void:
	# Create chain of 20 nodes
	var parts := []
	var connections := []
	var instances := []
	
	for i in range(20):
		var wheel := WeightWheel.new()
		instances.append(wheel)
		parts.append({
			"name": "wheel%d" % i,
			"part_id": "weight_wheel",
			"instance": wheel
		})
		
		if i > 0:
			connections.append({
				"from": "wheel%d" % (i - 1),
				"from_port": 0,
				"to": "wheel%d" % i,
				"to_port": 0
			})
	
	graph.build_from_arrays(parts, connections)
	
	var forward_ctx := forward_pass.execute(graph)
	
	var start_time := Time.get_ticks_msec()
	var backward_ctx := backward_pass.execute(graph, forward_ctx, 1.0)
	var elapsed := Time.get_ticks_msec() - start_time
	
	assert_eq(backward_ctx.accumulated_gradients.size(), 20, "Should compute all gradients")
	assert_true(elapsed < 100, "20-node chain should backprop in < 100ms (got %dms)" % elapsed)
	
	# Clean up
	for instance in instances:
		instance.free()

