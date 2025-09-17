extends Area2D

@export var level_scene_path: String
@onready var interaction_prompt = $InteractionPrompt

var player_is_near = false

func _ready():
	# Conectar las señales del Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Asegurar que el prompt esté oculto al inicio
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body):
	# Verificar si es un CharacterBody2D (el jugador) en lugar del nombre específico
	if body is CharacterBody2D:
		print("Jugador entró al área de ", level_scene_path)
		if interaction_prompt:
			interaction_prompt.visible = true
		player_is_near = true

func _on_body_exited(body):
	if body is CharacterBody2D:
		print("Jugador salió del área")
		if interaction_prompt:
			interaction_prompt.visible = false
		player_is_near = false

func _input(event):
	if player_is_near and (event.is_action_pressed("jump") or event.is_action_pressed("ui_accept")):
		enter_level()

func enter_level():
	if level_scene_path != "" and ResourceLoader.exists(level_scene_path):
		print("¡Entrando al nivel: ", level_scene_path)
		# Cambiar la música antes de entrar al nivel
		MusicPlayer.force_play_music("floral_fury")
		get_tree().change_scene_to_file(level_scene_path)
	else:
		print("❌ Error: Ruta del nivel no válida: ", level_scene_path)
