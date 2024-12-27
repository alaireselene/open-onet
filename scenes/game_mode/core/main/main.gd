extends Node2D

const GRID_SIZE = 10 # Kích thước lưới tổng cộng (10x10)
const INNER_GRID_SIZE = 8 # Kích thước lưới chứa Pokémon (8x8)
const SPRITE_COUNT = 16 # Số lượng Pokémon
const TILE_SCENE = preload("res://scenes/game_mode/core/tile/Tile.tscn") # Đường dẫn Scene Tile
const PLACEHOLDER_SCENE = preload("res://scenes/game_mode/core/Placeholder.tscn")

var pokemon_sprites = [] # Danh sách các sprite Pokémon
var grid_data = [] # Dữ liệu grid để sắp xếp các ô
var selected_tiles = [] # Lưu các ô đã chọn
var tile_size = Vector2(120, 112) # Kích thước mỗi ô dựa trên kích thước sprite

func _ready():
	load_sprites()
	generate_grid()
	populate_grid()

func load_sprites():
	# Tải các sprite Pokémon vào danh sách
	for i in range(SPRITE_COUNT):
		var texture = load("res://assets/sprites/pokemons/pokemon_%d.png" % i)
		pokemon_sprites.append(texture)

func generate_grid():
	# Khởi tạo lưới 10x10 với tất cả các ô là rỗng (-1)
	grid_data.resize(GRID_SIZE)
	for i in range(GRID_SIZE):
		grid_data[i] = []
		for j in range(GRID_SIZE):
			grid_data[i].append(-1) # Mặc định là rỗng

	# Tạo danh sách chứa các ID Pokémon, mỗi ID lặp lại 4 lần
	var pokemon_ids = []
	for id in range(SPRITE_COUNT):
		for temp in range(4):
			pokemon_ids.append(id)
	pokemon_ids.shuffle() # Trộn ngẫu nhiên danh sách

	# Gán Pokémon vào lưới con 8x8 (vùng giữa)
	var index = 0
	for i in range(1, INNER_GRID_SIZE + 1):
		for j in range(1, INNER_GRID_SIZE + 1):
			grid_data[i][j] = pokemon_ids[index]
			index += 1

func populate_grid():
	# Tạo các node con cho giao diện từ grid_data
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			# Tính toán vị trí của từng ô
			var x = j * tile_size.x
			var y = i * tile_size.y

			if grid_data[i][j] == -1: # Ô rỗng
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

func _on_tile_selected(tile):
	if len(selected_tiles) < 2:
		selected_tiles.append(tile)
		if len(selected_tiles) == 2:
			process_match()

func process_match():
	var tile1 = selected_tiles[0]
	var tile2 = selected_tiles[1]

	# Đảm bảo không chọn cùng một ô
	if tile1 == tile2:
		print("Không thể chọn cùng một ô!")
		reset_selection()
		return

	# Kiểm tra ID Pokémon
	if tile1.pokemon_id != tile2.pokemon_id:
		print("Không giống nhau!")
		reset_selection()
		return

	# Lấy vị trí của các tile trong lưới
	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 == null or pos2 == null:
		print("Tile không hợp lệ!")
		reset_selection()
		return

	# Kiểm tra "match"
	if can_match(pos1, pos2):
		print("Match thành công!")
		remove_tiles(tile1, tile2)
	else:
		print("Không thể match!")
	reset_selection()

func get_tile_position(tile):
	var x = int(tile.position.x / tile_size.x) # Tính toán cột
	var y = int(tile.position.y / tile_size.y) # Tính toán hàng
	return Vector2(x, y)

func can_match(pos1, pos2):
	# Kiểm tra đường thẳng
	if check_straight_line(pos1, pos2):
		return true
	# Kiểm tra một góc 90 độ
	if check_one_corner(pos1, pos2):
		return true
	# Kiểm tra hai góc 90 độ
	if check_two_corners(pos1, pos2):
		return true
	return false

func check_straight_line(pos1, pos2):
	# Kiểm tra cùng hàng
	if pos1.y == pos2.y:
		for x in range(min(pos1.x, pos2.x) + 1, max(pos1.x, pos2.x)):
			if grid_data[int(pos1.y)][x] != -1:
				return false
		return true

	# Kiểm tra cùng cột
	if pos1.x == pos2.x:
		for y in range(min(pos1.y, pos2.y) + 1, max(pos1.y, pos2.y)):
			if grid_data[y][int(pos1.x)] != -1:
				return false
		return true

	return false

func check_one_corner(pos1, pos2):
	var corner1 = Vector2(pos1.x, pos2.y)
	var corner2 = Vector2(pos2.x, pos1.y)

	# Kiểm tra corner1
	if is_valid_position(corner1) and grid_data[int(corner1.y)][int(corner1.x)] == -1:
		if check_straight_line(pos1, corner1) and check_straight_line(corner1, pos2):
			return true

	# Kiểm tra corner2
	if is_valid_position(corner2) and grid_data[int(corner2.y)][int(corner2.x)] == -1:
		if check_straight_line(pos1, corner2) and check_straight_line(corner2, pos2):
			return true

	return false

func check_two_corners(pos1, pos2):
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var corner = Vector2(x, y)
			if is_valid_position(corner) and grid_data[int(corner.y)][int(corner.x)] == -1:
				if check_one_corner(pos1, corner) and check_straight_line(corner, pos2):
					return true
	return false

func is_valid_position(pos):
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

func remove_tiles(tile1, tile2):
	# Lấy vị trí logic
	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 and pos2:
		# Cập nhật lưới logic (đặt các ô thành rỗng)
		grid_data[int(pos1.y)][int(pos1.x)] = -1
		grid_data[int(pos2.y)][int(pos2.x)] = -1

	# Xóa node Pokémon khỏi giao diện
	tile1.queue_free()
	tile2.queue_free()

func refresh_grid():
	# Làm mới giao diện từ grid_data
	for child in get_children():
		child.queue_free()
	populate_grid()

func reset_selection():
	selected_tiles.clear()
