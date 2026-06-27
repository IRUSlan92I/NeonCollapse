class_name PauseMenu
extends Control


@onready var continue_button : Button = $%ContinueButton
@onready var main_menu_button : Button = $%MainMenuButton


func _ready() -> void:
	_init_focus()
	_setup_neighbors()


func _on_gui_focus_changed(_node: Control) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_select)


func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("pause"):
		_on_continue_button_pressed.call_deferred()


func _init_focus() -> void:
	continue_button.grab_focus()


func _setup_neighbors() -> void:
	continue_button.focus_neighbor_top = main_menu_button.get_path()
	main_menu_button.focus_neighbor_bottom = continue_button.get_path()


func _on_continue_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_decline)
	get_tree().paused = false
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_main_menu_button_pressed() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _on_visibility_changed() -> void:
	if not is_node_ready(): return 
	if visible:
		continue_button.grab_focus()
		get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	elif get_viewport().gui_focus_changed.is_connected(_on_gui_focus_changed):
		get_viewport().gui_focus_changed.disconnect(_on_gui_focus_changed)
