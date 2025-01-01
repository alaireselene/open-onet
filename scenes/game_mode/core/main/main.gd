extends Node2D
# Lấy thông số từ GameSettings Singleton
var grid_size = GameSettings.grid_size
var inner_grid_size = GameSettings.inner_grid_size
var pokemon_count = GameSettings.pokemon_count

var pokemon_sprites = []  # Danh sách các sprite Pokémon
var grid_data = []  # Dữ liệu grid để sắp xếp các ô
var selected_tiles = []  # Lưu các ô đã chọn
var tile_size = Vector2(120, 112)  # Kích thước mỗi ô dựa trên kích thước sprite

const TILE_SCENE = preload("res://scenes/game_mode/core/tile/Tile.tscn") # Đường dẫn Scene Tile
const PLACEHOLDER_SCENE = preload("res://scenes/game_mode/core/Placeholder.tscn")

signal all_matched
signal score_updated(new_score)  # Tín hiệu cập nhật điểm

func _ready():
	# Khi game bắt đầu
	load_sprites()
	generate_grid()
	populate_grid()

# Tải các sprite Pokémon vào danh sách
func load_sprites():
	for i in range(pokemon_count):
		var texture = load("res://assets/sprites/pokemons/pokemon_%d.png" % i)
		pokemon_sprites.append(texture)

# Khởi tạo lưới theo kích thước từ GameSettings
func generate_grid():
	grid_data.resize(grid_size.x)
	for i in range(grid_size.x):
		grid_data[i] = []
		for j in range(grid_size.y):
			grid_data[i].append(-1)  # Mặc định là rỗng

	# Tạo danh sách chứa các ID Pokémon, mỗi ID lặp lại 4 lần
	var pokemon_ids = []
	for id in range(pokemon_count):
		for temp in range(4):
			pokemon_ids.append(id)
	pokemon_ids.shuffle()  # Trộn ngẫu nhiên danh sách

	# Gán Pokémon vào lưới con (vùng giữa)
	var index = 0
	for i in range(1, inner_grid_size.x +1 ):
		for j in range(1, inner_grid_size.y +1 ):
			
			grid_data[i][j] = pokemon_ids[index]
			index += 1

# Tạo các node con cho giao diện từ grid_data
func populate_grid():
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
				tile.connect("tile_selected", Callable(self, "_on_tile_selected"))
				tile.position = Vector2(x, y)
				add_child(tile)

# Hàm xử lý khi một ô được chọn
func _on_tile_selected(tile):
	if len(selected_tiles) < 2:
		selected_tiles.append(tile)
		if len(selected_tiles) == 2:
			process_match()

# Kiểm tra và xử lý khi 2 ô đã được chọn
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

		check_all_matched()  # Kiểm tra nếu tất cả đã được match
	else:
		print("Không thể match!")
	reset_selection()

# Kiểm tra nếu tất cả các Pokémon đã được ghép thành công
func check_all_matched():
	var all_matched = true
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			if grid_data[i][j] != -1:
				all_matched = false
				break
	if all_matched:
		emit_signal("all_matched")  # Phát tín hiệu nếu tất cả đã match

# Tính toán vị trí của ô trong lưới
func get_tile_position(tile):
	var x = int(tile.position.x / tile_size.x)  # Tính toán cột
	var y = int(tile.position.y / tile_size.y)  # Tính toán hàng
	return Vector2(x, y)

# Kiểm tra xem hai ô có thể ghép với nhau không (hỗ trợ các kiểu nối khác nhau)
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

# Kiểm tra xem có thể ghép theo đường thẳng không (cùng hàng hoặc cùng cột)
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

# Kiểm tra một góc 90 độ
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

# Kiểm tra hai góc 90 độ
func check_two_corners(pos1, pos2):
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var corner = Vector2(x, y)
			if is_valid_position(corner) and grid_data[int(corner.y)][int(corner.x)] == -1:
				if check_one_corner(pos1, corner) and check_straight_line(corner, pos2):
					return true
	return false




# Kiểm tra nếu một vị trí là hợp lệ
func is_valid_position(pos):
	
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

# Xóa các ô đã ghép thành công
func remove_tiles(tile1, tile2):
	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 and pos2:
		# Cập nhật lưới logic (đặt các ô thành rỗng)
		grid_data[int(pos1.y)][int(pos1.x)] = -1
		grid_data[int(pos2.y)][int(pos2.x)] = -1

	# Xóa node Pokémon khỏi giao diện
	tile1.queue_free()
	tile2.queue_free()

# Làm mới giao diện từ grid_data
#func refresh_grid():
	#for child in get_children():
		#child.queue_free()
	#populate_grid()

# Xóa các ô đã chọn
func reset_selection():
	selected_tiles.clear()
