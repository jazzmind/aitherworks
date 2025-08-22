extends Node
class_name WeightWheel

##
# WeightWheel
#
# This is a placeholder implementation of a weight wheel part.
# It scales an incoming signal by an adjustable weight parameter.
# In a full implementation it would interface with the simulation
# layer to multiply tensor values and propagate gradients.

@export var weight: float = 1.0 : set = set_weight
signal weight_changed(new_weight: float)

func set_weight(value: float) -> void:
    weight = value
    emit_signal("weight_changed", weight)

func _ready() -> void:
    # TODO: connect this part to simulation input/output when
    # generating a machine.  For now it only stores the weight.
    pass