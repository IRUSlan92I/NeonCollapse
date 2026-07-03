class_name ControllerSplash
extends Control


func _ready() -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_best_with_controller)
	
	var label : Label = $Label
	var _opacity_tween := create_tween()
	_opacity_tween.tween_property(label, "modulate:a", 0.0, 0.0)
	_opacity_tween.tween_property(label, "modulate:a", 1.0, 1.0)
	_opacity_tween.tween_property(label, "modulate:a", 1.0, 1.0)
	_opacity_tween.tween_property(label, "modulate:a", 0.0, 1.0)
	_opacity_tween.tween_property(label, "modulate:a", 0.0, 0.1)
	
	await _opacity_tween.finished
	
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")
	
