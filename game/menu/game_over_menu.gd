class_name GameOverMenu
extends Control


@onready var retry_button : Button = $%RetryButton
@onready var main_menu_button : Button = $%MainMenuButton
@onready var focus_timer : Timer = $FocusTimer


func _on_gui_focus_changed(_node: Control) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_select)


func _on_retry_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	get_tree().paused = false
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)


func _on_main_menu_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _on_visibility_changed() -> void:
	if not is_node_ready(): return
	if visible:
		focus_timer.start()
		get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	elif get_viewport().gui_focus_changed.is_connected(_on_gui_focus_changed):
		get_viewport().gui_focus_changed.disconnect(_on_gui_focus_changed)


func _on_focus_timer_timeout() -> void:
	if main_menu_button != null:
			retry_button.grab_focus()
