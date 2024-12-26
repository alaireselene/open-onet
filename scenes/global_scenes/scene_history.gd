# SceneHistory.gd
extends Node

var history: Array = []
var current_scene_path: String = ""



func go_to_scene(new_scene_path: String):
	if current_scene_path != "":
		history.append(current_scene_path)
	current_scene_path = new_scene_path
	get_tree().change_scene_to_file(new_scene_path)

func go_back():
	if history.size() > 0:
		var previous_scene = history.pop_back()
		current_scene_path = previous_scene
		get_tree().change_scene_to_file(previous_scene)
	else:
		print("No previous scene in history!")
