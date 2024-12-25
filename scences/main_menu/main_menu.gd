extends Control

var _setting_scene
var _setting_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	_setting_scene = load("res://scences/setting/setting.tscn")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_setting_pressed():
	SceneHistory.go_to_scene("res://scences/setting/setting.tscn")
	


func _on_arcade_mode_gui_input(event: InputEvent):
	if Input.is_action_just_pressed("click"):
		SceneHistory.go_to_scene("res://scences/arcade_mode/arcade_mode.tscn")

func _on_shop_pressed():
	SceneHistory.go_to_scene("res://scences/shop/shop.tscn")

func _on_achievement_pressed():
	SceneHistory.go_to_scene("res://scences/achievement/achievement.tscn")

func _on_instruction_pressed():
	SceneHistory.go_to_scene("res://scences/instructions/instructions.tscn")
