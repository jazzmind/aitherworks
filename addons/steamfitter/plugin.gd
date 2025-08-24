@tool
extends EditorPlugin

##
# Steamfitter Editor Plugin
#
# This plugin is responsible for importing puzzle and part specifications
# written in YAML and generating corresponding Godot scenes and scripts.
# At the moment it provides only placeholder behaviour.  As you develop
# AItherworks further you should extend this plugin to parse YAML files
# under `res://data/specs/` and `res://data/parts/` and construct
# reusable scene hierarchies.

const SPEC_ROOT := "res://data/specs"
const PART_ROOT := "res://data/parts"

func _enter_tree() -> void:
    # Called when the plugin is loaded into the editor.  Use this
    # function to register custom types, menu items, or dock panels.
    print("Steamfitter plugin loaded (placeholder)")

    # TODO: register import actions for YAML specs.


func _exit_tree() -> void:
    # Called when the plugin is unloaded from the editor.  Unregister
    # anything you added in _enter_tree.
    print("Steamfitter plugin unloaded (placeholder)")

    # TODO: clean up registered types or menu items.


## Utility: scan for YAML files (example)
func _find_yaml_files(root_path: String) -> Array:
    # Returns an array of file paths for all .yaml files under the given
    # directory.  This is a simple helper function that can be used
    # when implementing your spec importer.  It runs in the editor,
    # so avoid expensive operations.
    var dir := DirAccess.open(root_path)
    if dir == null:
        return []
    var results := []
    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        var path := root_path + "/" + file_name
        if file_name.ends_with(".yaml"):
            results.append(path)
        elif dir.current_is_dir():
            results += _find_yaml_files(path)
        file_name = dir.get_next()
    dir.list_dir_end()
    return results
