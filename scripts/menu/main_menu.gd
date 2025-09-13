# main_menu.gd
extends Control

# Referencias a los nodos del menú
@onready var characters: AnimatedSprite2D = $Characters

func _ready() -> void:
	if characters:
		characters.play()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")
