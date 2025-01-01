extends Node2D
	
var	arcade_generator : ArcadeGenerator
var	logic_match : LogicMatch



var selected_tiles = []
#const TILE_SCENE = preload("res://scenes/game_mode/core/tile/Tile.tscn") 
#const PLACEHOLDER_SCENE = preload("res://scenes/game_mode/core/Placeholder.tscn")
func _ready():

	arcade_generator = ArcadeGenerator.new()
	logic_match = LogicMatch.new()
	start_game()

func start_game():	
	add_child(arcade_generator)
	add_child(logic_match)
		 #gen map		
	arcade_generator.set_grid_size(GameSettings.grid_size)
	arcade_generator.set_inner_grid_size (GameSettings.inner_grid_size)
	arcade_generator.set_pokemon_count(GameSettings.pokemon_count)
	arcade_generator.load_sprites(GameSettings.sprites_link)       
	 #sprites_link="res://assets/sprites/pokemons/pokemon_%d.png"
	arcade_generator.generate_grid()
	arcade_generator.populate_grid(self)
	
	#logic_match.LogicMatch(arcade_generator.grid_data, arcade_generator.grid_size)
	#print(logic_match.grid_size)
	#arcade_generator.connect("tile_select", Callable(self, "_on_tile_select"))
	
func _on_tile_selected(tile):
	selected_tiles.append(tile)
	if selected_tiles.size() == 2:
		logic_match.process_match(selected_tiles)
		selected_tiles.clear()


#func refresh_grid():
	#for child in get_children():
		#child.quene_free()
	#arcade_generator.populate_grid()
