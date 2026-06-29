class_name AbstractLevel
extends Node2D


@export var initial_corruption_x := 0.0
@export var corruption_speed := 0.0


var _corruption_x: float


@onready var player : Player = $Player
@onready var pause_menu : PauseMenu = $%PauseMenu

@onready var level_material : ShaderMaterial = $%LevelColorRect.material


func _ready() -> void:
	_corruption_x = initial_corruption_x
	pause_menu.hide()
	
	#TODO Add gameplay music


func _process(delta: float) -> void:
	_corruption_x += corruption_speed * delta

	var screen_to_world := player.camera.get_canvas_transform().affine_inverse()
	level_material.set_shader_parameter("screen_to_world", screen_to_world)
	level_material.set_shader_parameter("corruption_x", _corruption_x)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
		get_tree().paused = true
		pause_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
