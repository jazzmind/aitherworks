extends Node

## Backstory Transition Helper
# Provides easy functions to transition to the backstory scene for different chapters

func show_chapter_backstory(chapter_number: int) -> void:
	"""Transition to the backstory scene for a specific chapter"""
	
	# Change to the backstory scene
	get_tree().change_scene_to_file("res://game/ui/backstory_scene.tscn")
	
	# Wait for the scene to be ready, then set the chapter
	await get_tree().process_frame
	
	# Find the backstory scene and set the chapter
	var backstory_scene = get_tree().current_scene
	if backstory_scene.has_method("set_chapter"):
		backstory_scene.set_chapter(chapter_number)

func show_act_backstory(act_number: int) -> void:
	"""Show backstory for a specific act (same as chapter)"""
	show_chapter_backstory(act_number)

# Example usage functions for different story moments
func show_intro_backstory() -> void:
	"""Show the introduction backstory (Chapter 1)"""
	show_chapter_backstory(1)

func show_act_2_backstory() -> void:
	"""Show Act II backstory"""
	show_chapter_backstory(2)

func show_act_3_backstory() -> void:
	"""Show Act III backstory"""
	show_chapter_backstory(3)

func show_act_4_backstory() -> void:
	"""Show Act IV backstory"""
	show_chapter_backstory(4)

func show_act_5_backstory() -> void:
	"""Show Act V backstory"""
	show_chapter_backstory(5)

func show_act_6_backstory() -> void:
	"""Show Act VI backstory"""
	show_chapter_backstory(6)
