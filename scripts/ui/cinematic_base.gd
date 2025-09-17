extends Control

@export var next_scene_path: String = ""
@onready var cinematic_image = $CinematicImage

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		go_to_next_scene()

func go_to_next_scene():
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")