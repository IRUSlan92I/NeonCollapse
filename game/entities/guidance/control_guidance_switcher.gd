class_name ContolGuidanceSwitcher
extends Node


@export var keyboard_guidance : Guidance
@export var gamepad_guidance : Guidance


func _ready() -> void:
	if not Engine.is_editor_hint():
		_updated_by_input_type(InputManager.get_type())
		InputManager.type_changed.connect(_updated_by_input_type)


func _updated_by_input_type(type: InputManager.Type) -> void:
	match type:
		InputManager.Type.Keyboard:
			if keyboard_guidance:
				keyboard_guidance.show()
			if gamepad_guidance:
				gamepad_guidance.hide()
		InputManager.Type.Gamepad:
			if keyboard_guidance:
				keyboard_guidance.hide()
			if gamepad_guidance:
				gamepad_guidance.show()
