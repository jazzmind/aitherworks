extends Node
class_name AetherBattery

## Aether Battery
#
# Stores and recalls learned patterns using crystallized aether.
# Acts as memory storage for neural networks, embedding layers,
# and attention mechanisms. Can store vector representations
# and retrieve them based on similarity or index.

@export var storage_capacity: int = 100 : set = set_storage_capacity
@export var vector_dimension: int = 16 : set = set_vector_dimension
@export var retrieval_threshold: float = 0.8 : set = set_retrieval_threshold
@export var decay_rate: float = 0.001 : set = set_decay_rate

signal capacity_changed(new_capacity: int)
signal dimension_changed(new_dimension: int)
signal threshold_changed(new_threshold: float)
signal decay_changed(new_decay: float)
signal pattern_stored(index: int, pattern: Array)
signal pattern_retrieved(index: int, pattern: Array, similarity: float)

var memory_bank: Array = []
var access_counts: Array = []
var last_access_time: Array = []
var current_time: float = 0.0

func set_storage_capacity(value: int) -> void:
	storage_capacity = max(1, value)
	emit_signal("capacity_changed", storage_capacity)
	_resize_memory()

func set_vector_dimension(value: int) -> void:
	vector_dimension = max(1, value)
	emit_signal("dimension_changed", vector_dimension)
	_reset_memory()

func set_retrieval_threshold(value: float) -> void:
	retrieval_threshold = clampf(value, 0.0, 1.0)
	emit_signal("threshold_changed", retrieval_threshold)

func set_decay_rate(value: float) -> void:
	decay_rate = clampf(value, 0.0, 0.1)
	emit_signal("decay_changed", decay_rate)

func _resize_memory() -> void:
	"""Resize memory bank to match capacity"""
	memory_bank.resize(storage_capacity)
	access_counts.resize(storage_capacity)
	last_access_time.resize(storage_capacity)
	
	for i in range(storage_capacity):
		if memory_bank[i] == null:
			memory_bank[i] = _create_empty_vector()
			access_counts[i] = 0
			last_access_time[i] = 0.0

func _reset_memory() -> void:
	"""Reset all memory with new dimensions"""
	memory_bank.clear()
	access_counts.clear()
	last_access_time.clear()
	_resize_memory()

func _create_empty_vector() -> Array:
	"""Create an empty vector of the current dimension"""
	var vector: Array = []
	for i in range(vector_dimension):
		vector.append(0.0)
	return vector

func store_pattern(pattern: Array, index: int = -1) -> int:
	"""Store a pattern in memory, return the index where it was stored"""
	current_time += 1.0
	
	if pattern.size() != vector_dimension:
		print("Warning: Pattern dimension mismatch")
		return -1
	
	var storage_index: int = index
	
	# If no index specified, find best slot
	if storage_index == -1:
		storage_index = _find_storage_slot()
	
	# Ensure index is valid
	storage_index = clamp(storage_index, 0, storage_capacity - 1)
	
	# Store the pattern
	memory_bank[storage_index] = pattern.duplicate()
	access_counts[storage_index] = 1
	last_access_time[storage_index] = current_time
	
	emit_signal("pattern_stored", storage_index, pattern)
	return storage_index

func retrieve_pattern(query: Array) -> Dictionary:
	"""Retrieve the most similar pattern from memory"""
	current_time += 1.0
	
	if query.size() != vector_dimension:
		return {"found": false, "pattern": [], "similarity": 0.0, "index": -1}
	
	var best_similarity: float = 0.0
	var best_index: int = -1
	var best_pattern: Array = []
	
	# Search through memory bank
	for i in range(memory_bank.size()):
		if memory_bank[i] != null:
			var similarity: float = _calculate_similarity(query, memory_bank[i])
			
			if similarity > best_similarity and similarity >= retrieval_threshold:
				best_similarity = similarity
				best_index = i
				best_pattern = memory_bank[i].duplicate()
	
	# Update access tracking
	if best_index != -1:
		access_counts[best_index] += 1
		last_access_time[best_index] = current_time
		emit_signal("pattern_retrieved", best_index, best_pattern, best_similarity)
	
	return {
		"found": best_index != -1,
		"pattern": best_pattern,
		"similarity": best_similarity,
		"index": best_index
	}

func _find_storage_slot() -> int:
	"""Find the best slot to store a new pattern"""
	# First, try to find an empty slot
	for i in range(memory_bank.size()):
		if _is_empty_vector(memory_bank[i]):
			return i
	
	# If no empty slots, find least recently used with decay
	var oldest_time: float = current_time
	var oldest_index: int = 0
	
	for i in range(memory_bank.size()):
		var adjusted_time: float = last_access_time[i] - (access_counts[i] * decay_rate)
		if adjusted_time < oldest_time:
			oldest_time = adjusted_time
			oldest_index = i
	
	return oldest_index

func _is_empty_vector(vector: Array) -> bool:
	"""Check if a vector is empty (all zeros)"""
	if vector == null or vector.size() == 0:
		return true
	
	for value in vector:
		if abs(float(value)) > 1e-6:
			return false
	
	return true

func _calculate_similarity(vector_a: Array, vector_b: Array) -> float:
	"""Calculate cosine similarity between two vectors"""
	if vector_a.size() != vector_b.size():
		return 0.0
	
	var dot_product: float = 0.0
	var magnitude_a: float = 0.0
	var magnitude_b: float = 0.0
	
	for i in range(vector_a.size()):
		var a: float = float(vector_a[i])
		var b: float = float(vector_b[i])
		
		dot_product += a * b
		magnitude_a += a * a
		magnitude_b += b * b
	
	magnitude_a = sqrt(magnitude_a)
	magnitude_b = sqrt(magnitude_b)
	
	if magnitude_a == 0.0 or magnitude_b == 0.0:
		return 0.0
	
	return dot_product / (magnitude_a * magnitude_b)

func get_memory_usage() -> float:
	"""Get percentage of memory currently in use"""
	var used_slots: int = 0
	for vector in memory_bank:
		if not _is_empty_vector(vector):
			used_slots += 1
	
	return float(used_slots) / float(storage_capacity)

func get_status() -> Dictionary:
	"""Get current status for debugging and UI display"""
	return {
		"type": "Aether Battery",
		"storage_capacity": storage_capacity,
		"vector_dimension": vector_dimension,
		"memory_usage": get_memory_usage(),
		"retrieval_threshold": retrieval_threshold,
		"decay_rate": decay_rate,
		"total_accesses": current_time
	}

func _ready() -> void:
	_resize_memory()
