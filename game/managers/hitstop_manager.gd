class_name CHitstopManager
extends Node


const NORMAL_TIME_SCALE = 1.0


@export var short_hitstop_duration := 0.05
@export var medium_hitstop_duration := 0.1
@export var long_hitstop_duration := 0.15
@export var hitstop_time_scale := 0.0


func short_hitstop() -> void:
	_hitstop(short_hitstop_duration)


func medium_hitstop() -> void:
	_hitstop(medium_hitstop_duration)


func long_hitstop() -> void:
	_hitstop(long_hitstop_duration)


func _hitstop(duration: float) -> void:
	Engine.time_scale = hitstop_time_scale
	await get_tree().create_timer(duration, true, true, true).timeout
	Engine.time_scale = NORMAL_TIME_SCALE
