@tool
class_name Danger
extends ColorRect


const DAMAGE_VALUE = 50.0
const COLLISION_OFFSET = Vector2(16, 16)


var _player : Player


@onready var damage_timer : Timer = $DamageTimer
@onready var collision : CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	_setup_collision()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_setup_collision()


func _setup_collision() -> void:
	collision.shape.size = size - COLLISION_OFFSET
	collision.position = (size)/2


func _hit_player() -> bool:
	if not _player: return false
	SoundManager.play_sfx_stream(SoundManager.sfx_stream_danger, global_position)
	_player.deal_damage(DAMAGE_VALUE)
	HitstopManager.medium_hitstop()
	return true


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player = body
	_hit_player()
	damage_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	damage_timer.stop()
	_player = null


func _on_damage_timer_timeout() -> void:
	if not _hit_player():
		damage_timer.stop()
