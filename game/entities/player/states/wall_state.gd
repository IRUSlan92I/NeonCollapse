extends AbstractPlayerState


const PARTICLE_FACTOR = 100.0


enum Direction {
	Left,
	Right,
}


@export var direction := Direction.Left

@export var idle : AbstractPlayerState
@export var jump : AbstractPlayerState

@export var particles : GPUParticles2D


func enter() -> void:
	particles.emitting = true
	match direction:
		Direction.Left:
			player.player_sprite.play(ANIMATION_WALL_LEFT)
		Direction.Right:
			player.player_sprite.play(ANIMATION_WALL_RIGHT)


func exit() -> void:
	particles.emitting = false


func physics_process(_delta: float) -> void:
	particles.amount_ratio = clampf(player.velocity.y / PARTICLE_FACTOR, 0.0, 1.0)
	
	if player.is_on_floor():
		switch_state.emit(idle)
	elif not player.is_on_wall():
		switch_state.emit(jump)
