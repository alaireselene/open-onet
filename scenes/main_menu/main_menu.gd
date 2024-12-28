extends Control

var _setting_scene
var _setting_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	_setting_scene = load("res://scenes/setting/setting.tscn")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_settings_button_pressed():
	SceneHistory.go_to_scene("res://scenes/setting/setting.tscn")
	
func _on_shop_pressed():
	SceneHistory.go_to_scene("res://scenes/shop/shop.tscn")

func _on_achievement_pressed():
	SceneHistory.go_to_scene("res://scenes/achievement/achievement.tscn")

func _on_guide_button_pressed():
	SceneHistory.go_to_scene("res://scenes/guide/guide.tscn")


func _on_arcade_pressed():
	SceneHistory.go_to_scene("res://scenes/game_mode/arcade/arcade_mode.tscn")


func _on_inventory_pressed() -> void:
	SceneHistory.go_to_scene("res://scenes/inventory/inventory.tscn")
