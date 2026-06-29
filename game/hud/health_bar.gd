class_name HealthBar
extends Node2D

const ANIMATION_ALERT = "alert"

const SHADER_MAX_VALUE = "shader_parameter/max_value"
const SHADER_CURRENT_VALUE = "shader_parameter/current_value"
const SHADER_OLD_VALUE = "shader_parameter/old_value"


const OLD_VALUE_DECRETION_RATE = 25.0


var _max_value := 0.0:
	set(value):
		_max_value = value
		if is_node_ready():
			health_sprite.material.set(SHADER_MAX_VALUE, _max_value)

var _current_value := 0.0:
	set(value):
		_current_value = value
		if is_node_ready():
			health_sprite.material.set(SHADER_CURRENT_VALUE, _current_value)

var _old_value := 0.0:
	set(value):
		_old_value = value
		if is_node_ready():
			health_sprite.material.set(SHADER_OLD_VALUE, _old_value)

var _old_value_tween : Tween

var _is_animation_needed := false


@onready var background_sprite : Sprite2D = $BackgroundSprite
@onready var alert_sprite : Sprite2D = $AlertSprite
@onready var health_sprite : Sprite2D = $HealthSprite

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	alert_sprite.hide()


func _process(_delta: float) -> void:
	if _is_animation_needed and not animation_player.is_playing():
		animation_player.play(ANIMATION_ALERT)
		_is_animation_needed = false


func initialize(max_value: float, value: float) -> void:
	_max_value = max_value
	_current_value = value
	_old_value = value


func set_current_value(value: float) -> void:
	if value < _current_value:
		_is_animation_needed = true
	
	_current_value = value
	var time := (_old_value - _current_value)/OLD_VALUE_DECRETION_RATE
	
	if _old_value_tween and _old_value_tween.is_running():
		_old_value_tween.kill()
	
	_old_value_tween = create_tween()
	_old_value_tween.tween_property(self, "_old_value", _current_value, abs(time))
