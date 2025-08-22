extends Node

## Act1Engine
# Minimal numeric core to support Act I levels:
# - Forward: per-lane Weight Wheels, optional Activation (ReLU)
# - Loss: MSE for vector targets
# - Backward: per-lane gradients and SGD update

class_name Act1Engine

signal epoch_completed(epoch: int, loss: float)

var learning_rate: float = 0.05
var use_relu: bool = false
var num_lanes: int = 3

func set_num_lanes(lanes: int) -> void:
	num_lanes = max(1, lanes)
	if _weights.size() != num_lanes:
		_weights.resize(num_lanes)
		for i in range(num_lanes):
			if typeof(_weights[i]) != TYPE_FLOAT:
				_weights[i] = 1.0

func run_epoch(samples: Array) -> float:
	# samples: Array of dictionaries {"x": PoolRealArray or Array[float], "y": PoolRealArray}
	var total_loss: float = 0.0
	for s in samples:
		var x: Array = s["x"]
		var y: Array = s["y"]
		if x.size() != _weights.size():
			# adjust lanes if needed
			set_num_lanes(x.size())
		var ctx: Dictionary = {}
		var y_hat: Array = _forward(x, ctx)
		var loss: float = _mse(y_hat, y)
		total_loss += loss
		var grad: Array = _mse_grad(y_hat, y)
		_backward(ctx, grad)
	var avg: float = total_loss / max(1, samples.size())
	return avg

func _forward(x: Array, ctx: Dictionary) -> Array:
	# Simple chain: x ⊙ w -> (optional relu)
	# Store intermediates for backprop
	ctx.clear()
	ctx["x"] = x.duplicate()
	var z: Array = []
	for i in range(x.size()):
		var w: float = float(_weights[i])
		z.append(float(x[i]) * w)
	ctx["z"] = z
	var a: Array = z
	if use_relu:
		a = []
		for v in z:
			a.append(max(0.0, float(v)))
		ctx["relu_mask"] = z
	ctx["a"] = a
	return a

func _backward(ctx: Dictionary, dL_da: Array) -> void:
	var dL_dz: Array = dL_da
	if use_relu and ctx.has("relu_mask"):
		dL_dz = []
		var mask: Array = ctx["relu_mask"]
		for i in range(mask.size()):
			dL_dz.append(float(dL_da[i]) if float(mask[i]) > 0.0 else 0.0)
	var x: Array = ctx["x"]
	# per-lane grad: dL/dw_i = dL/dz_i * x_i
	for i in range(x.size()):
		var grad_w: float = float(dL_dz[i]) * float(x[i])
		_apply_sgd(i, grad_w)

func _mse(y_hat: Array, y: Array) -> float:
	var s: float = 0.0
	for i in range(y_hat.size()):
		var e: float = (float(y_hat[i]) - float(y[i]))
		s += e * e
	return s / max(1, y_hat.size())

func _mse_grad(y_hat: Array, y: Array) -> Array:
	var g: Array = []
	var n: int = max(1, y_hat.size())
	for i in range(y_hat.size()):
		g.append(2.0 * (float(y_hat[i]) - float(y[i])) / float(n))
	return g

# State for per-lane weight wheels (Act I scope)
var _weights: Array[float] = [1.0, 1.0, 1.0]

func get_weights() -> Array:
	return _weights.duplicate()

func set_weight_at(index: int, value: float) -> void:
	if index >= 0 and index < _weights.size():
		_weights[index] = value

func set_all_weights(value: float) -> void:
	for i in range(_weights.size()):
		_weights[i] = value

func _apply_sgd(i: int, grad_w: float) -> void:
	if i >= 0 and i < _weights.size():
		_weights[i] -= learning_rate * grad_w
