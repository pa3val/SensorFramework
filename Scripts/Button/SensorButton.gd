@tool
extends TouchScreenButton

enum Adaptive {
	# Joystick position as in editor
	NONE, 
	# Joystick position in the editor adapts to the device screen
	POSITION, 
	# Adapts the size to the height difference and its position
	HEIGHT, 
	# Adapts the size to the width difference and its position
	WIDTH, 
}

@export var adapt_mode: Adaptive

## Shows the size of the editor window
@export var viewport_size: Vector2 :
	set(_value):
		viewport_size = _set_viewport_size()

func _ready():
	SignalManager.create_button_pressed(self.name)
	SignalManager.create_button_released(self.name)

	pressed.connect(_on_pressed)
	released.connect(_on_released)

func _on_pressed():
	SignalManager.emit_signal("pressed_" + self.name)

func _on_released():
	SignalManager.emit_signal("released_" + self.name)

func adapt_button():
	if adapt_mode == Adaptive.NONE: return
	
	# Calculate screen difference
	var diff_scale_x = get_viewport_rect().size.x / viewport_size.x
	var diff_scale_y = get_viewport_rect().size.y / viewport_size.y

	position *= Vector2(diff_scale_x, diff_scale_y)
	
	# Selects which difference to calculate the size
	var diff_scale = scale
	if adapt_mode == Adaptive.HEIGHT:
		diff_scale = Vector2(diff_scale_y, diff_scale_y)
	elif adapt_mode == Adaptive.WIDTH:
		diff_scale = Vector2(diff_scale_x, diff_scale_x)
	scale = diff_scale
	
	
func _set_viewport_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)