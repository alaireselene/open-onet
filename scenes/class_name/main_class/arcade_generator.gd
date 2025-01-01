class_name ArcadeGenerator
extends GridGenerator


# Called when the node enters the scene tree for the first time.
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
