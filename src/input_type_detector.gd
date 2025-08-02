extends Node2D

enum InputType {KEYBOARD_MOUSE, CONTROLLER}

var _current_input_type = InputType.KEYBOARD_MOUSE

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		_current_input_type = InputType.CONTROLLER
		return
	_current_input_type = InputType.KEYBOARD_MOUSE

func get_current_input_type() -> InputType:
	return _current_input_type
