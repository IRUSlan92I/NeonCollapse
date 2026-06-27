class_name CHitstopManager
extends Node


const NORMAL_TIME_SCALE = 1.0


@export var hitstop_duration := 0.1
@export var hitstop_time_scale := 0.0


func hitstop() -> void:
	Engine.time_scale = hitstop_time_scale
	await get_tree().create_timer(hitstop_duration, true, true, true).timeout
	Engine.time_scale = NORMAL_TIME_SCALE
