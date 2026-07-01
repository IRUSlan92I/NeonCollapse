class_name LevelSelection
extends Control


@onready var grid : GridContainer = $%GridContainer


func _ready() -> void:
	for i in range(LevelManager.levels.size()):
		var level := LevelManager.levels[i]
		var disable := SaveManager.completed_levels < i
		
		var button : Button = Button.new()
		button.text = "Level %d" % (i + 1)
		button.disabled = disable
		button.focus_mode = Control.FOCUS_NONE if disable else Control.FOCUS_ALL
		grid.add_child(button)
		button.pressed.connect(_on_level_selected.bind(i, level))
		
		if i == 0:
			button.grab_focus()
	
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)


func _on_gui_focus_changed(_node: Control) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_select)


func _on_level_selected(index: int, level: PackedScene) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	LevelManager.current_level_index = index
	get_tree().change_scene_to_packed(level)


func _on_main_menu_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_decline)
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
