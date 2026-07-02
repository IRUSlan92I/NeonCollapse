class_name CSoundManager
extends Node


const MASTER_BUS = "Master"
const UI_BUS = "UI"
const SFX_BUS = "SFX"
const MUSIC_BUS = "Music"


@export_group("Pitch settings", "pitch")
@export_range(0.9, 1.1, 0.01) var pitch_ui_min := 1.0
@export_range(0.9, 1.1, 0.01) var pitch_ui_max := 1.0
@export_range(0.9, 1.1, 0.01) var pitch_sfx_min := 1.0
@export_range(0.9, 1.1, 0.01) var pitch_sfx_max := 1.0

@export_group("Number of players", "player_count")
@export_range(1, 10) var player_count_ui := 1
@export_range(1, 100) var player_count_sfx := 1

@export_group("UI Streams", "ui_stream")
@export var ui_stream_accept : AudioStream
@export var ui_stream_decline : AudioStream
@export var ui_stream_select : AudioStream

@export_group("SFX Streams", "sfx_stream")
@export var sfx_stream_corruption : AudioStream
@export var sfx_stream_danger : AudioStream
@export var sfx_stream_destruction : AudioStream
@export var sfx_stream_fall : AudioStream
@export var sfx_stream_game_over : AudioStream
@export var sfx_stream_jump : AudioStream
@export var sfx_stream_land : AudioStream
@export var sfx_stream_level_completed : AudioStream
@export var sfx_stream_swing : AudioStream
@export var sfx_stream_turret_hit : AudioStream
@export var sfx_stream_turret_shot : AudioStream
@export var sfx_stream_wall_jump : AudioStream


@export_group("Music Streams", "music_stream")
@export var music_stream_menu : AudioStream
@export var music_stream_gameplay : AudioStream



var _ui_players : Array[AudioStreamPlayer] = []
var _sfx_players : Array[AudioStreamPlayer2D] = []
var _music_player : AudioStreamPlayer


func _ready() -> void:
	_create_ui_players()
	_create_sfx_players()
	_create_music_player()


func play_ui_stream(stream: AudioStream) -> AudioStreamPlayer:
	var player := _get_free_player(_ui_players)
	player.stream = stream
	player.pitch_scale = randf_range(pitch_ui_min, pitch_ui_max)
	player.play()
	return player


func play_sfx_stream(stream: AudioStream, position: Vector2) -> AudioStreamPlayer2D:
	var player := _get_free_2d_player(_sfx_players)
	player.stream = stream
	player.pitch_scale = randf_range(pitch_ui_min, pitch_ui_max)
	player.position = position
	player.play()
	return player


func play_music_stream(stream: AudioStream) -> AudioStreamPlayer:
	if _music_player.stream == stream: return
	
	_music_player.stream = stream
	_music_player.play()
	return _music_player


func _create_ui_players() -> void:
	for i in range(player_count_ui):
		var player : AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = UI_BUS
		_ui_players.append(player)
		add_child(player)


func _create_sfx_players() -> void:
	for i in range(player_count_sfx):
		var player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS
		_sfx_players.append(player)
		add_child(player)


func _create_music_player() -> void:
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = MUSIC_BUS
	_music_player = player
	add_child(player)


func _get_free_player(players: Array[AudioStreamPlayer]) -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			return player
	return players[0]


func _get_free_2d_player(players: Array[AudioStreamPlayer2D]) -> AudioStreamPlayer2D:
	for player in players:
		if not player.playing:
			return player
	return players[0]
