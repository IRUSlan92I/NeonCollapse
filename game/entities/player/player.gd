class_name Player
extends CharacterBody2D


@export_group("Movement", "movement")
@export_range(0.0, 1000.0) var movement_max_speed_normal := 350
@export_range(0.0, 1000.0) var movement_max_speed_after_attack := 250
@export_range(0.0, 1000.0) var movement_acceleration := 1000.0

@export_group("Jump", "jump")
@export_range(0.0, 1000.0) var jump_max_fall_speed := 1000
@export_range(0.0, 1000.0) var jump_velocity := 500.0

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


@onready var state_machine : StateMachine = $StateMachine

@onready var jump_buffer_timer : Timer = $JumpBufferTimer
@onready var coyote_time_timer : Timer = $CoyoteTimeTimer
@onready var attack_cooldown_timer : Timer = $AttackCooldownTimer
@onready var slide_delay_timer : Timer = $SlideDelayTimer

@onready var _max_speed := movement_max_speed_normal


func _ready() -> void:
	state_machine.init()


func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_time_timer.start()
	if is_on_ceiling_only() and velocity.y < 0.0:
		velocity.y = 0.0
	
	if not is_on_floor():
		var gravity_factor := gravity_factor_jump if velocity.y < 0.0 else gravity_factor_fall
		
		if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
			velocity.y *= gravity_factor_passive_jump
		
		velocity += get_gravity() * gravity_factor * delta
		velocity.y = clampf(velocity.y, -jump_max_fall_speed, jump_max_fall_speed)
	
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
		
	if not coyote_time_timer.is_stopped() and not jump_buffer_timer.is_stopped():
		velocity.y = -jump_velocity
		jump_buffer_timer.stop()
		coyote_time_timer.stop()
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * _max_speed, movement_acceleration * delta)
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
