class_name CodeLine
extends Parallax2D


const WIDTH = 11696
const MIN_SCROLL_SPEED = 500
const MAX_SCROLL_SPEED = 1000


func _ready() -> void:
	repeat_size.x = WIDTH
	scroll_offset.x = randi_range(0, WIDTH)
	autoscroll.x = -randi_range(MIN_SCROLL_SPEED, MAX_SCROLL_SPEED)
