extends Node2D

var grid_size = 16  # Size of each grid cell
var grid_color = Color(0.2, 0.2, 0.2)  # Dark grey
var grid_thickness = 1

func _draw():
	var viewport_size = get_viewport_rect().size
	
	# Draw vertical lines
	for x in range(0, int(viewport_size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), grid_color, grid_thickness)
	
	# Draw horizontal lines
	for y in range(0, int(viewport_size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), grid_color, grid_thickness)
