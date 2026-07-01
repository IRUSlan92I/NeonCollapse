class_name CLevelManager
extends Node


@export var levels : Array[PackedScene] = []


var current_level_index := 0


func _ready() -> void:
	levels = levels.filter(func(item: PackedScene) -> bool: return item != null)
