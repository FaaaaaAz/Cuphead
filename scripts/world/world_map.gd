# world_map.gd
extends Node2D

# Referencias a todos los elementos animados del mapa
@onready var shop: AnimatedSprite2D = $Shop
@onready var botanic_panic: AnimatedSprite2D = $BotaticPanic
@onready var clip_joint_calamity: AnimatedSprite2D = $ClipJointCalamity
@onready var home: AnimatedSprite2D = $Home
@onready var ruse_of_an_ooze: AnimatedSprite2D = $RuseOfAnOoze
@onready var shump_tutorial: AnimatedSprite2D = $ShumpTutorial

# Sistema de navegación
var current_level_index: int = 0
var levels: Array = []
var level_positions: Array = []
var level_scenes: Array = []

# Cursor/jugador para navegar
var cursor_position: Vector2
var move_speed: float = 200.0

# Esta función se ejecuta cuando la escena está lista
func _ready() -> void:
	# Iniciar todas las animaciones automáticamente
	start_all_animations()
	
	# Configurar los niveles disponibles
	setup_levels()
	
	# Configurar posición inicial del cursor
	setup_cursor()
	
	print("Mapa del mundo cargado. Usa WASD para moverte y ENTER/SPACE para seleccionar nivel.")

func setup_levels() -> void:
	"""Configurar los niveles disponibles en el mapa"""
	# Agregar niveles disponibles con sus posiciones y escenas
	if botanic_panic:
		levels.append(botanic_panic)
		level_positions.append(botanic_panic.global_position)
		level_scenes.append("res://scenes/levels/level_1.tscn")
	
	if clip_joint_calamity:
		levels.append(clip_joint_calamity)
		level_positions.append(clip_joint_calamity.global_position)
		level_scenes.append("res://scenes/levels/level_1.tscn") # Cambiar cuando tengas más niveles
	
	if ruse_of_an_ooze:
		levels.append(ruse_of_an_ooze)
		level_positions.append(ruse_of_an_ooze.global_position)
		level_scenes.append("res://scenes/levels/level_1.tscn") # Cambiar cuando tengas más niveles
	
	if shump_tutorial:
		levels.append(shump_tutorial)
		level_positions.append(shump_tutorial.global_position)
		level_scenes.append("res://scenes/levels/level_1.tscn") # Cambiar cuando tengas más niveles
	
	if shop:
		levels.append(shop)
		level_positions.append(shop.global_position)
		level_scenes.append("") # La tienda no es un nivel
	
	if home:
		levels.append(home)
		level_positions.append(home.global_position)
		level_scenes.append("") # La casa no es un nivel

func setup_cursor() -> void:
	"""Configurar la posición inicial del cursor"""
	if levels.size() > 0:
		cursor_position = level_positions[current_level_index]
		highlight_current_level()

func _input(event: InputEvent) -> void:
	"""Manejar input del jugador en el mapa"""
	if event.is_action_pressed("move_up"):
		navigate_level(-1)
	elif event.is_action_pressed("move_down"):
		navigate_level(1)
	elif event.is_action_pressed("move_left"):
		navigate_level(-1)
	elif event.is_action_pressed("move_right"):
		navigate_level(1)
	elif event.is_action_pressed("jump") or event.is_action_pressed("shoot"):
		select_current_level()
	elif Input.is_action_just_pressed("ui_cancel") or event.is_action_pressed("ui_cancel"):
		# Volver al menú principal con ESC
		print("Volviendo al menú principal...")
		if SceneTransition:
			SceneTransition.circular_transition_to("res://scenes/ui/start_menu.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")

func navigate_level(direction: int) -> void:
	"""Navegar entre niveles"""
	if levels.size() == 0:
		return
	
	# Remover highlight del nivel actual
	remove_highlight()
	
	# Cambiar índice
	current_level_index += direction
	
	# Asegurar que el índice esté en rango válido
	if current_level_index >= levels.size():
		current_level_index = 0
	elif current_level_index < 0:
		current_level_index = levels.size() - 1
	
	# Actualizar posición del cursor
	cursor_position = level_positions[current_level_index]
	
	# Highlight del nuevo nivel
	highlight_current_level()
	
	print("Nivel seleccionado: ", get_level_name(current_level_index))

func highlight_current_level() -> void:
	"""Resaltar el nivel actual"""
	if current_level_index < levels.size():
		var current_level = levels[current_level_index]
		if current_level:
			# Efecto de highlight (hacer más grande y cambiar color)
			var tween = create_tween()
			tween.tween_property(current_level, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(current_level, "modulate", Color.YELLOW, 0.1)

func remove_highlight() -> void:
	"""Remover highlight del nivel actual"""
	if current_level_index < levels.size():
		var current_level = levels[current_level_index]
		if current_level:
			# Volver al tamaño y color normal
			var tween = create_tween()
			tween.tween_property(current_level, "scale", Vector2(1.0, 1.0), 0.1)
			tween.tween_property(current_level, "modulate", Color.WHITE, 0.1)

func select_current_level() -> void:
	"""Seleccionar el nivel actual"""
	if current_level_index >= level_scenes.size():
		return
	
	var scene_path = level_scenes[current_level_index]
	var level_name = get_level_name(current_level_index)
	
	if scene_path != "":
		print("Entrando al nivel: ", level_name)
		# Usar transición circular para entrar al nivel
		if SceneTransition:
			SceneTransition.circular_transition_to(scene_path)
		else:
			get_tree().change_scene_to_file(scene_path)
	else:
		print("Esta ubicación no es un nivel jugable: ", level_name)

func get_level_name(index: int) -> String:
	"""Obtener el nombre del nivel por índice"""
	if index >= levels.size():
		return "Desconocido"
	
	var level = levels[index]
	if level == botanic_panic:
		return "Botanic Panic"
	elif level == clip_joint_calamity:
		return "Clip Joint Calamity"
	elif level == ruse_of_an_ooze:
		return "Ruse of an Ooze"
	elif level == shump_tutorial:
		return "Shmup Tutorial"
	elif level == shop:
		return "Tienda"
	elif level == home:
		return "Casa"
	else:
		return "Nivel Desconocido"

func start_all_animations() -> void:
	"""Iniciar todas las animaciones"""
	# Shop
	if shop:
		shop.play()
	
	# Botanic Panic
	if botanic_panic:
		botanic_panic.play()
	
	# Clip Joint Calamity
	if clip_joint_calamity:
		clip_joint_calamity.play()
	
	# Home
	if home:
		home.play()
	
	# Ruse of an Ooze
	if ruse_of_an_ooze:
		ruse_of_an_ooze.play()
	
	# Shmup Tutorial
	if shump_tutorial:
		shump_tutorial.play()
	
