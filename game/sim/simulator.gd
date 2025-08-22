extends Node

##
# Simulator
#
# This script will host the deterministic simulation core for
# Signalworks.  During runtime it manages the propagation of signals,
# the accumulation of gradients and the application of optimizers.
#
# For now the simulator does nothing; it exists to provide a stable
# entry point for future development.  You can attach this script
# to a node in your main scene or instantiate it dynamically.

func _ready() -> void:
    # Perform any initialisation here.
    pass

func _process(delta: float) -> void:
    # Placeholder update loop.  The simulation will eventually
    # iterate over parts, propagate signals and apply training
    # operations.  Until then this method does nothing.
    pass