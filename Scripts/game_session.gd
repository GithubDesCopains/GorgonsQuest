extends Node

## Carries selected world/level across scene changes.
var selected_world: int = 1
var selected_level: int = 1

## Level editor test play: when set, this JSON level replaces the campaign slot.
var custom_level_path: String = ""
## File the editor was editing, so it can reopen it after a test play.
var editor_source_path: String = ""

func is_custom_level() -> bool:
	return not custom_level_path.is_empty()

func scene_after_level() -> String:
	return "res://Tools/level_editor.tscn" if is_custom_level() else "res://Scenes/overworld_map.tscn"
