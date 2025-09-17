extends Control

# Escena siguiente a cargar cuando se haga click
@export var next_scene_path: String = ""

# Referencia a la imagen de la escena
@onready var cinematic_image = $CinematicImage

func _ready():
	print("Escena cinematográfica iniciada")

func _input(event):
	# Detecta un clic izquierdo del ratón o la tecla Enter/Espacio
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		go_to_next_scene()

func go_to_next_scene():
	if next_scene_path != "":
		print("Cambiando a: ", next_scene_path)
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Historia terminada - regresando al menú principal")
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")