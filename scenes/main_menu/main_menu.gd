extends Control

var _scenes = {
	"settings": preload("res://scenes/setting/setting.tscn"),
	"shop": preload("res://scenes/shop/shop.tscn"),
	"achievement": preload("res://scenes/achievement/achievement.tscn"),
	"guide": preload("res://scenes/guide/guide.tscn"),
	"arcade": preload("res://scenes/game_mode/arcade/arcade_mode.tscn"),
	"inventory": preload("res://scenes/inventory/inventory.tscn")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioPlayer.play_music_main_menu()

func _process(_delta):
	pass

func _on_settings_button_pressed():
	SceneHistory.go_to_scene(_scenes["settings"].resource_path)
	
func _on_shop_pressed():
	SceneHistory.go_to_scene(_scenes["shop"].resource_path)

func _on_achievement_pressed():
	SceneHistory.go_to_scene(_scenes["achievement"].resource_path)

#func _on_guide_button_pressed():
	#SceneHistory.go_to_scene("res://scenes/guide/guide.tscn")

func _on_guide_button_pressed():
	SceneHistory.go_to_scene(_scenes["guide"].resource_path)

func _on_arcade_pressed():
	SceneHistory.go_to_scene(_scenes["arcade"].resource_path)

func _on_inventory_pressed():
	SceneHistory.go_to_scene(_scenes["inventory"].resource_path)
