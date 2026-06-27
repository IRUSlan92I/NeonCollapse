class_name AbstractLevel
extends Node2D


@onready var player : Player = $Player
@onready var pause_menu : PauseMenu = $%PauseMenu


func _ready() -> void:
	$Menus.show()
	pause_menu.hide()
	
	#TODO Add gameplay music


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
		get_tree().paused = true
		pause_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
