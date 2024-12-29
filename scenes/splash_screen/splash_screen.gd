extends Control


var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Splash Screen")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_click"):
		print("Mouse Click")
		SceneHistory.go_to_scene(main_menu_scene)
