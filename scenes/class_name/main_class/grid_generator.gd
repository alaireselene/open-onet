class_name GridGenerator
extends FatherClass

const TILE_SCENE = preload("res://scenes/game_mode/core/tile/Tile.tscn") 
const PLACEHOLDER_SCENE = preload("res://scenes/game_mode/core/Placeholder.tscn")


# Called when the node enters the scene tree for the first time.
func set_grid_size(size: Vector2):
	grid_size = size

func set_inner_grid_size(size : Vector2):
	inner_grid_size = size

func set_pokemon_count(count: int):
	pokemon_count = count
	

func load_sprites(sprites_link):
	for i in range(pokemon_count):
		var texture = load(sprites_link % i)
		pokemon_sprites.append(texture)

	
func generate_grid():
	push_error("generate_grid() must be overridden by subclasses!")



func populate_grid(obj_main):
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			# Tính toán vị trí của từng ô
			var x = j * tile_size.x
			var y = i * tile_size.y

			if grid_data[i][j] == -1:  # Ô rỗng
				var placeholder = PLACEHOLDER_SCENE.instantiate()
				placeholder.position = Vector2(x, y)
				add_child(placeholder)
			else:  # Ô Pokémon
				var tile = TILE_SCENE.instantiate()
				var id = grid_data[i][j]
				tile.set_sprite(pokemon_sprites[id], id)
				tile.connect("tile_selected", Callable(obj_main, "_on_tile_selected"))
				tile.position = Vector2(x, y)
				add_child(tile)
