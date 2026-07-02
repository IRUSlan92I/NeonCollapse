class_name CInputManager
extends Node


signal type_changed(type: Type)


enum Type {
	Keyboard,
	Gamepad,
}


@export_range(0.0, 1.0, 0.01) var dead_zone := 0.2


@onready var _type : Type:
	set(value):
		_type = value
		type_changed.emit(_type)


func _ready() -> void:
	if Input.get_connected_joypads().size() > 0:
		_type = Type.Gamepad
	else:
		_type = Type.Keyboard


func _input(event: InputEvent) -> void:
	if _is_keyboard_event(event):
		_type = Type.Keyboard
	elif _is_gamepad_event(event):
		_type = Type.Gamepad


func _is_keyboard_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		return true
	if event is InputEventMouse:
		return true
	return false


func _is_gamepad_event(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		return true
	if event is InputEventJoypadMotion and not _is_deadzone(event):
		return true
	return false


func _is_deadzone(event: InputEventJoypadMotion) -> bool:
	if event.axis_value < -dead_zone:
		return false
	if event.axis_value > dead_zone:
		return false
	return true


func get_type() -> Type:
	return _type
