@tool
class_name Guidance
extends Node2D


const SMALL_SIZE = Vector2(48, 48)
const BIG_SIZE = Vector2(96, 48)


enum Size {
	Small,
	Big,
	Custom,
}


@export var custom_size := SMALL_SIZE:
	set(value):
		custom_size = value
		if is_node_ready():
			_update_size()
	
@export var size := Size.Small:
	set(value):
		size = value
		if is_node_ready():
			_update_size()

@export_multiline() var text := "":
	set(value):
		text = value
		if is_node_ready():
			_update_text()


@onready var rect : NinePatchRect = $NinePatchRect
@onready var label : Label = $Label


func _ready() -> void:
	_update_size()
	_update_text()


func _update_size() -> void:
	var new_size := Vector2.ZERO
	match size:
		Size.Small:
			new_size = SMALL_SIZE
		Size.Big:
			new_size = BIG_SIZE
		Size.Custom:
			new_size = custom_size
	rect.set_deferred("size", new_size)
	rect.set_deferred("position", -new_size/2)


func _update_text() -> void:
	label.text = text
