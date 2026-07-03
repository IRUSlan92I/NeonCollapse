class_name AbstractLevel
extends Node2D


const CORRUPTION_DAMAGE = 10.0
const MAX_DISTANCE_TO_CORRUPTION = 320.0
const CAMERA_LIMIT_OFFSET = -20


@export var is_player_running_on_start := true
@export var background_offset := 0.0
@export var initial_corruption_x := -400.0
@export var corruption_speed := 200.0
@export var desctruction_offset := 100.0


var _corruption_x: float


@onready var player : Player = $Player
@onready var pause_menu : PauseMenu = $%PauseMenu
@onready var game_over_menu : GameOverMenu = $%GameOverMenu
@onready var completion_menu : CompletionMenu = $%CompletionMenu
@onready var health_bar : HealthBar = $%HealthBar

@onready var corruption_timer : Timer = $CorruptionTimer
@onready var destruction_timer : Timer = $DestructionTimer
@onready var death_fall_timer : Timer = $DeathFallTimer

@onready var level_material : ShaderMaterial = $%LevelColorRect.material
@onready var code_material : ShaderMaterial = $%CodeSprite.material

@onready var camera : Camera2D = player.camera
@onready var level_end : Area2D = $LevelEnd

@onready var parallax_1 : Parallax2D = $Background/Parallax1


func _ready() -> void:
	parallax_1.scroll_offset.x = -background_offset * parallax_1.scroll_scale.x
	
	camera.limit_right = int(level_end.position.x + CAMERA_LIMIT_OFFSET)
	
	_corruption_x = initial_corruption_x
	pause_menu.hide()
	game_over_menu.hide()
	completion_menu.hide()
	
	if is_player_running_on_start:
		player.velocity.x = player.move_max_speed_normal
	
	health_bar.initialize(player.MAX_HEALTH, player.MAX_HEALTH)
	player.health_changed.connect(health_bar.set_current_value)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	SoundManager.play_music_stream(SoundManager.music_stream_gameplay)


func _process(_delta: float) -> void:
	var screen_to_world := camera.get_canvas_transform().affine_inverse()
	level_material.set_shader_parameter("screen_to_world", screen_to_world)
	level_material.set_shader_parameter("corruption_x", _corruption_x)
	code_material.set_shader_parameter("screen_to_world", screen_to_world)
	code_material.set_shader_parameter("destruction_x", _corruption_x - desctruction_offset)


func _physics_process(delta: float) -> void:
	_corruption_x += corruption_speed * delta
	
	if not player: return
	
	if player.position.x < _corruption_x - desctruction_offset:
		_destroy_player()
	elif player.position.x < _corruption_x:
		if corruption_timer.is_stopped():
			corruption_timer.start()
	else:
		corruption_timer.stop()
		if player.position.x - _corruption_x > MAX_DISTANCE_TO_CORRUPTION:
			_corruption_x = player.position.x - MAX_DISTANCE_TO_CORRUPTION
	
	if player.position.y > 0.0:
		SoundManager.play_sfx_stream(SoundManager.sfx_stream_fall, player.global_position)
		death_fall_timer.start()
		_delete_player()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
		get_tree().paused = true
		pause_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _destroy_player() -> void:
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_destruction, player.global_position)
	_delete_player()


func _delete_player() -> void:
	player.camera.reparent(self)
	destruction_timer.start()
	player.queue_free()


func _show_game_over() -> void:
	get_tree().paused = true
	game_over_menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _complete_level(player_position: Vector2) -> void:
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_level_completed, player_position)
	get_tree().paused = true
	completion_menu.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if SaveManager.completed_levels <= LevelManager.current_level_index:
		SaveManager.completed_levels = LevelManager.current_level_index + 1
		SaveManager.save()


func _on_corruption_timer_timeout() -> void:
	if not player:
		corruption_timer.stop()
		return
	player.deal_damage(CORRUPTION_DAMAGE)
	HitstopManager.medium_hitstop()
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_corruption, player.global_position)


func _on_player_dead() -> void:
	_show_game_over()
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_game_over, player.global_position)


func _on_death_fall_timer_timeout() -> void:
	_show_game_over()


func _on_destruction_timer_timeout() -> void:
	_show_game_over()


func _on_level_end_body_entered(body: Node2D) -> void:
	if body is Player:
		_complete_level(player.global_position)
