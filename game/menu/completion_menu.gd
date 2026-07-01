class_name CompletionMenu
extends Control


@onready var next_level_button : Button = $%NextLevelButton
@onready var main_menu_button : Button = $%MainMenuButton
@onready var focus_timer : Timer = $FocusTimer


func _is_last_level() -> bool:
	return LevelManager.current_level_index >= (LevelManager.levels.size() - 1)


func _on_gui_focus_changed(_node: Control) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_select)


func _on_next_level_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	get_tree().paused = false
	LevelManager.current_level_index += 1
	get_tree().change_scene_to_packed(LevelManager.levels[LevelManager.current_level_index])


func _on_main_menu_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _on_visibility_changed() -> void:
	if not is_node_ready(): return 
	if visible:
		next_level_button.visible = not _is_last_level()
		focus_timer.start()
		get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	elif get_viewport().gui_focus_changed.is_connected(_on_gui_focus_changed):
		get_viewport().gui_focus_changed.disconnect(_on_gui_focus_changed)


func _on_focus_timer_timeout() -> void:
	if next_level_button != null and next_level_button.visible:
		next_level_button.grab_focus()
	elif main_menu_button != null:
		main_menu_button.grab_focus()
