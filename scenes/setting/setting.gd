extends Control

@onready var slider= $"Setting Panel/Container/Âm thanh/BGM/Volume Slider"

func _ready() -> void:
	slider.max_value = 7
	slider.value = (slider.min_value + slider.max_value)/2
	


func _on_back_pressed():
	SceneHistory.go_back()


func _on_volume_slider_value_changed(value: float) -> void:
	AudioPlayer.play()
	AudioServer.set_bus_volume_db(0, value)
