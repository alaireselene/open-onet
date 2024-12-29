extends Node2D
## Main game board controller that manages the Pokémon tile grid.
##
## Handles grid generation, tile placement, match detection, and game flow.
## Grid size is 10x10 with an inner 8x8 area containing Pokémon tiles.
## Outer edges are filled with placeholder tiles for boundary padding.
##
## Signals:
## - all_matched: Emitted when all tiles have been successfully matched and removed.
## - score_updated(new_score): Emitted whenever the score changes.
##
## Usage:
## - The node automatically generates and populates the grid upon scene loading.
## - Connect to "score_updated" to update any score UI element.
## - Connect to "all_matched" to transition to a victory sequence or next level.

# Constants
## The total size of the grid, including boundary placeholders.
const GRID_SIZE = 10
## The size of the inner playable grid, containing Pokémon tiles.
const INNER_GRID_SIZE = 8
## The total number of unique Pokémon sprite IDs to load.
const SPRITE_COUNT = 16
## Scene resource for the interactable Pokémon tile.
const TILE_SCENE = preload("res://scenes/game_mode/core/tile/Tile.tscn")
## Scene resource for the placeholder tile surrounding the grid.
const PLACEHOLDER_SCENE = preload("res://scenes/game_mode/core/Placeholder.tscn")
## Blank tile ID used to represent an empty grid cell.
const BLANK_TILE = -1

# Variables
## Array storing loaded Pokémon sprite textures.
var pokemon_sprites = []
## 2D array (10x10) tracking the logical state of each grid position (Pokémon ID or blank).
var grid_data = []
## Holds two selected tiles for matching.
var selected_tiles = []
## The size of each grid cell in pixels, used for layout and collision checks.
var tile_size = Vector2(120, 112)

## Emitted when all tiles are matched in the grid.
signal all_matched
## Emitted when the player’s score changes. [br]
## @param new_score The current total score after update.
signal score_updated(new_score)

## Called when the node is added to the scene tree. [br]
## Loads Pokémon sprites, generates a new grid, and populates the interface.
func _ready():
	## Initialize game board on scene load
	load_sprites()
	generate_grid()
	populate_grid()

## Loads Pokémon sprite textures and appends them to the local pokemon_sprites array.
func load_sprites():
	# Tải các sprite Pokémon vào danh sách
	for i in range(SPRITE_COUNT):
		var texture = load("res://assets/sprites/pokemons/pokemon_%d.png" % i)
		pokemon_sprites.append(texture)

## Generates a new 10x10 grid with inner 8x8 region for Pokémon. [br]
## The outer ring is left as blank (placeholder).
func generate_grid():
	grid_data.resize(GRID_SIZE)
	for i in range(GRID_SIZE):
		grid_data[i] = []
		for j in range(GRID_SIZE):
			grid_data[i].append(BLANK_TILE) # Default empty

	var pokemon_ids = []
	for id in range(SPRITE_COUNT):
		for temp in range(4):
			pokemon_ids.append(id)
	pokemon_ids.shuffle() 

	var index = 0
	for i in range(1, INNER_GRID_SIZE + 1):
		for j in range(1, INNER_GRID_SIZE + 1):
			grid_data[i][j] = pokemon_ids[index]
			index += 1

## Populates the Node2D scene with either a placeholder or a Pokémon tile [br]
## based on the contents of grid_data.
func populate_grid():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var x = j * tile_size.x
			var y = i * tile_size.y

			if grid_data[i][j] == BLANK_TILE: # Ô rỗng
				var placeholder = PLACEHOLDER_SCENE.instantiate()
				placeholder.position = Vector2(x, y)
				add_child(placeholder)
			else: # Ô Pokémon
				var tile = TILE_SCENE.instantiate()
				var id = grid_data[i][j]
				tile.set_sprite(pokemon_sprites[id], id)
				tile.connect("tile_selected", Callable(self, "_on_tile_selected"))
				tile.position = Vector2(x, y)
				add_child(tile)
	return

## Callback triggered when a tile emits "tile_selected". [br]
## Stores up to two tiles for matching, then processes a potential match.
func _on_tile_selected(tile):
	if len(selected_tiles) < 2:
		selected_tiles.append(tile)
		if len(selected_tiles) == 2:
			process_match()

