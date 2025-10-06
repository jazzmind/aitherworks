class_name SimulationProfiler extends RefCounted
## Performance profiling utilities for the simulation engine.
##
## Provides timing measurements for critical paths to ensure 60 FPS (16ms budget).
## Per plan.md Technical Context:
## - Simulation loop: <16ms for 20-part machine
## - Forward/backward pass: <100ms for typical machines
## - Level load: <3s

# Performance budget constants (milliseconds)
const SIMULATION_BUDGET_MS: float = 16.0  # 60 FPS target
const FORWARD_PASS_BUDGET_MS: float = 100.0  # Typical machine budget
const LEVEL_LOAD_BUDGET_MS: float = 3000.0  # 3 second load time

# Profiling data storage
var _timing_data: Dictionary = {}
var _active_timers: Dictionary = {}
var _warnings_enabled: bool = true

## Start timing a named section.
##
## @param section_name: Unique identifier for the section being timed
func start_timer(section_name: String) -> void:
	_active_timers[section_name] = Time.get_ticks_msec()

## Stop timing a section and record the elapsed time.
##
## @param section_name: Must match a previously started timer
## @return: Elapsed time in milliseconds, or -1 if timer not found
func stop_timer(section_name: String) -> float:
	if not _active_timers.has(section_name):
		push_error("Profiler: No active timer for '%s'" % section_name)
		return -1.0
	
	var start_time: int = _active_timers[section_name]
	var elapsed: float = float(Time.get_ticks_msec() - start_time)
	
	# Remove from active timers
	_active_timers.erase(section_name)
	
	# Store timing data
	if not _timing_data.has(section_name):
		_timing_data[section_name] = []
	_timing_data[section_name].append(elapsed)
	
	# Check against budgets and warn if exceeded
	_check_budget(section_name, elapsed)
	
	return elapsed

## Check if elapsed time exceeds known budget and issue warning.
func _check_budget(section_name: String, elapsed: float) -> void:
	if not _warnings_enabled:
		return
	
	var budget: float = -1.0
	var budget_name: String = ""
	
	# Match section name to known budgets
	if section_name.contains("simulation") or section_name.contains("forward_backward"):
		budget = SIMULATION_BUDGET_MS
		budget_name = "simulation loop"
	elif section_name.contains("forward_pass") or section_name.contains("backward_pass"):
		budget = FORWARD_PASS_BUDGET_MS
		budget_name = "forward/backward pass"
	elif section_name.contains("level_load") or section_name.contains("load_level"):
		budget = LEVEL_LOAD_BUDGET_MS
		budget_name = "level load"
	
	if budget > 0 and elapsed > budget:
		push_warning("Performance: %s exceeded budget (%.1fms > %.1fms in '%s')" % [
			budget_name, elapsed, budget, section_name
		])

## Get timing statistics for a section.
##
## @param section_name: Section to get stats for
## @return: Dictionary with min, max, avg, count, or empty dict if no data
func get_stats(section_name: String) -> Dictionary:
	if not _timing_data.has(section_name):
		return {}
	
	var timings: Array = _timing_data[section_name]
	if timings.is_empty():
		return {}
	
	var total: float = 0.0
	var min_time: float = timings[0]
	var max_time: float = timings[0]
	
	for time in timings:
		total += time
		if time < min_time:
			min_time = time
		if time > max_time:
			max_time = time
	
	return {
		"min": min_time,
		"max": max_time,
		"avg": total / float(timings.size()),
		"count": timings.size(),
		"total": total
	}

## Clear all timing data.
func reset() -> void:
	_timing_data.clear()
	_active_timers.clear()

## Enable or disable budget warning messages.
func set_warnings_enabled(enabled: bool) -> void:
	_warnings_enabled = enabled

## Get all recorded section names.
func get_all_sections() -> Array[String]:
	var sections: Array[String] = []
	sections.assign(_timing_data.keys())
	return sections

## Print summary of all timing data to console.
func print_summary() -> void:
	print("\n=== Simulation Profiler Summary ===")
	
	for section_name in _timing_data.keys():
		var stats: Dictionary = get_stats(section_name)
		if stats.is_empty():
			continue
		
		print("%s:" % section_name)
		print("  Min: %.2f ms" % stats["min"])
		print("  Max: %.2f ms" % stats["max"])
		print("  Avg: %.2f ms" % stats["avg"])
		print("  Count: %d" % stats["count"])
	
	print("===================================\n")

## Measure a callable and return elapsed time + result.
##
## @param callable_obj: Callable to measure
## @param section_name: Name for profiling data
## @return: Dictionary with "elapsed" (float) and "result" (Variant)
func measure(callable_obj: Callable, section_name: String) -> Dictionary:
	start_timer(section_name)
	var result = callable_obj.call()
	var elapsed: float = stop_timer(section_name)
	
	return {
		"elapsed": elapsed,
		"result": result
	}

## Quick inline timer for one-off measurements.
##
## Example:
##   var timer = profiler.quick_timer()
##   do_expensive_operation()
##   print("Elapsed: %.2f ms" % timer.elapsed())
func quick_timer() -> QuickTimer:
	return QuickTimer.new()

## Quick timer helper class for inline measurements.
class QuickTimer extends RefCounted:
	var _start_time: int
	
	func _init() -> void:
		_start_time = Time.get_ticks_msec()
	
	func elapsed() -> float:
		return float(Time.get_ticks_msec() - _start_time)
	
	func reset() -> void:
		_start_time = Time.get_ticks_msec()

