extends Button

# Grid position in the game board
var grid_position: Vector2i

var type: int = 0
var selected: bool = false

signal tile_pressed(tile: Button)  # Renamed from 'pressed' to 'tile_pressed'

func _ready() -> void:
	pressed.connect(_on_button_pressed)  # Connect to Button's built-in pressed signal

func _on_button_pressed() -> void:
	emit_signal("tile_pressed", self)  # Emit our custom signal

func select() -> void:
	selected = true
	# Add visual feedback for selection
	modulate = Color(1.2, 1.2, 1.2)

func deselect() -> void:
	selected = false
	# Reset visual feedback
	modulate = Color(1, 1, 1)
