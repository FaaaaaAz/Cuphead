extends Area2D

# Exportamos la ruta de la escena del nivel para poder configurarla desde el Inspector
@export var level_scene_path: String

# Referencia al ícono que muestra la tecla a presionar
@onready var interaction_prompt = $GODO

# Variable para saber si el jugador está dentro del área
var player_is_near = false

# Esta función se llama cuando un cuerpo (como el jugador) entra en el área
func _on_body_entered(body):
	# Verificamos si el cuerpo que entró es el jugador
	# (Asumiendo que tu jugador tiene un script llamado "map_player.gd" o similar)
	if body.name == "MapPlayer":
		interaction_prompt.show() # Mostramos el ícono "E"
		player_is_near = true

# Esta función se llama cuando el cuerpo sale del área
func _on_body_exited(body):
	if body.name == "MapPlayer":
		interaction_prompt.hide() # Ocultamos el ícono "E"
		player_is_near = false

# Se ejecuta en cada fotograma
func _process(delta):
	# Si el jugador está cerca y presiona la tecla de interacción...
	if player_is_near and Input.is_action_just_pressed("ui_accept"):
		# Por ahora, solo imprimimos un mensaje para probar
		print("¡Entrando al nivel: ", level_scene_path)
		# MÁS ADELANTE, AQUÍ LLAMAREMOS A LA TITLE CARD
