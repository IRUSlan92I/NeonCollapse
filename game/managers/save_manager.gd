class_name CSaveManager
extends Node


@export var save_file_path := "user://save.bin"
@export var save_file_pass := "save_file_data"


const CATEGORY_GAME = "game"
const GAME_COMPLETED_LEVELS = "completed_levels"


var completed_levels := 0

var _save_file: ConfigFile


func _ready() -> void:
	_save_file = ConfigFile.new()
	_load()


func save() -> void:
	_save_file.set_value(CATEGORY_GAME, GAME_COMPLETED_LEVELS, completed_levels)
	_save_file.save_encrypted_pass(save_file_path, save_file_pass)




func _load() -> void:
	if _save_file.load_encrypted_pass(save_file_path, save_file_pass) == OK:
		_process_save_file()
	
	save()


func _process_save_file() -> void:
	completed_levels = _save_file.get_value(
		CATEGORY_GAME, GAME_COMPLETED_LEVELS, completed_levels
	)
