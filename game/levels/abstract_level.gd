class_name AbstractLevel
extends Node2D


const CORRUPTION_DAMAGE = 10.0


@export var initial_corruption_x := 0.0
@export var corruption_speed := 0.0


var _corruption_x: float


@onready var player : Player = $Player
@onready var pause_menu : PauseMenu = $%PauseMenu
@onready var game_over_menu : GameOverMenu = $%GameOverMenu
@onready var health_bar : HealthBar = $%HealthBar

@onready var corruption_timer : Timer = $CorruptionTimer
@onready var death_fall_timer : Timer = $DeathFallTimer

@onready var level_material : ShaderMaterial = $%LevelColorRect.material


func _ready() -> void:
	_corruption_x = initial_corruption_x
	pause_menu.hide()
	game_over_menu.hide()
	
	health_bar.initialize(player.MAX_HEALTH, player.MAX_HEALTH)
	player.health_changed.connect(health_bar.set_current_value)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	#TODO Add gameplay music


func _process(_delta: float) -> void:
	var screen_to_world := player.camera.get_canvas_transform().affine_inverse()
	level_material.set_shader_parameter("screen_to_world", screen_to_world)
	level_material.set_shader_parameter("corruption_x", _corruption_x)


func _physics_process(delta: float) -> void:
	_corruption_x += corruption_speed * delta
	
	if player.position.x < _corruption_x:
		if corruption_timer.is_stopped():
			corruption_timer.start()
	else:
		corruption_timer.stop()
	
	if player.position.y > 0.0:
		if death_fall_timer.is_stopped():
			death_fall_timer.start()
			SoundManager.play_sfx_stream(SoundManager.sfx_stream_fall, player.global_position)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
		get_tree().paused = true
		pause_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _show_game_over() -> void:
	get_tree().paused = true
	game_over_menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_corruption_timer_timeout() -> void:
	player.deal_damage(CORRUPTION_DAMAGE)
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_corruption, player.global_position)


func _on_player_dead() -> void:
	_show_game_over()
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_game_over, player.global_position)


func _on_death_fall_timer_timeout() -> void:
	_show_game_over()
