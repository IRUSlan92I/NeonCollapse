class_name Player
extends CharacterBody2D


signal health_changed(value: float)
signal dead()


const MAX_HEALTH = 100.0
const CAMERA_OFFSET_FACTOR = 0.4
const CAMERA_OFFSET_TIME = 1.0


@export_group("Movement", "move")
@export_range(0.0, 1000.0) var move_max_speed_normal := 350
@export_range(0.0, 1000.0) var move_max_speed_slowed := 250
@export_range(0.0, 1000.0) var move_acceleration := 750.0

@export_group("Jump", "jump")
@export_range(0.0, 1000.0) var jump_max_fall_speed := 1000
@export_range(0.0, 1000.0) var jump_floor_velocity := 500.0
@export var jump_wall_velocity := Vector2(500, 500)

@export_group("Gravity factors", "gravity_factor")
@export_range(0.0, 2.0) var gravity_factor_jump := 1.0
@export_range(0.0, 2.0) var gravity_factor_fall := 1.5
@export_range(0.0, 2.0) var gravity_factor_slide := 0.1
@export_range(0.0, 1.0) var gravity_factor_passive_jump := 0.5

@export_group("Attack slow down", "slow_down")
@export_range(0.0, 1000.0) var slow_down_attack := 0.05
@export_range(0.0, 1000.0) var slow_down_sustain := 0.70
@export_range(0.0, 1000.0) var slow_down_release := 0.25


var _slow_down_tween: Tween
var _camera_offset_tween: Tween

var _last_wall_normal: = 0.0

var _current_health: = MAX_HEALTH:
	set(value):
		_current_health = value
		health_changed.emit(_current_health)


@onready var player_sprite : AnimatedSprite2D = $PlayerSprite
@onready var blade_sprite : AnimatedSprite2D = $BladeSprite
@onready var left_attack_sprite : AnimatedSprite2D = $LeftAttackSprite
@onready var right_attack_sprite : AnimatedSprite2D = $RightAttackSprite
@onready var left_attack_area : Area2D = $LeftAttackArea
@onready var right_attack_area : Area2D = $RightAttackArea

@onready var camera : Camera2D = $Camera2D
@onready var state_machine : StateMachine = $StateMachine

@onready var jump_buffer_timer : Timer = $JumpBufferTimer

@onready var floor_coyote_time_timer : Timer = $FloorCoyoteTimeTimer
@onready var wall_coyote_time_timer : Timer = $WallCoyoteTimeTimer

@onready var wall_attach_timer : Timer = $WallAttachTimer
@onready var attack_buffer_timer : Timer = $AttackBufferTimer
@onready var attack_cooldown_timer : Timer = $AttackCooldownTimer

@onready var wall_left_particles : GPUParticles2D = $WallLeftParticles
@onready var wall_right_particles : GPUParticles2D = $WallRightParticles

@onready var _max_speed := move_max_speed_normal


func _ready() -> void:
	state_machine.init()
	
	for sprite : AnimatedSprite2D in [ left_attack_sprite, right_attack_sprite ]:
		var lambda := func() -> void:
			sprite.hide()
			if not is_zero_approx(velocity.x):
				blade_sprite.show()
		sprite.animation_finished.connect(lambda)
		sprite.hide()


func _physics_process(delta: float) -> void:	
	if is_on_floor():
		floor_coyote_time_timer.start()
		_last_wall_normal = 0.0
	if is_on_ceiling_only() and velocity.y < 0.0:
		velocity.y = 0.0
	
	var input_direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
	
	if not is_on_floor():
		var gravity_factor := gravity_factor_jump if velocity.y < 0.0 else gravity_factor_fall
		
		if is_on_wall_only() and not is_zero_approx(input_direction):
			var wall_normal := get_wall_normal().x
			if (wall_normal * input_direction) < 0.0:
				wall_coyote_time_timer.start()
				if sign(wall_normal) != sign(_last_wall_normal):
					wall_attach_timer.start()
					velocity.y = 0.0
				_last_wall_normal = wall_normal
				
				if not Input.is_action_pressed("move_down") and velocity.y > 0.0:
					gravity_factor = gravity_factor_slide if wall_attach_timer.is_stopped() else 0.0
		
		if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
			velocity.y *= gravity_factor_passive_jump
			
		velocity += get_gravity() * gravity_factor * delta
		velocity.y = clampf(velocity.y, -jump_max_fall_speed, jump_max_fall_speed)
	
	if not jump_buffer_timer.is_stopped():
		if not floor_coyote_time_timer.is_stopped():
			velocity.y = -jump_floor_velocity
			jump_buffer_timer.stop()
			floor_coyote_time_timer.stop()
			SoundManager.play_sfx_stream(SoundManager.sfx_stream_jump, global_position)
		elif not wall_coyote_time_timer.is_stopped():
			velocity = -jump_wall_velocity
			velocity.x *= -_last_wall_normal
			jump_buffer_timer.stop()
			wall_coyote_time_timer.stop()
			SoundManager.play_sfx_stream(SoundManager.sfx_stream_wall_jump, global_position)
	
	if input_direction:
		var input_velocity := input_direction * _max_speed
		velocity.x = move_toward(velocity.x, input_velocity, move_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, move_acceleration * delta)
	
	if not attack_buffer_timer.is_stopped():
		if _can_attack():
			_attack()
			attack_buffer_timer.stop()
	
	move_and_slide()
	state_machine.physics_process(delta)
	
	if _camera_offset_tween and _camera_offset_tween.is_running():
		_camera_offset_tween.kill()
	_camera_offset_tween = create_tween()
	var new_camera_position := Vector2(velocity.x * CAMERA_OFFSET_FACTOR, 0)
	_camera_offset_tween.tween_property(camera, "position", new_camera_position, CAMERA_OFFSET_TIME)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if _can_attack():
			_attack()
		else:
			attack_buffer_timer.start()


func deal_damage(value: float) -> void:
	_current_health -= value
	health_changed.emit(_current_health)
	if _current_health < 0.0 or is_zero_approx(_current_health):
		dead.emit()


func _can_attack() -> bool:
	if not attack_cooldown_timer.is_stopped():
		return false
	if is_on_wall() and is_on_floor() or is_zero_approx(velocity.x):
		return false
	return true


func _attack() -> void:
	attack_cooldown_timer.start()
	var is_left := velocity.x <= 0.0
	var sprite := left_attack_sprite if is_left else right_attack_sprite
	var attack_area := left_attack_area if is_left else right_attack_area
	sprite.show()
	attack_area.monitoring = true
	blade_sprite.hide()
	sprite.play("attack")
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_swing, global_position)
	
	_max_speed = move_max_speed_normal
	_slow_down_tween = create_tween()
	_slow_down_tween.tween_property(self, "_max_speed", move_max_speed_slowed, slow_down_attack)
	_slow_down_tween.tween_property(self, "_max_speed", move_max_speed_slowed, slow_down_sustain)
	_slow_down_tween.tween_property(self, "_max_speed", move_max_speed_normal, slow_down_release)
	_slow_down_tween.tween_property(sprite, "visible", false, 0.0)


func _on_attack_area_entered(area: Area2D) -> void:
	if area is TurretProjectile:
		area.queue_free()


func _on_left_attack_sprite_animation_finished() -> void:
	left_attack_area.monitoring = false


func _on_right_attack_sprite_animation_finished() -> void:
	right_attack_area.monitoring = false
