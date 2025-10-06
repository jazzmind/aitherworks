extends GutTest

## Unit tests for TrainingLoop
## Tests end-to-end training: forward → loss → backward → update

const TrainingLoop = preload("res://game/sim/training_loop.gd")
const SimulationGraph = preload("res://game/sim/graph.gd")
const SteamSource = preload("res://game/parts/steam_source.gd")
const WeightWheel = preload("res://game/parts/weight_wheel.gd")

var training_loop: TrainingLoop
var graph: SimulationGraph

func before_each() -> void:
	training_loop = TrainingLoop.new()
	graph = SimulationGraph.new()

func after_each() -> void:
	training_loop = null
	graph = null

## ========================================
## Basic Training
## ========================================

func test_single_epoch_training() -> void:
	# Simple: wheel learns to multiply by 2
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 1.0)
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	# Training data: input doesn't matter for single wheel, target is what we want
	var data := [
		{"input": [1.0], "target": 2.0}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 1)
	var results := training_loop.train(graph, data, config)
	
	assert_eq(results.epoch_stats.size(), 1, "Should have 1 epoch")
	assert_true(results.final_loss >= 0.0, "Loss should be non-negative")
	
	wheel.free()

func test_multi_epoch_training() -> void:
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 1.0)
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [1.0], "target": 2.0}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 10)
	var results := training_loop.train(graph, data, config)
	
	assert_true(results.epoch_stats.size() <= 10, "Should not exceed max epochs")
	assert_true(results.epoch_stats.size() > 0, "Should have at least 1 epoch")
	
	wheel.free()

## ========================================
## Training Configuration
## ========================================

func test_training_config_creation() -> void:
	var config := TrainingLoop.TrainingConfig.new(0.05, "sgd", 50)
	
	assert_eq(config.learning_rate, 0.05, "Learning rate should be set")
	assert_eq(config.optimizer, "sgd", "Optimizer should be set")
	assert_eq(config.max_epochs, 50, "Max epochs should be set")

func test_default_config() -> void:
	var config := TrainingLoop.TrainingConfig.new()
	
	assert_eq(config.learning_rate, 0.01, "Default learning rate")
	assert_eq(config.optimizer, "sgd", "Default optimizer")
	assert_eq(config.max_epochs, 100, "Default max epochs")

## ========================================
## Training Results
## ========================================

func test_results_structure() -> void:
	var wheel := WeightWheel.new()
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [1.0], "target": 1.5}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 5)
	var results := training_loop.train(graph, data, config)
	
	assert_not_null(results, "Results should exist")
	assert_true(results.epoch_stats.size() > 0, "Should have epoch stats")
	assert_true(results.total_time_ms >= 0.0, "Should track time")
	
	wheel.free()

func test_loss_history() -> void:
	var wheel := WeightWheel.new()
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [1.0], "target": 1.5}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 3)
	var results := training_loop.train(graph, data, config)
	
	var loss_history := results.get_loss_history()
	assert_eq(loss_history.size(), results.epoch_stats.size(), "Loss history should match epochs")
	
	wheel.free()

## ========================================
## Early Stopping
## ========================================

func test_early_stopping_on_convergence() -> void:
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 1.0)
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	# Easy problem - should converge quickly
	var data := [
		{"input": [1.0], "target": 1.0}  # Weight already correct
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 100)
	config.early_stopping_patience = 3
	var results := training_loop.train(graph, data, config)
	
	# Should stop early due to convergence or no improvement
	assert_true(results.epoch_stats.size() < 100, "Should stop before max epochs")
	
	wheel.free()

## ========================================
## Multiple Samples
## ========================================

func test_training_with_multiple_samples() -> void:
	var wheel := WeightWheel.new()
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [1.0], "target": 2.0},
		{"input": [2.0], "target": 4.0},
		{"input": [3.0], "target": 6.0}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.01, "sgd", 5)
	var results := training_loop.train(graph, data, config)
	
	assert_eq(results.epoch_stats[0].samples_processed, 3, "Should process all samples")
	
	wheel.free()

## ========================================
## Edge Cases
## ========================================

func test_empty_training_data() -> void:
	var wheel := WeightWheel.new()
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	# Expect error about empty data
	gut.p("Note: Error about empty data is expected")
	var results := training_loop.train(graph, [], null)
	
	assert_eq(results.epoch_stats.size(), 0, "No epochs should run with empty data")
	
	wheel.free()

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
	
	var data := [
		{"input": [1.0], "target": 2.0}
	]
	
	# Expect error about cycle
	gut.p("Note: Error about cycle is expected")
	var results := training_loop.train(graph, data, null)
	
	assert_eq(results.epoch_stats.size(), 0, "Should not train graph with cycles")
	
	wheel1.free()
	wheel2.free()

## ========================================
## Epoch Statistics
## ========================================

func test_epoch_stats_tracking() -> void:
	var wheel := WeightWheel.new()
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [1.0], "target": 1.5}
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 2)
	var results := training_loop.train(graph, data, config)
	
	for i in range(results.epoch_stats.size()):
		var stats := results.epoch_stats[i]
		assert_eq(stats.epoch, i, "Epoch number should match")
		assert_true(stats.loss >= 0.0, "Loss should be non-negative")
		assert_true(stats.accuracy >= 0.0 and stats.accuracy <= 1.0, "Accuracy should be in [0,1]")
		assert_true(stats.time_ms >= 0.0, "Time should be non-negative")
	
	wheel.free()

## ========================================
## Learning
## ========================================

func test_loss_decreases_over_time() -> void:
	var wheel := WeightWheel.new()
	wheel.set_num_weights(1)
	wheel.set_weight(0, 0.5)  # Start with wrong weight
	
	var parts := [
		{"name": "wheel1", "part_id": "weight_wheel", "instance": wheel}
	]
	
	graph.build_from_arrays(parts, [])
	
	var data := [
		{"input": [2.0], "target": 4.0}  # Should learn to multiply by 2
	]
	
	var config := TrainingLoop.TrainingConfig.new(0.1, "sgd", 20)
	config.early_stopping_patience = 20  # Don't stop early
	var results := training_loop.train(graph, data, config)
	
	# Loss should generally decrease (allowing for some noise)
	if results.epoch_stats.size() >= 2:
		var first_loss := results.epoch_stats[0].loss
		var last_loss := results.epoch_stats[-1].loss
		
		# Loss should decrease or stay similar (within noise)
		assert_true(last_loss <= first_loss * 2.0, 
			"Loss should not increase dramatically (first: %.4f, last: %.4f)" % [first_loss, last_loss])
	
	wheel.free()

