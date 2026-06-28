extends AbstractPlayerState


enum Direction {
	Left,
	Right,
}


@export var direction := Direction.Left

@export var idle : AbstractPlayerState
@export var another_direction : AbstractPlayerState
@export var run : AbstractPlayerState
@export var run_another_direction : AbstractPlayerState


func enter() -> void:
	player.blade_sprite.show()
	match direction:
		Direction.Left:
			player.player_sprite.play(ANIMATION_JUMP_LEFT)
			player.blade_sprite.play(ANIMATION_JUMP_LEFT)
		Direction.Right:
			player.player_sprite.play(ANIMATION_JUMP_RIGHT)
			player.blade_sprite.play(ANIMATION_JUMP_RIGHT)


func exit() -> void:
	player.blade_sprite.hide()


func physics_process(_delta: float) -> void:
	if player.is_on_floor():
		if is_zero_approx(player.velocity.x):
			switch_state.emit(idle)
		else:
			match direction:
				Direction.Left:
					if player.velocity.x < 0.0:
						switch_state.emit(run)
					else:
						switch_state.emit(run_another_direction)
				Direction.Right:
					if player.velocity.x > 0.0:
						switch_state.emit(run)
					else:
						switch_state.emit(run_another_direction)
	else:
		if not is_zero_approx(player.velocity.x):
			match direction:
				Direction.Left:
					if player.velocity.x > 0.0:
						switch_state.emit(another_direction)
				Direction.Right:
					if player.velocity.x < 0.0:
						switch_state.emit(another_direction)
