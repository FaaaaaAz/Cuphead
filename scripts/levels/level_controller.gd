extends Node2D

func _ready():
	MusicPlayer.play_level_start_sequence()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_map()

func return_to_map():
	MusicPlayer.play_music("map_theme")
	SceneTransition.change_scene("res://scenes/ui/world_map.tscn")