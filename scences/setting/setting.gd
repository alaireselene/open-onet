extends Control
	

func _on_back_pressed():
	SceneHistory.go_back()	


func _on_volume_value_changed(value: float):
	$AudioStreamPlayer.play()
	AudioServer.set_bus_volume_db(0, value)


func _on_mute_toggled(toggled_on: bool):
	if toggled_on:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
