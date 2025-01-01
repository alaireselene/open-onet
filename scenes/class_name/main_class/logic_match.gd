class_name LogicMatch
extends FatherClass

# Called when the node enters the scene tree for the first time.
#func _init(grid_data, grid_size):
	#self.grid_data = grid_data
	#self.grid_size =grid_size
# Called every frame. 'delta' is the elapsed time since the previous frame.
signal score_updated(new_score)
signal all_matched


func process_match(selected_tiles: Array):
	var tile1 = selected_tiles[0]
	var tile2 = selected_tiles[1]

	if tile1 == tile2:
		print("Không thể chọn cùng một ô!")
		selected_tiles.clear()   #xoa cac o da chon
		return

	if tile1.pokemon_id != tile2.pokemon_id:
		print("Không giống nhau!")
		selected_tiles.clear()
		return

	var pos1 = get_tile_position(tile1)
	var pos2 = get_tile_position(tile2)

	if pos1 == null or pos2 == null:
		print("Tile không hợp lệ!")
		selected_tiles.clear()
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
	selected_tiles.clear()

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
