class_name FatherClass
extends Node2D

var tile_size = Vector2(120, 112)

static var grid_size =  Vector2(0, 0)                      #level con can
var inner_grid_size = Vector2(0, 0)					#level
var pokemon_count = 0								#level
var pokemon_sprites = []  # Danh sách các sprite Pokémon-- chi danh cho generate

static var grid_data = []  # Dữ liệu grid để sắp xếp các ô  con can
