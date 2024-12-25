extends Button

var pokemon_id = -1
signal tile_selected(tile)
func set_sprite(texture, id):
	$MarginContainer/TextureRect.texture = texture
	pokemon_id = id
	
	
func _on_pressed():
	emit_signal("tile_selected", self)
	
