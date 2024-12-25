extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Splash Screen")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("click"):
		print("Mouse Click")
		SceneHistory.go_to_scene("res://scences/main_menu/main_menu.tscn")
