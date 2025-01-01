extends Node

# Các thông số về lưới và Pokémon cho từng màn chơi
var grid_size = Vector2(10, 10)  # Mặc định cho màn 1
var inner_grid_size = Vector2(8, 8)  # Mặc định cho màn 1
var pokemon_count = 16  # Mặc định cho màn 1
var pokemon_per_tile = 4  # Số lần xuất hiện của mỗi Pokémon
var current_level = 1
var sprites_link = "res://assets/sprites/pokemons/pokemon_%d.png"

func _ready():
	pass

func set_level(level: int):
	match level:
		1:
			grid_size = Vector2(10, 10)
			inner_grid_size = Vector2(8, 8)
			pokemon_count = 16
			current_level = 1
		2:
			grid_size = Vector2(8, 12)
			inner_grid_size = Vector2(6, 10)
			pokemon_count = 15
			current_level = 2
		3:
			grid_size = Vector2(14, 20)
			inner_grid_size = Vector2(12, 18)
			pokemon_count = 54
			current_level = 3
		_:
			print("Level không hợp lệ")
			
var screen_positions = {
	1: Vector2(330, -12),
	2: Vector2(270, 50),
	3: Vector2(254, 35)
}

# Hàm để thay đổi màn chơi
var screen_scales = {
	1: Vector2(0.6, 0.6),  # Màn 1 có scale 1x
	2: Vector2(0.6, 0.6),  # Màn 2 có scale nhỏ hơn
	3: Vector2(0.37, 0.37)   # Màn 3 có scale lớn hơn
}

func get_main_scale() -> Vector2:
	return screen_scales.get(current_level, Vector2(1, 1))
# Hàm để lấy vị trí của main theo màn chơi
func get_main_position() -> Vector2:
	return screen_positions.get(current_level, Vector2(0, 0))
	
