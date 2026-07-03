extends AbstractLevel


@onready var congratulations : Control = $CanvasLayer/Congratulations


func _ready() -> void:
	super._ready()
	congratulations.hide()


func _complete_level(player_position: Vector2) -> void:
	SoundManager.play_ui_stream(SoundManager.sfx_stream_congratulations)
	get_tree().paused = true
	congratulations.show()
	
	await get_tree().create_timer(5, true).timeout
	congratulations.hide()
	super._complete_level(player_position)
