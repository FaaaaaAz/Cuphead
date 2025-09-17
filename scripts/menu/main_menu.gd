extends Control

@onready var characters: AnimatedSprite2D = $Characters

func _ready() -> void:
	MusicPlayer.play_music("menu_theme")
	
	if characters:
		characters.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
