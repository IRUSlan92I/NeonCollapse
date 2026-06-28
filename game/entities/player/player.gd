class_name Player
extends CharacterBody2D


@export_group("Movement", "movement")
@export_range(0.0, 1000.0) var movement_max_speed_normal := 350
@export_range(0.0, 1000.0) var movement_max_speed_after_attack := 250
@export_range(0.0, 1000.0) var movement_acceleration := 1000.0

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

var _last_wall_normal: = 0.0


@onready var player_sprite : AnimatedSprite2D = $PlayerSprite
@onready var blade_sprite : AnimatedSprite2D = $BladeSprite
@onready var attack_left_sprite : AnimatedSprite2D = $AttackLeftSprite
@onready var attack_right_sprite : AnimatedSprite2D = $AttackRightSprite

@onready var state_machine : StateMachine = $StateMachine

@onready var jump_buffer_timer : Timer = $JumpBufferTimer

@onready var floor_coyote_time_timer : Timer = $FloorCoyoteTimeTimer
@onready var wall_coyote_time_timer : Timer = $WallCoyoteTimeTimer

@onready var wall_attach_timer : Timer = $WallAttachTimer
@onready var attack_cooldown_timer : Timer = $AttackCooldownTimer

@onready var _max_speed := movement_max_speed_normal


func _ready() -> void:
	state_machine.init()


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
		elif not wall_coyote_time_timer.is_stopped():
			velocity = -jump_wall_velocity
			velocity.x *= -_last_wall_normal
			jump_buffer_timer.stop()
			wall_coyote_time_timer.stop()
	
	
	if input_direction:
		var input_velocity := input_direction * _max_speed
		velocity.x = move_toward(velocity.x, input_velocity, movement_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, movement_acceleration * delta)
	
	move_and_slide()
	state_machine.physics_process(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not _slow_down_tween or not _slow_down_tween.is_running():
			print("Attack")
			_slow_down_tween = create_tween()
			_slow_down_tween.tween_property(self, "_max_speed", \
				movement_max_speed_after_attack, slow_down_attack)
			_slow_down_tween.tween_property(self, "_max_speed", \
				movement_max_speed_after_attack, slow_down_sustain)
			_slow_down_tween.tween_property(self, "_max_speed", \
				movement_max_speed_normal, slow_down_release)