## Checks whether two selected tiles match, removes them if valid, and updates score. [br]
func process_match():
	var tile1 = selected_tiles[0]
	var tile2 = selected_tiles[1]

	if tile1 == tile2:
		print("Không thể chọn cùng một ô!")
		reset_selection()
		return

	if tile1.pokemon_id != tile2.pokemon_id:
		print("Không giống nhau!")
		reset_selection()
		return

	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 == null or pos2 == null:
		print("Tile không hợp lệ!")
		reset_selection()
		return

	if can_match(pos1, pos2):
		print("Match thành công!")
		remove_tiles(tile1, tile2)
		
		# Tính điểm
		var gained_score = ScoreAlgorithms.add_score(2, TimeManager.finished_time1)  # Sử dụng time_since_last_match để tính điểm
		emit_signal("score_updated", ScoreAlgorithms.score)
		print("Điểm nhận được: ", gained_score)
		GameData.save_game()
		
		
		check_all_matched()  # Kiểm tra nếu tất cả đã được match
	else:
		print("Không thể match!")
	reset_selection()

## Checks if all tiles in the grid are matched (i.e., -1). [br]
## Emits all_matched signal if true.
func check_all_matched():
	var all_matched = true
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid_data[i][j] != BLANK_TILE:
				all_matched = false
				break
	if  all_matched:
		emit_signal("all_matched")

## Computes the (grid_x, grid_y) position of a tile from its pixel coordinates. [br]
## @return A Vector2 containing grid coordinates.
func get_tile_position(tile):
	var x = int(tile.position.x / tile_size.x)
	var y = int(tile.position.y / tile_size.y)
	return Vector2(x, y)

## Determines if two positions can be matched by checking possible paths: [br]
## straight line, one-corner, or two-corner path.
func can_match(pos1, pos2):
	if check_straight_line(pos1, pos2):
		return true
	if check_one_corner(pos1, pos2):
		return true
	if check_two_corners(pos1, pos2):
		return true
	return false

## Checks if pos1 and pos2 are aligned horizontally or vertically [br]
## and if no tiles block their path.
func check_straight_line(pos1, pos2):
	if pos1.y == pos2.y:
		for x in range(min(pos1.x, pos2.x) + 1, max(pos1.x, pos2.x)):
			if grid_data[int(pos1.y)][x] != BLANK_TILE:
				return false
		return true

	if pos1.x == pos2.x:
		for y in range(min(pos1.y, pos2.y) + 1, max(pos1.y, pos2.y)):
			if grid_data[y][int(pos1.x)] != BLANK_TILE:
				return false
		return true

	return false

## Checks for a path with a single corner that is unoccupied.
func check_one_corner(pos1, pos2):
	var corner1 = Vector2(pos1.x, pos2.y)
	var corner2 = Vector2(pos2.x, pos1.y)

	if is_valid_position(corner1) and grid_data[int(corner1.y)][int(corner1.x)] == BLANK_TILE:
		if check_straight_line(pos1, corner1) and check_straight_line(corner1, pos2):
			return true

	if is_valid_position(corner2) and grid_data[int(corner2.y)][int(corner2.x)] == BLANK_TILE:
		if check_straight_line(pos1, corner2) and check_straight_line(corner2, pos2):
			return true

	return false

## Checks for a path using two corners, ensuring both corners are free (-1) and [br]
## each path segment is valid.
func check_two_corners(pos1, pos2):
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var corner = Vector2(x, y)
			if is_valid_position(corner) and grid_data[int(corner.y)][int(corner.x)] == BLANK_TILE:
				if check_one_corner(pos1, corner) and check_straight_line(corner, pos2):
					return true
	return false

## Verifies that the given grid coordinates are within valid bounds.
func is_valid_position(pos):
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

## Removes two matched Pokémon tiles from the grid_data array and from the scene.
func remove_tiles(tile1, tile2):
	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 and pos2:
		grid_data[int(pos1.y)][int(pos1.x)] = BLANK_TILE
		grid_data[int(pos2.y)][int(pos2.x)] = BLANK_TILE

	# Xóa node Pokémon khỏi giao diện
	tile1.queue_free()
	tile2.queue_free()

## Clears and repopulates the grid in case of reload or texture updates.
func refresh_grid():
	for child in get_children():
		child.queue_free()
	populate_grid()

## Clears the selected_tiles array, allowing new selections to begin.
func reset_selection():
	selected_tiles.clear()
