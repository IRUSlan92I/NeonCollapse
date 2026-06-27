class_name OptionsMenu
extends Control


const WINDOW_FACTOR = "window_factor"


var _play_sound := false


@onready var fullscreen_button : CheckButton = $%FullscreenCheckButton
@onready var window_factor_buttons : HBoxContainer = $%WindowFactorContainer
@onready var back_button : Button = $%BackButton
@onready var master_slider : Slider = $%MasterSlider
@onready var ui_slider : Slider = $%UISlider
@onready var sfx_slider : Slider = $%SFXSlider
@onready var music_slider : Slider = $%MusicSlider


func _ready() -> void:
	_load_current_settings()
	_connect_window_factor_buttons()
	
	fullscreen_button.grab_focus()
	
	if OS.get_name() == "Web":
		_setup_for_web()
		master_slider.grab_focus()
	
	_play_sound = true
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)


func _setup_for_web() -> void:
	$%FullscreenLabel.hide()
	$%WindowFactorLabel.hide()
	fullscreen_button.hide()
	window_factor_buttons.hide()
	master_slider.focus_neighbor_top = back_button.get_path()
	back_button.focus_neighbor_bottom = master_slider.get_path()


func _connect_window_factor_buttons() -> void:
	for child in window_factor_buttons.get_children():
		if child is Button:
			var button : Button = child
			button.pressed.connect(_on_window_factor_button_pressed.bind(button))


func _load_current_settings() -> void:
	fullscreen_button.button_pressed = SettingsManager.fullscreen
	for child in window_factor_buttons.get_children():
		if child is Button:
			var button : Button = child
			var window_factor : int = button.get_meta(WINDOW_FACTOR, 0)
			if window_factor == SettingsManager.window_factor:
				button.button_pressed = true
	_update_window_factor_disabled()
	
	master_slider.value = SettingsManager.master_volume
	ui_slider.value = SettingsManager.ui_volume
	sfx_slider.value = SettingsManager.sfx_volume
	music_slider.value = SettingsManager.music_volume


func _update_window_factor_disabled() -> void:
	for child in window_factor_buttons.get_children():
		if not child is Button: continue
		child.disabled = SettingsManager.fullscreen
		child.focus_mode = Control.FOCUS_NONE if SettingsManager.fullscreen else Control.FOCUS_ALL


func _on_gui_focus_changed(_node: Control) -> void:
	SoundManager.play_ui_stream(SoundManager.ui_stream_select)


func _on_fullscreen_check_button_toggled(toggled: bool) -> void:
	if _play_sound: SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	SettingsManager.fullscreen = toggled
	_update_window_factor_disabled()


func _on_back_button_pressed() -> void:
	if _play_sound: SoundManager.play_ui_stream(SoundManager.ui_stream_decline)
	get_tree().change_scene_to_file("res://game/menu/main_menu.tscn")


func _on_window_factor_button_pressed(button: Button) -> void:
	if _play_sound: SoundManager.play_ui_stream(SoundManager.ui_stream_accept)
	var window_factor : int = button.get_meta(WINDOW_FACTOR, 0)
	if window_factor > 0:
		SettingsManager.window_factor = window_factor


func _on_master_volume_changed(value: float) -> void:
	if _play_sound: SoundManager.play_ui_stream(SoundManager.ui_stream_select)
	SettingsManager.master_volume = floor(value)


func _on_ui_volume_changed(value: float) -> void:
	if _play_sound: SoundManager.play_ui_stream(SoundManager.ui_stream_select)
	SettingsManager.ui_volume = floor(value)


func _on_sfx_volume_changed(value: float) -> void:
	var screen_center := SettingsManager.window_base_size/2.0
	if _play_sound: SoundManager.play_sfx_stream(SoundManager.ui_stream_select, screen_center)
	SettingsManager.sfx_volume = floor(value)


func _on_music_volume_changed(value: float) -> void:
	SettingsManager.music_volume = floor(value)
