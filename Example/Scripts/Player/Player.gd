extends Area2D

@export var speed: float = 300

var screen_size
var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Connect signals
	SignalManager.connect("change_pos_Joystick", _on_joystick_change_pos)
	SignalManager.connect("reset_Joystick", _on_joystick_reset)
	SignalManager.connect("pressed_Button", _on_button_pressed)

	screen_size = get_viewport().size

func _physics_process(delta):
	
	position.x += velocity.x * delta * speed
	position.y += velocity.y * delta * speed
	
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.stop()

func _on_joystick_change_pos(x, y, angle):
	velocity = Vector2(x, y)

func _on_joystick_reset(x, y, angle):
	velocity = Vector2(x, y)

func _on_button_pressed():
	print("Hello")