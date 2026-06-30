class_name Code
extends Node2D


const CODE_LINE = preload("res://game/effects/code_line.tscn")


func _ready() -> void:
	for y in range(0, SettingsManager.window_base_size.y, 16):
		var line : CodeLine = CODE_LINE.instantiate()
		line.scroll_offset.y = y
		add_child(line)
