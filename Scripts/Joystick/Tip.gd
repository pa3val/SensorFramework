extends TextureRect

# -----------------------------------------------------------------------			
# ONREADY VARIABLES

# Position to which Tip returns
@onready var default_position: Vector2 = position

# Maximum axis values
@onready var max_x_value: float = get_parent().max_x_value
@onready var max_y_value: float = get_parent().max_y_value

# -----------------------------------------------------------------------			
# PUBLIC FUNCTIONS

## Calculate position of tip
func calc_new_tip_position(hipotenuse: int, touch_position: Vector2):
	
	# Calculates and sets new Tip position on axes
	var _x_pos = _get_axis_pos_on_circle(hipotenuse, touch_position.x)
	var _y_pos = _get_axis_pos_on_circle(hipotenuse, touch_position.y)
	position = Vector2(_x_pos, _y_pos) + default_position
	
	# Calculates values on axes
	var _x_value = 0
	var _y_value = 0

	_x_value = _calculate_axis_value(max_x_value, touch_position.x)
	_y_value = _calculate_axis_value(max_y_value, touch_position.y)

	#Calculates angle of Tip
	var _angle = atan2(_x_pos, -_y_pos)

	# Calls signal with all values
	SignalManager.emit_signal("change_pos_" + get_parent().name, _x_value, _y_value, _angle)
	
	
	
## Sets Tip values to default
func reset():
	position = default_position
	
	# Calls signal with default values
	SignalManager.emit_signal("reset_" + get_parent().name, 0, 0, 0)
	
# -----------------------------------------------------------------------			
# PRIVATE FUNCTIONS

## Calculates the value of touch on the axis 
func _calculate_axis_value(axis_max_value: float, axis_touch_position: float) -> float:
	if absf(axis_touch_position) <= get_parent().deadzone_radius:
		return 0
		
	var value = clampf(axis_max_value / (get_parent().clampzone_radius - get_parent().deadzone_radius) * # Calculates min value on axis
					(abs(axis_touch_position) - get_parent().deadzone_radius) * # Calculates value of touch on axis
					(-1 if axis_touch_position < 0 else 1), # Sets direction
					-absf(axis_max_value),
					 absf(axis_max_value)
					)
	return value

## Helps get tip position on base by cos and sin
func _get_axis_pos_on_circle(hipotenuse: float, touch_position: float) -> float:
	if hipotenuse <= get_parent().clampzone_radius:
		return touch_position
		
	# Calculates cos or sin values of angle
	var angle_val = touch_position / hipotenuse
	angle_val = clampf(angle_val, -1, 1)
	
	# Returns value of angle
	return get_parent().clampzone_radius * angle_val
