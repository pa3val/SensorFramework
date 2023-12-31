extends Node

## Manager to signals of joystick.
## Dynamically sets signals of joysticks.[br]
## [color=yellow]!!! Important:[/color] Before using Joystick
## [color=green]add this file to Project -> Project Settings -> Autoload[/color]

## Create joystick signal when reset with default values
func create_joystick_reset(sig_name):
	add_user_signal("reset_" + sig_name, ["x", "y", "angle"])

## Create joystick signal with all values
func create_joystick_change_pos(sig_name):
	add_user_signal("change_pos_" + sig_name, ["x", "y", "angle"])

func create_button_released(sig_name):
	add_user_signal("released_" + sig_name)

func create_button_pressed(sig_name):
	add_user_signal("pressed_" + sig_name)
