@tool
class_name Turret
extends Node2D


enum Direction {
	Left,
	Right,
}


const PROJECTILE = preload("res://game/entities/turret/turret_projectile.tscn")

const ANIMATION_IDLE = "idle"
const ANIMATION_SHOOT = "shoot"

const SHOT_FRAME = 3


@export_range(1.0, 10.0) var shoot_delay := 1.0

@export var direction := Direction.Left:
	set(value):
		direction = value
		if is_node_ready():
			_update_direction()


@onready var left_sprite : AnimatedSprite2D = $LeftSprite
@onready var right_sprite : AnimatedSprite2D = $RightSprite

@onready var left_muzzle : Node2D = $LeftMuzzle
@onready var right_muzzle : Node2D = $RightMuzzle

@onready var shoot_timer : Timer = $ShootTimer


var _current_sprite : AnimatedSprite2D
var _current_muzzle : Node2D


func _ready() -> void:
	left_sprite.hide()
	right_sprite.hide()
	_update_direction()
	if not Engine.is_editor_hint():
		shoot_timer.start(shoot_delay)


func _shoot() -> void:
	var projectile : TurretProjectile = PROJECTILE.instantiate()
	projectile.global_position = _current_muzzle.global_position
	projectile.direction = _get_projectile_direction()
	get_tree().current_scene.add_child(projectile)


func _update_direction() -> void:
	if _current_sprite:
		_current_sprite.hide()
	match direction:
		Direction.Left:
			_current_sprite = left_sprite
			_current_muzzle = left_muzzle
		Direction.Right:
			_current_sprite = right_sprite
			_current_muzzle = right_muzzle
		_:
			push_error("Wrong turret direction")
	_current_sprite.show()


func _get_projectile_direction() -> Vector2:
	match direction:
		Direction.Left:
			return Vector2.LEFT
		Direction.Right:
			return Vector2.RIGHT
		_:
			push_error("Wrong turret direction")
			return Vector2.ZERO


func _on_left_sprite_animation_finished() -> void:
	left_sprite.play(ANIMATION_IDLE)


func _on_right_sprite_animation_finished() -> void:
	right_sprite.play(ANIMATION_IDLE)


func _on_shoot_timer_timeout() -> void:
	_current_sprite.play(ANIMATION_SHOOT)
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_turret_shot, global_position)


func _on_sprite_frame_changed() -> void:
	if _current_sprite.frame == SHOT_FRAME:
		_shoot()
