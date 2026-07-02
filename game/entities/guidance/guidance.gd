@tool
class_name Guidance
extends Node2D


enum Size {
	Small,
	Big,
}


@export var size := Size.Small:
	set(value):
		size = value
		if is_node_ready():
			_update_size()

@export var text := "":
	set(value):
		text = value
		if is_node_ready():
			_update_text()


@onready var small_sprite : Sprite2D = $SmallSprite
@onready var big_sprite : Sprite2D = $BigSprite
@onready var label : Label = $Label


func _ready() -> void:
	_update_size()
	_update_text()


func _update_size() -> void:
	match size:
		Size.Small:
			small_sprite.show()
			big_sprite.hide()
		Size.Big:
			small_sprite.hide()
			big_sprite.show()

func _update_text() -> void:
	label.text = text
