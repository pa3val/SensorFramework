@tool
extends Control

## Before using this Joystick
## add SignalManager to Project -> Project Settings -> Autoload

# -----------------------------------------------------------------------			
# CONST VARIABLES

## Enum for joystick move modes
enum Modes {
	# Joystick doesn't move
	FIXED,
	# Joystick follow the touch
	DYNAMIC,
}

## Enum for adaptivity modes
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

## Max radius of joystick base
const MAX_BASE_RADIUS = 1000

## Max radius of joystick tip  
const MAX_TIP_RADIUS = 1000 

## Max radius of zone, where joystick return zero
const MAX_DEAD_ZONE = MAX_BASE_RADIUS

# -----------------------------------------------------------------------			
# EXPORT VARIABLES

@export_category("Simple Joystick")

@export_group("Adaptive")

## Set joystick adapt mode
@export var adapt_mode: Adaptive 

## Shows the size of the editor window
@export var viewport_size: Vector2 :
	set(_value):
		viewport_size = _set_viewport_size()

@export_group("Settings")

## Sets joystick mode
@export var joystick_mode: Modes

## Sets joystick capture mode
@export var capture_on_move: bool = false

## Sets max value, that return joystick returns on X axis
@export var max_x_value: float = 1.0

## Sets max value, that return joystick returns on Y axis
@export var max_y_value: float = 1.0

@export_group("Sizes")

## Dynamically sets radius to Base
@export_range(0, MAX_BASE_RADIUS) var base_radius: float = 150.0 :
	set(value):
		base_radius = value
		size = $Base.size
		_change_scale($Base, base_radius)
		
## Dynamically sets radius to Tip
@export_range(0, MAX_TIP_RADIUS) var tip_radius: float = 50.0 :
	set(value):
		tip_radius = value
		_change_scale($Tip, tip_radius)
		
## Dynamically sets radius of zone, where joystick return zero
@export_range(0, MAX_DEAD_ZONE) var deadzone_radius: float = 50.0

## Dynamically sets radius of zone, where joystick moves
@export_range(0, MAX_BASE_RADIUS) var clampzone_radius: float = 150.0

# -----------------------------------------------------------------------			
# PRIVATE VARIABLES

## Indicates that joystick is in use
var _is_in_use: bool = false 

## Stores value of touch that use joystick
var _joystick_touch_index: int = -1 

## Position to which joystick returns
var default_position = Vector2.ZERO

# -----------------------------------------------------------------------			
# ONREADY VARIABLES

@onready var Tip = $Tip
@onready var Base = $Base

# -----------------------------------------------------------------------
# PRIVATE METHODS	

func _ready():

	# Create Signals
	SignalManager.create_joystick_change_pos(self.name)
	SignalManager.create_joystick_reset(self.name)

	# Sets the size and position
	_change_scale(Base, base_radius)
	_change_scale(Tip, tip_radius)
	
	if Engine.is_editor_hint(): return
	
	# Sets the joystick depending on the adapt mode
	_adapt_joystick()
	
	# Set default position to Tip, because Tip creates quicker than Base
	Tip.default_position = Tip.position
	default_position = position

func _input(event):
	if not event is InputEventScreenDrag and not event is InputEventScreenTouch:
		return
	
	# Calculate position and hipotenuse of touch position in joystick
	var local_touch_position = event.position - (position + size / 2)
	var hipotenuse = sqrt(local_touch_position.x ** 2 + local_touch_position.y ** 2)
	
	# Checks and sets joystick occupancy by touch
	if (event is InputEventScreenDrag and capture_on_move) or \
		event is InputEventScreenTouch:
		_set_joystick_busy(event.index, hipotenuse)
	
	# Calculate new position of joystick
	if _is_in_use and event.index == _joystick_touch_index:
		Tip.calc_new_tip_position(hipotenuse, local_touch_position)
		if joystick_mode == Modes.DYNAMIC:
			var value_to_move = local_touch_position - (Tip.position - Tip.default_position)
			position += value_to_move
		if event is InputEventScreenTouch and not event.is_pressed():
			_reset_joystick()		

## Check is joystick currently use by touch
func _set_joystick_busy(index: int, hipotenuse: int):
	_is_in_use = true if _is_in_use else hipotenuse <= clampzone_radius
	if _joystick_touch_index == -1 and _is_in_use:
		_joystick_touch_index = index

## Reset all parameters of joystick
func _reset_joystick():
	position = default_position
	_is_in_use = false
	_joystick_touch_index = -1
	Tip.reset()

## Calculates and sets the size and position of the joystick
## depending on the selected adaptivity mode
func _adapt_joystick():
	if adapt_mode == Adaptive.NONE: return
	
	# Calculate screen difference
	var diff_scale_x = get_viewport_rect().size.x / viewport_size.x
	var diff_scale_y = get_viewport_rect().size.y / viewport_size.y
	
	# Selects which difference to calculate the size
	var diff_scale = 1
	if adapt_mode == Adaptive.HEIGHT:
		diff_scale = diff_scale_y
	elif adapt_mode == Adaptive.WIDTH:
		diff_scale = diff_scale_x
	
	# Calculate size if joystick
	size *= Vector2(diff_scale_x, diff_scale_y)
	_change_scale(Base, base_radius * diff_scale)
	_change_scale(Tip, tip_radius * diff_scale)
	
	# Calculate new position of joystick
	
	# Calculate anchor position
	var anchor_position = Vector2(
		get_viewport_rect().size.x * anchor_left, 
		get_viewport_rect().size.y * anchor_bottom
		)
	# Calculates the position of the joystick relative to the anchor
	var local_position = anchor_position - position
	local_position *= Vector2(diff_scale_x, diff_scale_y)
	# Sets new joystick position
	position = anchor_position - local_position
	
	# Sets the other variables
	clampzone_radius *= diff_scale
	deadzone_radius *= diff_scale

## Calculate new sizes of joystick elements
func _change_scale(target, radius: float):
	if target == null: return
	
	# selects the size to calculate against (for different-sized joysticks)
	var target_size = (
		target.size.x if target.size.x < target.size.y 
		else target.size.y
	)
	
	# Sets new scale and position
	target.scale = Vector2(radius * 2 / target_size, radius * 2 / target_size)
	target.position = size / 2 - target.size / 2 * target.scale
	
## Set viewport_size variable
func _set_viewport_size() -> Vector2:
		return Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
			)
