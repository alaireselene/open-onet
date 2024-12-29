extends Node2D

signal score_updated(score: int)
signal _on_all_matched
signal tile_selected(tile: Node2D)

@onready var level_data = preload("res://scenes/game_mode/core/main/LevelData.gd").new()

var grid_data: Array = []
var selected_tile: Node2D = null
var can_play: bool = true

func _ready():
	var current_level = GameData.current_level
	if level_data.load_level(current_level):
		initialize_grid()
		print("Level loaded successfully")
	else:
		push_error("Failed to load level data")

func initialize_grid():
	grid_data.clear()

	# Create grid based on level shape
	for y in range(level_data.grid_height):
		var row = []
		for x in range(level_data.grid_width):
			if level_data.shape_data.is_empty() or level_data.shape_data[y][x] == 1:
				var tile = create_tile(x, y)
				row.append(tile)
			else :
				row.append(null)
	shuffle_grid()

func create_tile(x: int, y: int) -> Node2D:
	var tile_scene = preload("res://scenes/game_mode/core/tile/Tile.tscn")
	var tile = tile_scene.instantiate()
	tile.position = Vector2(x * 64, y * 64)
	tile.grid_position = Vector2(x, y)
	tile.pressed.connect(_on_tile_pressed.bind(tile))
	add_child(tile)
	return tile

func shuffle_grid():
	var tiles = []
	var positions = []

	# Collect all tiles and their positions
	for y in range(level_data.grid_height):
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				tiles.append(grid_data[y][x])
				positions.append(Vector2(x, y))

	# Shuffle tiles and reposition them
	tiles.shuffle()
	for i in range(tiles.size()):
		var tile = tiles[i]
		var pos = positions[i]
		grid_data[pos.y][pos.x] = tile
		tile.position = Vector2(pos.x * 64, pos.y * 64)
		tile.grid_position = pos

func _on_tile_pressed(tile: Node2D):
	if !can_play:
		return

	if selected_tile == null:
		selected_tile = tile
		tile.select()
		emit_signal("tile_selected", tile)
	else:
		if selected_tile == tile:
			selected_tile.deselect()
			selected_tile = null
		else:
			if can_connect(selected_tile, tile):
				handle_match(selected_tile, tile)
			selected_tile.deselect()
			selected_tile = null

func can_connect(tile1: Node2D, tile2: Node2D) -> bool:
	if tile1.type != tile2.type:
		return false
	
	var path = find_path(tile1.grid_position, tile2.grid_position)
	return path != null

func find_path(start: Vector2i, end: Vector2i) -> Array:
	# Try direct path
	if can_move_direct(start, end):
		return [start, end]

	# Try 1 corners (L-shape) paths
	var corner = find_one_corner_path(start, end)
	if corner and corner != Vector2i(-1, -1):
		return [start, corner, end]

	# Try 2 corners (Z-shape or C-shape) paths
	var corners = find_two_corners_path(start, end)
	if corners:
		return [start, corners[0], corners[1], end]

	return []

func can_move_direct(start: Vector2i, end: Vector2i) -> bool:
	# Check if points are on the same row or column
	if start.x != end.x and start.y != end.y:
		return false
	
	# Check if there are any obstacles between points
	if start.x == end.x:
		var min_y = min(start.y, end.y)
		var max_y = max(start.y, end.y)
		for y in range(min_y + 1, max_y):
			if grid_data[y][start.x]:
				return false
	else:
		var min_x = min(start.x, end.x)
		var max_x = max(start.x, end.x)
		for x in range(min_x + 1, max_x):
			if grid_data[start.y][x]:
				return false

	return true

func find_one_corner_path(start: Vector2i, end: Vector2i) -> Vector2i:
	# Try corner at (start.x, end.y)
	var corner1 = Vector2i(start.x, end.y)
	if corner1 != start and corner1 != end:
		if can_move_direct(start, corner1) and can_move_direct(corner1, end):
			if !grid_data[corner1.y][corner1.x]:
				return corner1

	# Try corner at (end.x, start.y)
	var corner2 = Vector2i(end.x, start.y)
	if corner2 != start and corner2 != end:
		if can_move_direct(start, corner2) and can_move_direct(corner2, end):
			if !grid_data[corner2.y][corner2.x]:
				return corner2

	return Vector2i(-1, -1)

func find_two_corners_path(start: Vector2i, end: Vector2i) -> Array:
	# Try all possible first corners
	for x in range(level_data.grid_width):
		for y in range(level_data.grid_height):
			var corner1 = Vector2i(x, y)
			if corner1 == start or corner1 == end:
				continue
			if grid_data[y][x]:
				continue
			
			# If we can reach corner1 from start
			if can_move_direct(start, corner1):
				# Try all possible second corners
				var corner2_attempts = [
					Vector2i(corner1.x, end.y),
					Vector2i(end.x, corner1.y)
				]

				for corner2 in corner2_attempts:
					if corner2 != corner1 and corner2 != end:
						if !grid_data[corner2.y][corner2.x]:
							if can_move_direct(corner1, corner2) and can_move_direct(corner2, end):
								return [corner1, corner2]

	return []

func handle_match(tile1: Node2D, tile2: Node2D):
	# Handle tile match
	remove_tiles(tile1, tile2)

	match level_data.collapse_behavior:
		"down":
			collapse_down()
		"left":
			collapse_left()
		"right":
			collapse_right()
		"up":
			collapse_up()

	ScoreAlgorithms.add_match()
	emit_signal("score_updated", ScoreAlgorithms.score)

	if is_grid_empty():
		emit_signal("all_matched")

func remove_tiles(tile1: Node2D, tile2: Node2D):
	grid_data[tile1.grid_position.y][tile1.grid_position.x] = null
	grid_data[tile2.grid_position.y][tile2.grid_position.x] = null
	tile1.queue_free()
	tile2.queue_free()

func collapse_up():
	for x in range(level_data.grid_width):
		var write_y = 0
		for y in range(level_data.grid_height):
			if grid_data[y][x]:
				if y != write_y:
					grid_data[write_y][x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[write_y][x]
					tile.position.y = write_y * 64
					tile.grid_position.y = write_y
				write_y += 1

func collapse_down():
	for x in range(level_data.grid_width):
		var write_y = level_data.grid_height - 1
		for y in range(level_data.grid_height - 1, -1, -1):
			if grid_data[y][x]:
				if y != write_y:
					grid_data[write_y][x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[write_y][x]
					tile.position.y = write_y * 64
					tile.grid_position.y = write_y
				write_y -= 1

func collapse_left():
	for y in range(level_data.grid_height):
		var write_x = 0
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				if x != write_x:
					grid_data[y][write_x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[y][write_x]
					tile.position.x = write_x * 64
					tile.grid_position.x = write_x
				write_x += 1

func collapse_right():
	for y in range(level_data.grid_height):
		var write_x = level_data.grid_width - 1
		for x in range(level_data.grid_width - 1, -1, -1):
			if grid_data[y][x]:
				if x != write_x:
					grid_data[y][write_x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[y][write_x]
					tile.position.x = write_x * 64
					tile.grid_position.x = write_x
				write_x -= 1

func is_grid_empty() -> bool:
	for y in range(level_data.grid_height):
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				return false
	return true