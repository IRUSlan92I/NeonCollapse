class_name TurretProjectile
extends Area2D


const SPEED = 300
const DAMAGE = 20.0

const ANIMATION_WOBBLE = "wobble"


@export var direction := Vector2.ZERO


var is_on_screen := false


@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var fly_particles : GPUParticles2D = $FlyParticles


func _ready() -> void:
	sprite.play(ANIMATION_WOBBLE)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SoundManager.play_sfx_stream(SoundManager.sfx_stream_turret_hit, global_position)
		HitstopManager.short_hitstop()
		body.deal_damage(DAMAGE)
	queue_free()


func _on_screen_entered() -> void:
	is_on_screen = true


func _on_screen_exited() -> void:
	if is_on_screen:
		queue_free()


func _on_destroy_particles_finished() -> void:
	queue_free()
