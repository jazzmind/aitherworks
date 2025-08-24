extends Node

## Basic tests for SpecValidator and part processing

func _ready() -> void:
	print("[TEST] Running SpecValidator tests...")
	var validator := SpecValidator.new()
	var res := validator.validate_parts_and_specs("res://data/parts", "res://data/specs")
	assert(res.has("ok"))
	assert(res.has("messages"))
	print("[TEST] Validator OK:", res.ok)
	for m in res.messages:
		print("[VALIDATOR] ", m)

	print("[TEST] Part processing smoke test...")
	# Create a WeightWheel and test processing
	var wheel := WeightWheel.new()
	wheel.set_weights([1.0, 2.0, -1.0])
	var out := wheel.process_signals([1.0, 1.0, 1.0])
	assert(abs(out - 2.0) < 0.0001)
	# Activation gate
	var gate := ActivationGate.new()
	gate.activation_type = ActivationGate.ActivationType.RELU
	var gout := gate.apply_activation(-1.0)
	assert(gout == 0.0)
	print("[TEST] Part processing passed.")

