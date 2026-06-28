extends AbstractPlayerState


@export var running_left : AbstractPlayerState
@export var running_right : AbstractPlayerState
@export var jump_left : AbstractPlayerState
@export var jump_right : AbstractPlayerState


func enter() -> void:
	player.player_sprite.play(ANIMATION_IDLE)


func physics_process(_delta: float) -> void:
	if player.is_on_floor():
		if is_zero_approx(player.velocity.x):
			pass
		elif player.velocity.x < 0.0:
			switch_state.emit(running_left)
		elif player.velocity.x > 0.0:
			switch_state.emit(running_right)
	else:
		if is_zero_approx(player.velocity.x):
			switch_state.emit([jump_left, jump_right].pick_random())
		elif player.velocity.x < 0.0:
			switch_state.emit(jump_left)
		elif player.velocity.x > 0.0:
			switch_state.emit(jump_right)
